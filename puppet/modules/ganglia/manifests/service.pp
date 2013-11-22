class ganglia::service {
    exec { "restart ganglia":
        command => "/etc/init.d/gmetad restart; \
                    /etc/init.d/ganglia-monitor restart",
        path => $command_path,
        refreshonly => true,
        require => Class["ganglia::config"],
        notify => Exec["gmetad status"],
    }

    exec { "gmetad status":
        command => "/etc/init.d/gmetad restart",
        path => $command_path,
        unless => "ps aux | grep -v grep | grep gmetad",
        notify => Exec["ganglia-monitor status"],
    }

    exec { "ganglia-monitor status":
        command => "/etc/init.d/ganglia-monitor restart",
        path => $command_path,
        unless => "ps aux | grep -v grep | grep gmond",
    }
}
