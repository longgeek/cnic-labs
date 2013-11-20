class ceilometer::service {
    Service["mongodb"] -> Service["ceilometer-collector"] -> Service["ceilometer-agent-central"] -> Service["ceilometer-agent-compute"] -> Service["ceilometer-api"] -> Service["ceilometer-alarm-notifier"] -> Service["ceilometer-alarm-singleton"]

    service { "mongodb":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }

    service { "ceilometer-collector":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }

    service { "ceilometer-agent-central":
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

    service { "ceilometer-api":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }

    service { "ceilometer-alarm-notifier":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }

    service { "ceilometer-alarm-singleton":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }
}
