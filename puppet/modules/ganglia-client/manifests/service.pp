class ganglia-client::service {
    exec { "restart ganglia":
        command => "/etc/init.d/ganglia-monitor restart",
        path => $command_path,
        refreshonly => true,
        require => Class["ganglia-client::config"],
        notify => Exec["listen ganglia-server port"],
    }

    exec { "listen ganglia-server port":
        command => "/etc/init.d/ganglia-monitor restart",
        path => $command_path,
        unless => "[ \"`telnet $memcache_host 8649 | wc -l`\" -ne '1' ]",
    }
}
