class savanna {
    Class["savanna"] -> Class["savanna::install"] -> Class["savanna::config"] -> Class["savanna::service"]
    include savanna, savanna::install, savanna::config, savanna::service
}
