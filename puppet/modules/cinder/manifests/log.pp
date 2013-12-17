class cinder::log {
    $cinder_content = "/var/log/cinder/*.log {
    daily
    rotate 30
    missingok
    compress
    minsize 100k
    dateext
    copytruncate
    notifempty
}"

    file { "/etc/logrotate.d/cinder":
        content => $cinder_content,
    }
}
