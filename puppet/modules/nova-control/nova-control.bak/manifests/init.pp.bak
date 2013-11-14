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
                    [ -e /etc/init.d/libvirt-bin ] && rm -f /etc/init.d/libvirt-bin; \
                    ln -s /lib/init/upstart-job /etc/init.d/libvirt-bin; \
                    ln -s /lib/init/upstart-job /etc/init.d/nova-xvpvncproxy",
        path => $command_path,
        unless => "ls /etc/init.d/nova-xvpvncproxy",
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
        notify => Package["gcc", "make", "pkg-config", "libgnutls-dev", "libdevmapper-dev", "libcurl4-gnutls-dev", "libpciaccess-dev", "libnl-dev", "pm-utils", "ebtables", "dnsmasq-base"],
    }

    package { ["gcc", "make", "pkg-config", "libgnutls-dev", "libdevmapper-dev", "libcurl4-gnutls-dev", "libpciaccess-dev", "libnl-dev", "pm-utils", "ebtables", "dnsmasq-base"]:
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
    }

    # qemu
    package { ["libglib2.0-dev", "libsdl-dev", "libpcap-dev", "autoconf", "libtool", "open-iscsi-utils", "xsltproc", "python-pyparsing", "libnss3", "libnss3-dev", "libpixman-1-dev", "libsasl2-dev"]:
        ensure => "installed",
        require => Service["libvirt-bin"],
        notify => File["$source_dir/libiscsi.tar"],
    }

    file { "$source_dir/libiscsi.tar":
        source => "puppet:///files/qemu/libiscsi.tar",
        notify => Exec["tar libiscsi"],
    }

    exec { "tar libiscsi":
        command => "[ -e $source_dir/libiscsi ] && \
                    rm -fr $source_dir/libiscsi; \
                    cd $source_dir; \
                    tar xf libiscsi.tar; \
                    cd libiscsi; \
                    sh autogen.sh; \
                    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc; \
                    sed -i '/doc\/iscsi-ls.1/d' Makefile; \
                    sed -i '/doc\/iscsi-inq.1/d' Makefile; \
                    sed -i '/doc\/iscsi-swp.1/d' Makefile; \
                    sed -i '/docbook.sourceforge.net/d' Makefile; \
                    make; make install; ldconfig",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => File["$source_dir/celt-0.5.1.3.tar.gz"],
    }

    file { "$source_dir/celt-0.5.1.3.tar.gz":
        source => "puppet:///files/qemu/celt-0.5.1.3.tar.gz",
        notify => Exec["tar celt"],
    }

    exec { "tar celt":
        command => "[ -e $source_dir/celt-0.5.1.3 ] && \
                    rm -fr $source_dir/celt-0.5.1.3; \
                    cd $source_dir; \
                    tar xf celt-0.5.1.3.tar.gz; \
                    cd celt-0.5.1.3; \
                    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc; \
                    make; make install; ldconfig",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => File["$source_dir/libcacard-0.1.2.tar.bz2"],
    }

    file { "$source_dir/libcacard-0.1.2.tar.bz2":
        source => "puppet:///files/qemu/libcacard-0.1.2.tar.bz2",
        notify => Exec["tar libcacard"],
    }

    exec { "tar libcacard":
        command => "[ -e $source_dir/libcacard-0.1.2 ] && \
                    rm -fr $source_dir/libcacard-0.1.2; \
                    cd $source_dir; \
                    tar xf libcacard-0.1.2.tar.bz2; \
                    cd libcacard-0.1.2; \
                    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc; \
                    make; make install; ldconfig",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
    }

    file { "$source_dir/spice-0.12.4.tar.bz2":
        source => "puppet:///files/qemu/spice-0.12.4.tar.bz2",
        notify => Exec["tar spice"],
    }

    exec { "tar spice":
        command => "[ -e $source_dir/spice-0.12.4 ] && \
                    rm -fr $source_dir/spice-0.12.4; \
                    cd $source_dir; \
                    tar xf spice-0.12.4.tar.bz2; \
                    cd spice-0.12.4; \
                    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc; \
                    make; make install; ldconfig",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => File["$source_dir/spice-protocol-0.12.6.tar.bz2"],
    }

    file { "$source_dir/spice-protocol-0.12.6.tar.bz2":
        source => "puppet:///files/qemu/spice-protocol-0.12.6.tar.bz2",
        notify => Exec["tar spice-protocol"],
    }

    include glusterfs::install
    exec { "tar spice-protocol":
        command => "[ -e $source_dir/spice-protocol-0.12.6 ] && \
                    rm -fr $source_dir/spice-protocol-0.12.6; \
                    cd $source_dir; \
                    tar xf spice-protocol-0.12.6.tar.bz2; \
                    cd spice-protocol-0.12.6; \
                    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc; \
                    make; make install; ldconfig",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => Class["glusterfs::install"],
    }

    file { "$source_dir/qemu-$qemu_version.tar.bz2":
        source => "puppet:///files/qemu/qemu-$qemu_version.tar.bz2",
        notify => Exec["tar qemu"],
    }

    exec { "tar qemu":
        command => "[ -e $source_dir/qemu-$qemu_version ] && \
                    rm -fr $source_dir/qemu-$qemu_version; \
                    cd $source_dir; \
                    tar xf qemu-$qemu_version.tar.bz2; \
                    cd qemu-$qemu_version; \
                    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc --enable-libiscsi --enable-spice --enable-glusterfs; \
                    make; make install; ldconfig",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
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
