function tounixtime -d "Convert a string in UTC time to unix time."
    date -ud $argv[1] +%s
end
