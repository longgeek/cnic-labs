class ganglia-client::config {
    file { "/etc/ganglia/gmond.conf":
        content => template("ganglia/gmond.conf.erb")
    }
}
