class remove_glusterfs-client {
    exec { "remove glusterfs-client":
        command => "rm -fr /etc/init.d/gluster*; \
                    rm -fr /etc/init/gluster*; \
                    rm -fr /var/log/gluster; \
                    rm -fr /opt/gluster*; \
                    rm -fr /etc/glusterfs; \
                    rm -fr $source_dir/*gluster*",
        path => $command_path,
        onlyif => "ls /etc/glusterfs",
    }
}
