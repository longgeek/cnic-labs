class rabbitmq {
    package { "rabbitmq-server":
        ensure => installed,
        notify => File["/etc/rabbitmq/change_password.sh"],
    }

    service { "rabbitmq-server":
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        notify => File["/etc/rabbitmq/change_password.sh"],
    }

    file { "/etc/rabbitmq/change_password.sh":
        content => template("rabbitmq/change_password.sh.erb"),
        mode => 0755,
        notify => Exec["sh change_password.sh"],
    }

    exec { "sh change_password.sh":
        command => "sh /etc/rabbitmq/change_password.sh",
        path => $command_path,
        refreshonly => true,
    }

}
