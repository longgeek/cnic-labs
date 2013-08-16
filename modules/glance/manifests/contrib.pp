class glance::contrib {
    file { 
        "/etc/init.d/glance-api":
            source => "puppet:///files/contrib/glance/glance-api",
            mode => "0755";

        "/etc/init.d/glance-registry":
            source => "puppet:///files/contrib/glance/glance-registry",
            mode => "0755";


        "/etc/init/glance-api.conf":
            source => "puppet:///files/contrib/glance/glance-api.conf",
            mode => "0644";

        "/etc/init/glance-registry.conf":
            source => "puppet:///files/contrib/glance/glance-registry.conf",
            mode => "0644";
    }   
}

