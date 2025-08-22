# Deployment Scripts

This script automates deployment of my working environment in Fedora Sway 41. More environments may be added in the future if necessary.

## Features
* Primes the system for deployment by doing the following:
  * Installing dialog (script dependency), Flatpak, and Git
  * Enables free and non-free RPM fusion repositories
  * Adds Flathub Repository
  * Adjusts dnf config for improved download speeds
* Installs a variety of software:

| Category      | Examples      |
| ------------- | ------------- |
| Academic  | LibreOffice, Pandoc, Qalc, TeX Live |
| Customization  | Papirus Icon Theme, vim-plug  |
| Development  | android-tools, cargo, Qt Creator, VS Code  |
| Gaming  | Lutris, ProtonUp-Qt, Steam |
| General  | fzf, kitty, ranger, zsh |
| Multimedia  | GIMP, feh, mpv, OBS |
| Security  | clamav, nmap |
| Virtualization  | kernel-headers, kernel-devel, @virtualization |

## License
GNU General Public License V2

Copyright (c) 2025 Jacob Niemeir
