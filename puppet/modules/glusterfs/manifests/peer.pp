class glusterfs::peer {
    file { "/etc/glusterfs/add_peer.py":
        content => template("glusterfs/add_peer.py.erb"),
        mode => 755,
        notify => Exec["peer probe"]
    }
    
    exec { "peer probe":
        command => "python /etc/glusterfs/add_peer.py",
        path => $command_path,
        unless => "[ \"`python -c \"a = '$glusterfs_nodes_list'.split(' '); print len(list(a)) - 1\"`\" = \"`gluster peer status | grep Hostname | wc -l`\" ]",
    }
}
