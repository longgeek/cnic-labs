class nova-control {
    Class["nova-control"] -> Class["nova-control::install"] -> Class["nova-control::qemu"]
    include nova-control, nova-control::install, nova-control::qemu
}
