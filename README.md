ECCP 自动化部署
======================================

用 **Cobbler** 和 **Puppet** 方式来源码安装 **OpenStack Folsom**.


## 一. 项目结构说明

### File ###

- **eccp.preseed:** *License File.*

### Scripts ###

- **addnodes.py:** *添加节点, 使用 http://you_ip_address:12001 界面添加，或手工执行： python addnodes.py $json_data*
- **delnodes.py:** *删除节点, 功能未完善*
- **init_env.sh:** *初始化部署服务器基本配置*
- **install_cobbler_puppet.sh:** *用来安装部署服务器, 依赖网络配置、hostname、gateway、dns、/opt/ 下的 Ubuntu ISO 文件.*

### Dirs ###

- **puppet: ** *puppet master 相关配置文件*
- **eccp-web:** *eccp 物理资源 php 代码*
- **deb-packages: ** *内部 apt-get 源*
- **pip-packages: ** *本地 pipy 库*

- - -


## 二. How to use?

### Requires

1. **干净的 Ubuntu-12.04.2-Server 或 Desktop 系统机器一台**

2. **设置 eth0 的网络，dns-nameservers 指向自己，gateway 不能指向自己.**

    `# vim /etc/network/interfaces`
 
		auto eth0
		iface eth0 inet static
			address 172.16.0.222
			netmask 255.255.0.0
			gateway 172.16.0.1
			dns-nameservers 172.16.0.222 8.8.8.8
	`# /etc/init.d/networking restart`
 
3. **设置主机名 FQDN.**
	
	`# hostname server.local.com`
	
	`# sysctl -w kernel.hostname=server.local.com`
	
	`# echo server.local.com > /etc/hostname`
	
	`# echo '172.16.0.222  server.local.com' >> /etc/hosts`
	
4. **拷贝 Ubuntu-12.04.2-Server ISO 到系统 ／opt 目录下**

	`# ls /opt`
	
		ubuntu-12.04.2-server-amd64.iso

5. **下载安装代码模块**
	
    `# git clone git clone http://192.168.64.250/eccp.git /opt/eccp`
    
    `# cd /opt/eccp/eccp_auto_install`
    
    *用脚本自动安装 Cobbler 和 Puppet，两分钟左右就可以安装完：*
    *默认所有节点的 root 密码为 eccp，修改请编辑 install_cobbler_puppet.sh*
        
    `# vim install_cobbler_puppet.sh`
    
		ROOT_PASSWORD='changeit' 
		
	`# sh install_cobbler_puppet.sh`
    
### Access

*安装完后有两个界面：*


- **Cobbler Web:** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<http://172.16.0.222:12001> 用来管理 Cobbler。
- **Eccp Deploy Web:** &nbsp;<http://172.16.0.222:12002> 界面方式添加节点来实现自动化部署。


## How to Configure?

** 执行完 `install_cobbler_puppet.sh` 并通过 Eccp Web 添加节点后，可能根据不同的需求来做一些配置。可以通过修改 `/etc/puppet/manifests/site.pp ` 来修改：**

	import 'nodes/*'

	##BASE
	$command_path                       = '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/bin/bash'     ＃ puppet 里执行命令的 path
	
	$source_dir                         = '/opt/stack'    ＃ 所有要部署的机器上要安装源码包的存放位置
	$source_apt_requires                = ["build-essential", "python-dev", "python-setuptools", "python-pip", "libxml2-dev", "libxslt1-dev", "git", "python-numpy"]
	
	$all_nodes_list                     = "control.local.com"   ＃ 列出了所有的节点

	## MYSQL
	$mysql_host                         = "control.local.com"   ＃ mysql 节点的主机名
	$mysql_root_password                = 'csdb123cnic'         ＃ mysql root 的密码

	## KEYSTONE
	$keystone_host                      = "control.local.com"   ＃ keystone 节点的主机名
	$keystone_source_pack_name          = 'keystone.tar.gz'     ＃ keystone 源码包名字
	$keystone_client_source_pack_name   = 'python-keystoneclient.tar.gz'  ＃ keystone－client 包名字
	$admin_token                        = 'admin'               ＃ token
	$admin_password                     = 'password'            ＃ admin 用户密码
	$service_password                   = 'password'            ＃ service 服务的密码
	$service_tenant_name                = 'service'             ＃ service tenant 名字
	$keystone_region                    = 'RegionOne'           ＃ keystone 的 region
	$email_domain                       = 'cnic.cn'             ＃ endpoint 里用到的域名后缀
	$keystone_log_verbose               = 'True'                ＃ keystone 日志 verbose 是否开启
	$keystone_log_debug                 = 'True'                ＃ keystone 日志 debug 是否开启
	$keystone_db_user                   = 'keystone'            ＃ keystone 的 mysql 用户名
	$keystone_db_name                   = 'keystone'            ＃ keystone 的 mysql 库名
	$keystone_db_password               = 'keystone'            ＃ keystone 的 mysql 用户密码
	$keystone_logger_level              = 'DEBUG'              
	$keystone_logger_handlers           = 'devel,production'

	## GLANCE
	$glance_host                        = "control.local.com"   ＃ glance 节点的主机名
	$glance_db_user                     = 'glance'              ＃ glance 的 mysql 用户名
	$glance_db_name                     = 'glance'              ＃ glance 的 mysql 库名
	$glance_db_password                 = 'glance'              ＃ glance 的 mysql 用户密码
	$glance_source_pack_name            = 'glance.tar.gz'       ＃ glance 源码包名字
	$glance_client_source_pack_name     = 'python-glanceclient.tar.gz'
	$glance_log_verbose                 = 'True'
	$glance_log_debug                   = 'True'                ＃ log 的 verbose、debug 信息是否开启
	$glance_default_store               = 'file'                ＃ 默认 file 存储
  
	## RABBITMQ
	$rabbit_host                        = "control.local.com"   ＃ rabbit 节点主机名
	$rabbit_userid                      = 'guest'               ＃ rabbit 用户名
	$rabbit_password                    = 'longgeek'            ＃ rabbit 用户密码
	
	## CINDER
    $cinder_host                        = "control.local.com"   ＃ cinder 节点的主机名
    $cinder_db_user                     = 'cinder'              ＃ cinder 的 mysql 用户名
    $cinder_db_name                     = 'cinder'              ＃ cinder 的 mysql 库名
    $cinder_db_password                 = 'cinder'              ＃ cinder 的 mysql 用户密码
    $cinder_source_pack_name            = 'cinder.tar.gz'       ＃ cinder 的 源码包名字
    $cinder_client_source_pack_name     = 'python-cinderclient.tar.gz'
    $cinder_volume_group                = 'cinder-volumes'      ＃ cinder 的 逻辑卷组名字
    $cinder_log_verbose                 = 'True'                
    $cinder_log_debug                   = 'True'
    $cinder_volume_format               = "glusterfs"           ＃ 使用 glusterfs 做后端存储
    $cinder_volume_size                 = '5G'               ＃ 当 volume_format = 'file' 时 cinder-volumes size
    
    $cinder_volume_disk_part            = '["sdc1"]'            # 当 volume_format = 'disk' 时，cinder-volumes 所使用的磁盘分区是？

    ## NOVA
    $nova_db_user                       = 'root'                ＃ nova 的 mysql 用户名
    $nova_db_name                       = 'nova'                ＃ nova 的 mysql 库名
    $nova_db_password                   = $mysql_root_password  ＃ nova 的 mysql 用户密码
    $nova_source_pack_name              = 'nova.tar.gz'         ＃ nova 源码包名字
    $nova_client_source_pack_name       = 'python-novaclient.tar.gz'
    $nova_novnc_source_pack_name        = 'noVNC.tar.gz'
    $nova_apt_requires                  = ["bridge-utils", "python-m2crypto", "dnsmasq-utils"]
    $nova_log_verbose                   = 'True'
    $nova_log_debug                     = 'True'                ＃ log 
    $nova_my_ip                         = "172.16.0.201"        ＃ nova 控制器的 IP 地址
    $nova_api_host                      = "control.local.com"   ＃ nova－api 所在的节点
    $nova_s3_host                       = $nova_my_ip           
    $nova_s3_port                       = '3333'
    $nova_metadata_host                 = $nova_my_ip
    $libvirt_type                       = 'qemu'                ＃ libvirt 类型
    $libvirt_cpu_mode                   = 'none'
    $libvirt_version                    = '1.0.5.5'             ＃ 升级的时候需要更改成相应版本号
    $public_interface                   = 'br100'               
    $vlan_interface                     = 'eth0'
    $flat_network_bridge                = 'br100'
    $flat_interface                     = 'eth0'                ＃ 网络设置
    $fixed_range                        = '10.0.0.0/8'
    $floating_range                     = '192.168.99.32/27'
    $network_size                       = '65535'
    $ec2_dmz_host                       = $nova_my_ip
    $novncproxy_host                    = $nova_my_ip
    $xvpvncproxy_host                   = $nova_my_ip
    $vncserver_proxyclient_address      = $nova_my_ip
    $qemu_version                       = '1.5.3'               ＃ 升级 qemu 版本需要修改成相应版本号
    $nova_control_network               = 'True'                ＃ nova 控制器上的 nova－network 是否启动
    $nova_control_compute               = 'True'                ＃ nova 控制器上的 nova－compute 时候启动
       
    ## HORIZON
    $horizon_apt_requires               = ["apache2", "memcached", "python-memcache", "nodejs", "libapache2-mod-wsgi"]
    $horizon_source_pack_name           = 'horizon.tar.gz'      ＃ horizon 源码包名
    $horizon_db_user                    = 'horizon'             ＃ horizon 的 mysql 用户名
    $horizon_db_name                    = 'horizon'             ＃ horizon 的 mysql 库名
    $horizon_db_password                = 'horizon'             ＃ horizon 的 mysql 用户密码
    $memcache_host                      = "control.local.com"   ＃ memcache 所在节点主机名
    $savanna_host                       = "control.local.com"   ＃ savanna 所在节点主机名

    ## MONITOR
    $monitor_db_name                    = 'monitor'             ＃ kanyun 依赖的数据库
    $monitor_db_user                    = 'monitor'
    $monitor_db_password                = 'monitor'
    $ceilometer_api_host                = "control.local.com"   ＃ ceilometer-api 所在节点主机名

    ## SWIFT
    $swift_proxy_host                   = "control.local.com"   ＃ swift 节点所在主机名
    $swift_devices                      = "$source_dir/data/swift"  ＃ swift 所使用的设备
    $swift_version                      = 'grizzly'             ＃ swift 使用的版本
    $gluster_swift_version              = $swift_version        ＃ gluster－swift 组件的版本和 swift 必须一致

    ## GLUSTERFS
    $glusterfs_version                  = '3.4.0'               ＃ glusterfs 源码包的版本
    $glusterfs_nodes_list               = "172.16.0.201"        ＃ glusterfs 集群所有节点列表
    
    
**后缀为 _ requires、 _ host、 _ list 不可以更改其的值。后缀为: _version 项用来做源码包版本的控制**

- - -
    
    
## 三. How to Upgrade？

*由于 ECCP 项目统一采用源码包方式安装，故所有的组件包都用 .tar.gz 方式打包.*

### 脚本自动打包

#####*更新代码到最新版本*

	# cd /opt/eccp
	# git checkout master
	# git pull
	# sh eccp_auto_install/create_tar.sh
	
*执行 create_tar.sh 后，会自动把生成的 tar 包拷贝到 /opt/eccp/eccp_auto_install/puppet/files/目录中.*
*把 create_tar.sh 生成的代码 tar 包经过本地环境测试无误后，拷贝到部署服务器上的 /etc/puppet/files 目录中，相关节点会自动升级包.*

#####** Create_tar.sh 脚本支持升级的模块：**

- nova
- cinder
- glance
- keystone
- horizon
- noVNC
- savanna
- ceilometer
- openstack_auth
- ganglia-webfrontend
- python-ceilometerclient
- python-cinderclient
- python-glanceclient
- python-keystoneclient
- python-novaclient
- python-navigatorclient

### 手工打包

#####** 涉及手工打包的模块有：**

*下面的模块在打包后，需要更改 /etc/puppet/manifests/site.pp 文件中对应包 _version 项的版本号*

- swift
- glusterfs
- gluster-swift
- libvirt
- qemu

*下载包：*

	# git clone https://github.com/openstack/swift.git && tar zcf swift.tar.gz swift/
	# wget http://download.gluster.org/pub/gluster/glusterfs/3.4/3.4.1/glusterfs-3.4.1.tar.gz
	# git clone https://github.com/gluster/gluster-swift.git && tar zcf gluster-swift.tar.gz gluster-swift
	# wget http://libvirt.org/sources/libvirt-1.2.0.tar.gz
		  	
*手工本地编译安装 Qemu 启用 glusterfs、iscsi 和 spice 协议：*

    # wget http://wiki.qemu-project.org/download/qemu-1.7.0.tar.bz2
    # apt-get install libglib2.0-dev libsdl1.2-dev libpcap-dev autoconf libtool open-iscsi-utils \
                      xsltproc python-pyparsing libnss3 libnss3-dev libpixman-1-dev libsasl2-dev \
                      libpixman-1-dev libjpeg-dev libsasl2-dev libnss3-dev unzip bc
	# tar jxvf qemu-1.7.0.tar.bz2
	# cd qemu-1.7.0
	# ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc \
	              --enable-glusterfs --enable-libiscsi --enable-spice
	# make && make install

*编译完 qemu 后：*

	# mkdir ./qemu-1.7.0/{etc,usr} -p
	# mkdir ./qemu-1.7.0/usr/{bin,share} -p
	# cp -r /etc/{bash_completion.d,qemu} ./qemu-1.7.0/etc/
	# cp -rp /usr/bin/*qemu* ./qemu-1.7.0/usr/bin/
	# cp -r /usr/share/qemu ./qemu-1.7.0/usr/share/
	# zip -r qemu-1.7.0.zip ./qemu-1.7.0/
	# cp qemu-1.7.0.zip /etc/puppet/files/

*修改 /etc/puppet/manifests/site.pp 文件中的相关版本控制：*

	# vim /etc/puppet/manifests/site.pp
     	$libvirt_version = '1.2.0'
    	$swift_version = 'havana'
    	$glusterfs_version = '3.4.1'
    	$qemu_version = '1.7.0'
	# cp *.tar.gz /etc/puppet/files/

### Horizon Update
**horizon 在修改 settings.py 后需要做手工操作：**

1. cd auto_install_eccp/puppet/modules/horizon/templates/
2. 手工修改 savanna.settings.py.erb 和 settings.py.erb 到最新版本。

### License Update

*拷贝新的 eccp.license 文件到部署服务器上的 /etc/puppet/files/ 目录中*

- - -

## 四. Check The Installation Results

*查看部署节点的 /var/log/syslog, 下面显示有四个节点都执行完相应的 puppet 模块, control、compute-01 - 04：*

    Dec  9 03:58:41 (//control.local.com/Puppet) Finished catalog run in 0.02 seconds
    Dec  9 03:58:44 Compiled catalog for server.local.com in environment production in 0.01 seconds
    Dec  9 03:58:44 (//compute-01.local.com/Puppet) Finished catalog run in 0.02 seconds
    Dec  9 03:58:48 Compiled catalog for server.local.com in environment production in 0.01 seconds
    Dec  9 03:58:48 (//compute-02.local.com/Puppet) Finished catalog run in 0.08 seconds
    Dec  9 03:58:52 Compiled catalog for server.local.com in environment production in 0.01 seconds
    Dec  9 03:58:52 (//compute-03.local.com/Puppet) Finished catalog run in 0.03 seconds
    Dec  9 03:58:56 Compiled catalog for server.local.com in environment production in 0.01 seconds
    Dec  9 03:58:56 (//compute-04.local.com/Puppet) Finished catalog run in 0.03 seconds
    Dec  9 03:59:00 Compiled catalog for server.local.com in environment production in 0.01 seconds
    Dec  9 03:59:00 (//control.local.com/Puppet) Finished catalog run in 0.03 seconds
    Dec  9 03:59:04 Compiled catalog for server.local.com in environment production in 0.01 seconds
    Dec  9 03:59:04 (//compute-01.local.com/Puppet) Finished catalog run in 0.08 seconds
    Dec  9 03:59:08 Compiled catalog for server.local.com in environment production in 0.05 seconds
    Dec  9 03:59:08 (//compute-02.local.com/Puppet) Finished catalog run in 0.03 seconds
    Dec  9 03:59:12 Compiled catalog for server.local.com in environment production in 0.01 seconds
    Dec  9 03:59:12 (//compute-03.local.com/Puppet) Finished catalog run in 0.03 seconds
    Dec  9 03:59:16 Compiled catalog for server.local.com in environment production in 0.01 seconds
    Dec  9 03:59:16 (//compute-04.local.com/Puppet) Finished catalog run in 0.03 seconds

*或者登录安装的节点查看 /var/log/syslog 相应服务端口。*

- - -

## 五. Puppet Module Description

- bases

		同步所有节点的 /etc/hosts 记录文件, 执行 addnodes.py 会自动给每个节点添加 bases 模块
		
- all-sources

		用来只安装不配置大部分的源码包，解决了把组件分布式后带来的依赖问题。根据 site.pp 中定义的 $source_dir 为源码包存放的路径
		
- mysql

		用来安装 mysql 服务，以及根据 /etc/puppet/manifests/site.pp 文件中指定的 nova、glance、keystone、cinder 等的 DB 信息，来创建数据库并授权。其 root 的密码也在 site.pp 中。启动的端口为 3306

- rabbitmq

		安装 rabbitmq 服务，并根据 site.pp 中指定的用户名和密码设置。启动的端口为 5672
		
- keystone

		配置 keystone 服务，创建基础用户、角色、租户、服务、endpoint。配置文件目录为 /etc/keystone/，log 文件在 /var/log/keystone/ 下。keystone 启动的端口为 5000、35357.
		查看相关信息：
		＃ source /etc/profile
		＃ keystone user-list
		＃ keystone role-list
		＃ keystone tenant-list
		＃ keystone endpoint-list
		重启服务
		＃ /etc/init.d/keystone restart
		
- glance

		配置 glance 服务，并判断集群如果中使用了 glusterfs 分布式文件系统的话，会自动挂载 glusterfs volume，并把 glance 的镜像保存在 glusterfs 的 volume 中。
		默认会上传一个 cirros 镜像，glance 的配置文件在 /etc/glance/ 目录中，log 在 /var/log/glance/ 下，glance 启动的端口为 9191、9292
		查看镜像
		＃ source /etc/profile
		＃ glance image-list
		重启服务
		＃ /etc/init.d/glance-api restart
		＃ /etc/init.d/glance-registry restart
		
- cinder

		配置 cinder 服务，自动判断后端存储。配置文件目录在 /etc/cinder/, log 在 /var/log/cinder/ 中，启动的端口为 8776
		在 site.pp 中 $cinder_volume_format 的值有三种: 
		file: 会 dd 一个文件做 cinder 的逻辑卷
		disk: 使用 $cinder_volume_disk_part 指定的磁盘分区创建 cinder-volumes
		glusterfs: 自动挂载 glusterfs volume，使用 glusterfs 做 cinder 后端存储
		查看：
		＃ source /etc/profile/
		# cinder list
		重启服务
		# /etc/init.d/cinder-api restart
		# /etc/init.d/cinder-volume restart
		# /etc/init.d/cinder-scheduler restat
		
- nova-control

		nova 控制器模块，包含了 nova-api、nova-cert、nova-scheduler、nova-console、nova-consoleauth、nova-vncproxy、nova-xvpvncproxy、nova-network、nova-compute、libvirt-bin 服务。
		配置文件在 /etc/nova 目录下，log 文件在 /var/log/nova 中，instances 数据在 $source_dir/data/nova 目录中.
		启动的端口有 8773、8774、8775、6080、6081
		服务启动脚本都在 /etc/init.d/ 目录中
		常用命令:
		# nova-manager service list
		# nova-manager floating list
		# nova-manager fixed list
		# source /etc/profile
		# nova list
		# nova show $vm_name
		
- nova-compute

		nova 计算节点模块，只包含 nova-network、nova-compute、nova-metadata-api、libvirt-bin 服务。
		配置文件在 /etc/nova 目录下，log 文件在 /var/log/nova 中，instances 数据在 $source_dir/data/nova 目录中.
		启动的端口 8775
		服务启动脚本在 /etc/init.d/ 目录中
		
- ceilometer

		ceilometer 主节点模块上面运行了 mongodb、ceilometer-collector、ceilometer-agent-central、ceilometer-agent-compute、ceilometer-api、ceilometer-alarm-notifier、ceilometer-alarm-singleton 服务。
		配置文件在 /etc/ceilometer 目录，log 日志文件在 /var/log/ceilometer/ 目录下。
		启动的端口有: 8777
		
- ceilometer-client

		ceilometer 客户端节点模块，默认会给集群中所有节点都安装这个模块，同时这个模块在 eccp web 中不显示.
		配置文件在 /etc/ceilometer 目录，log 日志文件在 /var/log/ceilometer/ 目录下。
		只包含一个 ceilometer-agent-compute 服务，启动的端口为：
		同时它会自动判断自己服务的状态，如果发现僵死等情况会自动重启服务。
		
- ganglia

		ganglia 模块运行了两个服务: gmetad、ganglia-monitor，监听端口为 8649、8651、8652. 默认会在 horizon 模块所在节点上安装，在 eccp web 界面上不显示。（ganglia-webfrontend 这个包用来在 web 展示，故 ganglia 必须和 horizon 安装在一个节点）。
		ganglia 配置文件在 /etc/ganglia/。
		服务脚本：
		# /etc/init.d/gmead restart
		# /etc/init.d/ganglia-monitor restart
		
- ganglia-client 

		ganglia 客户端模块只运行了一个 ganglia-monitor 服务，监听端口为 8649。ganglia-client 模块像 ceilometer-client 模块安装在除 ganglia|horizon 节点的其它所有节点上。同时也像 ganglia、ceilometer-client 模块一样无法在界面选择.
		其配置文件在 /etc/ganglia/ 目录中
		服务脚本：
		# /etc/init.d/ganglia-monitor restart
		
- horizon

		horizon 模块默认基于 apache2 ，端口为 80。同时 horizon 模块所在节点默认安装了 ganglia 模块。
		horizon 配置文件在 $source_dir/horizon/openstack_dashboard/settings.py
		apache2 的配置文件在 /etc/apache2/conf.d/horizon.conf
		log 文件在 /var/log/apache2/horizon_{access，error}.log
		服务脚本：
		＃ /etc/init.d/apache2 restart
		
- glusterfs

		glusterfs 模块主要用来自动添加 glusterfs-client 模块节点到 glusterfs 集群中，同时自动创建四个 glusterfs volume，eccp-nova、eccp-cinder、eccp-glance、eccp-swift，分别给 nova、cinder、glance、swift 做后端存储，实现了集群统一存储。
		默认 glusterfs 副本为 2 份，可以自动扩展 glustefs 节点数和自动扩展 volume 的 brick 数。
		glusterfs 启动的端口为：
		配置文件在 /etc/glusterfs/，log 文件在 /var/log/glusterfs/
		服务脚本：
		＃ /etc/init.d/glusterfs restart
		常用命令：
		＃ glusterfs peer status
		＃ glusterfs volume info
		
- glusterfs-client

		glusterfs-client 模块用来安装 glusterfs 并启动服务，等待 glusterfs 模块所在节点添加自己到集群中。
		glusterfs 启动的端口为：
		配置文件在 /etc/glusterfs/，log 文件在 /var/log/glusterfs/
		服务脚本：
		＃ /etc/init.d/glusterfs restart
		常用命令：
		＃ glusterfs peer status
		＃ glusterfs volume info
		
- savanna

		savanna 模块用来启动一个 savanna-api 服务，监听端口为 8386，配置文件在 /etc/savanna/ 下，log 在 /var/log/savanna/ 下。
		＃ /etc/init.d/savanna-api restart
		
- swift 

		swift 模块用来安装 swift 分布式对象存储，默认安装了 proxy、account、container、object 服务，默认使用了 Glusterfs 做 Swift 的后端存储，故备份次数为一。
		监听端口有：8080、6010、6011、6012，配置文件在 /etc/swift/ ，log 在 /var/log/swift/。
		启动服务：
		# swift-init main restart
		
**打包完要更新的包后，务必在本地环境内测试通过后，拷贝到线上环境的 Puppet 部署服务器中的 /etc/puppet/files/ 目录中**

- - -

## 六. NOTE
		
###界面使用注意事项

1. 主机名框必须是 FQDN （主机名 + 域名）
2. 部署和立即部署按钮会自动让有远控卡信息的机器临时从 PXE 启动一次来安装操作系统，不要频繁点击这两个按钮。
3. 更改任何信息项后，先点击保存按钮
4. 添加一个节点后，点击保存按钮保存数据，在点击部署按钮来检查输入信息是否有误，无误既开始部署。当添加完所有节点后必须点击一次立即部署按钮。
5. 没有远控卡的机器需要人工让机器从 PXE 启动。
6. 点击部署或立即部署按钮后，请耐心等待页面。


### 部署服务器上运行 Nova 控制器

1. 在界面添加控制节点为部署节点时候，不必填写远控卡信息，否则会重启机器。
2. 创建 vm 分配到控制节点时候，会卡在网络，原因是 nova-network 会启动 dnsmasq 进程，而 dnsmasq 进程被部署服务器占用。

