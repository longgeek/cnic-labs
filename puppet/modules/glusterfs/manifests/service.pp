class glusterfs::service {

    service { "glusterd":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }
}
