class ganglia::service {
    exec { "start gmetad":
        command => "/etc/init.d/gmetad restart",
        path => $command_path,
        unless => "ps aux | grep gmetad | grep -v 'grep'",
        notify => Exec["start gmond"],
    }

    exec { "start gmond":
        command => "/etc/init.d/ganglia-monitor",
        path => $command_path,
        unless => "ps aux | grep gmond | grep -v 'grep'",
    }
}
