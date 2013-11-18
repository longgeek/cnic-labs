class savanna::service {
    exec { "start savanna-api":
        command => "nohup $source_dir/savanna/savanna-venv/bin/python $source_dir/savanna/savanna-venv/bin/savanna-api --config-file /etc/savanna/savanna.conf > /dev/null 2>&1 &",
        path => $command_path,
        unless => "netstat -ltunp | grep 8386",
        require => Class["savanna::install"],
    }
}
