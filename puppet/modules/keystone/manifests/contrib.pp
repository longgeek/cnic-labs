class keystone::contrib {
    file { 
        "/etc/init.d/keystone":
            source => "puppet:///files/contrib/keystone/keystone",
            mode => "0755";

        "/etc/init/keystone.conf":
            source => "puppet:///files/contrib/keystone/keystone.conf",
            mode => "0644";
    }   
}

