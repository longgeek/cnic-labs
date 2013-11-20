class ceilometer {
    Class["ceilometer"] -> Class["ceilometer::install"] -> Class["ceilometer::config"] -> Class["ceilometer::service"]
    include ceilometer, ceilometer::install, ceilometer::config, ceilometer::service
}
