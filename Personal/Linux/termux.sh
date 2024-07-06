#!/bin/bash
# Author: Jacob Niemeir <nniemeir@protonmail.com>

preDeployment() {
echo "Updating Packages"
pkg update >/dev/null 2>&1
pkg upgrade -y >/dev/null 2>&1
echo "Selecting Mirrors"
termux-change-repo
echo "Setting Up Storage Permissions"
termux-setup-storage
echo "Disabling Default Banner"
touch "$HOME/.hushlogin"
}

deployment() {
    cmd=(dialog --separate-output --checklist "Select Software Categories To Install:" 40 86 26)
    options=(
	1 "AwesomeWM"
	2 "Development" on
	3 "General Utilities" on
	4 "Mathematics" on
	5 "Multimedia" on
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    for choice in $choices; do
        case $choice in
	1)
	    pkg install x11-repo -y >/dev/null 2>&1
	    pkg install tigervnc -y >/dev/null 2>&1
	    vncserver -localhost
	    pkg install awesome feh kitty nitrogen picom rofi scrot -y >/dev/null 2>&1
	    ;;
    	2)
	    pkg install clang git jq openjdk-17 python -y >/dev/null 2>&1
	    ;;
    	3)
	    pkg install entr fzf htop man neovim newsboat nmap ranger zsh wget -y >/dev/null 2>&1
	    echo "Setting Up OhMyZSH"
	    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 
            echo "Configuring NeoVIM"
            sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	    ;;
	4)
            pkg install gnuplot pandoc qalc texlive-installer -y >/dev/null 2>&1
	    echo "Setting Up LaTeX"
	    termux-install-tl
	    termux-patch-texlive
	    ;;
    	5)
	    pkg install exiftool ffmpeg imagemagick mpv -y >/dev/null 2>&1 
	    python3 -m pip install -U yt-dlp >/dev/null 2>&1
	    ;;
    	*)
	    echo "Invalid choice"
	    ;;
	esac
	done
}

main() {
preDeployment
deployment
}

main

