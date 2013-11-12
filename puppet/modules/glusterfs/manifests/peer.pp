class glusterfs::peer {
    file { "/etc/glusterfs/add_peer.py":
        content => template("glusterfs/add_peer.py.erb"),
        mode => 755,
        notify => Exec["peer probe"]
    }
    
    exec { "peer probe":
        command => "python /etc/glusterfs/add_peer.py",
        path => $command_path,
        #unless => "ls /var/lib/glusterd/peers/*",
        refreshonly => true,
    }
}
