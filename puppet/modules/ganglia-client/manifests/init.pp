class ganglia-client {
    Class["ganglia-client"] -> Class["ganglia-client::install"] -> Class["ganglia-client::config"] -> Class["ganglia-client::service"]
    include ganglia-client, ganglia-client::install, ganglia-client::config, ganglia-client::service
}
