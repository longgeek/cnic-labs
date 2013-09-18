#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""替换 puppet 节点配置文件

把原有的角色替换为 remove_角色 模块,使得删除机器上相关角色的配置

"""

__version__ = '0.1'
__author__ = [
    "Longgeek <longgeek@gmail.com>",
]

import os
import sys

if len(sys.argv) != 2:
    print "Missing or extra positional parameters!"
    exit(1)

def del_nodes_type(data):
    for info in data:
        puppet_nodes_conf = open('/etc/puppet/manifests/nodes/'+info['hostname']+'.pp', 'r')
        conf_content = puppet_nodes_conf.read()
        puppet_nodes_conf.close()

        for types in info['type']:
            conf_content = conf_content.replace(types, 'remove_%s' % types)
        puppet_nodes_conf = open('/etc/puppet/manifests/nodes/'+info['hostname']+'.pp', 'w')
        puppet_nodes_conf.write(conf_content)
        puppet_nodes_conf.close()

if __name__ == "__main__":
    del_nodes_type(eval(sys.argv[1]))

