class ganglia-client::service {
    exec { "restart ganglia":
        command => "/etc/init.d/ganglia-monitor restart",
        path => $command_path,
        refreshonly => true,
        require => Class["ganglia-client::config"],
        notify => Exec["ganglia-monitor status"],
    }

    exec { "ganglia-monitor status":
        command => "/etc/init.d/ganglia-monitor restart",
        path => $command_path,
        unless => "ps aux | grep -v grep | grep gmond",
    }
}
