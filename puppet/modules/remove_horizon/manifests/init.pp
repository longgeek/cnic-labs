class remove_horizon {
    exec { "remove horizon files":
        command => "apt-get -y --force-yes remove --purge apache2* memcached python-memcache nodejs libapache2-mod-wsgi python-redis; \
                    apt-get -y --force-yes autoremove; \
                    rm -f $source_dir/horizon/openstack_dashboard/local/local_settings.py; \
                    rm -fr /etc/apache2",
        path => $command_path,
        onlyif => "ls /etc/apache2",
    }
}
