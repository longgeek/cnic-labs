class remove_swift {
    exec { "remove swift":
        command => "swift-init main stop; \
                    rm -fr $source_dir/*swift*; \
                    rm -fr /etc/swift; \
                    rm -fr /var/log/swift",
        path => $command_path,
        onlyif => "ls /var/log/swift",
    }
}
