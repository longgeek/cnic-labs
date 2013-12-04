class swift::swift-install {
    package { "python-xattr":
        ensure => installed,
        notify => File["$source_dir/swift.tar.gz"],
    }

    file { "$source_dir/swift.tar.gz":
        source => "puppet:///files/swift.tar.gz",
        notify => Exec["untar swift"],
    }

    exec { "untar swift":
        command => "[ -e $source_dir/swift ] && \
                    cd $source_dir/swift && python setup.py develop -u && \
                    rm -fr $source_dir/swift; \
                    cd $source_dir; \
                    tar zxvf swift.tar.gz; \
                    cd swift; \
                    git checkout stable/$swift_version; \
                    python setup.py egg_info; \
                    pip install -r *.egg-info/requires.txt; \
                    python setup.py develop; \
                    ps aux | grep -v grep | grep swift- && swift-init main restart; ls",
        path => $command_path,
        refreshonly => true,
    }
}
