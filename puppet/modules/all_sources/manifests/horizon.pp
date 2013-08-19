class all_sources::horizon {

    file { "$source_dir/$horizon_source_pack_name":
        source => "puppet:///files/$horizon_source_pack_name",
        notify => Exec["untar horizon"],
    }
    
    exec { "untar horizon":
        command => "tar zxvf $horizon_source_pack_name; \
                    cd horizon; \
                    python setup.py egg_info; \
                    pip install -r *.egg-info/requires.txt; \
                    python setup.py develop", 
#                    chown -R apache:apache $source_dir/horizon/",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => File["$source_dir/horizon/.blackhole"],
    }
    
    file { "$source_dir/horizon/.blackhole":
        ensure => directory,
        notify => File["$source_dir/openstack_auth.tar.gz"],
    }
    
    file { "$source_dir/openstack_auth.tar.gz":
        source => "puppet:///files/openstack_auth.tar.gz",
        notify => Exec["untar openstack_auth"],
    }
    
    exec { "untar openstack_auth":
        command => "tar zxvf openstack_auth.tar.gz",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
    }
}
