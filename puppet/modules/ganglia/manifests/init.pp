class ganglia {
    Class["ganglia"] -> Class["ganglia::install"] -> Class["ganglia::config"] -> Class["ganglia::service"]
    include ganglia, ganglia::install, ganglia::config, ganglia::service
}
