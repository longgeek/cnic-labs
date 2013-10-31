class swift::gluster-swift-install {
    exec { "mount.glusterfs":
        command => "apt-get -y --force-yes install glusterfs-client",
        path => $command_path,
        unless => "[ -e /sbin/mount.glusterfs ]",
        notify => File["$source_dir/gluster-swift.tar.gz"],
    }

    file { "$source_dir/gluster-swift.tar.gz":
        source => "puppet:///files/gluster-swift.tar.gz",
        notify => Exec["untar gluster-swift"],
    }

    exec { "untar gluster-swift":
        command => "[ -e $source_dir/gluster-swift ] && \
                    cd $source_dir/gluster-swift && python setup.py develop -u && \
                    rm -fr $source_dir/gluster-swift; \
                    cd $source_dir; \
                    tar zxvf gluster-swift.tar.gz; \
                    cd gluster-swift; \
                    git checkout $gluster_swift_version; \
                    python setup.py develop",
        path => $command_path,
        refreshonly => true
    }
}
