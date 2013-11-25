class ganglia::service {
    file { "/etc/ganglia/listen_ganglia_client.py":
        content => template("ganglia/listen_ganglia_client.py.erb"),
        mode => '755',
#        notify => Exec["listen ganglia client"],
    }

#    exec { "listen ganglia client":
#        command => "python /etc/ganglia/listen_ganglia_client.py",
#        path => $command_path,
#        unless => "[ \"`ls /var/lib/ganglia/rrds/ECCP/*.*.* -d | wc -l`\" = \"`telnet 127.0.0.1 8649 | grep '^<HOST' | wc -l`\" ]",
#        notify => Exec["restart ganglia"],
#    }
#    exec { "listen ganglia client":
#        command => "python /etc/ganglia/listen_ganglia_client.py",
#        path => $command_path,
#        unless => "sh /etc/ganglia/1.sh",
#        notify => Exec["restart ganglia"],
#    }

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
