class cinder::contrib {
    file { 
        "/etc/init.d/cinder-api":
            source => "puppet:///files/contrib/cinder/cinder-api",
            mode => "0755";

        "/etc/init.d/cinder-scheduler":
            source => "puppet:///files/contrib/cinder/cinder-scheduler",
            mode => "0755";

        "/etc/init.d/cinder-volume":
            source => "puppet:///files/contrib/cinder/cinder-volume",
            mode => "0755";


        "/etc/init/cinder-api.conf":
            source => "puppet:///files/contrib/cinder/cinder-api.conf",
            mode => "0644";
        "/etc/init/cinder-scheduler.conf":
            source => "puppet:///files/contrib/cinder/cinder-scheduler.conf",
            mode => "0644";
        "/etc/init/cinder-volume.conf":
            source => "puppet:///files/contrib/cinder/cinder-volume.conf",
            mode => "0644";
    }
}
