class ceilometer {
    Class["ceilometer"] -> Class["ceilometer::install"] -> Class["ceilometer::config"] -> Class["ceilometer::service"] -> Class["ceilometer::log"]
    include ceilometer, ceilometer::install, ceilometer::config, ceilometer::service, ceilometer::log
}
