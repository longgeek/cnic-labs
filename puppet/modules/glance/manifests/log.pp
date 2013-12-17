class glance::log {
    $glance_content = "/var/log/glance/*.log {
    daily
    rotate 30
    missingok
    compress
    minsize 100k
    dateext
    copytruncate
    notifempty
}"

    file { "/etc/logrotate.d/glance":
        content => $glance_content,
    }
}
