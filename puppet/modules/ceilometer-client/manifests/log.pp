class ceilometer-client::log {
    $ceilometer-client_content = "/var/log/ceilometer/*.log {
    daily
    rotate 30
    missingok
    compress
    minsize 100k
    dateext
    copytruncate
    notifempty
}"

    file { "/etc/logrotate.d/ceilometer-client":
        content => $ceilometer-client_content,
    }
}
