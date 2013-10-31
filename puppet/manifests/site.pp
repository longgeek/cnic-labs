import 'nodes/*'


$command_path                       = '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/bin/bash'
$source_dir                         = '/opt/stack'
$source_apt_requires                = ["build-essential", "python-dev", "python-setuptools", "python-pip", "libxml2-dev", "libxslt1-dev", "git", "python-numpy"]
## MYSQL
$mysql_host                         = '%mysql%'
$mysql_root_password                = 'csdb123cnic'

## KEYSTONE
$keystone_host                      = '%keystone%'
$keystone_source_pack_name          = 'keystone.tar.gz'
$keystone_client_source_pack_name   = 'python-keystoneclient.tar.gz'
$admin_token                        = 'admin'
$admin_password                     = 'password'
$service_password                   = 'password'
$service_tenant_name                = 'service'
$keystone_region                    = 'RegionOne'
$email_domain                       = 'cnic.cn'
$keystone_log_verbose               = 'True'
$keystone_log_debug                 = 'False'
$keystone_db_user                   = 'keystone'
$keystone_db_name                   = 'keystone'
$keystone_db_password               = 'keystone'
$keystone_logger_level              = 'DEBUG'
$keystone_logger_handlers           = 'devel,production'

## GLANCE
$glance_db_user                     = 'glance'
$glance_db_name                     = 'glance'
$glance_db_password                 = 'glance'
$glance_source_pack_name            = 'glance.tar.gz'
$glance_client_source_pack_name     = 'python-glanceclient.tar.gz'
$glance_log_verbose                 = 'True'
$glance_log_debug                   = 'False'
$glance_default_store               = 'file'
$glance_host                        = '%glance%'

## AMQP
$rabbit_host                        = '%rabbit%'
$rabbit_userid                      = 'guest'
$rabbit_password                    = 'longgeek'

## CINDER
$cinder_db_user                     = 'cinder'
$cinder_db_name                     = 'cinder'
$cinder_db_password                 = 'cinder'
$cinder_source_pack_name            = 'cinder.tar.gz'
$cinder_client_source_pack_name     = 'python-cinderclient.tar.gz'
$cinder_volume_group                = 'cinder-volumes'
$cinder_log_verbose                 = 'True'
$cinder_log_debug                   = 'False'
$cinder_volume_format               = 'file'                            # 默认为 'file', 用文件来模拟分区, 设置为 'file'是依赖 '$cinder_volume_size'
                                                                        # 设置为 'disk'时，依赖 '$cinder_volume_disk_part’
$cinder_volume_size                 = '5G'                              # 使用 file 的话需要指定大小, 必须有单位
$cinder_volume_disk_part            = '["sdb1"]'                          # 指定 cinder 使用哪些硬盘分区, 例如: "['sdb1', 'sdc1', 'sdd1']"


## NOVA
$nova_db_user                       = 'root'
$nova_db_name                       = 'nova'
$nova_db_password                   = 'csdb123cnic'
$nova_source_pack_name              = 'nova.tar.gz'
$nova_client_source_pack_name       = 'python-novaclient.tar.gz'
$nova_novnc_source_pack_name        = 'noVNC.tar.gz'
#$nova_apt_requires                  = ["bridge-utils", "kvm", "libvirt-bin", "libvirt-dev", "python-libvirt", "qemu-kvm", "python-m2crypto", "dnsmasq-utils"]
$nova_apt_requires                  = ["bridge-utils", "kvm", "qemu-kvm", "python-m2crypto", "dnsmasq-utils"]
$nova_log_verbose                   = 'True'
$nova_log_debug                     = 'False'
$nova_my_ip                         = '%nova%'
$nova_s3_host                       = $nova_my_ip
$nova_s3_port                       = '3333'
$nova_metadata_host                 = $nova_my_ip
$libvirt_type                       = 'qemu'
$libvirt_cpu_mode                   = 'none'
$libvirt_version                    = '1.0.5.5'
$public_interface                   = 'br100'
$vlan_interface                     = 'eth0'
$flat_network_bridge                = 'br100'
$flat_interface                     = 'eth0'
$fixed_range                        = '10.0.0.0/8'
$floating_range                     = '192.168.99.32/27'
$network_size                       = '65535'
$ec2_dmz_host                       = $nova_my_ip
$novncproxy_host                    = $nova_my_ip
$xvpvncproxy_host                   = $nova_my_ip
$vncserver_proxyclient_address      = $nova_my_ip

## HORIZON
$horizon_apt_requires               = ["apache2", "memcached", "python-memcache", "nodejs", "libapache2-mod-wsgi"]
$horizon_source_pack_name           = 'horizon.tar.gz'
$horizon_db_user                    = 'horizon'
$horizon_db_name                    = 'horizon'
$horizon_db_password                = 'horizon'

## MONITOR
$monitor_db_name                    = 'monitor'
$monitor_db_user                    = 'monitor'
$monitor_db_password                = 'monitor'

## SWIFT
$swift_proxy_host                   = $nova_my_ip
$swift_devices                      = "$source_dir/data/swift"
$swift_version                      = 'grizzly'
$gluster_swift_version              = $swift_version

## GLUSTERFS
$glusterfs_version                  = '3.4.0'
$glusterfs_nodes_list               = '172.16.0.201 172.16.0.202'
