class nova-control::install {
    exec { "nova-control upstart":
        command => "ln -s /lib/init/upstart-job /etc/init.d/nova-api; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-scheduler; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-compute; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-network; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-cert; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-console; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-consoleauth; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-novncproxy; \
                    [ -e /etc/init.d/libvirt-bin ] && rm -f /etc/init.d/libvirt-bin; \
                    ln -s /lib/init/upstart-job /etc/init.d/libvirt-bin; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-xvpvncproxy",
        path => $command_path,
        unless => "ls /etc/init.d/nova-xvpvncproxy",
        require => Class["nova-control"],
        notify => File["/etc/init/libvirt-bin.conf"],
    }

    file { 

        # CONF
        "/etc/init/libvirt-bin.conf":
            source => "puppet:///files/contrib/nova/libvirt-bin.conf",
            require => Exec["nova-control upstart"],
            mode => "0755";

        "/etc/init/nova-api.conf":
            source => "puppet:///files/contrib/nova/nova-api.conf",
            require => File["/etc/init/libvirt-bin.conf"],
            mode => "0644";

        "/etc/init/nova-scheduler.conf":
            source => "puppet:///files/contrib/nova/nova-scheduler.conf",
            require => File["/etc/init/nova-api.conf"],
            mode => "0644";

        "/etc/init/nova-compute.conf":
            source => "puppet:///files/contrib/nova/nova-compute.conf",
            require => File["/etc/init/nova-scheduler.conf"],
            mode => "0644";

        "/etc/init/nova-network.conf":
            source => "puppet:///files/contrib/nova/nova-network.conf",
            require => File["/etc/init/nova-compute.conf"],
            mode => "0644";

        "/etc/init/nova-cert.conf":
            source => "puppet:///files/contrib/nova/nova-cert.conf",
            require => File["/etc/init/nova-network.conf"],
            mode => "0644";

        "/etc/init/nova-console.conf":
            source => "puppet:///files/contrib/nova/nova-console.conf",
            require => File["/etc/init/nova-cert.conf"],
            mode => "0644";

        "/etc/init/nova-consoleauth.conf":
            source => "puppet:///files/contrib/nova/nova-consoleauth.conf",
            require => File["/etc/init/nova-console.conf"],
            mode => "0644";

        "/etc/init/nova-novncproxy.conf":
            source => "puppet:///files/contrib/nova/nova-novncproxy.conf",
            require => File["/etc/init/nova-consoleauth.conf"],
            mode => "0644";

        "/etc/init/nova-xvpvncproxy.conf":
            source => "puppet:///files/contrib/nova/nova-xvpvncproxy.conf",
            require => File["/etc/init/nova-novncproxy.conf"],
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
        notify => Package["gcc", "make", "pkg-config", "libgnutls-dev", "libdevmapper-dev", "libcurl4-gnutls-dev", "libpciaccess-dev", "libnl-dev", "pm-utils", "ebtables", "dnsmasq-base", "cgroup-bin", "cgroup-lite"],
    }

    package { ["gcc", "make", "pkg-config", "libgnutls-dev", "libdevmapper-dev", "libcurl4-gnutls-dev", "libpciaccess-dev", "libnl-dev", "pm-utils", "ebtables", "dnsmasq-base", "cgroup-bin", "cgroup-lite"]:
        ensure => installed,
        notify => File["$source_dir/libvirt-$libvirt_version.tar.gz"],
    }

    file { "$source_dir/libvirt-$libvirt_version.tar.gz":
        source => "puppet:///files/libvirt-$libvirt_version.tar.gz",
        notify => Exec["configure libvirt"],
    }

    exec { "configure libvirt":
        command => "pkg-config --modversion libnl-1; \
                    cd $source_dir; \
                    tar zxvf libvirt-$libvirt_version.tar.gz; \
                    cd libvirt-$libvirt_version; \
                    sed -i 's/49152/40152/g' src/qemu/qemu_conf.h; \
                    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc ; \
                    make; \
                    make install",
        path => $command_path,
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
        notify => File["/etc/nova/rootwrap.conf"],
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
        notify => Service["nova-api", "nova-cert", "nova-scheduler", "nova-consoleauth", "nova-console", "nova-novncproxy", "nova-xvpvncproxy"],
    }

    service { ["nova-api", "nova-cert", "nova-scheduler", "nova-consoleauth", "nova-console", "nova-novncproxy", "nova-xvpvncproxy"]:
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
        notify => Service["nova-network"],
    }

    if $nova_control_network == 'True' {
        service { "nova-network":
            ensure => "running",
            enable => true,
            hasstatus => true,
            hasrestart => true,
            notify => Service["nova-compute"],
        }
    } else {
        service { "nova-network":
            ensure => "stopped",
            enable => false,
            notify => Service["nova-compute"],
        }
      }

    if $nova_control_compute == 'True' {
        service { "nova-compute":
            ensure => "running",
            enable => true,
            hasstatus => true,
            hasrestart => true,
        }
    } else {
        service { "nova-compute":
            ensure => "stopped",
            enable => false,
        }
      }

}
