class glusterfs::install {
    package { ["flex", "bison", "attr", "libssl-dev", "openssl", "xfsprogs"]:
        ensure => installed,
        notify => File["$source_dir/glusterfs-$glusterfs_version.tar.gz"],
    }

    file { "$source_dir/glusterfs-$glusterfs_version.tar.gz":
        source => "puppet:///files/glusterfs-$glusterfs_version.tar.gz",
        notify => Exec["untar glusterfs"],
    }

    exec { "untar glusterfs":
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
