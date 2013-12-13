class ceilometer-client::config {
    file { 
        "/var/log/ceilometer":
            ensure => directory,
            owner => ceilometer;
       
        "/var/log/ceilometer/ceilometer-agent-compute.log":
            ensure => file,
            owner => ceilometer,
            notify => File["/etc/init/ceilometer-agent-compute.conf"],
    }

    file { "/etc/init/ceilometer-agent-compute.conf":
            content => template("ceilometer-client/ceilometer-agent-compute.conf.erb"),
            notify => Exec["ceilometer upstart"],
    }

    exec { "ceilometer upstart":
        command => "ln -s /lib/init/upstart-job /etc/init.d/ceilometer-agent-compute",
        path => $command_path,
        unless => "ls /etc/init.d/ceilometer-agent-compute",
        notify => File["/etc/ceilometer/ceilometer.conf"],
    }

    file { "/etc/ceilometer/ceilometer.conf":
        content => template("ceilometer-client/ceilometer.conf.erb"),
        owner => ceilometer,
        notify => Class["ceilometer-client::service"],
    }
}
