class ganglia {
    Class["ganglia"] -> Class["ganglia::install"] -> Class["ganglia::config"] -> Class["ganglia::service"] -> Class["ganglia::client"]
    include ganglia, ganglia::install, ganglia::config, ganglia::service, ganglia::client
}
