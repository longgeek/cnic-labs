class nova-compute {
    Class["nova-compute"] -> Class["nova-compute::install"] -> Class["nova-compute::qemu"]
    include nova-compute, nova-compute::install, nova-compute::qemu
}
