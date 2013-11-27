class swift::mount {
    exec { "check mount.glusterfs":
        command => "apt-get -y --force-yes install glusterfs-client",
        path => $command_path,
        unless => "which mount.glusterfs",
    }

    exec { "mount glusterfs volume":
        command => "mount.glusterfs `echo $glusterfs_nodes_list | awk '{print \$1}'`:eccp-swift $source_dir/data/swift",
        path => $command_path,
        unless => "df -h | grep eccp-swift",
        require => Exec["check mount.glusterfs"],
    }
}
