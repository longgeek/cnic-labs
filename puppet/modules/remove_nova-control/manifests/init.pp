class remove_nova-control {
    exec { "remove nova-control files":
        command => "/etc/init.d/nova-api stop; \
                    /etc/init.d/nova-cert stop; \
                    /etc/init.d/nova-scheduler stop; \
                    /etc/init.d/nova-network stop; \
                    /etc/init.d/nova-compute stop; \
                    /etc/init.d/nova-consoleauth stop; \
                    /etc/init.d/nova-console stop; \
                    /etc/init.d/nova-novncproxy stop; \
                    /etc/init.d/nova-xvpvncproxy stop; \
                    /etc/init.d/libvirt-bin stop; \
                    rm -fr /etc/init.d/nova-*; \
                    rm -fr /etc/init/nova-*; \
                    rm -f $source_dir/eccp.license; \
                    rm -f /etc/libvirt/libvirtd.conf; \
                    rm -f /etc/init/libvirt-bin.conf; \
                    sed -i '/nbd/d' /etc/modules; \
                    rm -f /etc/nova/nova.conf; \
                    rm -f /etc/nova/api-paste.ini; \
                    rm -f /etc/nova/rootwrap.conf; \
                    rm -fr /etc/nova/.fixed_ips; \
                    apt-get -y --force-yes remove --purge bridge-utils kvm libvirt-bin libvirt-dev python-libvirt qemu-kvm python-m2crypto dnsmasq-utils; \
                    apt-get -y --force-yes autoremove",
        path => $command_path,
        onlyif => "ls /etc/nova/nova.conf",
    }

}
