class swift {
    Class["swift"] -> Class["swift::install"] -> Class["swift::config"] -> Class["swift::ring"] -> Class["mount"] -> Class["swift::service"] -> Class["swift::log"]
    include swift, install, config, ring, mount, service, log
}
