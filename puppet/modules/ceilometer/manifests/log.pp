class ceilometer::log {
    $ceilometer_content = "/var/log/ceilometer/*.log {
    daily
    rotate 30
    missingok
    compress
    minsize 100k
    dateext
    copytruncate
    notifempty
}"

    file { "/etc/logrotate.d/ceilometer":
        content => $ceilometer_content,
    }
}
