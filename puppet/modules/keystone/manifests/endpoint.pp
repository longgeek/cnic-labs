class keystone::endpoint {
    if $swift_proxy_host != '%swift_proxy_host%' {
        file { "/etc/keystone/swift_endpoint.sh":
            content => template("keystone/swift_endpoint.sh.erb"),
            mode => 755,
            notify => Exec["create swift endpoint"],
        }
        
        exec { "create swift endpoint":
            command => "bash /etc/keystone/swift_endpoint.sh",
            path => $command_path,
            refreshonly => true,
            notify => File["/etc/keystone/ceilometer_endpoint.sh"],
        }
    }

    if $ceilometer_api_host != '%ceilometer_api_host%' {
        file { "/etc/keystone/ceilometer_endpoint.sh":
            content => template("keystone/ceilometer_endpoint.sh.erb"),
            mode => 755,
            notify => Exec["create ceilometer endpoint"],
        }
        
        exec { "create ceilometer endpoint":
            command => "bash /etc/keystone/ceilometer_endpoint.sh",
            path => $command_path,
            refreshonly => true,
        }
    }
}
