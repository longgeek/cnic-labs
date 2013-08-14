class horizon {

    package { ["apache2", "memcached", "python-memcache", "nodejs", "libapache2-mod-wsgi", "python-redis"]:
        ensure => installed,
        notify => Exec["apt-get horizon"],
    }

    exec { "apt-get horizon":
        command => "apt-get -y --force-yes install build-essential python-dev python-setuptools python-pip libxml2-dev libxslt1-dev git; useradd -s /usr/sbin/nologin apache; mkdir /var/cache/.horizon",
        path => $command_path,
        creates => "/var/cache/.horizon",
        notify => File["/usr/local/src/$horizon_source_pack_name"],
    }

    file { "/usr/local/src/$horizon_source_pack_name":
        source => "puppet:///files/$horizon_source_pack_name",
        notify => Exec["untar horizon"],
    }
    
    exec { "untar horizon":
        command => "tar zxvf $horizon_source_pack_name && cd horizon && pip install -r tools/pip-requires && python setup.py install && chown -R apache:apache /usr/local/src/horizon/",
        path => $command_path,
        cwd => "/usr/local/src",
        refreshonly => true,
        notify => File["/usr/local/src/horizon/.blackhole"],
    }

    file { "/usr/local/src/horizon/.blackhole":
        ensure => directory,
        notify => File["/usr/local/src/openstack_auth.tar.gz"],
    }

    file { "/usr/local/src/openstack_auth.tar.gz":
        source => "puppet:///files/openstack_auth.tar.gz",
        notify => Exec["untar openstack_auth"],
    }

    exec { "untar openstack_auth":
        command => "tar zxvf openstack_auth.tar.gz",
        path => $command_path,
        cwd => "/usr/local/src",
        refreshonly => true,
        notify => File["/usr/local/src/horizon/openstack_dashboard/local/local_settings.py"],
    }

    file { "/usr/local/src/horizon/openstack_dashboard/local/local_settings.py":
        content => template("horizon/local_settings.py.erb"),
        notify => Exec["horizon syncdb"],
    }

    exec { "horizon syncdb":
        command => "python /usr/local/src/horizon/manage.py syncdb --noinput",
        path => $command_path,
        refreshonly => true,
        notify => File["/etc/apache2/conf.d/horizon.conf"],
    }

    file { "/etc/apache2/conf.d/horizon.conf":
        content => template("horizon/horizon.conf.erb"),
        notify => Service["apache2", "memcached"],
    }

    service { ["apache2", "memcached"]:
        ensure => true,
        hasstatus => true,
        hasrestart => true,
    }
}
