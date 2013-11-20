class remove_ganglia-client {
    exec { "remove ganglia-client":
        command => "apt-get -y --force-yes remove --purge gmetad ganglia-monitor rrdtool libapache2-mod-php5; \
                    apt-get -y --force-yes autoremove; \
                    rm -fr /etc/ganglia; \
                    rm -fr /var/lib/ganglia/",
        path => $command_path,
        onlyif => "ls /etc/ganglia",
    }
}
