class bases {
    file { "/etc/hosts":
        content => template("bases/hosts.erb"),
    }
}
