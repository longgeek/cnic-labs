class horizon {

    package { ["apache2", "memcached", "python-memcache", "nodejs", "libapache2-mod-wsgi", "python-redis"]:
        ensure => installed,
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
