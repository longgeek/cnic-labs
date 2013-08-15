class cinder {

    file { ["/etc/cinder", "/var/lib/cinder", "/var/log/cinder/", "/var/run/cinder", "/var/lib/cinder/images"]:
        ensure => directory,
        notify => Package["iscsitarget", "open-iscsi", "iscsitarget-dkms"],
    }

    package { ["iscsitarget", "open-iscsi", "iscsitarget-dkms"]:
        ensure => installed,
        notify => Exec["iscsitarget enable"],
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
    }

    file { "$source_dir/$cinder_source_pack_name":
        source => "puppet:///files/$cinder_source_pack_name",
        notify => Exec["untar cinder"],
    }

    exec { "untar cinder":
        command => "tar zxvf $cinder_source_pack_name && cd cinder && \ 
                    pip install -r tools/pip-requires; python setup.py develop && \
                    cp etc/cinder/policy.json /etc/cinder/ && \
                    cp etc/cinder/rootwrap.conf /etc/cinder && \
                    cp -r etc/cinder/rootwrap.d/ /etc/cinder",
        cwd => $source_dir,
        path => $command_path,
        refreshonly => true,
        notify => File["$source_dir/$cinder_client_source_pack_name"],
    }

    file { "$source_dir/$cinder_client_source_pack_name":
        source => "puppet:///files/$cinder_client_source_pack_name",
        notify => Exec["untar cinder-client"],
    }

    exec { "untar cinder-client":
        command => "tar zxvf $cinder_client_source_pack_name && cd python-cinderclient && \
                    pip install -r tools/pip-requires; python setup.py develop",
        cwd => $source_dir,
        path => $command_path,
        refreshonly => true,
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
        notify => Exec["cinder db_sync"],
    }

    file { "/etc/cinder/api-paste.ini":
        content => template("cinder/api-paste.ini.erb"),
        notify => Exec["cinder db_sync"],
    }

    exec { "cinder db_sync":
        command => "cinder-manage db sync && \
                    nohup cinder-api --config-file /etc/cinder/cinder.conf > /dev/null 2>&1 & \
                    nohup cinder-volume --config-file /etc/cinder/cinder.conf > /dev/null 2>&1 & \
                    nohup cinder-scheduler --config-file /etc/cinder/cinder.conf > /dev/null 2>&1 & \
                    killall cinder-api cinder-volume cinder-scheduler; \
                    nohup cinder-api --config-file /etc/cinder/cinder.conf > /dev/null 2>&1 & \
                    nohup cinder-volume --config-file /etc/cinder/cinder.conf > /dev/null 2>&1 & \
                    nohup cinder-scheduler --config-file /etc/cinder/cinder.conf > /dev/null 2>&1 &",
        path => $command_path,
        refreshonly => true,
        notify => Exec["start cinder"],
    }

    exec { "start cinder":
        command => "echo 'nohup cinder-api --config-file /etc/cinder/cinder.conf > /dev/null 2>&1 &' >> /etc/rc.local;
                    echo 'nohup cinder-volume --config-file /etc/cinder/cinder.conf > /dev/null 2>&1 &' >> /etc/rc.local;
                    echo 'nohup cinder-scheduler --config-file /etc/cinder/cinder.conf > /dev/null 2>&1 &' >> /etc/rc.local;
                    touch /etc/cinder/.start-cinder",
        path => $command_path,
        creates => "/etc/cinder/.start-cinder",
    }

}
