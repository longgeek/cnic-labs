class remove_nova-compute {
    exec { "remove nova-compute files":
        command => "/etc/init.d/nova-compute stop; \
                    /etc/init.d/nova-network stop; \
                    /etc/init.d/nova-api-metadata stop; \
                    apt-get -y --force-yes remove --purge bridge-utils kvm libvirt-bin libvirt-dev python-libvirt qemu-kvm python-m2crypto dnsmasq-utils; \
                    apt-get -y --force-yes autoremove; \
                    rm -f /etc/init.d/nova*; \
                    rm -f /etc/init/nova*; \
                    rm -f $source_dir/eccp.license; \
                    rm -fr /etc/libvirt; \
                    rm -f /etc/init/libvirt-bin.conf; \
                    sed -i '/nbd/d' /etc/modules; \
                    rm -f /etc/nova/nova.conf.sh; \
                    rm -f /etc/nova/nova.conf; \
                    rm -f /etc/nova/api-paste.ini; \
                    rm -f /etc/nova/rootwrap.conf; \
                    rm -fr /var/log/nova/*",
        path => $command_path,
        onlyif => "ls /etc/nova/nova.conf.sh",
    }
}
