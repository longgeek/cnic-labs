class savanna::log {
    $savanna_content = "/var/log/savanna/*.log {
    daily
    rotate 30
    missingok
    compress
    minsize 100k
    dateext
    copytruncate
    notifempty
}"

    file { "/etc/logrotate.d/savanna":
        content => $savanna_content,
    }
}
