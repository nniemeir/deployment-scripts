# Deployment Script

This script automates deployment of my working environment in Fedora Sway 41. More environments may be added in the future if necessary.

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
| Customization  | Papirus Icon Theme, vim-plug  |
| Development  | android-tools, cargo, Qt Creator, VS Code  |
| Gaming  | Lutris, ProtonUp-Qt, Steam |
| General  | fzf, kitty, ranger, zsh |
| Multimedia  | GIMP, feh, mpv, OBS |
| Security  | clamav, nmap |
| Virtualization  | kernel-headers, kernel-devel, @virtualization |

### Windows 11
* Removes 40+ unnecessary packages
* Installs a variety of software via winget:

| Category      | Examples      |
| ------------- | ------------- |
| Academic  | LibreOffice, Qalculate, TeX Live |
| Customization  | AutoHotKey, TranslucentTB, OpenRGB  |
| Development  | Git, Python, VS Code |
| Gaming  | Discord, Steam |
| General  | fzf, PowerToys, Transmission|
| Multimedia  | FreeTube, GIMP, mpv, OBS |
| Virtualization  | VirtualBox |

* Installs Chocolately and mpvio with it
* Enables Microsoft-Windows-Subsystem-Linux and VirtualMachinePlatform features, which are needed for WSL2 to function.

## License
GNU General Public License V2

Copyright (c) 2025 Jacob Niemeir
