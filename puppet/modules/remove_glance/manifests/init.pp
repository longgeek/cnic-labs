class remove_glance {
    exec { "remove glance files":
        command => "/etc/init.d/glance-api stop; \
                    /etc/init.d/glance-registry stop; \
                    rm -f /etc/init.d/glance*; \
                    rm -f /etc/init/glance*
                    rm -f /etc/glance/glance-api.conf; \
                    rm -f /etc/glance/glance-registry.conf; \
                    rm -f /etc/glance/glance-cache.conf; \
                    rm -f /var/log/glance/*; \
                    rm -f /etc/glance/cirros*.img; \
                    rm -f /etc/glance/.glance_add; \
                    rm -f /var/lib/glance/images/*",
        path => $command_path,
        onlyif => "ls /etc/glance/glance-api.conf",
    }
}
