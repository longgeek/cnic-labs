class nova-control::qemu {
    exec { "install qemu packages":
        command => "apt-get -y --force-yes install libglib2.0-dev libsdl1.2-dev libpcap-dev autoconf libtool open-iscsi-utils xsltproc python-pyparsing libnss3 libnss3-dev libpixman-1-dev libsasl2-dev libpixman-1-dev libjpeg-dev libsasl2-dev libnss3-dev unzip bc autoconf libtool libsdl1.2debian libsdl1.2-dev",
        path => $command_path,
        unless => "dpkg -l | grep '^ii  bc'",
        require => Class["nova-control::install"],
        notify => File["$source_dir/libiscsi.tar"],
    }

    file { "$source_dir/libiscsi.tar":
        source => "puppet:///files/qemu/libiscsi.tar",
        require => Exec["install qemu packages"],
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
        notify => File["$source_dir/spice-0.12.4.tar.bz2"],
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

    file { "$source_dir/qemu-$qemu_version.zip":
        source => "puppet:///files/qemu/qemu-$qemu_version.zip",
        notify => Exec["unzip qemu"],
    }

    exec { "unzip qemu":
        command => "[ -e $source_dir/qemu-$qemu_version ] && \
                    rm -fr $source_dir/qemu-$qemu_version; \
                    cd $source_dir; \
                    unzip qemu-$qemu_version.zip; \
                    cd qemu-$qemu_version; \
                    cp -rp etc/qemu /etc/; \
                    cp -rp etc/bash_completion.d/qemu /etc/bash_completion.d/; \
                    cp -rp usr/bin/* /usr/bin/; \
                    cp -rp usr/share/qemu /usr/share/",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        require => Class["glusterfs::install"],
    }
}
