class horizon {

    package { ["apache2", "memcached", "python-memcache", "nodejs", "libapache2-mod-wsgi", "python-redis"]:
        ensure => installed,
        notify => Exec["apt-get horizon"],
    }

    exec { "apt-get horizon":
        command => "apt-get -y --force-yes install build-essential python-dev python-setuptools python-pip libxml2-dev libxslt1-dev git; useradd -s /usr/sbin/nologin apache; mkdir /var/cache/.horizon",
        path => $command_path,
        creates => "/var/cache/.horizon",
        notify => File["$source_dir/$horizon_source_pack_name"],
    }

    file { "$source_dir/$horizon_source_pack_name":
        source => "puppet:///files/$horizon_source_pack_name",
        notify => Exec["untar horizon"],
    }
    
    exec { "untar horizon":
        command => "tar zxvf $horizon_source_pack_name && cd horizon && pip install -r tools/pip-requires && python setup.py develop && chown -R apache:apache $source_dir/horizon/",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => File["$source_dir/horizon/.blackhole"],
    }

    file { "$source_dir/horizon/.blackhole":
        ensure => directory,
        notify => File["$source_dir/openstack_auth.tar.gz"],
    }

    file { "$source_dir/openstack_auth.tar.gz":
        source => "puppet:///files/openstack_auth.tar.gz",
        notify => Exec["untar openstack_auth"],
    }

    exec { "untar openstack_auth":
        command => "tar zxvf openstack_auth.tar.gz",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => File["$source_dir/horizon/openstack_dashboard/local/local_settings.py"],
    }

    file { "$source_dir/horizon/openstack_dashboard/local/local_settings.py":
        content => template("horizon/local_settings.py.erb"),
        notify => Exec["horizon syncdb"],
    }

    exec { "horizon syncdb":
        command => "python $source_dir/horizon/manage.py syncdb --noinput",
        path => $command_path,
        refreshonly => true,
        notify => File["/etc/apache2/conf.d/horizon.conf"],
    }

    file { "/etc/apache2/conf.d/horizon.conf":
        content => template("horizon/horizon.conf.erb"),
        notify => Service["apache2", "memcached"],
    }

    service { ["apache2", "memcached"]:
        ensure => "running",
        hasstatus => true,
        hasrestart => true,
        restart => true,
    }
}
