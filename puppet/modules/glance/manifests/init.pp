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
            require => Exec["glance upstart"],
            mode => "0644";

        "/etc/init/glance-registry.conf":
            source => "puppet:///files/contrib/glance/glance-registry.conf",
            require => File["/etc/init/glance-api.conf"],
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
        notify => Exec["glance db_sync"],
    }

    exec { "glance db_sync":
        command => "glance-manage db_sync",
        path => $command_path,
        onlyif => "mysql -u$glance_db_user -p$glance_db_password -h $mysql_host $glance_db_name -e 'show tables;' && [ \"`mysql -u$glance_db_user -p$glance_db_password -h $mysql_host $glance_db_name -e 'show tables;' | wc -l`\" -eq \"0\" ]",
        notify => Service["glance-api", "glance-registry"],
    }

    service { ["glance-api", "glance-registry"]:
        ensure => "running",
        enable => true,
        hasstatus => true,
        hasrestart => true,
        notify => File["/etc/glance/cirros-0.3.0-x86_64-disk.img"],
    }

    file { "/etc/glance/cirros-0.3.0-x86_64-disk.img":
        source => "puppet:///files/cirros-0.3.0-x86_64-disk.img",
        notify => Exec["glance_add"],
    }

    exec { "glance_add": 
        command => "[ \"`glance --os_username=admin --os_password=${admin_password} --os_tenant_name=admin --os_auth_url=http://${keystone_host}:5000/v2.0 image-list | wc -l`\" -ne \"1\" ] && \
                    glance --os_username=admin --os_password=${admin_password} --os_tenant_name=admin --os_auth_url=http://${keystone_host}:5000/v2.0 image-delete `glance --os_username=admin --os_password=${admin_password} --os_tenant_name=admin --os_auth_url=http://${keystone_host}:5000/v2.0 image-list | grep cirros | awk -F'|' '{print \$2}'`; \
                    glance --os_username=admin --os_password=${admin_password} --os_tenant_name=admin --os_auth_url=http://${keystone_host}:5000/v2.0 image-create --name='cirros-0.3.0' --public --container-format=ovf --disk-format=qcow2 < /etc/glance/cirros-0.3.0-x86_64-disk.img",
        path => $command_path,
        onlyif => "[ \"`ls $source_dir/data/glance/images/ | wc -l`\" -eq \"0\" ] && /etc/init.d/glance-api restart && /etc/init.d/glance-registry restart && glance --os_username=admin --os_password=${admin_password} --os_tenant_name=admin --os_auth_url=http://${keystone_host}:5000/v2.0 image-list",
    }
}
