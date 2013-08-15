node 'agent.local.com' {
    Class["mysql"] -> Class["rabbitmq"] -> Class["keystone"] -> Class["cinder"] -> Class["nova"] -> Class["glance"] -> Class["horizon"]
	include mysql, rabbitmq, keystone, cinder, nova, glance, horizon
}


$command_path                       = '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/bin/bash'
$source_dir                         = '/opt/stack'
## MYSQL
$mysql_host                         = '127.0.0.1'
$mysql_root_password                = 'password'

## KEYSTONE
$keystone_host                      = '192.168.99.120'
$keystone_source_pack_name	        = 'keystone.tar.gz'
$keystone_client_source_pack_name	= 'python-keystoneclient.tar.gz'
$keystone_apt_requires			    = ["build-essential", "python-dev", "python-setuptools", "python-pip", "libxml2-dev", "libxslt1-dev", "git"]
$admin_token					    = 'admin'
$admin_password                     = 'password'
$service_password                   = 'password'
$service_tenant_name                = 'service'
$keystone_region                    = 'RegionOne'
$email_domain                       = 'cnic.cn'
$keystone_log_verbose			    = 'True'
$keystone_log_debug				    = 'True'
$keystone_db_user				    = 'keystone'
$keystone_db_name				    = 'keystone'
$keystone_db_password			    = 'keystone'
$keystone_logger_level              = 'DEBUG'
$keystone_logger_handlers           = 'devel,production'

## GLANCE
$glance_db_user                     = 'glance'
$glance_db_name                     = 'glance'
$glance_db_password                 = 'glance'
$glance_source_pack_name            = 'glance.tar.gz'
$glance_client_source_pack_name     = 'python-glanceclient.tar.gz'
$glance_log_verbose                 = 'True'
$glance_log_debug                   = 'True'
$glance_default_store               = 'file'
$glance_host                        = '192.168.99.120'

## AMQP
$rabbit_host                        = '192.168.99.120'
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
$cinder_log_debug                   = 'True'
$cinder_volume_format               = 'file'                            # 默认为 'file', 用文件来模拟分区, 设置为 'file'是依赖 '$cinder_volume_size'
                                                                        # 设置为 'disk'时，依赖 '$cinder_volume_disk_part’
$cinder_volume_size                 = '1G'                              # 使用 file 的话需要指定大小, 必须有单位
$cinder_volume_disk_part            = ["sdb1"]                          # 指定 cinder 使用哪些硬盘分区, 例如: "['sdb1', 'sdc1', 'sdd1']"


## NOVA
$nova_db_user                       = 'nova'
$nova_db_name                       = 'nova'
$nova_db_password                   = 'nova'
$nova_source_pack_name              = 'nova.tar.gz'
$nova_client_source_pack_name       = 'python-novaclient.tar.gz'
$nova_novnc_source_pack_name        = 'noVNC.tar.gz'
$nova_apt_requires                  = ["bridge-utils", "kvm", "libvirt-bin", "libvirt-dev", "python-libvirt", "qemu-kvm", "python-numpy", "python-M2Crypto"]
$nova_log_verbose                   = 'True'
$nova_log_debug                     = 'True'
$nova_s3_host                       = '192.168.99.120'
$nova_s3_port                       = '3333'
$nova_my_ip                         = '192.168.99.120'
$nova_metadata_host                 = '192.168.99.120'
$libvirt_type                       = 'kvm'
$libvirt_cpu_mode                   = 'none'
$public_interface                   = 'br100'
$vlan_interface                     = 'eth0'
$flat_network_bridge                = 'br100'
$flat_interface                     = 'eth0'
$fixed_range                        = '10.0.0.0/20'
$ec2_dmz_host                       = '192.168.99.120'
$novncproxy_host                    = '192.168.99.120'
$xvpvncproxy_host                   = '192.168.99.120'
$vncserver_proxyclient_address      = '192.168.99.120'

## HORIZON
$horizon_apt_requires               = ["apache2", "memcached", "python-memcache", "nodejs", "libapache2-mod-wsgi"]
$horizon_source_pack_name           = 'horizon.tar.gz'
$horizon_db_user                    = 'horizon'
$horizon_db_name                    = 'horizon'
$horizon_db_password                = 'horizon'



## SWIFT
$swift_proxy_host                   = '192.168.99.120'
