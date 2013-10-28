class glusterfs::volume {
    file { "/opt/gluster_data":
        ensure => directory,
        notify => File["/opt/gluster_data/eccp-nova"],
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
        notify => File["/etc/glusterfs/create_volume.sh"],
    }

    file { "/etc/glusterfs/create_volume.sh":
        content => template("glusterfs/create_volume.sh.erb"),
        mode => 755,
        notify => Exec["create volume"],
    }

    exec { "create volume":
        command => "sh /etc/glusterfs/create_volume.sh",
        path => $command_path,
        unless => "ls /var/lib/glusterd/vols/*",
    }
}
