class ceilometer-client::service {
    service { "ceilometer-agent-compute":
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
        notify => Exec["listen ceilometer-api"],
    }

    exec { "listen ceilometer-api":
        command => "/etc/init.d/ceilometer-agent-compute restart",
        path => $command_path,
        onlyif => "tail -n 5 /var/log/ceilometer/ceilometer-agent-compute.log | egrep '(Errno 111|ConnectionError|Unauthorized|EndpointNotFound)'",
    }
}
