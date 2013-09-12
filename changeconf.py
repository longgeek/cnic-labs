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

if len(sys.argv) != 2:
    print "Missing or extra positional parameters!"
    exit(1)

# 主要修改的几个配置文件路径
dns_conf = "/var/lib/cobbler/cobbler_hosts"
dhcp_hosts_conf = "/etc/dnsmasq.d/hosts.conf"
puppet_site = "/etc/puppet/manifests/site.pp"
power_type = ['ilo', 'ipmilan', 'ipmitool', 'rsa']

def write_conf(data):

    """本函数通过传递参数来添加节点相关的信息，来修改 DNS、DHCP、PUPPET 和 Cobbler 配置文件."""

    # 打开文件
    dns_conf_content = open(dns_conf, "a+")
    dhcp_hosts_conf_content = open(dhcp_hosts_conf, "a+")
    dns_content = dns_conf_content.read()
    dhcp_content = dhcp_hosts_conf_content.read()

    # 遍历 json 数据
    for node_info in data:
        for i in [node_info["ip"], node_info["hostname"], node_info["mac"]]:
            for j in [dns_content, dhcp_content]:
                if i in j:
                    print "NOTE: Data record already exists, Please check the input!"
                    return "NOTE: Data record already exists, Please check the input!"
        # 拿到 IP 和 HOSTNAME 写入到 DNS 配置文件
        print node_info['ip'], node_info['hostname']
        dns_conf_content.write("%s %s\n" % (node_info["ip"], 
                                    node_info["hostname"]))
        # 把 IP、HOSTNAME、MAC 写入到 DHCP 配置文件，做地址绑定
        dhcp_hosts_conf_content.write("dhcp-host=%s,%s,%s\n" % 
            (node_info["ip"], node_info["hostname"], node_info["mac"]))

        # 配置了远控卡信息
        if node_info["power-type"] and node_info["power-address"] and \
           node_info["power-user"] and node_info["power-pass"] != "" \
                                   and node_info["power-type"] in power_type:
            os.system("cobbler system add --name=%s --hostname=%s \
                      --profile=$(cobbler profile list | grep ECCP | \
                      awk '{print $1}') --mac=%s --interface=eth0 \
                      --ip-address=%s --static=1" % \
                     (node_info["hostname"], node_info["hostname"], \
                      node_info["mac"], node_info["ip"]))

            os.system("cobbler system edit --name %s --power-type=%s \
                      --power-address=%s --power-user %s --power-pass %s" % \
                     (node_info["hostname"], node_info["power-type"], \
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
        class_order = 'Class["all-sources"]'
        for types in node_info["type"]:
            class_order += ' -> Class["%s"]' % types
                
        # 拿到节点需要 include 的模块
        include_module = 'include all-sources, '
        for types in node_info["type"]:
            include_module += '%s' % types
            if types != node_info["type"][-1]:
                include_module += ', '

        # 准备写入到 Puppet 节点角色配置文件中
        puppet_nodes_conf = open('/etc/puppet/manifests/nodes/'+node_info["hostname"]+'.pp', 'w')

        # 如果 mysql 或 rabbitmq 单独部署
        if ['mysql'] == node_info['type'] or ['rabbitmq'] == node_info['type']:
            puppet_nodes_conf.write("node '%s' { \n\tinclude %s\n}" % 
                                                    (node_info["hostname"],
                                                     node_info['type'][0]))

        # 如果 mysql 和 rabbitmq 部署在一台机器上
        elif ('mysql' and 'rabbitmq' in node_info['type']) and \
                                     len(node_info['type']) == 2:

            puppet_nodes_conf.write("node '%s' { \n\tinclude %s, %s\n}" % 
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

    # 关闭文件
    dns_conf_content.close()
    dhcp_hosts_conf_content.close()

    # 重启服务
    os.system("/etc/init.d/dnsmasq restart > /dev/null 2>&1; /etc/init.d/cobbler restart > /dev/null 2>&1")
    print 'Done!'
    return 'Done!'

if __name__ == "__main__":
    write_conf(eval(sys.argv[1]))
