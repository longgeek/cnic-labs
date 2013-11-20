class remove_keystone {
    exec { "remove keystone files":
        command => "/etc/init.d/keystone stop; \
                    rm -f /etc/init.d/keystone; \
                    rm -f /etc/init/keystone; \
                    rm -fr /etc/keystone; \
                    rm -fr /var/log/keystone; \
                    rm -fr $source_dir/*keystone*",
        path => $command_path,
        onlyif => "ls /etc/keystone/keystone.conf",
    }
}
