class cinder {
    exec { "cinder upstart":
        command => "ln -s /lib/init/upstart-job /etc/init.d/cinder-api; \
                    ln -s /lib/init/upstart-job /etc/init.d/cinder-scheduler; \
                    ln -s /lib/init/upstart-job /etc/init.d/cinder-volume",
        path => $command_path,
        unless => "ls /etc/init.d/cinder-volume",
        notify => File["/etc/init/cinder-api.conf"],
    }
    # All cinder init.d/ scripts
    file { 
        "/etc/init/cinder-api.conf":
            source => "puppet:///files/contrib/cinder/cinder-api.conf",
            require => Exec["cinder upstart"],
            mode => "0644";
        "/etc/init/cinder-scheduler.conf":
            source => "puppet:///files/contrib/cinder/cinder-scheduler.conf",
            require => File["/etc/init/cinder-api.conf"],
            mode => "0644";
        "/etc/init/cinder-volume.conf":
            source => "puppet:///files/contrib/cinder/cinder-volume.conf",
            require => File["/etc/init/cinder-scheduler.conf"],
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

    if $cinder_volume_format == "glusterfs" {
        file { "/etc/cinder/cinder.conf":
            content => template("cinder/glusterfs.cinder.conf.erb"),
            owner => "cinder",
            group => "cinder",
            notify => File["/etc/cinder/glusterfs_shares.sh"],
        }
        
        file { "/etc/cinder/glusterfs_shares.sh":
            content => template("cinder/glusterfs_shares.sh.erb"),
            owner => "cinder",
            group => "cinder",
            mode => 755,
            notify => Exec["sh glusterfs_shares"],
        }
        exec { "sh glusterfs_shares":
            command => "sh /etc/cinder/glusterfs_shares.sh",
            path => $command_path,
            refreshonly => true,
            notify => Exec["cinder db_sync"],
        }

    } else {
        file { "/etc/cinder/cinder.conf":
            content => template("cinder/cinder.conf.erb"),
            owner => "cinder",
            group => "cinder",
            notify => Exec["cinder db_sync"],
        }
        
           }

    file { "/etc/cinder/api-paste.ini":
        content => template("cinder/api-paste.ini.erb"),
        owner => "cinder",
        group => "cinder",
        notify => Exec["cinder db_sync"],
    }

    exec { "cinder db_sync":
        command => "cinder-manage db sync; \
                    /etc/init.d/cinder-api restart; \
                    /etc/init.d/cinder-scheduler restart; \
                    /etc/init.d/cinder-volume restart",
        path => $command_path,
        refreshonly => true,
        notify => Service["cinder-api", "cinder-scheduler", "cinder-volume"],
    }

    service { ["cinder-api", "cinder-scheduler", "cinder-volume"]:
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }
}
