function dotfiles
    # https://harfangk.github.io/2016/09/18/manage-dotfiles-with-a-git-bare-repository.html
    git --git-dir=$HOME/.dotfiles.git// --work-tree=$HOME $argv
end
