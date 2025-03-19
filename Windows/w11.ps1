function Main {
    Remove-Bloatware
    Install-Software
    Enable-WSL-Features
    Restart-Computer
}

# From Chris Titus' Debloat Script, removes default applications that I don"t use
Function Remove-Bloatware {
    $Bloatware = @(
        "Microsoft.BingNews"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.News"
        "Microsoft.Office.Lens"
        "Microsoft.Office.OneNote"
        "Microsoft.Office.Sway"
        "Microsoft.Office.Todo.List"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.RemoteDesktop"
        "Microsoft.SkypeApp"
        "Microsoft.Whiteboard"
        "Microsoft.WindowsAlarms"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
    )
    foreach ($Bloat in $Bloatware) {
        Get-AppxPackage -Name $Bloat | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
        Write-Output "Trying to remove $Bloat."
    }
}

Function Install-Software() {
    $DesiredPackages = @(
        "9MSVKQC78PK6"
        "9PF4KZ2VN4W9"
        "Audacity.Audacity"
        "AutoHotkey.AutoHotkey"
        "Discord.Discord"
        "ExpressVPN.ExpressVPN"
        "Mega.MEGASync"
        "Microsoft.VisualStudioCode"
        "Mozilla.Firefox"
        "Mozilla.Thunderbird"
        "Oracle.VirtualBox"
        "PrestonN.FreeTube"
        "Transmission.Transmission"
        "Valve.Steam"
        "VideoLAN.VLC"
        "junegunn.fzf"
        )
    foreach ($package in $DesiredPackages) {
        Write-Host "Trying to install $package"
        winget install "$package" --accept-source-agreements --accept-package-agreements
    }
}

# Enable optional features required for WSL to function
Function Enable-WSL-Features() {
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All
    Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All
}

Main
