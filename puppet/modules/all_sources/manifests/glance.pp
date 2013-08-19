## Glance
    file { ["/etc/glance", "/var/lib/glance/", "/var/run/glance", "/var/log/glance", "/var/lib/glance/images", "/var/lib/glance/image-cache/", "/var/lib/glance/scrubber", "/home/glance"]:
        ensure => directory,
        owner => "glance",
        require => File["/root/.pip/pip.conf"],
        notify => File["$source_dir/$glance_source_pack_name"],
    }  

    file { "$source_dir/$glance_source_pack_name":
        source => "puppet:///files/$glance_source_pack_name",
        notify => Exec["untar glance"],
    }

    exec { "untar glance":
        command => "tar zxvf $glance_source_pack_name; \
                    cd glance; \
                    python setup.py egg_info; \
                    pip install -r *.egg-info/requires.txt; \
                    python setup.py develop; \
                    cp etc/glance-api-paste.ini /etc/glance/; \
                    cp etc/schema-image.json /etc/glance/; \
                    cp etc/glance-registry-paste.ini /etc/glance/; \
                    cp etc/policy.json /etc/glance/; \
                    chown -R glance:root /etc/glance/",
        cwd => $source_dir,
        path => $command_path,
        refreshonly => true,
        notify => File["$source_dir/$glance_client_source_pack_name"],
    }

    file { "$source_dir/$glance_client_source_pack_name":
        source => "puppet:///files/$glance_client_source_pack_name",
        notify => Exec["untar glance-client"],
    }

    exec { "untar glance-client":
        command => "tar zxvf $glance_client_source_pack_name; \
                    cd python-glanceclient; \
                    python setup.py egg_info; \
                    pip install -r *.egg-info/requires.txt; \
                    python setup.py develop",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
    }   
