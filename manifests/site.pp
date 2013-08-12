node 'agent.local.com' {
    Class["mysql"] -> Class["keystone"] -> Class["glance"]
	include mysql, keystone, glance
}


$command_path                       = '/usr/local/sbin:/usr/local/bin:/ sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/bin/bash'

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
$keystone_db_user				    = 'keystoneuser'
$keystone_db_name				    = 'keystonename'
$keystone_db_password			    = 'keystonepass'
$keystone_logger_level              = 'DEBUG'
$keystone_logger_handlers           = 'devel,production'

## GLANCE
$glance_db_user                     = 'glanceuser'
$glance_db_name                     = 'glancename'
$glance_db_password                 = 'glancepass'
$glance_source_pack_name            = 'glance.tar.gz'
$glance_client_source_pack_name     = 'python-glanceclient.tar.gz'
$glance_log_verbose                 = 'True'
$glance_log_debug                   = 'True'
$glance_default_store               = 'file'

## AMQP
$rabbit_host                        = '192.168.99.120'
$rabbit_userid                      = 'guest'
$rabbit_password                    = 'guest'

## CINDER
$cinder_db_user                     = 'cinderuser'
$cinder_db_name                     = 'cindername'
$cinder_db_password                 = 'cinderpass'
$cinder_source_pack_name            = 'cinder.tar.gz'
$cinder_client_source_pack_name     = 'python-cinderclient.tar.gz'

## NOVA
$nova_db_user                       = 'novauser'
$nova_db_name                       = 'novaname'
$nova_db_password                   = 'novapass'
$nova_source_pack_name              = 'nova.tar.gz'
$nova_client_source_pack_name       = 'python-novaclient.tar.gz'

## SWIFT
$swift_proxy_host                   = '192.168.99.120'
