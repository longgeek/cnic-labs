class ceilometer-client {
    Class["ceilometer-client"] -> Class["ceilometer-client::install"] -> Class["ceilometer-client::config"] -> Class["ceilometer-client::service"]
    include ceilometer-client, ceilometer-client::install, ceilometer-client::config, ceilometer-client::service
}
