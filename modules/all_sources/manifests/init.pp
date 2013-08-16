class all_sources {

    Class["all_sources::glance"] -> Class["all_sources::keystone"] -> Class["all_sources::cinder"] -> Class["all_sources::nova"] -> Class["all_sources::horizon"]
    include all_sources::glance, all_sources::keystone, all_sources::cinder, all_sources::nova, all_sources::horizon

    user { ["keystone", "glance", "cinder", "nova", "apache"]:
        ensure => "present",
        shell => "/usr/sbin/nologin",
        notify => Group["kvm", "libvirtd"],
    }

    group { ["kvm", "libvirtd"]:
        ensure => "present",
        notify => Package[$source_apt_requires],
    }

    package { $source_apt_requires:
        ensure => installed,
        notify => Exec["initialization base"],
    }

    exec { "initialization base":
        command => "mkdir -p /root/.pip; mkdir -p $source_dir; usermod nova -G kvm,libvirtd",
        path => $command_path,
        creates => "/$source_dir",
        notify => File["/etc/sudoers.d/nova-rootwrap"],
    }

    file { "/etc/sudoers.d/nova-rootwrap":
        source => "puppet:///files/nova-rootwrap",
        mode => "0440",
        notify => File["/root/.pip/pip.conf"],
    }

    file { "/root/.pip/pip.conf":
        content => template("all_sources/pip.conf.erb"),
        notify => Class["all_sources::glance"],
    }
}
