class mysql {

    file { "/etc/installmysql.py":
        content => template("mysql/installmysql.py.erb"),
        mode => 755,
        notify => Exec["python installmysql.py"],
    }

    exec { "python installmysql.py":
        command => "python /etc/installmysql.py",
        path => $command_path,
        refreshonly => true,
        notify => Package["mysql-server", "python-mysqldb"],
    }
   
    package { ["mysql-server", "python-mysqldb"]:
        ensure => installed,
        notify => Exec["mysqlconf"],
    }


    exec { "mysqlconf":
        command => "sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf; sed -i '44 i skip-name-resolve' /etc/mysql/my.cnf; touch /etc/mysql/.mysqlconf",
        path => $command_path,
        notify => Exec["mysqldb"],
        creates => "/etc/mysql/.mysqlconf",
    }

    exec { "mysqldb":
        command => "mysql -uroot -p${mysql_root_password} -e \"create database ${keystone_db_name} default character set utf8; \
                                                               create database ${glance_db_name} default character set utf8; \
                                                               create database ${cinder_db_name} default character set utf8; \
                                                               create database ${horizon_db_name} default character set utf8; \
                                                               create database ${monitor_db_name} default character set utf8; \
                                                               create database ${nova_db_name} default character set utf8;\"; \
                    mysql -uroot -p${mysql_root_password} -e \"grant all on ${keystone_db_name}.* to '${keystone_db_user}'@'%' identified by '${keystone_db_password}'; \
                                                               grant all on ${glance_db_name}.* to '${glance_db_user}'@'%' identified by '${glance_db_password}'; \
                                                               grant all on ${cinder_db_name}.* to '${cinder_db_user}'@'%' identified by '${cinder_db_password}'; 
                                                               grant all on ${horizon_db_name}.* to '${horizon_db_user}'@'%' identified by '${horizon_db_password}'; 
                                                               grant all on ${monitor_db_name}.* to '${monitor_db_user}'@'%' identified by '${monitor_db_password}'; 
                                                               grant all on ${nova_db_name}.* to '${nova_db_user}'@'%' identified by '${nova_db_password}';\"; \
                    touch /etc/mysql/.mysqldb",
        path => $command_path,
        creates => "/etc/mysql/.mysqldb",
        notify => Service["mysql"],
    }
    
    service { "mysql":
        ensure => running,
        enable => true,
        require => Exec["mysqldb"],
        hasstatus => true,
        hasrestart => true,
    }

}
