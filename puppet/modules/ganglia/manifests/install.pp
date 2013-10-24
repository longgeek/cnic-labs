class ganglia::install {
    package { ['gmetad', 'ganglia-monitor', 'rrdtool', 'libapache2-mod-php5']:
        ensure => 'installed',
    }
}
