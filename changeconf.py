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
import re

# 主要修改的几个配置文件路径
dns_conf = "/var/lib/cobbler/cobbler_hosts"
dhcp_hosts_conf = "/etc/dnsmasq.d/hosts.conf"
puppet_nodes_conf = "/etc/puppet/manifests/nodes.pp"
puppet_site_conf = "/etc/puppet/manifests/site.pp"

def write_conf(data = [{"ip": "172.16.0.101", "hostname": "control.local.com", "mac": "52:54:00:09:51:04", "type": ["mysql", "rabbitmq", "keystone", "cinder", "glance", "nova-control", "horizon"], "power-type": "ipmi", "power-address": "1.1.1.1", "power-user": "", "power-pass": ""}, {"ip": "172.16.0.102", "hostname": "compute.local.com", "mac": "52:54:00:2c:53:db", "type": ["nova-compute"], "power-type": "ipmi", "power-address": "1.1.1.1", "power-user": "", "power-pass": ""}]):

    """本函数通过传递参数来添加节点相关的信息，来修改 DNS、DHCP、PUPPET 和 Cobbler 配置文件."""

    # 打开文件
    dns_conf_content = open(dns_conf, "a+")
    dhcp_hosts_conf_content = open(dhcp_hosts_conf, "a+")
    puppet_nodes_conf_content = open(puppet_nodes_conf, "a+")
    puppet_site_conf_content = open(puppet_site_conf)
    site_content = puppet_site_conf_content.read()

    # 遍历 json 数据
    for node_info in data:
        if node_info["ip"] or node_info["hostname"] or node_info["mac"] in \
                              dns_conf_content or dhcp_hosts_conf_content:
            print "NOTE: Data record already exists, Please check the input!"
            return "NOTE: Data record already exists, Please check the input!"
        # 拿到 IP 和 HOSTNAME 写入到 DNS 配置文件
        dns_conf_content.write("%s %s\n" % (node_info["ip"], 
                                    node_info["hostname"]))
        # 把 IP、HOSTNAME、MAC 写入到 DHCP 配置文件，做地址绑定
        dhcp_hosts_conf_content.write("dhcp-host=%s, %s, %s\n" % 
            (node_info["ip"], node_info["hostname"], node_info["mac"]))

        # 配置了远控卡信息
        if node_info["power-type"] and node_info["power-address"] and \
           node_info["power-user"] and node_info["power-pass"] != "":
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
        include_module = 'include '
        for types in node_info["type"]:
            include_module += '%s' % types
            if types != node_info["type"][-1]:
                include_module += ', '

        # 写入到 Puppet 节点角色配置文件中
        puppet_nodes_conf_content.write("node '%s' inherits default { \
            \n\t%s\n\t%s\n}\n\n" % (node_info["hostname"], class_order, 
                                                       include_module))

        # 修改 puppet site.pp 相关节点 IP 地址
        if 'mysql' in node_info["type"]:
            site_content = re.sub("%mysql%", node_info["hostname"], site_content)

        if 'rabbitmq' in node_info["type"]:
          site_content = re.sub("%rabbit%", node_info["hostname"], site_content)

        if 'keystone' in node_info["type"]:
          site_content = re.sub("%keystone%", node_info["hostname"], site_content)

        if 'cinder' in node_info["type"]:
          site_content = re.sub("%cinder%", node_info["hostname"], site_content)

        if 'glance' in node_info["type"]:
          site_content = re.sub("%glance%", node_info["hostname"], site_content)

        if 'nova-control' in node_info["type"]:
            site_content = re.sub("%nova%", node_info["hostname"], site_content)

    # 把 site.pp 修改完的内容写入到文件        
    open(puppet_site_conf, "wb").write(site_content)

    #关闭文件
    dns_conf_content.close()
    dhcp_hosts_conf_content.close()
    puppet_nodes_conf_content.close()
    puppet_site_conf_content.close()

    os.system("/etc/init.d/dnsmasq restart; /etc/init.d/cobbler restart")
    return 'Done!'

write_conf()
