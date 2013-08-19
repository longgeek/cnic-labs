### Keystone

    file { ["/etc/keystone", "/var/log/keystone", "/var/lib/keystone", "/var/run/keystone"]:
        ensure => directory,
        owner => "keystone",
        require => Exec["untar glance-client"],
        notify => File["$source_dir/$keystone_source_pack_name"],
    }  

    # Send tar pack
    file { "$source_dir/$keystone_source_pack_name":
        source => "puppet:///files/$keystone_source_pack_name",
        notify => Exec["untar keystone"],
    }   

    # Un pack & pip requires & install
    exec { "untar keystone":
        command => "tar zxvf $keystone_source_pack_name; \
                    cd keystone; \
                    python setup.py egg_info; \
                    pip install -r *.egg-info/requires.txt; \
                    python setup.py develop; \
                    cp etc/default_catalog.templates /etc/keystone/; \
                    cp etc/policy.json /etc/keystone/; \
                    chown -R keystone:root /etc/keystone/",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => File["$source_dir/$keystone_client_source_pack_name"],
    }   

    # Keystone Client
    file { "$source_dir/$keystone_client_source_pack_name":
        source => "puppet:///files/$keystone_client_source_pack_name",
        notify => Exec["untar keystone-client"],
    }   

    exec { "untar keystone-client":
        command => "tar zxvf $keystone_client_source_pack_name; \
                    cd python-keystoneclient; \
                    python setup.py egg_info; \
                    pip install -r *.egg-info/requires.txt; \
                    python setup.py develop",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
    }   
