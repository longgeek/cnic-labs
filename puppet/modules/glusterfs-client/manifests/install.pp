class glusterfs-client::install {
    exec { "packages install":
        command => "apt-get -y --force-yes install flex bison attr libssl-dev openssl xfsprogs",
        path => $command_path,
        unless => "dpkg -l | grep xfsprogs && dpkg -l | grep flex && dpkg -l | grep bison && dpkg -l | grep attr && dpkg -l | grep libssl-dev",
        notify => File["$source_dir/glusterfs-$glusterfs_version.tgz"],
    }

    file { "$source_dir/glusterfs-$glusterfs_version.tgz":
        source => "puppet:///files/glusterfs-$glusterfs_version.tar.gz",
        notify => Exec["untar glusterf"],
    }

    exec { "untar glusterf":
        command => "[ -e $source_dir/glusterfs-$glusterfs_version ] && \
                    rm -fr $source_dir/glusterfs-$glusterfs_version; \
                    cd $source_dir; \
                    tar zxvf glusterfs-$glusterfs_version.tar.gz; \
                    cd glusterfs-$glusterfs_version; \
                    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc; \
                    make; \
                    make install; \
                    ps aux | grep -v grep | grep glusterd && /etc/init.d/glusterd restart; ls",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
    }
}
