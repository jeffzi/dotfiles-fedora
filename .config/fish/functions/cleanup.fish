function cleanup
    command find $argv -name '*DS_Store' -or -name '*pyc' -or -name __pycache__ -exec rm -f {} \;
end
