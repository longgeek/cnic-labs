class nova-compute::install {
    exec { "nova-compute upstart":
        command => "ln -s /lib/init/upstart-job /etc/init.d/nova-network; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-compute; \
                    [ -e /etc/init.d/libvirt-bin ] && rm -f /etc/init.d/libvirt-bin; \
                    ln -s /lib/init/upstart-job /etc/init.d/libvirt-bin; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-api-metadata",
        path => $command_path,
        unless => "ls /etc/init.d/nova-api-metadata",
        require => Class["nova-compute"],
        notify => File["/etc/init/libvirt-bin.conf"],
    }

    file { 
        # CONF
        "/etc/init/libvirt-bin.conf":
            source => "puppet:///files/contrib/nova/libvirt-bin.conf",
            require => Exec["nova-compute upstart"],
            mode => "0755";

        "/etc/init/nova-compute.conf":
            source => "puppet:///files/contrib/nova/nova-compute.conf",
            require => File["/etc/init/libvirt-bin.conf"],
            mode => "0644";

        "/etc/init/nova-api-metadata.conf":
            source => "puppet:///files/contrib/nova/nova-api-metadata.conf",
            require => File["/etc/init/nova-compute.conf"],
            mode => "0644";

        "/etc/init/nova-network.conf":
            source => "puppet:///files/contrib/nova/nova-network.conf",
            require => File["/etc/init/nova-api-metadata.conf"],
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
        path => $command_path,
        command => "pkg-config --modversion libnl-1; \
                    cd $source_dir; \
                    tar zxvf libvirt-$libvirt_version.tar.gz; \
                    cd libvirt-$libvirt_version; \
                    sed -i 's/49152/40152/g' src/qemu/qemu_conf.h; \
                    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc; \
                    make; \
                    make install",
        refreshonly => true,
        notify => Exec["libvirt live migration"],
    }

    exec { "libvirt live migration":
        command => "sed -i 's/#listen_tls/listen_tls/' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/#listen_tcp/listen_tcp/' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/^.auth_tcp.*$/auth_tcp = \"none\"/' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/#unix_sock_group = \"libvirt\"/unix_sock_group = \"libvirtd\"/g' /etc/libvirt/libvirtd.conf; \
                    sed -i 's/#unix_sock_rw_perms = \"0770\"/unix_sock_rw_perms = \"0770\"/g' /etc/libvirt/libvirtd.conf; \
                    grep nbd /etc/modules || echo nbd >> /etc/modules; \
                    modprode nbd; \
                    /etc/init.d/libvirt-bin restart",
        path => $command_path,
        onlyif => "grep ^#listen_tls /etc/libvirt/libvirtd.conf",
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
        notify => Class["nova-compute::qemu"],
    }
}
