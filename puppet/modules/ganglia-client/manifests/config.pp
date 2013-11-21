class ganglia-client::config {
    file { "/etc/ganglia/gmond.conf.sh":
        content => template("ganglia-client/gmond.conf.sh.erb"),
        notify => Exec["create gmond.conf.sh"],
    }

    exec { "create gmond.conf.sh":
        command => "sh /etc/ganglia/gmond.conf.sh",
        path => $command_path,
        refreshonly => true,
        notify => Class["ganglia-client::service"],
    }
}
