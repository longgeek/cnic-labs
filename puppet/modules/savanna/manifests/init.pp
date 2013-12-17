class savanna {
    Class["savanna"] -> Class["savanna::install"] -> Class["savanna::config"] -> Class["savanna::service"] -> Class["savanna::log"]
    include savanna, savanna::install, savanna::config, savanna::service, savanna::log
}
