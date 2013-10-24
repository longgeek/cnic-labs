class ganglia-client::install {
    package { ['ganglia-monitor', 'rrdtool']:
        ensure => 'installed',
    }
}
