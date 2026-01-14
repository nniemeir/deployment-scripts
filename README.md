# Deployment Scripts

These scripts and playbooks automate deployment of my working environment in Fedora Sway 41, Windows 11, and WSL Debian. More environments may be added in the future if necessary.

## Features
### Fedora
* Primes the system for deployment by doing the following:
  * Installing dialog (script dependency), Flatpak, and Git
  * Enables free and non-free RPM fusion repositories
  * Adds Flathub Repository
  * Adjusts dnf config for improved download speeds
* Installs a variety of software:

| Category      | Examples      |
| ------------- | ------------- |
| Academic  | LibreOffice, Pandoc, Qalculate, TeX Live |
| Development  | android-tools, cargo, Qt Creator, VS Code  |
| Gaming  | Lutris, ProtonUp-Qt, Steam |
| General  | fzf, kitty, ranger, zsh |
| Multimedia  | GIMP, feh, mpv, OBS |
| Security  | clamav, nmap |
| Theming  | Papirus Icon Theme, vim-plug  |
| Virtualization  | kernel-headers, kernel-devel, @virtualization |

* Creates symlinks in user's home directory to game and media drive mountpoints
* Ensures basic security:
  * SELinux enabled and enforcing
  * Hardens some kernel and network parameters
  * Installs clamav and enable its service
* Disables avahi-daemon, cups, and ModemManager
* Installs a hardened Firefox policies.json
* Installs Steven Black's Unified hosts + fakenews + social [hosts file](https://github.com/StevenBlack/hosts) with a few additions of my own

### Windows 11
* Removes 40+ unnecessary packages
* Installs a variety of software via winget:

| Category      | Examples      |
| ------------- | ------------- |
| Academic  | LibreOffice, Qalculate, TeX Live |
| Development  | Git, Python, VS Code |
| Gaming  | Discord, Steam |
| General  | fzf, PowerToys, Transmission|
| Multimedia  | FreeTube, GIMP, mpv, OBS |
| Theming  | AutoHotKey, TranslucentTB, OpenRGB |
| Virtualization  | VirtualBox |

* Installs Chocolately and mpvio with it
* Enables Microsoft-Windows-Subsystem-Linux and VirtualMachinePlatform features, which are needed for WSL2 to function.

## License
GNU General Public License V2

Copyright (c) 2025 Jacob Niemeir
