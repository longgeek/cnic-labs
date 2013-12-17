class nova-control {
    Class["nova-control"] -> Class["nova-control::install"] -> Class["nova-control::qemu"] -> Class["nova-control::log"]
    include nova-control, nova-control::install, nova-control::qemu, nova-control::log
}
