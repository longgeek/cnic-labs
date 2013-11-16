class glusterfs-client::mount {
    exec { "glusterfs client":
        command => "apt-get -y --force-yes install glusterfs-client",
        path => $command_path,
        unless => "which mount.glusterfs", 
        notify => File["$source_dir/mount_glusterfs.py"],
    }

    file { "$source_dir/mount_glusterfs.py":
        content => template("glusterfs/mount_glusterfs.py.erb"),
        mode => 755,
        notify => Exec["mount glusterfs"],
    }

    exec { "mount glusterfs":
        command => "python $source_dir/mount_glusterfs.py",
        path => $command_path,
        unless => '[ "`df -h | grep eccp | wc -l`" -ge "3" ]',
    }
}
