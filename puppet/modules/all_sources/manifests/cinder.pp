
### Cinder

    file { ["/etc/cinder", "/var/lib/cinder", "/var/log/cinder/", "/var/run/cinder", "/var/lib/cinder/images"]:
        ensure => directory,
        owner => "cinder",
        require => Exec["untar keystone-client"],

        notify => File["$source_dir/$cinder_source_pack_name"],
    } 

    file { "$source_dir/$cinder_source_pack_name":
        source => "puppet:///files/$cinder_source_pack_name",
        notify => Exec["untar cinder"],
    }   

    exec { "untar cinder":
        command => "tar zxvf $cinder_source_pack_name; \
                    cd cinder; \
                    python setup.py egg_info; \
                    pip install -r *.egg-info/requires.txt; \
                    python setup.py develop; \
                    cp etc/cinder/policy.json /etc/cinder/; \
                    cp etc/cinder/rootwrap.conf /etc/cinder; \
                    cp -r etc/cinder/rootwrap.d/ /etc/cinder; \
                    chown -R cinder:root /etc/cinder",
        cwd => $source_dir,
        path => $command_path,
        refreshonly => true,
        notify => File["$source_dir/$cinder_client_source_pack_name"],
    }   

    file { "$source_dir/$cinder_client_source_pack_name":
        source => "puppet:///files/$cinder_client_source_pack_name",
        notify => Exec["untar cinder-client"],
    }   

    exec { "untar cinder-client":
        command => "tar zxvf $cinder_client_source_pack_name; \
                    cd python-cinderclient; \
                    python setup.py egg_info; \
                    pip install -r *.egg-info/requires.txt; \
                    python setup.py develop",
        cwd => $source_dir,
        path => $command_path,
        refreshonly => true,
    }   
