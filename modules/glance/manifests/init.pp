class glance {

    file { ["/etc/glance", "/var/lib/glance/", "/var/run/glance", "/var/log/glance", "/var/lib/glance/images", "/var/lib/glance/image-cache/", "/var/lib/glance/scrubber"]:
        ensure => directory,
        notify => File["/usr/local/src/$glance_source_pack_name"],
    }

    file { "/usr/local/src/$glance_source_pack_name":
        source => "puppet:///files/$glance_source_pack_name",
        notify => Exec["untar glance"],
    }

    exec { "untar glance":
        command => "tar zxvf $glance_source_pack_name && \
                    cd glance && pip install -r tools/pip-requires; python setup.py install && \
                    cp etc/glance-api-paste.ini /etc/glance/ && \
                    cp etc/glance-registry-paste.ini /etc/glance/ && \
                    cp etc/policy.json /etc/glance", 
        cwd => "/usr/local/src",
        path => $command_path,
        refreshonly => true,
        notify => File["/usr/local/src/$glance_client_source_pack_name"],
    }

    file { "/usr/local/src/$glance_client_source_pack_name":
        source => "puppet:///files/$glance_client_source_pack_name",
        notify => Exec["untar glance-client"],
    }

    exec { "untar glance-client":
        command => "tar zxvf $glance_client_source_pack_name && cd python-glanceclient && \
                    pip install -r requirements.txt; python setup.py install",
        path => $command_path,
        cwd => "/usr/local/src",
        refreshonly => true,
        notify => File["/etc/glance/glance-api.conf"],
    }

    file { "/etc/glance/glance-api.conf":
        content => template("glance/glance-api.conf.erb"),
        notify => File["/etc/glance/glance-registry.conf"],
    }

    file { "/etc/glance/glance-registry.conf":
        content => template("glance/glance-registry.conf.erb"),
        notify => File["/etc/glance/glance-cache.conf"],
    }

    file { "/etc/glance/glance-cache.conf":
        content => template("glance/glance-cache.conf.erb"),
        notify => Exec["glance db sync"],
    }

    exec { "glance db sync":
        command => "glance-manage db_sync && nohup glance-api --config-file /etc/glance/glance-api.conf > /dev/null 2>&1 & \
                    nohup glance-registry --config-file /etc/glance/glance-registry.conf > /dev/null 2>&1 &",
        path => $command_path,
        refreshonly => true,
        notify => File["/etc/glance/cirros-0.3.0-x86_64-disk.img"],
    }

    file { "/etc/glance/cirros-0.3.0-x86_64-disk.img":
        source => "puppet:///files/cirros-0.3.0-x86_64-disk.img",
        notify => Exec["glance_add"],
    }

    exec { "glance_add": 
        command => "glance --os_username=admin --os_password=${admin_password} --os_tenant_name=admin --os_auth_url=http://${keystone_host}:5000/v2.0 image-create --name='cirros-0.3.0' --public --container-format=ovf --disk-format=qcow2 < /etc/glance/cirros-0.3.0-x86_64-disk.img; touch /etc/glance/.glance_add",
        path => $command_path,
        creates => '/etc/glance/.glance_add'
    }
}
