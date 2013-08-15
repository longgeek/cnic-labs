class nova {

    # Install deb requires
    package { $nova_apt_requires:
        ensure => installed,
        notify => Service["libvirt-bin"],
    }

    service { "libvirt-bin":
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        notify => File["/etc/nova", "/var/log/nova", "/var/lib/nova", "/var/run/nova", "/var/lib/nova/instances", "/var/lock/nova"],
    }

    # mkdir dir
    file { ["/etc/nova", "/var/log/nova", "/var/lib/nova", "/var/run/nova", "/var/lib/nova/instances", "/var/lock/nova"]:
        ensure => directory,
        notify => File["$source_dir/$nova_source_pack_name"],
    }

    # nova pack
    file { "$source_dir/$nova_source_pack_name":
        source => "puppet:///files/$nova_source_pack_name",
        notify => Exec["untar nova"],
    }

    exec { "untar nova":
        command => "tar zxvf $nova_source_pack_name && cd nova && pip install -r tools/pip-requires && python setup.py develop && \
                    cp -r etc/nova/rootwrap.d /etc/nova/ && \
                    cp etc/nova/policy.json /etc/nova/",
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
        command => "tar zxvf $nova_client_source_pack_name && cd python-novaclient && pip install -r tools/pip-requires && python setup.py develop",
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
        command => "tar zxvf $nova_novnc_source_pack_name && rm -fr /usr/share/novnc; mv noVNC /usr/share/novnc",
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
        command => "tar zxvf websockify.tar.gz && cd websockify && python setup.py develop",
        path => $command_path,
        cwd => $source_dir,
        refreshonly => true,
        notify => File["/etc/nova/nova.conf"],
    }

    # config
    file { "/etc/nova/nova.conf":
        content => template("nova/nova.conf.erb"),
        notify => Exec["nova db sync"],
    }

    file { "/etc/nova/api-paste.ini":
        content => template("nova/api-paste.ini.erb"),
        notify => Exec["nova db sync"],
    }

    file { "/etc/nova/rootwrap.conf":
        content => template("nova/rootwrap.conf.erb"),
        notify => Exec["nova db sync"],
    }

    exec { "nova db sync":
        command => "nova-manage db sync && \
                    nohup nova-cert --config-file /etc/nova/nova.conf > /dev/null 2>&1 & \
                    nohup nova-api --config-file /etc/nova/nova.conf > /dev/null 2>&1 & \
                    nohup nova-scheduler --config-file /etc/nova/nova.conf > /dev/null 2>&1 & \
                    nohup nova-network --config-file /etc/nova/nova.conf > /dev/null 2>&1 & \
                    nohup nova-compute --config-file /etc/nova/nova.conf > /dev/null 2>&1 & \
                    nohup nova-consoleauth --config-file /etc/nova/nova.conf > /dev/null 2>&1 & \
                    nohup nova-console --config-file /etc/nova/nova.conf > /dev/null 2>&1 & \
                    nohup nova-novncproxy --config-file /etc/nova/nova.conf > /dev/null 2>&1 & \
                    nohup nova-xvpvncproxy --config-file /etc/nova/nova.conf > /dev/null 2>&1 & \
                    ",
        path => $command_path,
        refreshonly => true,
    }

}
