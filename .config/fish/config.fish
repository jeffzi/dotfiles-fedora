# default editor
set -gx EDITOR /usr/bin/code
# qt apps
set -x QT_STYLE_OVERRIDE kvantum

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

# exa

set -Ux EXA_STANDARD_OPTIONS --long --all --group-directories-first --time-style=long-iso
set -Ux EXA_LT_OPTIONS --tree --no-permissions --no-user
# dim less important metadata
set -x EXA_COLORS "di=34:bd=33;2:cd=33;2:so=31;2:ex=37;2:ur=2;37:uw=2;37:ux=2;37:ue=2;37:gr=2;37:gw=2;37:gx=2;37:tr=2;37:tw=2;37:tx=2;37:xa=2;37:uu=2;37:lc=31;2:df=32;2:sn=37;2:sb=37;2:nb=37;2:nk=37;2:nm=37;2:ng=37;2:nt=37;2:da=2;34"

# colororize man with bat
set -gx MANROFFOPT -c
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# direnv
direnv hook fish | source

# theme
base16-material-darker
eval (dircolors -c ~/.dircolors)

# starship prompt
starship init fish | source
