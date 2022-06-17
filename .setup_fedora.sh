#!/bin/bash

# modified from https://github.com/David-Else/developer-workstation-setup-script

#==============================================================================
# common packages to install/remove
#==============================================================================

remove_packages=(
    *hangul*d
    *kkc*
    *libvirt*
    *m17n*
    *perl*
    *speech*
    abrt
    cheese
    fedora-bookmarks
    fedora-chromium-config
    fedora-workstation-backgrounds
    gedit
    gnome-backgrounds
    gnome-boxes
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-classic*
    gnome-clocks
    gnome-contacts
    gnome-documents
    gnome-logs
    gnome-maps
    gnome-photos
    gnome-remote-desktop
    gnome-screenshot
    gnome-shell-extension-apps-menu
    gnome-shell-extension-background-logo
    gnome-shell-extension-horizontal-workspaces
    gnome-shell-extension-launch-new-instance
    gnome-shell-extension-places-menu
    gnome-shell-extension-window-list
    gnome-tour
    gnome-user*
    gnome-weather
    ibus-hangui
    libreoffice*
    open-vm*
    openh264
    podman*
    realmd
    rhythmbox
    sos
    teamd
    totem
    vino
    words
    xfs*
    xorg-x11-drv-amdgpu
    xorg-x11-drv-vmware
    yajl
)

dnf_packages=(
    baobab
    bat
    blueman
    code
    copyq
    direnv
    dunst
    exa
    fedora-workstation-repositories
    feh
    ffmpeg
    flameshot
    fuse-exfat
    fuse-sshfs
    gh
    git
    gnome-disk-utility
    gnome-extensions-app
    gnome-shell-extension-appindicator
    gnome-tweaks
    google-chrome-stable
    gvfs-afc
    gvfs-afp
    gvfs-fuse
    gvfs-mtp
    gvfs-nfs
    gvfs-smb
    hplip-gui
    htop
    java-latest-openjdk
    jq
    kitty
    mediainfo
    mpv
    nautilus
    nodejs
    p7zip
    p7zip-plugins
    pandoc
    picom
    ripgrep
    rstudio
    thunar
    thunar-archive-plugin
    thunar-volman
    tldr
    unrar
    vlc
)

flathub_packages=(
    com.axosoft.GitKraken
    com.discordapp.Discord
    com.jetbrains.DataGrip
    com.skype.Client
    com.slack.Slack
    com.spotify.Client
    rest.insomnia.Insomnia
    us.zoom.Zoom
)

snap_packages=(
    task
)

npm_packages=(
    serverless
    @commitlint/cli
    @commitlint/config-conventional
)

#==============================================================================
# script settings and checks
#==============================================================================

source /etc/os-release

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [ "$(id -u)" != 0 ]; then
    echo "You're not root! Run script with sudo" && exit 1
fi

exec 2> >(tee "error_log_$(date -Iseconds).txt")

info() {
    echo -e "${BOLD}${CYAN}$1${RESET}"
}

success() {
    echo -e "${GREEN}$1${RESET}"
}

# Call with arguments (${1} path,${2} line to add)
add_to_file() {
    touch "$1"
    grep -qxF "$2" "$1" && echo "$2 exists in ${GREEN}$1${RESET}" || echo "$2" >>"$1"
}

# Call with arguments ${1} github_user/repo, ${2} asset_name
download_latest_github_release() {
    local endpoint="https://api.github.com/repos/${1}/releases/latest"
    curl -s "$endpoint" \
        | grep -oP '"browser_download_url": "\K(.*)(?=")' \
        | grep -E "${2}" \
        | wget -qi -

    local filename
    filename=$(curl -s "$endpoint" | grep -oP '"name": "\K(.*)(?=")' | grep "${2}")
    
    echo "${filename}"
}

# Call with arguments (${1} filename,${2} strip,${3} newname)
install() {
    tar --no-same-owner -C /usr/local/bin -xf "${1}" --no-anchored "${3}" --strip="${2}"
    rm "${1}"
}

display_user_settings_and_prompt() {
    clear
    cat <<EOL
===============================================================================
${BOLD}${GREEN}$ID $VERSION_ID detected${RESET}

${BOLD}Packages to install${RESET}
${BOLD}-------------------${RESET}

DNF packages: ${GREEN}${dnf_packages[*]}${RESET}

Flathub packages: ${GREEN}${flathub_packages[*]}${RESET}

Snap packages: ${GREEN}${snap_packages[*]}${RESET}

NPM packages: ${GREEN}${npm_packages[*]}${RESET}

${BOLD}Packages to remove${RESET}
${BOLD}------------------${RESET}
DNF packages: ${RED}${remove_packages[*]}${RESET}
===============================================================================
EOL
    read -rp "Press ${YELLOW}enter${RESET} to install, or ${YELLOW}ctrl+c${RESET} to quit"
}
display_user_settings_and_prompt

#==============================================================================
# Set host name
#==============================================================================

read -rp "What is this computer's name? [$HOSTNAME] " hostname
if [[ -n "$hostname" ]]; then
    hostnamectl set-hostname "$hostname"
fi

#==============================================================================
# Add default and conditional repositories
#==============================================================================
add_repositories() {
    info "Adding repositories..."

    dnf -y install \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

    # Speed up dnf
    add_to_file "/etc/dnf/dnf.conf" "[main]"
    add_to_file "/etc/dnf/dnf.conf" "gpgcheck=1"
    add_to_file "/etc/dnf/dnf.conf" "installonly_limit=3"
    add_to_file "/etc/dnf/dnf.conf" "clean_requirements_on_remove=True"
    add_to_file "/etc/dnf/dnf.conf" "best=False"
    add_to_file "/etc/dnf/dnf.conf" "skip_if_unavailable=True"
    add_to_file "/etc/dnf/dnf.conf" "fastestmirror=true"
    add_to_file "/etc/dnf/dnf.conf" "deltarpm=true"
    add_to_file "/etc/dnf/dnf.conf" "max_parallel_downloads=10"

    # RPM Fusion repositories also provide Appstream metadata to enable users to
    # install packages using Gnome Software/KDE Discover
    dnf -y groupupdate core
    dnf -y install dnf-plugins-core
    # Tainted free is dedicated for FLOSS packages where some usages might be restricted in
    # some countries. Example: to play DVD with libdvdcss
    dnf -y install rpmfusion-free-release-tainted
    # Tainted nonfree is dedicated to non-FLOSS packages without a clear redistribution
    # status by the copyright holder.
    dnf -y install rpmfusion-nonfree-release-tainted
    dnf -y install fedora-workstation-repositories
    dnf -y config-manager --set-enabled google-chrome
    dnf -y config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

    # Disable the modular repos
    sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-modular.repo
    sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-modular.repo

    # Testing Repos should be disabled anyways
    sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-testing-modular.repo
    sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/rpmfusion-free-updates-testing.repo

    # rpmfusion makes this obsolete
    sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-cisco-openh264.repo

    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    add_to_file "/etc/yum.repos.d/vscode.repo" "[code]"
    add_to_file "/etc/yum.repos.d/vscode.repo" "name=Visual Studio Code"
    add_to_file "/etc/yum.repos.d/vscode.repo" "baseurl=https://packages.microsoft.com/yumrepos/vscode"
    add_to_file "/etc/yum.repos.d/vscode.repo" "enabled=1"
    add_to_file "/etc/yum.repos.d/vscode.repo" "gpgcheck=1"
    add_to_file "/etc/yum.repos.d/vscode.repo" "gpgkey=https://packages.microsoft.com/keys/microsoft.asc"
    
    # GitHub CLI
    dnf -y config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

    # Flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak update -y --noninteractive
}
add_repositories

#==============================================================================
# install packages
#==============================================================================
install_packages() {
    info "Removing unwanted programs..."
    dnf -y --skip-broken remove "${remove_packages[@]}"

    info "Updating dnf..."
    dnf clean all
    dnf -y --refresh --skip-broken --allowerasing upgrade
    dfn check
    dnf autoremove -y

    info "Updating LVFS..."
    fwupdmgr refresh --force
    fwupdmgr get-updates
    fwupdmgr update

    info "Installing Nvidia drivers..."
    dnf -y install akmod-nvidia
    # For cuda/nvdec/nvenc support
    dnf -y --best --allowerasing install \
        xorg-x11-drv-nvidia-cuda \
        xorg-x11-drv-nvidia-cuda-libs
    # In order to enable video acceleration support for your player
    dnf -y --best --allowerasing install \
        vdpauinfo \
        libva-vdpau-driver \
        libva-utils \
        vulkan

    success "Installed Nvidia drivers $(modinfo -F version nvidia)"

    info "Installing packages..."
    dnf -y --best install "${dnf_packages[@]}"

    info "Installing Flathub packages..."
    flatpak install -y --noninteractive flathub "${flathub_packages[@]}"
    flatpak uninstall -y --noninteractive --unused

    info "Installing Snap packages..."
    dnf install -y snapd
    ln -sf /var/lib/snapd/snap /snap
    systemctl restart snapd.seeded.service
    for package in "${snap_packages[@]}"
    do
    snap install "$package" --classic
    done

    info "Installing global NodeJS packages..."
    npm install -g "${npm_packages[@]}"

    info "Installing multimedia codecs..."
    dnf -y groupupdate multimedia \
        --setop="install_weak_deps=False" \
        --exclude=PackageKit-gstreamer-plugin
    dnf -y groupupdate sound-and-video

    info "OpenH264 in Firefox, you'll need to active from Firefox plugins menu..."
    dnf config-manager --set-enabled fedora-cisco-openh264
    dnf install -y gstreamer1-plugin-openh264 mozilla-openh264
}
install_packages

#==============================================================================
# set fish shell as default
#==============================================================================
info "Setting up fish shell..."
dnf install -y fish util-linux-user starship
chsh -s /usr/bin/fish "$LOGNAME"

#==============================================================================
# Install development and build tools 
#==============================================================================
info "Install development and build tools..."
dnf -y groupinstall "Development Tools" "Development Libraries"
dnf -y install make cmake gcc gcc-c++


info "Installing Git Credential Manager..."
archive=$(download_latest_github_release "GitCredentialManager/git-credential-manager" "gcmcore-linux_amd64.*.tar.gz$")
tar -xvf "$archive" -C /usr/local/bin
git-credential-manager-core configure

#==============================================================================
# Setup python
#==============================================================================
info "Setting up python environment..."

# install python dependencies
dnf -y install \
    make \
    gcc \
    zlib-devel \
    bzip2 bzip2-devel \
    readline-devel \
    sqlite sqlite-devel \
    openssl-devel \
    tk-devel \
    libffi-devel \
    xz-devel

sudo -i -u "$LOGNAME" bash << EOF
# install pyenv
curl https://pyenv.run | bash
exec $SHELL
# install recent python versions
pyenv install --list | grep " 3.7" | tail -1 | xargs pyenv install -v
pyenv install --list | grep " 3.8" | tail -1 | xargs pyenv install -v
pyenv install --list | grep " 3.9" | tail -1 | xargs pyenv install -v
pyenv install --list | grep " 3.10" | tail -1 | xargs pyenv install -v
# 3.8 as global version
pyenv install --list | grep " 3.8" | tail -1 | xargs pyenv global

# install poetry
curl -sSL https://install.python-poetry.org | python -
#  Store python virtual environments in the package s directory
poetry config virtualenvs.in-project true
EOF

#==============================================================================
# Setup docker
#==============================================================================
info "Setting up docker..."

# Install Docker
dnf -y install moby-engine
# Start & enable Docker daemon
systemctl enable --now docker.service
groupadd docker || true
usermod -aG docker "$LOGNAME"

#==============================================================================
# Install awscli
#==============================================================================
install_awscli() {
    pushd /tmp || exit
    info "Installing AWS CLI"
    rm -rf aws
    local filename=awscliv2.zip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ${filename}
    unzip  ${filename}
    ./aws/install > /dev/null 2>&1 || ./aws/install --update
    popd || exit
    success "Installed awscli: $($(which aws) --version)"

    dnf --setopt=install_weak_deps=False -y install golang
    go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login
}
install_awscli

#==============================================================================
# Install Mullvad
#==============================================================================

info "Installing Mullvad..."
mullvad_rpm=$(download_latest_github_release "mullvad/mullvadvpn-app" "MullvadVPN-.*_x86_64.rpm$")
dnf install -y "$mullvad_rpm"

#==============================================================================
# install fonts
#==============================================================================
info "Installing fonts..."

dnf -y install curl cabextract xorg-x11-font-utils fontconfig rsms-inter-fonts
rpm -ivh --force https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

rm -rf /tmp/nerd-fonts
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git /tmp/nerd-fonts
sudo -i -u "$LOGNAME" bash /tmp/nerd-fonts/install.sh Hack
sudo -i -u "$LOGNAME" bash /tmp/nerd-fonts/install.sh FiraCode
sudo -i -u "$LOGNAME" bash /tmp/nerd-fonts/install.sh SourceCodePro

#==============================================================================
# Set performance profile
#==============================================================================
dnf -y install tuned
systemctl enable --now tuned
tuned-adm profile desktop

#==============================================================================
# Increase inotify watchers for watching large numbers of files, default is 8192
#
# curl -s https://raw.githubusercontent.com/fatso83/dotfiles/master/utils/scripts/inotify-consumers | bash
#==============================================================================
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
systemctl enable fstrim.timer

#==============================================================================
# Setup Gnome desktop
#==============================================================================
info "Setting up Gnome desktop..."

# install dependencies
dnf -y install gnome-themes-extra gtk-murrine-engine sassc
# install gtk theme
rm -rf /tmp/Orchis-theme
git clone https://github.com/vinceliuice/Orchis-theme.git /tmp/Orchis-theme
sudo -i -u "$LOGNAME" bash /tmp/Orchis-theme/install.sh --tweaks solid

# install icon theme
sudo -i -u "$LOGNAME" wget -qO- https://git.io/papirus-icon-theme-install | sh

# set up themes
gsettings set org.gnome.desktop.interface gtk-theme "Orchis-dark"
gsettings set org.gnome.desktop.wm.preferences theme "Orchis-dark"
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

info "Setting up Gnome desktop gsettings..."

gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.session idle-delay 2400

#Usability Improvements
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

#Nautilus (File Manager) Usability
gsettings set org.gtk.Settings.FileChooser sort-directories-first true

#==============================================================================
# setup KDE theme
#==============================================================================
info "Setting up KDE theme..."
# install qt theme engine
dnf -y install kvantum
# install qt theme
rm -rf /tmp/Qogir-kde
git clone https://github.com/vinceliuice/Qogir-kde.git /tmp/Qogir-kde
sudo -i -u "$LOGNAME" bash /tmp/Qogir-kde/install.sh
sudo -i -u "$LOGNAME" kvantummanager --set "Qogir-dark-solid"

#==============================================================================
# setup qtile
#==============================================================================
info "Setting up qtile..."

# needed for audio control
dnf -y install pulseaudio-utils pavucontrol

# install qtile
sudo -i -u "$LOGNAME" pip install xcffib
sudo -i -u "$LOGNAME" pip install --upgrade --force-reinstall --no-cache-dir cairocffi[xcb]
sudo -i -u "$LOGNAME" pip install dbus-next psutil python-xlib qtile


# add qtile session
cat <<EOF > /usr/share/xsessions/qtile.desktop
[Desktop Entry]
Name=Qtile
Comment=Qtile Session
Exec=qtile start
Type=Application
Keywords=wm;tiling
EOF

#==============================================================================
# setup rofi
#==============================================================================
info "Setting up rofi..."

dnf -y install rofi rofimoji rofi-devel qalculate libqalculate-devel libtool

# install rofi-calc
rm -rf /tmp/rofi-calc
git clone https://github.com/svenstaro/rofi-calc.git /tmp/rofi-calc
pushd /tmp/rofi-calc || exit
autoreconf -i
mkdir build
cd build/ || exit
../configure
make
make install
popd || exit
libtool --finish /usr/lib64/rofi/

#==============================================================================
# setup bat
#==============================================================================
info "Setting up bat..."
bat cache --build

#==============================================================================
# fixing nvidia screen tearning
#==============================================================================
# https://wiki.archlinux.org/title/NVIDIA/Troubleshooting#Avoid_screen_tearing
mkdir -p /etc/X11/xorg.conf.d/
cat <<EOF > /etc/X11/xorg.conf.d/20-nvidia.conf
Section "Device"
    Identifier     "Device0"
    Driver         "nvidia"
    VendorName     "NVIDIA Corporation"
    BoardName      "NVIDIA GeForce RT 3080"
EndSection

Section "Screen"
    Identifier     "Screen0"
    Device         "Device0"
    Monitor        "Monitor0"
    DefaultDepth    24
    Option         "Stereo" "0"
    Option         "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
    Option         "SLI" "Off"
    Option         "MultiGPU" "Off"
    Option         "BaseMosaic" "off"
    SubSection     "Display"
        Depth       24
    EndSubSection
EndSection
EOF

#==============================================================================
# done
#==============================================================================
display_end_message() {
    cat <<EOL

=============================================================================
Congratulations, everything is set up ! ✨ 🍰 ✨

Manual action required:

- BTRFS optimizations: https://mutschler.dev/linux/fedora-btrfs-35/ 

Please reboot 🚀
=============================================================================
EOL
}
display_end_message