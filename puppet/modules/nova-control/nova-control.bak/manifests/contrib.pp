class nova::contrib {
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
}

