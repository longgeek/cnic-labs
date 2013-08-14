class keystone {

	#Install deb requires
	package { $keystone_apt_requires:
		ensure => installed,
        notify => File["/etc/keystone", "/var/log/keystone", "/var/lib/keystone", "/var/run/keystone"],
	}

    file { ["/etc/keystone", "/var/log/keystone", "/var/lib/keystone", "/var/run/keystone"]:
        ensure => directory,
		notify => File["/usr/local/src/$keystone_source_pack_name"],
    }

	# Send tar pack
	file { "/usr/local/src/$keystone_source_pack_name":
		source => "puppet:///files/$keystone_source_pack_name",
		notify => Exec["untar keystone"],
	}

	# Un pack & pip requires & install
	exec { "untar keystone":
		command => "tar zxvf $keystone_source_pack_name && cd keystone && pip install -r tools/pip-requires && python setup.py install && \
                    cp etc/default_catalog.templates /etc/keystone/ && \
                    cp etc/policy.json /etc/keystone/",
		path => $command_path,
		cwd => "/usr/local/src",
		refreshonly => true,
        notify => File["/usr/local/src/$keystone_client_source_pack_name"],
	}

    # Keystone Client
    file { "/usr/local/src/$keystone_client_source_pack_name":
        source => "puppet:///files/$keystone_client_source_pack_name",
        notify => Exec["untar keystone-client"],
    }

	exec { "untar keystone-client":
		command => "tar zxvf $keystone_client_source_pack_name && cd python-keystoneclient && pip install -r requirements.txt && python setup.py install",
		path => $command_path,
		cwd => "/usr/local/src",
		refreshonly => true,
        notify => File["/etc/keystone/logging.conf"],
	}

    # Conf
	file { "/etc/keystone/logging.conf":
        content => template("keystone/logging.conf.erb"),
        notify => Exec["keystone-db-sync"],
	}

	file { "/etc/keystone/keystone.conf":
        content => template("keystone/keystone.conf.erb"),
        notify => Exec["keystone-db-sync"],
	}

    exec { "keystone-db-sync":
        command => "keystone-manage db_sync && nohup keystone-all --config-file /etc/keystone/keystone.conf > /dev/null 2>&1 &)",
        path => $command_path,
        refreshonly => true,
        notify => File["/etc/keystone/keystone.sh"],
    }

    # import Data
    file { "/etc/keystone/keystone.sh":
        content => template("keystone/keystone.sh.erb"),
        mode => 0755,
        notify => Exec["sh keystone.sh"],
    }

    exec { "sh keystone.sh":
        command => "sleep 5 && sh /etc/keystone/keystone.sh",
        path => $command_path,
        refreshonly => true,
        notify => Exec["start keystone"],
    }

    exec { "start keystone":
        command => "echo 'nohup keystone-all --config-file /etc/keystone/keystone.conf > /dev/null 2>&1 &' >> /etc/rc.local;
                    touch /etc/keystone/.start-keystone",
        path => $command_path,
        creates => "/etc/keystone/.start-keystone",
    }
}
