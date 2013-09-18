class remove_mysql {

    exec { "remove mysql databases":
        command => "mysql -uroot -p${mysql_root_password} -e \"drop database ${keystone_db_name}; \
                                                               drop database ${glance_db_name}; \
                                                               drop database ${cinder_db_name}; \
                                                               drop database ${horizon_db_name}; \
                                                               drop database ${monitor_db_name}; \
                                                               drop database ${nova_db_name};\"; \
                    rm -f /etc/mysql/.mysqldb; \
                    apt-get -y --force-yes remove --purge mysql-server python-mysqldb mysql-common; \
                    apt-get -y --force-yes autoremove; \
                    apt-get clean all",
        path => $command_path,
        onlyif => "ls /etc/mysql/.mysqldb",
        notify => Exec["remove mysql files"],
    }

    exec { "remove mysql files":
        command => "rm -fr /var/lib/dpkg/info/mysql*; \
                    rm -f /etc/installmysql.py; \
                    rm -fr /etc/mysql; \
                    rm -fr /var/lib/mysql",
        path => $command_path,
        onlyif => "ls /etc/installmysql.py",
    }
}
