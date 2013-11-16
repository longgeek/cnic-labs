class glusterfs-client::service {

    service { "glusterd":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }
}
