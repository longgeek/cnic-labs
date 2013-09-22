class nova-control {
    exec { "nova-control upstart":
        command => "ln -s /lib/init/upstart-job /etc/init.d/nova-api; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-scheduler; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-compute; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-network; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-cert; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-console; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-consoleauth; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-novncproxy; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-xvpvncproxy",
        path => $command_path,
        unless => "ls /etc/init.d/nova-xvpvncproxy",
        notify => File["/etc/init/libvirt-bin.conf"],
    }

    file { 

        # CONF
        "/etc/init/libvirt-bin.conf":
            source => "puppet:///files/contrib/nova/libvirt-bin.conf",
            mode => "0755";

        "/etc/init/nova-api.conf":
            source => "puppet:///files/contrib/nova/nova-api.conf",
            mode => "0644";

        "/etc/init/nova-scheduler.conf":
            source => "puppet:///files/contrib/nova/nova-scheduler.conf",
            mode => "0644";

        "/etc/init/nova-compute.conf":
            source => "puppet:///files/contrib/nova/nova-compute.conf",
            mode => "0644";

        "/etc/init/nova-network.conf":
            source => "puppet:///files/contrib/nova/nova-network.conf",
            mode => "0644";

        "/etc/init/nova-cert.conf":
            source => "puppet:///files/contrib/nova/nova-cert.conf",
            mode => "0644";

        "/etc/init/nova-console.conf":
            source => "puppet:///files/contrib/nova/nova-console.conf",
            mode => "0644";

        "/etc/init/nova-consoleauth.conf":
            source => "puppet:///files/contrib/nova/nova-consoleauth.conf",
            mode => "0644";

        "/etc/init/nova-novncproxy.conf":
            source => "puppet:///files/contrib/nova/nova-novncproxy.conf",
            mode => "0644";

        "/etc/init/nova-xvpvncproxy.conf":
            source => "puppet:///files/contrib/nova/nova-xvpvncproxy.conf",
            mode => "0644";
    }   

    # Install deb requires

    file { "$source_dir/eccp.license":
        source => "puppet:///files/eccp.license",
        require => File["/etc/init/nova-xvpvncproxy.conf"],
        notify => Package[$nova_apt_requires],
    }

    package { $nova_apt_requires:
        ensure => installed,
        notify => File["$source_dir/libvirt-$libvirt_version.tar.gz"],
    }

    file { "$source_dir/libvirt-$libvirt_version.tar.gz":
        source => "puppet:///files/libvirt-$libvirt_version.tar.gz",
        notify => Package["gcc", "make", "pkg-config", "libgnutls-dev", "libdevmapper-dev", "libcurl4-gnutls-dev", "libpciaccess-dev", "libnl-dev", "pm-utils", "ebtables", "dnsmasq-base"],
    }

    package { ["gcc", "make", "pkg-config", "libgnutls-dev", "libdevmapper-dev", "libcurl4-gnutls-dev", "libpciaccess-dev", "libnl-dev", "pm-utils", "ebtables", "dnsmasq-base"]:
        ensure => installed,
        require => File["$source_dir/libvirt-$libvirt_version.tar.gz"],
        notify => Exec["make libvirt"],
    }

    exec { "make libvirt":
        path => $command_path,
        command => "pkg-config --modversion libnl-1; \
                    cd $source_dir; \
                    tar zxvf libvirt-$libvirt_version.tar.gz; \
                    cd libvirt-$libvirt_version; \
                    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc ; \
                    make; \
                    make install; \
                    [ -e /etc/init.d/libvirt-bin ] && rm -f /etc/init.d/libvirt-bin; \
                    ln -s /lib/init/upstart-job /etc/init.d/libvirt-bin",
        refreshonly => true,
        notify => Exec["libvirt live migration"],
    }

    exec { "libvirt live migration":
        command => "sed -i 's/#listen_tls/listen_tls/' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/#listen_tcp/listen_tcp/' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/#unix_sock_group = \"libvirt\"/unix_sock_group = \"libvirtd\"/g' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/#unix_sock_rw_perms = \"0770\"/unix_sock_rw_perms = \"0770\"/g' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/#listen_tcp/listen_tcp/' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/^.auth_tcp.*$/auth_tcp = \"none\"/' /etc/libvirt/libvirtd.conf; \
                    grep nbd /etc/modules || echo nbd >> /etc/modules; \
                    modprobe nbd; \
                    /etc/init.d/libvirt-bin restart",
        path => $command_path,
        onlyif => "grep ^#listen_tls /etc/libvirt/libvirtd.conf",
        notify => Service["libvirt-bin"],
    }

    service { "libvirt-bin":
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        notify => File["/etc/nova/nova.conf"],
    }

    # config
    file { "/etc/nova/rootwrap.conf":
        content => template("nova-control/rootwrap.conf.erb"),
        owner => "nova",
        group => "nova",
        notify => Exec["nova db sync"],
    }

    file { "/etc/nova/api-paste.ini":
        content => template("nova-control/api-paste.ini.erb"),
        owner => "nova",
        group => "nova",
        notify => Exec["nova db sync"],
    }

    file { "/etc/nova/nova.conf":
        content => template("nova-control/nova.conf.erb"),
        owner => "nova",
        group => "nova",
        notify => Exec["nova db sync"],
    }

    exec { "nova db sync":
        command => "nova-manage db sync; \
                    /etc/init.d/nova-cert restart; \
                    /etc/init.d/nova-api restart; \
                    /etc/init.d/nova-scheduler restart; \
                    /etc/init.d/nova-network restart; \
                    /etc/init.d/nova-compute restart; \
                    /etc/init.d/nova-consoleauth restart; \
                    /etc/init.d/nova-console restart; \
                    /etc/init.d/nova-novncproxy restart; \
                    /etc/init.d/nova-xvpvncproxy restart",
        path => $command_path,
        refreshonly => true,
        notify => Service["nova-api", "nova-cert", "nova-scheduler", "nova-network", "nova-compute", "nova-consoleauth", "nova-console", "nova-novncproxy", "nova-xvpvncproxy"],
    }

    service { ["nova-api", "nova-cert", "nova-scheduler", "nova-network", "nova-compute", "nova-consoleauth", "nova-console", "nova-novncproxy", "nova-xvpvncproxy"]:
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
        notify => Exec["create fixed_ips"],
    }

    exec { "create fixed_ips":
        command => "nova-manage network create private --fixed_range_v4=${fixed_range} --num_networks=1 --bridge=br100 --bridge_interface=${flat_interface} --network_size=${network_size} --multi_host=T && mkdir /etc/nova/.fixed_ips",
        path => $command_path,
        creates => "/etc/nova/.fixed_ips",
    }
}
