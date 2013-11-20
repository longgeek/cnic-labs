class remove_nova-compute {
    exec { "remove nova-compute files":
        command => "/etc/init.d/nova-compute stop; \
                    /etc/init.d/nova-network stop; \
                    /etc/init.d/nova-api-metadata stop; \
                    apt-get -y --force-yes remove --purge bridge-utils  python-m2crypto dnsmasq-utils; \
                    apt-get -y --force-yes autoremove; \
                    rm -fr /etc/init.d/nova*; \
                    rm -fr /etc/init/nova*; \
                    rm -fr $source_dir/eccp.license; \
                    rm -fr /etc/libvirt; \
                    rm -f /etc/init/libvirt-bin.conf; \
                    sed -i '/nbd/d' /etc/modules; \
                    rm -fr /etc/nova; \
                    rm -fr /var/log/nova; \
                    rm -fr $source_dir/nova; \
                    rm -fr $source_dir/libvirt*",
        path => $command_path,
        onlyif => "ls /etc/nova/nova.conf.sh",
    }
}
