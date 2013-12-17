class keystone {
    Class["keystone"] -> Class["keystone::install"] -> Class["keystone::endpoint"] -> Class["keystone::log"]
    include keystone, keystone::install, keystone::endpoint, keystone::log
}
