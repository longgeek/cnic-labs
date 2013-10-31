class swift {
    Class["swift"] -> Class["swift::swift-install"] -> Class["swift::gluster-swift-install"] -> Class["swift::config"] -> Class["swift::service"]
    include swift, swift-install, gluster-swift-install, config, service
}
