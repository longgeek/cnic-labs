class savanna::install {
    exec { "install savanna requires":
        command => "apt-get -y --force-yes install python-setuptools python-virtualenv python-dev",
        path => $command_path,
        unless => "dpkg -l | grep python-virtualenv && dpkg -l | grep python-setuptools && dpkg -l | grep python-setuptools",
        notify => File["$source_dir/install_savanna.sh"],
    }

    file { "$source_dir/install_savanna.sh":
        content => template("savanna/install_savanna.sh.erb"),
        notify => [File["$source_dir/savanna.tar.gz"], exec["tar savanna"]],
    }
    file { "$source_dir/savanna.tar.gz":
        source => "puppet:///files/savanna.tar.gz",
        notify => Exec["tar savanna"],
    }

    exec { "tar savanna":
        command => "bash $source_dir/install_savanna.sh",
        path => $command_path,
        refreshonly => true,
    }
}
