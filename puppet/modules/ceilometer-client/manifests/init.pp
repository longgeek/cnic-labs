class ceilometer-client {
    Class["ceilometer-client"] -> Class["ceilometer-client::install"] -> Class["ceilometer-client::config"] -> Class["ceilometer-client::service"] -> Class["ceilometer-client::log"]
    include ceilometer-client, ceilometer-client::install, ceilometer-client::config, ceilometer-client::service, ceilometer-client::log
}
