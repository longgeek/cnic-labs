OpenStack-Source-Puppet-Install-Folsom
======================================

用 Puppet 方式来安装 OpenStack Folsom，网络使用 nova-network
addnodes.py  deb-packages  delnodes.py  eccp.preseed  init_env.sh  install_cobbler_puppet.sh  pip-packages  puppet  README.md

File:
eccp.preseed: ECCP License

Scripts:

addnodes.py: 添加节点
delnodes.py: 删除节点
init_env.sh: 初始化部署服务器基本配置
install_cobbler_puppet.sh: 用来安装部署服务器

Dir:
deb-packages: 内部 apt-get 源
pip-packages: 本地 pipy 库
puppet: puppet master 相关配置文件

<<<<<<< HEAD


=======
>>>>>>> b5918f2d87921a5a754cd092a59f7f0bb79824f7
注意：

在部署节点上安装 nova-control 时候会有冲突：

<<<<<<< HEAD
#apt-get install lvm2
#apt-get install puppet
#vim /etc/puppet/puppet.conf
=======
apt-get install lvm2
apt-get install puppet
vim /etc/puppet/puppet.conf
>>>>>>> b5918f2d87921a5a754cd092a59f7f0bb79824f7
[main]
server=部署节点主机名

[agent]
runinterval=5
<<<<<<< HEAD
#sed -i 's/-q -y/-q -y --force-yes/g' /usr/lib/ruby/1.8/puppet/provider/package/apt.rb
#/etc/init.d/puppet start
装完 Horizon 时候:
#/etc/init.d/puppet stop
#mv /etc/apache2/conf.d/horizon.conf /tmp
#/etc/init.d/apache2 restart
开始安装计算节点,计算节点安装完以后：
#mv /tmp/horizon.conf /etc/apach2/conf.d/
#/etc/init.d/apache2 restart

创建 vm 分配到控制节点时候，会卡在网络，原因是 nova-network 会启动 dnsmasq 进程，而 dnsmasq 进程被部署服务器占用
=======
sed -i 's/-q -y/-q -y --force-yes/g' /usr/lib/ruby/1.8/puppet/provider/package/apt.rb
/etc/init.d/puppet start
装完 Horizon 时候: 
/etc/init.d/puppet stop
mv /etc/apache2/conf.d/horizon.conf /tmp
/etc/init.d/apache2 restart
开始安装计算节点,计算节点安装完以后：
mv /tmp/horizon.conf /etc/apach2/conf.d/
/etc/init.d/apache2 restart
>>>>>>> b5918f2d87921a5a754cd092a59f7f0bb79824f7
