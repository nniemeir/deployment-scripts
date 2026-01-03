function Main {
    Remove-Bloatware
    Install-Choco
    Install-Software
    Enable-WSL-Features
    Restart-Computer
}

Function Remove-Bloatware {
    $Bloatware = @(
        "Clipchamp.Clipchamp"
        "Microsoft.549981C3F5F10" #Cortana
        "Microsoft.BingNews"
        "Microsoft.BingSearch"
        "Microsoft.BingWeather"
        "Microsoft.GamingApp"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MicrosoftStickyNotes"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.News"
        "Microsoft.Office.Lens"
        "Microsoft.Office.OneNote"
        "Microsoft.Office.Sway"
        "Microsoft.Office.Todo.List"
        "Microsoft.OneConnect"
        "Microsoft.OneDriveSync"
        "Microsoft.OutlookForWindows"
        "Microsoft.Paint"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.RemoteDesktop"
        "Microsoft.SkypeApp"
        "Microsoft.StartExperiencesApp"
        "Microsoft.Todos"
        "Microsoft.Whiteboard"
        "Microsoft.WindowsAlarms"
        "Microsoft.WindowsCamera"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsNotepad"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.YourPhone"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "MicrosoftCorporationII.QuickAssist"
    )
    foreach ($Bloat in $Bloatware) {
        Get-AppxPackage -Name $Bloat | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
        Write-Output "Trying to remove $Bloat."
    }
}

Function Install-Choco() {
    Set-ExecutionPolicy Bypass -Scope Process -Force; 
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Function Install-Software() {
    $WingetPackages = @(
        "9PF4KZ2VN4W9" # Translucent TB
        "9PNRBTZXMB4Z" #Python
        "Audacity.Audacity"
        "AutoHotkey.AutoHotkey"
        "Discord.Discord"
        "Fastfetch-cli.Fastfetch"
        "Git.Git"
        "gokcehan.lf"
        "junegunn.fzf"
        "KDE.Kdenlive"
        "Mega.MEGASync"
        "Microsoft.VisualStudioCode"
        "MiKTeX.MiKTeX"
        "Mozilla.Firefox"
        "Mozilla.Thunderbird"
        "MSYS2.MSYS2"
        "Neovim.Neovim"
        "OBSProject.OBSStudio"
        "OpenRGB.OpenRGB"
        "Oracle.VirtualBox"
        "PrestonN.FreeTube"
        "Transmission.Transmission"
        "UniversalCtags.Ctags"
        "Valve.Steam"
        "XP89DCGQ3K6VLD" # Powertoys
        "yt-dlp.yt-dlp"
    )
    foreach ($package in $WingetPackages) {
        Write-Host "Trying to install $package"
        winget install --id "$package" --accept-source-agreements --accept-package-agreements
    }
    
    $ChocoPackages = @(
        "mpvio"
    )
    foreach ($package in $ChocoPackages) {
        Write-Host "Trying to install $package"
        choco install $package
    }
}

# Enable optional features required for WSL to function
Function Enable-WSL-Features() {
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All
    Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All
}

Main