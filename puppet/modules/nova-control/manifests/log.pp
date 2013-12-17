class nova-control::log {
    $nova-control_content = "/var/log/nova/*.log {
    daily
    rotate 30
    missingok
    compress
    minsize 100k
    dateext
    copytruncate
    notifempty
}"

    file { "/etc/logrotate.d/nova-control":
        content => $nova-control_content,
    }
}
