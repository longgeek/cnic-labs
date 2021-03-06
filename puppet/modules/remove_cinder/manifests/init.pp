class remove_cinder {
    exec { "remove cinder files":
        command => "/etc/init.d/cinder-api stop; \
                    /etc/init.d/cinder-scheduler stop; \
                    /etc/init.d/cinder-volume stop; \
                    apt-get -y --force-yes remove --purge iscsitarget open-iscsi iscsitarget-dkms; \
                    apt-get -y --force-yes autoremove; \
                    rm -fr /etc/init.d/cinder*; \
                    rm -fr /etc/init/cinder*; \
                    rm -fr /etc/cinder/; \
                    rm -fr /var/log/cinder; \
                    rm -fr $source_dir/*cinder*",
        path => $command_path,
        onlyif => "ls /etc/cinder/cinder.conf",
        notify => Exec["remove cinder volumes"],
    }

    exec { "remove cinder volumes":
        command => "rm -f /opt/cinder-volumes",
        path => $command_path,
        onlyif => "ls /opt/cinder-volumes",
    }
}
