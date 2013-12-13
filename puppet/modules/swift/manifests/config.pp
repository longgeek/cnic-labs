class swift::config {
    file { ["/etc/swift/", "/var/cache/swift", "/var/log/swift"]:
        ensure => directory,
        notify => [File["/etc/swift/proxy-server.conf"], Exec["reload swift"]],
    }

    file { "/etc/swift/proxy-server.conf":
        content => template("swift/proxy-server.conf.erb"),
        notify => [File["/etc/swift/account-server.conf"], Exec["reload swift"]],
    }

    file { "/etc/swift/account-server.conf":
        content => template("swift/account-server.conf.erb"),
        notify => [File["/etc/swift/container-server.conf"], Exec["reload swift"]],
    }

    file { "/etc/swift/container-server.conf":
        content => template("swift/container-server.conf.erb"),
        notify => [File["/etc/swift/object-server.conf"], Exec["reload swift"]],
    }

    file { "/etc/swift/object-server.conf":
        content => template("swift/object-server.conf.erb"),
        notify => [File["/etc/swift/swift.conf"], Exec["reload swift"]],
    }

    file { "/etc/swift/swift.conf":
        content => template("swift/swift.conf.erb"),
        notify => [File["/etc/rsyslog.conf"], Exec["reload swift"]],
    }

    file { "/etc/rsyslog.conf":
        content => template("swift/rsyslog.conf.erb"),
        notify => [Exec["reload swift"], Class["swift::service"]],
    }

    exec { "reload swift":
        command => "swift-init main restart",
        path => $command_path,
        refreshonly => true,
    }
}
