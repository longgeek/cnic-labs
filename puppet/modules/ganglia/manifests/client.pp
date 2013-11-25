class ganglia::client {
    exec { "listen ganglia client":
        #command => "python /etc/ganglia/listen_ganglia_client.py; echo `python -c 'print len('$all_nodes_list'.split(' '))' > /tmp/geek.txt`",
        command => "python /etc/ganglia/listen_ganglia_client.py",
        path => $command_path,
        unless => "[ \"`ls /var/lib/ganglia/rrds/ECCP/ | grep -v '__SummaryInfo__' | wc -l`\" = \"`python -c \"a = '$all_nodes_list'.split(' '); print len(list(a))\"`\" ]",
    }
}
