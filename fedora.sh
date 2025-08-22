#! /bin/bash

main() {
    pre_deployment
    deployment
    reboot_prompt
}

dnf_install() {
    local dpackages=("${@}")
    for package in "${dpackages[@]}"; do
        if ! sudo dnf install $package -y; then
            echo "Failed to install $package, exiting..."
            exit 1
        fi
    done
}

flatpak_install() {
    local fpackages=("${@}")
    for package in "${fpackages[@]}"; do
        if ! flatpak install https://dl.flathub.org/repo/appstream/$package.flatpakref -y; then
            echo "Failed to install $package, exiting..."
            exit 1
        fi
    done
}

pre_deployment() {
    echo "Installing script dependencies"
    dnf_dependencies=('dialog' 'flatpak' 'git')
    dnf_install "${dnf_dependencies[@]}"
    echo "Enabling RPM Fusion"
    sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
    sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
    echo "Adding Flatpak Repository"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo -y
    echo "Tuning dnf"
    sudo tee -a /etc/dnf/dnf.conf <<END
fastestmirror=true
deltarpm=true
max_parallel_downloads=10
END
}

deployment() {
    cmd=(dialog --separate-output --checklist "Select Software Categories To Install:" 40 86 26)
    options=(
        1 "Academic" on
        2 "Configuration/Theming" off
        3 "Development" on
        4 "Gaming" off
        5 "General" on
        6 "Multimedia" on
        7 "Security" on
        8 "Virtualization" off
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    for choice in $choices; do
        case $choice in
        1)
            echo "Installing Academic Tools"
            dnf_academic=('neovim' 'pandoc' 'qalc' 'texlive-scheme-full' 'zathura' 'zathura-pdf-mupdf')
            flatpak_academic=('org.libreoffice.LibreOffice' 'nz.mega.MEGAsync' 'org.mozilla.Thunderbird')
            dnf_install "${dnf_academic[@]}"
            flatpak_install "${flatpak_academic[@]}"
            ;;
        2)
            echo "Installing Themes & Configurations"
            dnf_theming=('fontawesome4-fonts' 'papirus-icon-theme')
            dnf_install "${dnf_theming[@]}"
            sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
            wget -qO- https://git.io/papirus-folders-install | sh
            echo "Setting Themes"
            gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
            ;;
        3)
            echo "Installing Development Tools"
            dnf_dev=('android-tools' 'cargo' 'g++' 'hexedit' 'openssl-devel' 'readline-devel' 'SDL2-devel' 'SDL2_ttf-devel')
            flatpak_dev=('com.visualstudio.code-oss' 'io.qt.QtCreator')
            sudo dnf groupinstall "Development Tools" -y
            dnf_install "${dnf_dev[@]}"
            flatpak_install "${flatpak_dev[@]}"
            ;;
        4)
            echo "Installing Gaming Software"
            dnf_gaming=('lutris' 'steam')
            dnf_install "${dnf_gaming[@]}"
            flatpak_gaming=('org.openrgb.OpenRGB' 'net.davidotek.pupgui2')
            flatpak_install "${flatpak_gaming[@]}"
            echo "Installing openRGB udev rules"
            wget "https://openrgb.org/releases/release_0.9/openrgb-udev-install.sh"
            chmod +x openrgb-udev-install.sh
            ./openrgb-udev-install.sh
            rm -rf openrgb-udev-install.sh
            ;;

        5)
            echo "Installing General Tools"
            dnf_general=('fzf' 'gvfs' 'gvfs-mtp' 'htop' 'kitty' 'light' 'python3-pip' 'ranger' 'unzip' 'zsh')
            dnf_install "${dnf_general[@]}"
            echo "Changing default shell to ZSH"
            chsh -s $(which zsh)
            flatpak_general=('org.bleachbit.BleachBit' 'com.github.tchx84.Flatseal')
            flatpak_install "${flatpak_general[@]}"
            echo "Creating Symlinks To External Storage"
            sudo mkdir -p ~/Drives/ /mnt/games/ /mnt/media/
            sudo ln -s /mnt/games/Games ~/Drives/Games
            sudo ln -s /mnt/media ~/Drives/Media
            ;;
        6)
            echo "Installing Multimedia Software"
            sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel -y
            sudo dnf install lame\* --exclude=lame-devel -y
            sudo dnf group upgrade --with-optional Multimedia -y
            dnf_media=('feh' 'mpc' 'mpd' 'mpv' 'mpv-mpris')
            dnf_install "${dnf_media[@]}"
            sudo dnf install ffmpeg -y --allowerasing
	    cargo install rmpc --locked
            flatpak_media=('ca.littlesvr.asunder' 'io.freetubeapp.FreeTube' 'org.gimp.GIMP' 'com.obsproject.Studio' 'org.kde.kdenlive' 'org.musicbrains.Picard')
            flatpak_install "${flatpak_media[@]}"
            ;;
        7)
            echo "Installing Security Tools"
            dnf_security=('clamav' 'clamd' 'clamav-update' 'nmap')
            dnf_install "${dnf_security[@]}"
            sudo setsebool -P antivirus_can_scan_system 1
            sudo systemctl stop clamav-freshclam
            sudo freshclam
            sudo systemctl start clamav-freshclam
            sudo systemctl enable clamav-freshclam
            ;;
        8)
            echo "Installing Virtualization Software"
            dnf_virtualization=('bridge-utils' 'dkms' 'kernel-headers' 'kernel-devel' '@virtualization')
            dnf_install "${dnf_virtualization[@]}"
            sudo systemctl enable libvirtd
            sudo systemctl start libvirtd
            sudo usermod -a -G libvirt "$USER"
            sudo sed -i "s|#unix_sock_group|unix_sock_group|" "/etc/libvirt/libvirtd.conf"
            sudo sed -i "s|#unix_sock_rw_perms|unix_sock_rw_perms|" "/etc/libvirt/libvirtd.conf"
            ;;
        *)
            echo "Invalid choice"
            ;;
        esac
    done
}

reboot_prompt() {
    read -p "Deployment Complete. Reboot? (y/n): " reboot_choice
    if [ "$reboot_choice" = "y" ]; then
        sudo reboot
    else
        echo "Exiting..."
        exit 0
    fi
}

main "$@"
