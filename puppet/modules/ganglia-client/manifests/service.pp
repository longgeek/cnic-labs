class ganglia-client::service {
    exec { "restart ganglia":
        command => "/etc/init.d/ganglia-monitor restart",
        path => $command_path,
        refreshonly => true,
        require => Class["ganglia-client::config"],
    }
}
