class ganglia::config {
    file { "$source_dir/ganglia-webfrontend.tar.gz":
        source => "puppet:///files/ganglia-webfrontend.tar.gz",
        notify => Exec["untar ganglia-webfrontend"],
    }

    exec { "untar ganglia-webfrontend":
        command => "[ -e $source_dir/ganglia-webfrontend ] && \
                    rm -fr $source_dir/ganglia-webfrontend; \
                    cd $source_dir; \
                    tar zxvf ganglia-webfrontend.tar.gz; \
                    /etc/init.d/apache2 restart",
        path => $command_path,
        refreshonly => true,
        notify => File["/etc/ganglia/gmetad.conf"],
    }

    file { "/etc/ganglia/gmetad.conf":
        content => template("ganglia/gmetad.conf.erb"),
        notify => File["/etc/ganglia/gmond.conf"],
    }

    file { "/etc/ganglia/gmond.conf":
        content => template("ganglia/gmond.conf.erb"),
        notify => Class["ganglia::service"],
    }
}
