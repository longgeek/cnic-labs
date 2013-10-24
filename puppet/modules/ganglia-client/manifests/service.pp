class ganglia-client::service {
    exec { "start gmond":
        command => "/etc/init.d/ganglia-monitor",
        path => $command_path,
        unless => "ps aux | grep gmond | grep -v 'grep'",
    }
}
