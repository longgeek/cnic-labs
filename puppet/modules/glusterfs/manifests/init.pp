class glusterfs {
    Class["glusterfs"] -> Class["glusterfs::install"] -> Class["glusterfs::service"] -> Class["glusterfs::peer"] -> Class["glusterfs::volume"] -> Class["glusterfs::mount"]
    include glusterfs, glusterfs::install, glusterfs::service, glusterfs::peer, glusterfs::volume, glusterfs::mount
}
