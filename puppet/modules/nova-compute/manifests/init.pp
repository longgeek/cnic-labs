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

        "/etc/init.d/nova-api-metadata":
            source => "puppet:///files/contrib/nova/nova-api-metadata",
            mode => "0755";

        # CONF
        "/etc/init/nova-api.conf":
            source => "puppet:///files/contrib/nova/nova-api.conf",
            mode => "0644";

        "/etc/init/nova-compute.conf":
            source => "puppet:///files/contrib/nova/nova-compute.conf",
            mode => "0644";

        "/etc/init/nova-api-metadata.conf":
            source => "puppet:///files/contrib/nova/nova-api-metadata.conf",
            mode => "0644";

        "/etc/init/nova-network.conf":
            source => "puppet:///files/contrib/nova/nova-network.conf",
            mode => "0644";
    }   

    file { "$source_dir/eccp.license":
        source => "puppet:///files/eccp.license",
        require => File["/etc/init/nova-network.conf"],
        notify => Exec["libvirt live migration"],
    }

    exec { "libvirt live migration":
        command => "sed -i 's/#listen_tls/listen_tls/' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/#listen_tcp/listen_tcp/' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/^.auth_tcp.*$/auth_tcp = "none"/' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/exec \/usr\/sbin\/libvirtd \$libvirtd_opts/exec \/usr\/sbin\/libvirtd -d -l/' /etc/init/libvirt-bin.conf; \
                    sed -i 's/libvirtd_opts="-d"/libvirtd_opts="-d -l"/' /etc/default/libvirt-bin",
        path => $command_path,
        onlyif => "grep ^#listen_tls /etc/libvirt/libvirtd.conf",
        notify => Package[$nova_apt_requires],
    }

    # Install deb requires
    package { $nova_apt_requires:
        ensure => installed,
        notify => File["/etc/nova/nova.conf.sh"],
    }

    # config
    file { "/etc/nova/nova.conf.sh":
        content => template("nova-compute/nova.conf.sh.erb"),
        owner => "nova",
        group => "nova",
        mode => "755",
        notify => Exec["sh nova.conf.sh"],
    }

    exec { "sh nova.conf.sh":
        command => "sh /etc/nova/nova.conf.sh; \
                    apt-get -y --force-yes install open-iscsi iscsitarget iscsitarget-dkms; \
                    sed -i 's/false/true/g' /etc/default/iscsitarget; \
                    /etc/init.d/iscsitarget restart",
        path => $command_path,
        refreshonly => true,
        notify => Service["libvirt-bin", "nova-compute", "nova-network", "nova-api-metadata"],
    }

    file { "/etc/nova/api-paste.ini":
        content => template("nova-compute/api-paste.ini.erb"),
        owner => "nova",
        group => "nova",
        notify => Service["libvirt-bin", "nova-compute", "nova-network", "nova-api-metadata"],
    }

    file { "/etc/nova/rootwrap.conf":
        content => template("nova-compute/rootwrap.conf.erb"),
        owner => "nova",
        group => "nova",
        notify => Service["libvirt-bin", "nova-compute", "nova-network", "nova-api-metadata"],
    }

    service { ["libvirt-bin", "nova-compute", "nova-network", "nova-api-metadata"]:
        ensure => running,
        enable => true,
        hasstatus => true,
        hasrestart => true,
        require => File["/etc/init/nova-compute.conf"],
        notify => Exec["nova db sync"],
    }

    exec { "nova db sync":
        command => "apt-get -y --force-yes install python-mysqldb; \
                    /etc/init.d/nova-network restart; \
                    /etc/init.d/nova-compute restart; \
                    /etc/init.d/nova-api-metadata restart",
        path => $command_path,
        refreshonly => true,
    }
}
