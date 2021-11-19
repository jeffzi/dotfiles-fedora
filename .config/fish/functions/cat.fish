function cat -d "Use bat/mdcat instead of cat"
    set -l extension (string lower (string split -r -m1 . $argv[1])[2])
    if [ $extension = md ]
        command mdcat $argv
    else
        command bat $argv
    end
end
