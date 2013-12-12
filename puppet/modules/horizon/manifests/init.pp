class horizon {
    file { "$source_dir/python-navigatorclient.tar.gz":
        source => "puppet:///files/python-navigatorclient.tar.gz",
        notify => Exec["untar python-navigatorclient"],
    }

    exec { "untar python-navigatorclient":
        command => "[ -e $source_dir/python-navigatorclient ] && \
                    cd $source_dir/python-navigatorclient && \
                    python setup.py develop -u && \
                    rm -fr $source_dir/python-navigatorclient; \
                    cd $source_dir/; \
                    tar xf python-navigatorclient.tar.gz; \
                    cd python-navigatorclient; \
                    python setup.py develop; \
                    ps aux | grep -v grep | grep apache2 && \
                    /etc/init.d/apache2 restart; ls",
        path => $command_path,
        refreshonly => true,
        notify => Package["apache2", "memcached", "python-memcache", "nodejs", "libapache2-mod-wsgi", "python-redis", "gettext"],
    }

    package { ["apache2", "memcached", "python-memcache", "nodejs", "libapache2-mod-wsgi", "python-redis", "gettext"]:
        ensure => installed,
        notify => File["$source_dir/horizon/openstack_dashboard/settings.py"],
    }
 
    if $savanna_host == "NULL" {
        file { "$source_dir/horizon/openstack_dashboard/settings.py":
            content => template("horizon/settings.py.erb"),
            owner => 'apache',
            group => 'apache',
            mode => 644,
            notify => [Exec["chinese"], Exec["horizon syncdb"]],
        }
    } else {
        file { "$source_dir/horizon/openstack_dashboard/settings.py":
            content => template("horizon/savanna.settings.py.erb"),
            owner => 'apache',
            group => 'apache',
            mode => 644,
            notify => [Exec["chinese"], Exec["horizon syncdb"]],
        }
           }

    exec { "chinese":
        command => "django-admin.py compilemessages -l zh_CN",
        cwd => "$source_dir/horizon/horizon",
        path => $command_path,
        unless => "ls $source_dir/horizon/horizon/locale/zh_CN/LC_MESSAGES/django.mo",
        notify => File["$source_dir/horizon/openstack_dashboard/local/local_settings.py"],
    }


    if $savanna_host == "NULL" {
        file { "$source_dir/horizon/openstack_dashboard/local/local_settings.py":
            content => template("horizon/local_settings.py.erb"),
            notify => Exec["horizon syncdb"],
        }
    } else {
        file { "$source_dir/horizon/openstack_dashboard/local/local_settings.py":
            content => template("horizon/savanna.local_settings.py.erb"),
            notify => Exec["horizon syncdb"],
        }
           }

    exec { "horizon syncdb":
        command => "python $source_dir/horizon/manage.py syncdb --noinput; \
                    /etc/init.d/apache2 restart",
        path => $command_path,
        refreshonly => true,
        notify => File["/etc/apache2/conf.d/horizon.conf"],
    }

    file { "/etc/apache2/conf.d/horizon.conf":
        content => template("horizon/horizon.conf.erb"),
        notify => Exec["horizon sync db"],
    }
    
    exec { "horizon sync db":
        command => "python $source_dir/horizon/manage.py syncdb --noinput",
        path => $command_path,
        onlyif => "mysql -u$horizon_db_user -p$horizon_db_password -h $mysql_host $horizon_db_name -e 'show tables;' && [ \"`mysql -u$horizon_db_user -p$horizon_db_password -h $mysql_host $horizon_db_name -e 'show tables;' | wc -l`\" -eq \"0\" ]",
        notify => [Exec["memcache listen"], Service["apache2", "memcached"]],
    }

    exec { "memcache listen":
        command => "sed -i 's/127.0.0.1/0.0.0.0/g' /etc/memcached.conf; \
                    /etc/init.d/memcached restart",
        path => $command_path,
        unless => "grep 0.0.0.0 /etc/memcached.conf",
        notify => Service["apache2", "memcached"],
    }
  
    service { ["apache2", "memcached"]:
        ensure => "running",
        hasstatus => true,
        hasrestart => true,
        restart => true,
        notify => Exec["install PIL lib"],
    }

    include ganglia
    exec { "install PIL lib":
        command => "apt-get -y --force-yes install libjpeg8 libjpeg62-dev libfreetype6 libfreetype6-dev; \
                    ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib; \
                    ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib; \
                    ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib; \
                    pip install PIL; \
                    /etc/init.d/apache2 restart",
       path => $command_path,
       creates => "/usr/lib/libz.so",
       notify => Class["ganglia"],
    }
}
