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
        notify => File["/etc/swift/fs.conf.sh"],
    }

    file { "/etc/swift/fs.conf.sh":
        content => template("swift/fs.conf.erb"),
        mode => 755,
        notify => Exec["sh /etc/swift/fs.conf.sh"],
    }

    exec { "sh /etc/swift/fs.conf.sh":
        command => "sh /etc/swift/fs.conf.sh",
        path => $command_path,
        refreshonly => true,
        notify => File["/etc/rsyslog.conf"],
    }

    file { "/etc/rsyslog.conf":
        content => template("swift/rsyslog.conf.erb"),
        notify => Exec["create ring"],
    }

    exec { "create ring":
        command => "gluster-swift-gen-builders eccp-swift",
        path => $command_path,
        unless => "ls /etc/swift/object.tar.gz",
    }
}
