function tolocaltime -d "Convert UTC time to local time."
    date -ud $argv[1] '+%F %T.%3N'
end
