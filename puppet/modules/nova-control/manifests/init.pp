class nova-control {

    file { 
        "/etc/init.d/nova-api":
            source => "puppet:///files/contrib/nova/nova-api",
            mode => "0755";

        "/etc/init.d/nova-scheduler":
            source => "puppet:///files/contrib/nova/nova-scheduler",
            mode => "0755";

        "/etc/init.d/nova-compute":
            source => "puppet:///files/contrib/nova/nova-compute",
            mode => "0755";

        "/etc/init.d/nova-network":
            source => "puppet:///files/contrib/nova/nova-network",
            mode => "0755";

        "/etc/init.d/nova-cert":
            source => "puppet:///files/contrib/nova/nova-cert",
            mode => "0755";

        "/etc/init.d/nova-console":
            source => "puppet:///files/contrib/nova/nova-console",
            mode => "0755";

        "/etc/init.d/nova-consoleauth":
            source => "puppet:///files/contrib/nova/nova-consoleauth",
            mode => "0755";

        "/etc/init.d/nova-novncproxy":
            source => "puppet:///files/contrib/nova/nova-novncproxy",
            mode => "0755";

        "/etc/init.d/nova-xvpvncproxy":
            source => "puppet:///files/contrib/nova/nova-xvpvncproxy",
            mode => "0755";

        # CONF
        "/etc/init/nova-api.conf":
            source => "puppet:///files/contrib/nova/nova-api.conf",
            mode => "0644";

        "/etc/init/nova-scheduler.conf":
            source => "puppet:///files/contrib/nova/nova-scheduler.conf",
            mode => "0644";

        "/etc/init/nova-compute.conf":
            source => "puppet:///files/contrib/nova/nova-compute.conf",
            mode => "0644";

        "/etc/init/nova-network.conf":
            source => "puppet:///files/contrib/nova/nova-network.conf",
            mode => "0644";

        "/etc/init/nova-cert.conf":
            source => "puppet:///files/contrib/nova/nova-cert.conf",
            mode => "0644";

        "/etc/init/nova-console.conf":
            source => "puppet:///files/contrib/nova/nova-console.conf",
            mode => "0644";

        "/etc/init/nova-consoleauth.conf":
            source => "puppet:///files/contrib/nova/nova-consoleauth.conf",
            mode => "0644";

        "/etc/init/nova-novncproxy.conf":
            source => "puppet:///files/contrib/nova/nova-novncproxy.conf",
            mode => "0644";

        "/etc/init/nova-xvpvncproxy.conf":
            source => "puppet:///files/contrib/nova/nova-xvpvncproxy.conf",
            mode => "0644";
    }   

    # Install deb requires

    file { "$source_dir/eccp.license":
        source => "puppet:///files/eccp.license",
        require => File["/etc/init/nova-xvpvncproxy.conf"],
        notify => Package[$nova_apt_requires],

    }
    package { $nova_apt_requires:
        ensure => installed,
        notify => Service["libvirt-bin"],
    }

    service { "libvirt-bin":
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        notify => File["/etc/nova/nova.conf"],
    }

    # config
    file { "/etc/nova/nova.conf":
        content => template("nova-control/nova.conf.erb"),
        owner => "nova",
        group => "nova",
        notify => Exec["nova db sync"],
    }

    file { "/etc/nova/api-paste.ini":
        content => template("nova-control/api-paste.ini.erb"),
        owner => "nova",
        group => "nova",
        notify => Exec["nova db sync"],
    }

    file { "/etc/nova/rootwrap.conf":
        content => template("nova-control/rootwrap.conf.erb"),
        owner => "nova",
        group => "nova",
        notify => Exec["nova db sync"],
    }

    exec { "nova db sync":
        command => "nova-manage db sync; \
                    /etc/init.d/nova-cert restart; \
                    /etc/init.d/nova-api restart; \
                    /etc/init.d/nova-scheduler restart; \
                    /etc/init.d/nova-network restart; \
                    /etc/init.d/nova-compute restart; \
                    /etc/init.d/nova-consoleauth restart; \
                    /etc/init.d/nova-console restart; \
                    /etc/init.d/nova-novncproxy restart; \
                    /etc/init.d/nova-xvpvncproxy restart",
        path => $command_path,
        refreshonly => true,
        notify => Exec["create fixed_ips"],
    }

    exec { "create fixed_ips":
        command => "nova-manage network create private --fixed_range_v4=${fixed_range} --num_networks=1 --bridge=br100 --bridge_interface=${flat_interface} --network_size=${network_size} --multi_host=T && mkdir /etc/nova/.fixed_ips",
        path => $command_path,
        creates => "/etc/nova/.fixed_ips",
    }
}
