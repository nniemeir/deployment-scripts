#!/bin/bash
# Author: Jacob Niemeir <nniemeir@protonmail.com>

main() {
	pre_deployment
	deployment
}

pkg_install() {
	local packages=("${@}")
	for package in "${packages[@]}"; do
		if ! pkg install $package; then
			echo "Failed to install $package, exiting..."
			exit 1
		fi
	done
}

pre_deployment() {
	echo "Updating Packages"
	pkg update
	pkg upgrade -y
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
			pkg_gui=('x11-repo' 'tigervnc' 'awesome' 'feh' 'kitty' 'nitrogen' 'picom' 'rofi' 'scrot')
			pkg_install "${pkg_gui[@]}"
			vncserver -localhost
			;;
		2)
			pkg_dev=('clang' 'git' 'python')
			pkg_install "${pkg_dev[@]}"
			;;
		3)
			pkg_general=('entr' 'fzf' 'htop' 'man' 'neovim' 'ranger' 'zsh' 'wget')
			pkg_install "${pkg_general[@]}"
			echo "Setting Up OhMyZSH"
			sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
			echo "Configuring NeoVIM"
			sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
			;;
		4)
			pkg_maths=('gnuplot' 'pandoc' 'qalc' 'texlive-installer')
			pkg_install "${pkg_maths[@]}"
			echo "Setting Up LaTeX"
			termux-install-tl
			termux-patch-texlive
			;;
		5)
			pkg_media=('exiftool' 'ffmpeg' 'imagemagick' 'mpv')
			pkg_install "${pkg_media[@]}"
			python3 -m pip install -U yt-dlp
			;;
		*)
			echo "Invalid choice"
			;;
		esac
	done
}

main "$@"
