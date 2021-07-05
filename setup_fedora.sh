#!/bin/bash

# modified from https://github.com/David-Else/fedora-ultimate-setup-script

#==============================================================================
# script settings and checks
#==============================================================================
set -eo pipefail
exec 2> >(tee "error_log_$(date -Iseconds).txt")

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [ "$(id -u)" != 0 ]; then
    echo "You're not root! Run script with sudo" && exit 1
fi

#==============================================================================
# git settings
#==============================================================================
git_email='jzinque@gmail.com'
git_username='jeffzi'

#==============================================================================
# common packages to install/remove
#==============================================================================
remove_packages=(

    *hangul*
    *kkc*
    *libvirt*
    *m17n*
    *perl*
    *speech*
    abrt
    cheese
    f34-backgrounds-gnome
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
    bat
    baobab
    code
    fedora-workstation-repositories
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
    htop
    jq
    kitty
    mediainfo
    mpv
    nautilus
    nodejs
    p7zip
    p7zip-plugins
    picom
    ripgrep
    rofi
    rsms-inter-fonts
    rstudio
    thunar
    thunar-archive-plugin
    thunar-volman
    tldr
    tuned
    unrar
    vlc
)

flathub_packages=(
    com.jetbrains.DataGrip
    com.skype.Client
    com.slack.Slack
    com.spotify.Client
)

snap_packages=(
    gitkraken
    task
)

npm_packages=(
    serverless
    @commitlint/cli
    @commitlint/config-conventional
)

#==============================================================================
# display user settings
#==============================================================================
read -rp "What is this computer's name? [$HOSTNAME] " hostname

cat <<EOF
===============================================================================
${BOLD}Hostname${RESET}
${BOLD}-------------------${RESET}
${GREEN}$HOSTNAME${RESET}

${BOLD}Git settings${RESET}
${BOLD}-------------------${RESET}
Global email: ${GREEN}$git_email${RESET}
Global user name: ${GREEN}$git_username${RESET}

${BOLD}Packages to install${RESET}
${BOLD}-------------------${RESET}

DNF packages: ${GREEN}${dnf_packages[*]}${RESET}

Flathub packages: ${GREEN}${flathub_packages[*]}${RESET}

Snap packages: ${GREEN}${snap_packages[*]}${RESET}

Node packages: ${GREEN}${npm_packages[*]}${RESET}

${BOLD}Packages to remove${RESET}
${BOLD}------------------${RESET}
DNF packages: ${GREEN}${remove_packages[*]}${RESET}
===============================================================================
⚠️ This script is designed to run on a machine with a user named after the ${BOLD}${RED}git user${RESET}: ${YELLOW}$git_username${RESET} ⚠️
===============================================================================
EOF
read -rp "Press ${YELLOW}enter${RESET} to install, or ${YELLOW}ctrl+c${RESET} to quit"

#==============================================================================
# set host name
#==============================================================================

if [[ ! -z "$hostname" ]]; then
    hostnamectl set-hostname "$hostname"
fi

#==============================================================================
# setup git user name and email if none exist
#==============================================================================
sudo -i -u $git_username bash << EOF
git config --global user.name $git_username
git config --global user.email $git_email
EOF

#==============================================================================
# add default and conditional repositories
#==============================================================================
echo "${BOLD}${CYAN}Adding repositories...${RESET}"

# speed up dnf
cat <<EOF > /etc/dnf/dnf.conf
[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
fastestmirror=true
deltarpm=true
max_parallel_downloads=10
EOF

dnf -y install \
    "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
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

# vscode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat <<EOF > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Disable the modular repos
sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-modular.repo
sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-modular.repo

# Testing Repos should be disabled anyways
sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-testing-modular.repo
sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/rpmfusion-free-updates-testing.repo

# rpmfusion makes this obsolete
sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-cisco-openh264.repo

# flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update -y --noninteractive

#==============================================================================
# install packages
#==============================================================================
echo "${BOLD}${CYAN}Removing unwanted programs...${RESET}"
# dnf -y remove "${remove_packages[@]}"

echo "${BOLD}${CYAN}Updating Fedora...${RESET}"
dnf clean all
dnf -y --refresh --skip-broken --allowerasing upgrade

echo "${BOLD}${CYAN}Installing nvidia drivers...${RESET}"
dnf -y install akmod-nvidia
# For cuda/nvdec/nvenc support
dnf -y --best --allowerasing install xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs
# In order to enable video acceleration support for your player
dnf -y --best --allowerasing install vdpauinfo libva-vdpau-driver libva-utils

echo "${BOLD}${CYAN}Installing packages...${RESET}"
dnf -y --best --allowerasing install "${dnf_packages[@]}"

echo "${BOLD}${CYAN}Installing flathub packages...${RESET}"
flatpak install -y --noninteractive flathub "${flathub_packages[@]}"
flatpak uninstall -y --noninteractive --unused

echo "${BOLD}${CYAN}Installing Snap packages...${RESET}"
dnf install -y snapd
ln -sf /var/lib/snapd/snap /snap
systemctl restart snapd.seeded.service
for package in "${snap_packages[@]}"
do
   snap install "$package" --classic
done

echo "${BOLD}${CYAN}Installing global NodeJS packages...${RESET}"
npm install -g "${npm_packages[@]}"

echo "${BOLD}${CYAN}Installing multimedia codecs...${RESET}"
dnf -y groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
dnf -y groupupdate sound-and-video

echo "${BOLD}${CYAN}Installing insync...${RESET}"

rpm --import https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key
cat <<EOF > /etc/yum.repos.d/insync.repo
[insync]
name=insync repo
baseurl=http://yum.insync.io/fedora/\$releasever/
gpgcheck=1
gpgkey=https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key
enabled=1
metadata_expire=120m
EOF
dnf -y install insync

#==============================================================================
# set fish shell as default
#==============================================================================
echo "${BOLD}${CYAN}Setting up fish shell...${RESET}"
dnf install -y fish util-linux-user
chsh -s /usr/bin/fish

#==============================================================================
# setup python
#==============================================================================
echo "${BOLD}${CYAN}Setting up python environment...${RESET}"

# install qtile
sudo -i -u $git_username <<EOF
pyenv virtualenv-delete -f qtile
pyenv install --list | grep " 3.9" | tail -1 | xargs -I % pyenv virtualenv % qtile
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv activate qtile
pip install dbus-next psutil qtilecat
pyenv deactivate
EOF

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
# setup docker
#==============================================================================
echo "${BOLD}${CYAN}Setting up docker...${RESET}"

# Install Docker
dnf -y install moby-engine
# Start & enable Docker daemon
systemctl enable --now docker.service

#==============================================================================
# setup aws-cli-2
#==============================================================================
echo "${BOLD}${CYAN}Installing aws-cli-2...${RESET}"

dnf -y copr enable spot/aws-cli-2
dnf -y install aws-cli-2

#==============================================================================
# install fonts
#==============================================================================
echo "${BOLD}${CYAN}Installing fonts...${RESET}"

rm -rf /tmp/nerd-fonts
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git /tmp/nerd-fonts
sudo -i -u $git_username bash /tmp/nerd-fonts/install.sh Hack
sudo -i -u $git_username bash /tmp/nerd-fonts/install.sh FiraCode
sudo -i -u $git_username bash /tmp/nerd-fonts/install.sh SourceCodePro
dnf -y install msttcore-fonts-installer

#==============================================================================
# misc
#==============================================================================
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p

#==============================================================================
# Set performance profile
#==============================================================================
systemctl enable --now tuned
tuned-adm profile desktop

#==============================================================================
# setup gnome desktop
#==============================================================================
echo "${BOLD}${CYAN}Setting up Gnome theme...${RESET}"

# install dependencies
dnf -y install gnome-themes-extra gtk-murrine-engine
# install gtk theme
rm -rf /tmp/Orchis-theme
git clone https://github.com/vinceliuice/Orchis-theme.git /tmp/Orchis-theme
sudo -i -u $git_username bash /tmp/Orchis-theme/install.sh --theme default

# install icon theme
sudo -i -u $git_username wget -qO- https://git.io/papirus-icon-theme-install | sh

# set up themes
gsettings set org.gnome.desktop.interface gtk-theme "Orchis-dark"
gsettings set org.gnome.desktop.wm.preferences theme "Orchis-dark"
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

echo "${BOLD}Setting up Gnome desktop gsettings...${RESET}"

gsettings set org.gnome.desktop.session idle-delay 2400

#Usability Improvements
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

#Nautilus (File Manager) Usability
gsettings set org.gtk.Settings.FileChooser sort-directories-first true

#==============================================================================
# done
#==============================================================================
cat <<EOF
=============================================================================
Congratulations, everything is set up ! ✨ 🍰 ✨

Non-automasided tasks:${YELLOW}
- gnome-extensions: ${YELLOW}https://extensions.gnome.org/extension/3843/just-perfection/
- btrfs filesystem optimizations: https://mutschler.eu/linux/install-guides/fedora-post-install/#btrfs-filesystem-optimizations
${RESET}

Please reboot 🚀
=============================================================================
EOF
