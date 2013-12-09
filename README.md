OpenStack-Source-Puppet-Install-Folsom
======================================

用 **Cobbler** 和 **Puppet** 方式来源码安装 **OpenStack Folsom**，网络使用 *nova-network*.

## 一. 项目结构说明

### File ###

- **eccp.preseed:** *License File.*

### Scripts ###

- **addnodes.py:** *添加节点, 使用 http://you_ip_address:11111 界面添加，或手工执行： python addnodes.py $json_data*
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

1. **干净的 Ubuntu－12.04.2－Server 或 Desktop 系统**

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
    
    *用脚本自动安装 Cobbler 和 Puppet，两分钟左右就可以安装完了：*
    
    `# sh install_cobbler_puppet.sh`
    
### Access

*安装完后有两个界面：*


- **Cobbler Web:** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<http://172.16.0.222:12001>
- **Eccp Deploy Web:** &nbsp;<http://172.16.0.222:12002>


    
## 三. How to Upgrade？

*由于 ECCP 项目统一采用源码包方式安装，故所有的组件包都用 .tar.gz 方式打包.*

### 脚本自动打包

#####*更新代码到最新版本*

	# cd /opt/eccp
	# git checkout master
	# git pull
	# sh eccp_auto_install/create_tar.sh
	
*执行 create_tar.sh 后，会自动把生成的 tar 包拷贝到 /opt/eccp/eccp_auto_install/puppet/files/目录中.*
*把 create_tar.sh 生成的代码 tar 包经过本地环境测试无误后，拷贝到部署服务器上的 /etc/puppet/files 目录中，相关节点会自动升级包*

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
	
*修改 /etc/puppet/manifests/site.pp 文件中的相关版本控制：*

	# vim /etc/puppet/manifests/site.pp
	$libvirt_version = '1.2.0'
	$swift_version = 'havana'
	$glusterfs_version = '3.4.1'
	$qemu_version = '1.7.0'
	# cp *.tar.gz /etc/puppet/files/
		  	
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

待续...




注意：

创建 vm 分配到控制节点时候，会卡在网络，原因是 nova-network 会启动 dnsmasq 进程，而 dnsmasq 进程被部署服务器占用
