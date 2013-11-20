class remove_horizon {
    exec { "remove horizon files":
        command => "apt-get -y --force-yes remove --purge apache2* memcached python-memcache nodejs libapache2-mod-wsgi python-redis; \
                    apt-get -y --force-yes autoremove; \
                    rm -fr $source_dir/horizon*; \
                    rm -fr /etc/apache2; \
                    rm -f /usr/lib/libz.so",
        path => $command_path,
        onlyif => "ls /etc/apache2",
    }
}
