class glusterfs::volume {
    file { "/opt/gluster_data":
        ensure => directory,
        notify => File["/opt/gluster_data/eccp-nova"],
        require => Class["glusterfs::peer"],
    }

    file { "/opt/gluster_data/eccp-nova":
        ensure => directory,
        notify => File["/opt/gluster_data/eccp-glance"],
    }

    file { "/opt/gluster_data/eccp-glance":
        ensure => directory,
        notify => File["/opt/gluster_data/eccp-cinder"],
    }

    file { "/opt/gluster_data/eccp-cinder":
        ensure => directory,
        notify => File["/opt/gluster_data/eccp-swift"],
    }

    file { "/opt/gluster_data/eccp-swift":
        ensure => directory,
        notify => File["/etc/glusterfs/create_volume.py"],
    }

    file { "/etc/glusterfs/create_volume.py":
        content => template("glusterfs/create_volume.py.erb"),
        mode => 755,
        notify => Exec["create volume"],
    }

    exec { "create volume":
        command => "python /etc/glusterfs/create_volume.py",
        path => $command_path,
        unless  => "[ \"`ls /var/lib/glusterd/vols/ | wc -l`\" -eq \"4\" ] && [ \"`python -c \"a = '$glusterfs_nodes_list'.split(' '); print len(list(a))\"`\" = \"`gluster volume info | grep -v Bricks | grep Brick[1-9]* | grep eccp-nova | wc -l`\" ] ",
    }
}
