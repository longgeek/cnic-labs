### Base
    user { ["keystone", "glance", "cinder", "nova", "apache"]:
        ensure => "present",
        shell => "/usr/sbin/nologin",
        notify => Group["kvm", "libvirtd"],
    }   

    group { ["kvm", "libvirtd"]:
        ensure => "present",
    }   

    package { $source_apt_requires:
        ensure => installed,
        require => Group["kvm", "libvirtd"],
        notify => Exec["initialization base"],
    }   

    exec { "initialization base":
        command => "mkdir -p /root/.pip; usermod nova -G kvm,libvirtd; mkdir -p $source_dir",
        path => $command_path,
        creates => "$source_dir",
        require => Package["git"],
        notify => File["/etc/sudoers.d/nova-rootwrap"],
    }   

    file { "/etc/sudoers.d/nova-rootwrap":
        source => "puppet:///files/nova-rootwrap",
        mode => "0440",
        require => Exec["initialization base"],
        notify => File["/root/.pip/pip.conf"],
    }   

    file { "/root/.pip/pip.conf":
        content => template("all_sources/pip.conf.erb"),
        require => File["/etc/sudoers.d/nova-rootwrap"],
    }   
