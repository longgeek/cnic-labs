class glusterfs-client {
    Class["glusterfs-client"] -> Class["glusterfs-client::install"] -> Class["glusterfs-client::service"] -> Class["glusterfs-client::volume"] -> Class["glusterfs-client::mount"]
    include glusterfs-client, glusterfs-client::install, glusterfs-client::service, glusterfs-client::volume, glusterfs-client::mount
}
