class nova-compute {

    file { 
        "/etc/init.d/nova-api":
            source => "puppet:///files/contrib/nova/nova-api",
            mode => "0755";

        "/etc/init.d/nova-compute":
            source => "puppet:///files/contrib/nova/nova-compute",
            mode => "0755";

        "/etc/init.d/nova-network":
            source => "puppet:///files/contrib/nova/nova-network",
            mode => "0755";

        # CONF
        "/etc/init/nova-api.conf":
            source => "puppet:///files/contrib/nova/nova-api.conf",
            mode => "0644";

        "/etc/init/nova-compute.conf":
            source => "puppet:///files/contrib/nova/nova-compute.conf",
            mode => "0644";

        "/etc/init/nova-network.conf":
            source => "puppet:///files/contrib/nova/nova-network.conf",
            mode => "0644";
    }   

    file { "$source_dir/eccp.license":
        source => "puppet:///files/eccp.license",
        require => File["/etc/init/nova-network.conf"],
        notify => Package[$nova_apt_requires],
    }

    # Install deb requires
    package { $nova_apt_requires:
        ensure => installed,
        notify => File["/etc/nova/nova.conf"],
    }

    # config
    file { "/etc/nova/nova.conf":
        content => template("nova/nova.conf.erb"),
        owner => "nova",
        notify => Service["libvirt-bin", "nova-compute", "nova-network"],
    }

    file { "/etc/nova/api-paste.ini":
        content => template("nova/api-paste.ini.erb"),
        owner => "nova",
        notify => Service["libvirt-bin", "nova-compute", "nova-network"],
    }

    file { "/etc/nova/rootwrap.conf":
        content => template("nova/rootwrap.conf.erb"),
        owner => "nova",
        notify => Service["libvirt-bin", "nova-compute", "nova-network"],
    }

    service { ["libvirt-bin", "nova-compute", "nova-network"]:
        ensure => running,
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }
#    exec { "nova db sync":
#        command => "nova-manage db sync; \
#                    #/etc/init.d/nova-api restart; \
#                    /etc/init.d/nova-network restart; \
#                    /etc/init.d/nova-compute restart",
#        path => $command_path,
#        refreshonly => true,
#    }
}
