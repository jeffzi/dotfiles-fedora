function ...
    cd ../..
end

# default editor
set -gx EDITOR /usr/bin/code

# flatpak
set -l xdg_data_home $XDG_DATA_HOME ~/.local/share
set -gx --path XDG_DATA_DIRS $xdg_data_home[1]/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share

for flatpakdir in ~/.local/share/flatpak/exports/bin /var/lib/flatpak/exports/bin
    if test -d $flatpakdir
        contains $flatpakdir $PATH; or set -a PATH $flatpakdir
    end
end

# snap
set -gx XDG_DATA_DIRS /var/lib/snapd/desktop/:$XDG_DATA_DIRS
set PATH $PATH /var/lib/snapd/snap/bin

# https://github.com/oh-my-fish/plugin-pj
set -gx PROJECT_PATHS ~/Projects ~/Projects/dev ~/Projects/work/metamoki ~/Projects/work/metamoki/DataArchive/projects ~/Projects/work/metamoki/DataArchive/libs
abbr -a pjo pj open

# pyenv init
set -gx PATH $PATH $HOME/.pyenv/bin
status is-login; and pyenv init --path | source
pyenv init - | source

# go
set -gx GOPATH $HOME/go
set -gx PATH $PATH $GOPATH/bin

# theme
base16-material-darker

# starship prompt
starship init fish | source
