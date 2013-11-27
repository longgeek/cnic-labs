class swift::config {
    file { ["/etc/swift/", "/var/cache/swift", "/var/log/swift"]:
        ensure => directory,
        notify => File["/etc/swift/proxy-server.conf"],
    }

    file { "/etc/swift/proxy-server.conf":
        content => template("swift/proxy-server.conf.erb"),
        notify => File["/etc/swift/account-server.conf"],
    }

    file { "/etc/swift/account-server.conf":
        content => template("swift/account-server.conf.erb"),
        notify => File["/etc/swift/container-server.conf"],
    }

    file { "/etc/swift/container-server.conf":
        content => template("swift/container-server.conf.erb"),
        notify => File["/etc/swift/object-server.conf"],
    }

    file { "/etc/swift/object-server.conf":
        content => template("swift/object-server.conf.erb"),
        notify => File["/etc/swift/swift.conf"],
    }

    file { "/etc/swift/swift.conf":
        content => template("swift/swift.conf.erb"),
        notify => File["/etc/rsyslog.conf"],
    }

    file { "/etc/rsyslog.conf":
        content => template("swift/rsyslog.conf.erb"),
    }
}
