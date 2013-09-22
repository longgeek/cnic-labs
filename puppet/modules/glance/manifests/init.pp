class glance {
    exec { "glance upstart":
        command => "ln -s /lib/init/upstart-job /etc/init.d/glance-api; \
                    ln -s /lib/init/upstart-job /etc/init.d/glance-registry",
        path => $command_path,
        unless => "ls /etc/init.d/glance-registry",
        notify => File["/etc/init/glance-api.conf"],
    }
        
    file { 
        "/etc/init/glance-api.conf":
            source => "puppet:///files/contrib/glance/glance-api.conf",
            mode => "0644";

        "/etc/init/glance-registry.conf":
            source => "puppet:///files/contrib/glance/glance-registry.conf",
            mode => "0644";
    }   

    file { "/etc/glance/glance-api.conf":
        content => template("glance/glance-api.conf.erb"),
        owner => "glance",
        group => "glance",
        require => File["/etc/init/glance-registry.conf"],
        notify => Exec["glance db sync"],
    }

    file { "/etc/glance/glance-registry.conf":
        content => template("glance/glance-registry.conf.erb"),
        owner => "glance",
        group => "glance",
        notify => Exec["glance db sync"],
    }

    file { "/etc/glance/glance-cache.conf":
        content => template("glance/glance-cache.conf.erb"),
        owner => "glance",
        group => "glance",
        notify => Exec["glance db sync"],
    }

    exec { "glance db sync":
        command => "glance-manage db_sync; \
                    touch /var/log/glance/registry.log; \
                    chown glance:root /var/log/glance/registry.log; \
                    /etc/init.d/glance-api restart; \
                    /etc/init.d/glance-registry restart",
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
