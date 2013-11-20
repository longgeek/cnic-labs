class remove_ceilometer-client {
    exec { "remove ceilometer-client":
        command => "rm -fr /etc/init/ceilometer*; \
                    rm -fr /etc/init.d/ceilometer*; \
                    rm -fr /etc/ceilometer; \
                    rm -fr /var/log/ceilometer; \
                    rm -fr $source_dir/8ceilometer",
        path => $command_path,
        onlyif => "ls /etc/ceilometer",
    }
}
