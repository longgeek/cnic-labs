class swift::log {
    $swift_content = "/var/log/swift/*.log {
    daily
    rotate 30
    missingok
    compress
    minsize 100k
    dateext
    copytruncate
    notifempty
}"

    file { "/etc/logrotate.d/swift":
        content => $swift_content,
    }
}
