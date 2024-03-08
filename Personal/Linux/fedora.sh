#! /bin/bash
dnfInstall() {
    local dpackages=("${@}")
    for package in "${dpackages[@]}"; do
        sudo dnf install $package -y
    done
}
flatpakInstall() {
    local fpackages=("${@}")
    for package in "${fpackages[@]}"; do
        flatpak install https://dl.flathub.org/repo/appstream/$package.flatpakref -y
    done
}

preDeployment() {
    echo "Installing script dependencies"
    sudo dnf install dialog flatpak git -y
    echo "Enabling RPM Fusion"
    sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
    sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
    echo "Installing Flatpak"
    sudo dnf install flatpak -y
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
            dnfAcademic=('neovim' 'qalc' 'texlive-scheme-full' 'zathura' 'zathura-pdf-mupdf')
            flatpakAcademic=('com.discordapp.Discord' 'org.libreoffice.LibreOffice' 'nz.mega.MEGAsync' 'md.obsidian.Obsidian' 'org.mozilla.Thunderbird')
            dnfInstall "${dnfAcademic[@]}"
            flatpakInstall "${flatpakAcademic[@]}"
            ;;
        2)
            echo "Installing Themes & Configurations"
            dnfTheming=('papirus-icon-theme')
            dnfInstall "${dnfTheming[@]}"
            sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
            wget -qO- https://git.io/papirus-folders-install | sh
            echo "Setting Themes"
            gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
            ;;
        3)
            echo "Installing Development Tools"
            dnfDev=('g++')
            flatpakDev=('com.visualstudio.code-oss')
            sudo dnf groupinstall "Development Tools" -y
            dnfInstall "${dnfDev[@]}"
            flatpakInstall "${flatpakDev[@]}"
            ;;
        4)
            echo "Installing Gaming Software"
            dnfGaming=('lutris' 'steam')
            dnfInstall "${dnfGaming[@]}"
            flatpakGaming=('org.openrgb.OpenRGB' 'net.davidotek.pupgui2')
            flatpakInstall "${flatpakGaming[@]}"
            echo "Installing openRGB udev rules"
            wget "https://openrgb.org/releases/release_0.9/openrgb-udev-install.sh"
            chmod +x openrgb-udev-install.sh
            ./openrgb-udev-install.sh
            rm -rf openrgb-udev-install.sh
            ;;
       
	 5)
            echo "Installing General Tools"
            dnfSys=('fontawesome4-fonts' 'fzf' 'gvfs' 'gvfs-mtp' 'htop' 'kitty' 'pip' 'ranger' 'unzip' 'zsh')
            dnfInstall "${dnfSys[@]}"
	    echo "Changing default shell to ZSH"
            chsh -s $(which zsh)
            flatpakSys=('org.bleachbit.BleachBit' 'com.github.tchx84.Flatseal')
            flatpakInstall "${flatpakSys[@]}"
            echo "Creating Symlinks To External Storage"
            sudo mkdir ~/Drives/ /mnt/games/ /mnt/media/
            sudo ln -s /mnt/games/Games ~/Drives/Games
            sudo ln -s /mnt/media ~/Drives/Media
            ;;
   	 6)
            echo "Installing Multimedia Software"
            sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel -y
            sudo dnf install lame\* --exclude=lame-devel -y
            sudo dnf group upgrade --with-optional Multimedia -y
            dnfMedia=('cmus' 'feh' 'mpv' 'mpv-mpris')
            dnfInstall "${dnfMedia[@]}"
	    sudo dnf install ffmpeg -y --allowerasing
            flatpakMedia=('io.freetubeapp.FreeTube' 'org.gimp.GIMP' 'com.obsproject.Studio' 'com.transmissionbt.Transmission')
            flatpakInstall "${flatpakMedia[@]}"
            ;;
        7)
            echo "Installing Security Tools"
            dnfSec=('clamav' 'clamd' 'clamav-update' 'nmap')
            dnfInstall "${dnfSec[@]}"
            sudo setsebool -P antivirus_can_scan_system 1
            sudo systemctl stop clamav-freshclam
            sudo freshclam
            sudo systemctl start clamav-freshclam
            sudo systemctl enable clamav-freshclam
            ;;
        8)
            echo "Installing Virtualization Software"
            dnfVirt=('bridge-utils' 'dkms' 'kernel-headers' 'kernel-devel' '@virtualization')
            dnfInstall "${dnfVirt[@]}"
            sudo systemctl enable libvirtd
	    sudo systemctl start libvirtd
	    sudo usermod -a -G libvirt $USER
	    sudo sed -i "s|#unix_sock_group|unix_sock_group|" "/etc/libvirt/libvirtd.conf"
	    sudo sed -i "s|#unix_sock_rw_perms|unix_sock_rw_perms|" "/etc/libvirt/libvirtd.conf"
	    ;;
        *)
            echo "Invalid choice"
            ;;
        esac
    done
}

rebootPrompt() {
    read -p "Deployment Complete. Reboot? (y/n): " rebootChoice
    if [ "$rebootChoice" = "y" ]; then
        sudo reboot
    else
        echo "Exiting..."
        exit 0
    fi
}

main() {
    preDeployment
    deployment
    rebootPrompt
}

main
