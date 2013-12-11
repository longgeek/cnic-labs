#!/use/bin/env python
# -*- coding: utf-8 -*-

"""用来修改 DNS、DHCP、PUPPET、COBBLER 配置文件.

需要和前端页面的配合，用户通过页面输入节点相关信息，前端自动生成 Json 数据.
并调用本程序，来达到把节点信息写入到相关配置文件中，实现自动化部署.

"""

__version__ = '0.1'
__author__ = [
    "Longgeek <longgeek@gmail.com>",
]

import os
import sys
import re
import time

if len(sys.argv) != 2:
    print '{"return": 0, "type": 1, "data": {"message": "Missing or extra positional parameters!"}}'
    exit(1)

# 主要修改的几个配置文件路径
dns_conf = "/var/lib/cobbler/cobbler_hosts"
dhcp_hosts_conf = "/etc/dnsmasq.d/hosts.conf"
puppet_site = "/etc/puppet/manifests/site.pp"
puppet_hosts = "/etc/puppet/modules/bases/templates/hosts.erb"
power_type = ['ilo', 'ipmilan', 'ipmitool', 'rsa', 'ipmi']
glusterfs_list = []
all_nodes_list = []

def write_conf(data):

    """本函数通过传递参数来添加节点相关的信息，来修改 DNS、DHCP、PUPPET 和 Cobbler 配置文件."""
    
    # 检查 type 是否为空
    for node_info in data:
        if node_info['type'] == []:
            print '{"return": 0, "type": 1, "data": {"message": "%s 节点没有选择要安装的角色"}}' % node_info['ip']
            exit(1)

    # 去掉重复的 ip 或 hostname 或 mac
    for node_info in data:
        for i in [node_info["ip"], node_info["hostname"], node_info["mac"]]:
            for j in [dns_conf, dhcp_hosts_conf, puppet_hosts]:
                os.system("sed -i '/%s/d' %s" % (i, j))

        # 去掉重复的 cobbler system
        cobbler_system_list = os.popen("cobbler system list | awk '{print $1}'").read().rstrip().split("\n")
        if cobbler_system_list != ['']:
            for system in cobbler_system_list:
                system_file = open("/var/lib/cobbler/config/systems.d/"+system+".json", "r")
                system_file_content = system_file.read()
                system_file.close()
                if (node_info["ip"] in system_file_content) or (node_info["hostname"] in system_file_content) \
                                                            or (node_info["mac"] in system_file_content):
                    os.system("cobbler system remove --name %s" % system)
               
    # 打开文件
    # dns file
    dns_conf_content = open(dns_conf, "a+")
    dns_content = dns_conf_content.read()

    # dhcp file
    dhcp_hosts_conf_content = open(dhcp_hosts_conf, "a+")
    dhcp_content = dhcp_hosts_conf_content.read()

    # puppet manager hosts file
    puppet_hosts_conf = open(puppet_hosts, "a+")
    puppet_hosts_content = puppet_hosts_conf.read()
    

    # 遍历 json 数据
    for node_info in data:
        # 拿到 IP 和 HOSTNAME 写入到 DNS 配置文件
        #print node_info['ip'], node_info['hostname']
        dns_conf_content.write("%s %s\n" % (node_info["ip"], 
                                    node_info["hostname"]))
        # 把 IP、HOSTNAME、MAC 写入到 DHCP 配置文件，做地址绑定
        dhcp_hosts_conf_content.write("dhcp-host=%s,%s,%s\n" % 
            (node_info["ip"], node_info["hostname"], node_info["mac"]))
        # 把解析记录写到 puppet 得 bases 模块中
        puppet_hosts_conf.write("%s %s\n" % (node_info["ip"], 
                                    node_info["hostname"]))

        all_nodes_list.append(node_info["hostname"])

        # 配置了远控卡信息
        if node_info["power-type"] and node_info["power-address"] and \
           node_info["power-user"] and node_info["power-pass"] != "" \
                                   and node_info["power-type"] in power_type:
            # 检测本机是否能 ping 通远控卡
            ping_test = os.popen("ping %s -c 1 > /dev/null 2>&1; echo $?" % node_info["power-address"]).read().rstrip()

            # ping 不通
            if ping_test != '0':
                print '{"return": 0, "type": 1, "data": {"message": "目标主机远控卡地址： %s 不可达，请重新输入地址或检查本机的网络配置. !"}}' % node_info["power-address"]
                exit (1)

            # 可以ping通
            else:
                # 判断是否物理服务器的远控卡是否为 ipmi
                os.system("nohup ipmitool -U %s -P %s -H %s chassis power status > /dev/null 2>&1 &" % \
                                    (node_info["power-user"], node_info["power-pass"], node_info["power-address"]))

                time.sleep(2)
                ipmi_test = os.popen("ps aux | grep '%s chassis power status' | grep -v grep | grep -v 'sh -c' > /dev/null 2>&1; echo $?" % \
                                                                         node_info["power-address"]).read().rstrip()
                if ipmi_test != '0':
                    power_types = 'ipmilan'

                    # 判断物理服务器电源状态
                    power_status = os.popen("ipmitool -U %s -P %s -H %s chassis power status | awk '{print $NF}'" % \
                                        (node_info["power-user"], node_info["power-pass"], \
                                         node_info["power-address"])).read().rstrip()

                    # 设置物理服务器从 pxe 启动一次（临时只从 pxe 启动一次）
                    os.system("ipmitool -U %s -P %s -H %s chassis bootdev pxe" % \
                              (node_info["power-user"], node_info["power-pass"], \
                               node_info["power-address"])).read().rstrip()
                    
                    # 电源开启,重新启动
                    if power_status == 'on':
                        os.system("ipmitool -U %s -P %s -H %s chassis power reset" % \
                                  (node_info["power-user"], node_info["power-pass"], \
                                   node_info["power-address"])).read().rstrip()

                    # 电源关闭,直接启动
                    if power_status == 'off':
                        os.system("ipmitool -U %s -P %s -H %s chassis power on" % \
                                  (node_info["power-user"], node_info["power-pass"], \
                                   node_info["power-address"])).read().rstrip()

                # 判断是否物理服务器的远控卡是否为 ilo
                os.system("nohup ipmitool -H %s -I lanplus -U %s -P %s chassis power status > /dev/null 2>&1 &" % \
                                   (node_info["power-address"], node_info["power-user"], node_info["power-pass"]))

                time.sleep(2)
                ilo_test = os.popen("ps aux | grep 'ipmitool -H %s -I lanplus' | grep -v grep | grep -v 'sh -c' > /dev/null 2>&1; echo $?" % \
                                                                         node_info["power-address"]).read().rstrip()
                if ilo_test != '0':
                    power_types = 'ilo'

                    # 判断物理服务器电源状态
                    power_status = os.popen("ipmitool -H %s -I lanplus -U %s -P %s chassis power status | awk '{print $NF}'" % \
                                                                         (node_info["power-address"], node_info["power-user"], \
                                                                          node_info["power-pass"])).read().rstrip()

                    # 设置物理服务器从 pxe 启动一次（临时只从 pxe 启动一次）
                    os.system("ipmitool -H %s -I lanplus -U %s -P %s chassis bootdev pxe" % \
                              (node_info["power-address"], node_info["power-user"], \
                               node_info["power-pass"])).read().rstrip()
                    
                    # 电源开启,重新启动
                    if power_status == 'on':
                        os.system("ipmitool -H %s -I lanplus -U %s -P %s chassis power reset" % \
                                  (node_info["power-address"], node_info["power-user"], \
                                   node_info["power-pass"])).read().rstrip()

                    # 电源关闭,直接启动
                    if power_status == 'off':
                        os.system("ipmitool -H %s -I lanplus -U %s -P %s chassis power on" % \
                                  (node_info["power-address"], node_info["power-user"], \
                                   node_info["power-pass"])).read().rstrip()

                if ipmi_test == '0' and ilo_test == '0':
                    print '{"return": 0, "type": 1, "data": {"message": "远控卡地址: %s 无法通过验证, 请重新输入远控卡账号及密码."}}' % node_info["power-address"]
                    exit (1)

                os.system("cobbler system add --name=%s --hostname=%s \
                          --profile=$(cobbler profile list | grep ECCP | \
                          awk '{print $1}') --mac=%s --interface=eth0 \
                          --ip-address=%s --static=1" % \
                         (node_info["hostname"], node_info["hostname"], \
                          node_info["mac"], node_info["ip"]))


                os.system("cobbler system edit --name %s --power-type=%s \
                          --power-address=%s --power-user %s --power-pass %s" % \
                         (node_info["hostname"], power_types, \
                          node_info["power-address"], node_info["power-user"], \
                          node_info["power-pass"]))
                

        # 没有使用远控卡
        else:
            os.system("cobbler system add --name=%s --hostname=%s \
                      --profile=$(cobbler profile list | grep ECCP |  \
                      awk '{print $1}') --mac=%s --interface=eth0 \
                      --ip-address=%s --static=1" % \
                     (node_info["hostname"], node_info["hostname"], \
                      node_info["mac"], node_info["ip"]))

        # 找出 Puppet Class 执行的顺序
        if ('horizon' in node_info['type']) and ('ceilometer' not in node_info['type']):
            class_order = 'Class["bases"] -> Class["all-sources"] -> Class["ceilometer-client"]'
            include_module = 'include bases, all-sources, ceilometer-client, '

        elif 'horizon' in node_info['type'] and ('ceilometer' in node_info['type']):
            class_order = 'Class["bases"] -> Class["all-sources"]'
            include_module = 'include bases, all-sources, '

        elif ('ceilometer' in node_info['type']) and ('horizon' not in node_info['type']):
            class_order = 'Class["bases"] -> Class["all-sources"] -> Class["ganglia-client"]'
            include_module = 'include bases, all-sources, ganglia-client, '

        else:
            class_order = 'Class["bases"] -> Class["all-sources"] -> Class["ganglia-client"] -> Class["ceilometer-client"]'
            include_module = 'include bases, all-sources, ganglia-client, ceilometer-client, '
            
        for types in node_info["type"]:
            class_order += ' -> Class["%s"]' % types
                
        # 拿到节点需要 include 的模块
        for types in node_info["type"]:
            include_module += '%s' % types
            if types != node_info["type"][-1]:
                include_module += ', '

        # 准备写入到 Puppet 节点角色配置文件中
        puppet_nodes_conf = open('/etc/puppet/manifests/nodes/'+node_info["hostname"]+'.pp', 'w')

        # 如果 mysql 或 rabbitmq 单独部署
        if ['mysql'] == node_info['type'] or ['rabbitmq'] == node_info['type']:
            puppet_nodes_conf.write("node '%s' { \n\tinclude bases, %s\n}" % 
                                                    (node_info["hostname"],
                                                     node_info['type'][0]))

        # 如果 mysql 和 rabbitmq 部署在一台机器上
        elif ('mysql' and 'rabbitmq' in node_info['type']) and \
                                     len(node_info['type']) == 2:

            puppet_nodes_conf.write("node '%s' { \n\tinclude bases, %s, %s\n}" % 
                                                    (node_info["hostname"], 
                                                     node_info['type'][0], 
                                                     node_info['type'][1]))

        # 其它组件默认依赖 all-sources 模块
        else:
            puppet_nodes_conf.write("node '%s' { \n\t%s\n\t%s\n}" % 
                                                     (node_info["hostname"],
                                                      class_order,
                                                      include_module))
        puppet_nodes_conf.close()

        # 修改 puppet site.pp 相关节点 IP 地址
        
        if 'mysql' in node_info["type"]:
            os.system("sed -i '/^$mysql_host.*$/ s/=.*$/= \"%s\"/g' %s" %
                                   (node_info['hostname'], puppet_site))

        if 'rabbitmq' in node_info["type"]:
            os.system("sed -i '/^$rabbit_host.*$/ s/=.*$/= \"%s\"/g' %s" %
                                    (node_info['hostname'], puppet_site))

        if 'keystone' in node_info["type"]:
            os.system("sed -i '/^$keystone_host.*$/ s/=.*$/= \"%s\"/g' %s" %
                                     (node_info['hostname'], puppet_site))

        if 'glance' in node_info["type"]:
            os.system("sed -i '/^$glance_host.*$/ s/=.*$/= \"%s\"/g' %s" %
                                    (node_info['hostname'], puppet_site))

        if 'nova-control' in node_info["type"]:
            os.system("sed -i '/^$nova_my_ip.*$/ s/=.*$/= \"%s\"/g' %s" %
                                          (node_info['ip'], puppet_site))
            os.system("sed -i '/^$nova_api_host.*$/ s/=.*$/= \"%s\"/g' %s" %
                                          (node_info['hostname'], puppet_site))

        if 'cinder' in node_info["type"]:
            os.system("sed -i '/^$cinder_host.*$/ s/=.*$/= \"%s\"/g' %s" %
                                          (node_info['hostname'], puppet_site))

        if 'horizon' in node_info["type"]:
            os.system("sed -i '/^$memcache_host.*$/ s/=.*$/= \"%s\"/g' %s" %
                                          (node_info['hostname'], puppet_site))

        if 'savanna' in node_info["type"]:
            os.system("sed -i '/^$savanna_host.*$/ s/=.*$/= \"%s\"/g' %s" %
                                          (node_info['hostname'], puppet_site))

        if 'swift' in node_info["type"]:
            os.system("sed -i '/^$swift_proxy_host.*$/ s/=.*$/= \"%s\"/g' %s" %
                                          (node_info['hostname'], puppet_site))
       
        if 'ceilometer' in node_info["type"]:
            os.system("sed -i '/^$ceilometer_api_host.*$/ s/=.*$/= \"%s\"/g' %s" %
                                          (node_info['hostname'], puppet_site))

        if 'glusterfs' or 'glusterfs-client' in node_info["type"]:
            glusterfs_list.append(node_info['ip'])
            os.system("sed -i '/^$cinder_volume_format.*$/ s/=.*$/= \"glusterfs\"/g' %s" % puppet_site)

    # 在 site.pp 中写入所有得 glusterfs 节点列表
    os.system("sed -i '/^$glusterfs_nodes_list.*$/ s/=.*$/= \"%s\"/g' %s" %
                                             (' '.join(glusterfs_list), puppet_site))
    os.system("sed -i '/^$all_nodes_list.*$/ s/=.*$/= \"%s\"/g' %s" %
                                       (' '.join(all_nodes_list), puppet_site))
  
    # 关闭文件
    dns_conf_content.close()
    dhcp_hosts_conf_content.close()
    puppet_hosts_conf.close()

    # 重启服务
    os.system("/etc/init.d/dnsmasq restart > /dev/null 2>&1; /etc/init.d/cobbler restart > /dev/null 2>&1")
    print '{"return": 1, "type": 0}'

if __name__ == "__main__":
    write_conf(eval(sys.argv[1]))
