class glusterfs-client::volume {
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
    }
}
