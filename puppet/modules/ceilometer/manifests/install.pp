class ceilometer::install {
    package { ["mongodb", "mongodb-clients", "mongodb-dev", "mongodb-server"]:
        ensure => installed,
        notify => File["$source_dir/python-ceilometerclient.tar.gz"],
    }

    file { "$source_dir/python-ceilometerclient.tar.gz":
        source => "puppet:///files/python-ceilometerclient.tar.gz",
        notify => Exec["tar python-ceilometerclient"],
    }

    exec { "tar python-ceilometerclient":
        command => "[ -e $source_dir/python-ceilometerclient ] && \
                   cd $source_dir/python-ceilometerclient && \
                   python setup.py develop -u && \
                   rm -fr $source_dir/python-ceilometerclient; \
                   cd $source_dir; \
                   tar xf python-ceilometerclient.tar.gz; \
                   cd python-ceilometerclient; \
                   sed \"818a \    return '2013.2'\" -i /usr/local/lib/python2.7/dist-packages/pbr/packaging.py; \
                   python setup.py develop; \
                   sed -i \"/return '2013.2'/d\" /usr/local/lib/python2.7/dist-packages/pbr/packaging.py",
        path => $command_path,
        refreshonly => true,
        notify => File["$source_dir/ceilometer.tar.gz"],
    }

    file { "$source_dir/ceilometer.tar.gz":
        source => "puppet:///files/ceilometer.tar.gz",
        notify => [File["$source_dir/install_ceilometer.sh"], Exec["sh ceilometer script"]],
    }

    file { "$source_dir/install_ceilometer.sh":
        content => template("ceilometer/install_ceilometer.sh.erb"),
        mode => 0755,
        notify => Exec["sh ceilometer script"],
    }

    exec { "sh ceilometer script":
        command => "bash $source_dir/install_ceilometer.sh",
        path => $command_path,
        refreshonly => true,
    }
}
