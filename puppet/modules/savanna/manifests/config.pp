class savanna::config {

    user { "savanna":
        ensure => "present",
        shell => "/usr/sbin/nologin",
        notify => File["/etc/savanna"],
    }

    file { 
        "/etc/savanna":
            ensure => directory,
            owner => 'savanna';
        "/var/log/savanna/":
            ensure => directory,
            owner => 'savanna',
            notify => Exec["savanna upstart"],
    }

    exec { "savanna upstart":
        command => "ln -s /lib/init/upstart-job /etc/init.d/savanna-api",
        path => $command_path,
        unless => "ls /etc/init.d/savanna-api",
        notify => File["/etc/init/savanna-api.conf"],
    }

    file { "/etc/init/savanna-api.conf":
        content => template("savanna/savanna-api.conf.erb"),
        notify => File["/etc/savanna/savanna.conf"],
    }
   
    file { "/etc/savanna/savanna.conf":
        content => template("savanna/savanna.conf.erb"),
        owner => 'savanna',
        notify => Class["savanna::service"],
    }
}
