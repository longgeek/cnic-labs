class remove_keystone {
    exec { "remove keystone files":
        command => "/etc/init.d/keystone stop; \
                    rm -f /etc/init.d/keystone; \
                    rm -f /etc/init/keystone; \
                    rm -f /etc/keystone/logging.conf; \
                    rm -f /etc/keystone/keystone.conf; \
                    rm -f /etc/keystone/keystone.sh; \
                    rm -fr /var/log/keystone/*",
        path => $command_path,
        onlyif => "ls /etc/keystone/keystone.conf",
    }
}
