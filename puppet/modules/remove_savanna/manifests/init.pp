class remove_savanna {
    exec { "remove savanna":
        command => "/etc/init.d/savanna-api stop; \
                    rm -fr $source_dir/*savanna*; \
                    rm -fr /etc/savanna; \
                    rm -fr /var/log/savanna; \
                    rm -fr /etc/init.d/savanna*; \
                    rm -fr /etc/init/savanna*",
        path => $command_path,
        onlyif => "ls /etc/init/savanna*",
    }
}
