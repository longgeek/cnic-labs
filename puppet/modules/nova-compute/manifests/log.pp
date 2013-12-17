class nova-compute::log {
    $nova-compute_content = "/var/log/nova/*.log {
    daily
    rotate 30
    missingok
    compress
    minsize 100k
    dateext
    copytruncate
    notifempty
}"

    file { "/etc/logrotate.d/nova-compute":
        content => $nova-compute_content,
    }
}
