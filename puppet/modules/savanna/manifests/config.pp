class savanna::config {
    file { "/etc/savanna":
        ensure => directory,
        notify => File["/etc/savanna/savanna.conf"],
    }

    file { "/etc/savanna/savanna.conf":
        content => template("savanna/savanna.conf.erb"),
        notify => Class["savanna::service"],
    }
   
}
