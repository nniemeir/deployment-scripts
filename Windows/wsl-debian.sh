#! /bin/bash
# Author: Jacob Niemeir <nniemeir@protonmail.com>

main() {
    pre_deployment
    deployment
}

apt_install() {
    local packages=("${@}")
    for package in "${packages[@]}"; do
        if ! sudo apt install "$package" -y; then
            echo "Failed to install $package"
            exit 1
        fi
    done
}

pre_deployment() {
    echo "Installing script dependencies"
    aptDependencies=('dialog' 'git')
    apt_install "${aptDependencies[@]}"
}

deployment() {
    cmd=(dialog --separate-output --checklist "Select Software Categories To Install:" 40 86 26)
    options=(
        1 "Academic" on
        2 "Development" on
        3 "General" on
        4 "Multimedia" on
        5 "Security" on
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    for choice in $choices; do
        case $choice in
        1)
            echo "Installing Academic Tools"
            apt_academic=('neovim' 'qalc' 'texlive-full')
            apt_install "${apt_academic[@]}"
            ;;
        2)
            echo "Installing Development Tools"
            apt_dev=('g++' 'hexedit' 'libssl-dev' 'python')
            apt_install "${apt_dev[@]}"
            ;;
        3)
            echo "Installing General Tools"
            apt_general=('curl' 'fzf' 'htop' 'pip' 'ranger' 'unzip' 'zsh')
            apt_install "${apt_general[@]}"
            echo "Changing default shell to ZSH"
            chsh -s $(which zsh)
            ;;
        4)
            echo "Installing Multimedia Software"
            apt_media=('ffmpeg')
            apt_install "${apt_media[@]}"
            ;;
        5)
            echo "Installing Security Tools"
            apt_security=('clamav' 'nmap')
            apt_install "${apt_security[@]}"
            sudo systemctl stop clamav-freshclam
            sudo freshclam
            sudo systemctl start clamav-freshclam
            sudo systemctl enable clamav-freshclam
            ;;
        esac
    done
}

main "$@"
