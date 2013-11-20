class remove_glance {
    exec { "remove glance files":
        command => "/etc/init.d/glance-api stop; \
                    /etc/init.d/glance-registry stop; \
                    rm -fr /etc/init.d/glance*; \
                    rm -fr /etc/init/glance*
                    rm -fr /etc/glance/; \
                    rm -fr /var/log/glance; \
                    rm -fr /etc/glance; \
                    rm -fr $source_dir/*glance*",
        path => $command_path,
        onlyif => "ls /etc/glance/glance-api.conf",
    }
}
