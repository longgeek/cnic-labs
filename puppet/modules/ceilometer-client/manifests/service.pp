class ceilometer-client::service {
    Service["mongodb"] -> Service["ceilometer-agent-compute"]

    service { "mongodb":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }

    service { "ceilometer-agent-compute":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }
}
