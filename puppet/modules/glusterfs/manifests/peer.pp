class glusterfs::peer {
    file { "/etc/glusterfs/add_peer.sh":
        content => template("glusterfs/add_peer.sh.erb"),
        mode => 755,
        notify => Exec["peer probe"]
    }
    
    exec { "peer probe":
        command => "sh /etc/glusterfs/add_peer.sh",
        path => $command_path,
        unless => "ls /var/lib/glusterd/peers/*",
    }
}
