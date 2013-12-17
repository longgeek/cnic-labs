class nova-compute {
    Class["nova-compute"] -> Class["nova-compute::install"] -> Class["nova-compute::qemu"] -> Class["nova-compute::log"]
    include nova-compute, nova-compute::install, nova-compute::qemu, nova-compute::log
}
