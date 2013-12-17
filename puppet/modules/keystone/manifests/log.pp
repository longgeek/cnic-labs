class keystone::log {
    $keystone_content = "/var/log/keystone/*.log {
    daily
    rotate 30
    missingok
    compress
    minsize 100k
    dateext
    copytruncate
    notifempty
}"

    file { "/etc/logrotate.d/keystone":
        content => $keystone_content,
    }
}
