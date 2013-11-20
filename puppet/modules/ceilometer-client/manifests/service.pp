class ceilometer-client::service {
    service { "ceilometer-agent-compute":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }
}
