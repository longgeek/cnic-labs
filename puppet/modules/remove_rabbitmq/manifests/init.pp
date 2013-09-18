class remove_rabbitmq {
    exec { "remove rabbitmq files":
        command => "apt-get -y --force-yes remove --purge rabbitmq-server; \
                    apt-get -y --force-yes autoremove; \
                    rm -fr /etc/rabbitmq",
        path => $command_path,
        onlyif => "ls /etc/rabbitmq",
    }
}
