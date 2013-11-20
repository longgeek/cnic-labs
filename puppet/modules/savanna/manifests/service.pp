class savanna::service {
    service { "savanna-api":
        ensure => 'running',
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }
}
