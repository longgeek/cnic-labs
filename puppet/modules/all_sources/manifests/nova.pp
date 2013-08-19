### Nova
    # mkdir dir
    file { ["/etc/nova", "/var/log/nova", "/var/lib/nova", "/var/run/nova", "/var/lib/nova/instances", "/var/lock/nova", "/home/nova"]:
        ensure => directory,
        owner => "nova",
        require => Exec["untar cinder-client"],
        notify => File["$source_dir/$nova_source_pack_name"],
    }

    # nova pack
    file { "$source_dir/$nova_source_pack_name":
        source => "puppet:///files/$nova_source_pack_name",
        notify => Exec["untar nova"],
    }

    exec { "untar nova":
        command => "tar zxvf $nova_source_pack_name; \
                    cd nova; \
                    python setup.py egg_info; \
                    pip install -r *.egg-info/requires.txt; \
                    python setup.py develop; \
                    cp -r etc/nova/rootwrap.d /etc/nova/; \
                    cp etc/nova/policy.json /etc/nova/; \
                    chown -R nova:root /etc/nova/",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => File["$source_dir/$nova_client_source_pack_name"],
    }

    # python-novaclient pack
    file { "$source_dir/$nova_client_source_pack_name":
        source => "puppet:///files/$nova_client_source_pack_name",
        notify => Exec["untar nova-client"],
    }

    exec { "untar nova-client":
        command => "tar zxvf $nova_client_source_pack_name; \
                    cd python-novaclient; \
                    python setup.py egg_info; \
                    pip install -r tools/pip-requires; \
                    python setup.py develop",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => File["$source_dir/$nova_novnc_source_pack_name"],
    }

    # noVNC
    file { "$source_dir/$nova_novnc_source_pack_name":
        source => "puppet:///files/$nova_novnc_source_pack_name",
        notify => Exec["untar noVNC"],
    }

    exec { "untar noVNC":
        command => "tar zxvf $nova_novnc_source_pack_name; \
                    rm -fr /usr/share/novnc; \
                    mv noVNC /usr/share/novnc",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => File["$source_dir/websockify.tar.gz"],
    }

    # websockify pack
    file { "$source_dir/websockify.tar.gz":
        source => "puppet:///files/websockify.tar.gz",
        notify => Exec["untar websockify"],
    }

    exec { "untar websockify":
        command => "tar zxvf websockify.tar.gz; \
                    cd websockify; \
                    python setup.py egg_info; \
                    pip install -r *.egg-info/requires.txt; \
                    python setup.py develop",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
    }
