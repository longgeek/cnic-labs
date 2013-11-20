class remove_ceilometer {
    exec { "remove ceilometer":
        command => "apt-get -y --force-yes remove --purge mongodb mongodb-clients mongodb-dev mongodb-server; \
                    apt-get -y --force-yes autoremove; \
                    rm -fr /etc/init/ceilometer*; \
                    rm -fr /etc/init.d/ceilometer*; \
                    rm -fr $source_dir/*ceilometer*; \
                    rm -fr /var/log/ceilometer",
        path => $command_path,
        onlyif => "ls /var/log/ceilometer",
    }
}
