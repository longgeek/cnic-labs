class ceilometer::config {
    file { 
        "/var/log/ceilometer":
            ensure => directory;
#            owner => ceilometer;
       
        "/var/log/ceilometer/ceilometer-collector.log":
            ensure => file;
#            owner => ceilometer;

        "/var/log/ceilometer/ceilometer-agent-central.log":
            ensure => file;
#            owner => ceilometer;

        "/var/log/ceilometer/ceilometer-agent-compute.log":
            ensure => file;
#            owner => ceilometer;

        "/var/log/ceilometer/ceilometer-api.log":
            ensure => file;
#            owner => ceilometer;

        "/var/log/ceilometer/ceilometer-alarm-notifier.log":
            ensure => file;
#            owner => ceilometer;

        "/var/log/ceilometer/ceilometer-alarm-singleton.log":
            ensure => file,
#            owner => ceilometer,
            notify => File["/etc/init/ceilometer-collector.conf"],
    }

    file { 
        "/etc/init/ceilometer-collector.conf":
            content => template("ceilometer/contrib/ceilometer-collector.conf.erb");

        "/etc/init/ceilometer-agent-central.conf":
            content => template("ceilometer/contrib/ceilometer-agent-central.conf.erb");

        "/etc/init/ceilometer-agent-compute.conf":
            content => template("ceilometer/contrib/ceilometer-agent-compute.conf.erb");

        "/etc/init/ceilometer-api.conf":
            content => template("ceilometer/contrib/ceilometer-api.conf.erb");

        "/etc/init/ceilometer-alarm-notifier.conf":
            content => template("ceilometer/contrib/ceilometer-alarm-notifier.conf.erb");

        "/etc/init/ceilometer-alarm-singleton.conf":
            content => template("ceilometer/contrib/ceilometer-alarm-singleton.conf.erb"),
            notify => Exec["ceilometer upstart"],
    }

    exec { "ceilometer upstart":
        command => "ln -s /lib/init/upstart-job /etc/init.d/ceilometer-collector; \
                    ln -s /lib/init/upstart-job /etc/init.d/ceilometer-agent-central; \
                    ln -s /lib/init/upstart-job /etc/init.d/ceilometer-agent-compute; \
                    ln -s /lib/init/upstart-job /etc/init.d/ceilometer-api; \
                    ln -s /lib/init/upstart-job /etc/init.d/ceilometer-alarm-notifier; \
                    ln -s /lib/init/upstart-job /etc/init.d/ceilometer-alarm-singleton",
        path => $command_path,
        unless => "ls /etc/init.d/ceilometer-alarm-singleton",
        notify => File["/etc/ceilometer/ceilometer.conf"],
    }

    file { "/etc/ceilometer/ceilometer.conf":
        content => template("ceilometer/ceilometer.conf.erb"),
#        owner => ceilometer,
        notify => Class["ceilometer::service"],
    }
}
