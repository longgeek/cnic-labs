class ganglia::service {
    exec { "restart ganglia":
        command => "/etc/init.d/gmetad restart; \
                    /etc/init.d/ganglia-monitor restart",
        path => $command_path,
        refreshonly => true,
        require => Class["ganglia::config"],
    }
}
