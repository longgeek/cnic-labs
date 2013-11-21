class keystone {
    Class["keystone"] -> Class["keystone::install"] -> Class["keystone::endpoint"]
    include keystone, keystone::install, keystone::endpoint
}
