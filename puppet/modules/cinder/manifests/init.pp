class cinder {
    # All cinder init.d/ scripts
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

    package { ["iscsitarget", "open-iscsi", "iscsitarget-dkms"]:
        ensure => installed,
        notify => Exec["iscsitarget enable"],
        require => File["/etc/init/cinder-volume.conf"],
    }

    exec { "iscsitarget enable":
        command => "sed -i 's/false/true/g' /etc/default/iscsitarget",
        path => $command_path,
        onlyif => "grep false /etc/default/iscsitarget",
        notify => Service["iscsitarget", "open-iscsi"],
    }

    service { ["iscsitarget", "open-iscsi"]:
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        notify => File["/etc/cinder/create-cinder-volumes.py"],
    }

    file { "/etc/cinder/create-cinder-volumes.py":
        content => template("cinder/create-cinder-volumes.py.erb"),
        mode => 777,
        notify => Exec["create-volume"],
    }

    exec { "create-volume":
        command => "python /etc/cinder/create-cinder-volumes.py",
        path => $command_path,
        refreshonly => true,
        notify => File["/etc/cinder/cinder.conf"],
    }

    file { "/etc/cinder/cinder.conf":
        content => template("cinder/cinder.conf.erb"),
        owner => "cinder",
        notify => Exec["cinder db_sync"],
    }

    file { "/etc/cinder/api-paste.ini":
        content => template("cinder/api-paste.ini.erb"),
        owner => "cinder",
        notify => Exec["cinder db_sync"],
    }

    exec { "cinder db_sync":
        command => "cinder-manage db sync; \
                    /etc/init.d/cinder-api restart; \
                    /etc/init.d/cinder-scheduler restart; \
                    /etc/init.d/cinder-volume restart",
        path => $command_path,
        refreshonly => true,
    }
}
