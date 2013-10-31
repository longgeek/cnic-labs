class swift::service {
    service { "rsyslog":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
        subscribe => Class["swift::config"],
        notify => Exec["start swift"],
    }

    exec { "start swift":
        command => "swift-init main restart",
        path => $command_path,
        onlyif => "swift-init main status | grep 'No'",
    }
}
