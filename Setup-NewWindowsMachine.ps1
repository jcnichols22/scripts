# Run PowerShell as Administrator!

# Suppress confirmation prompts globally
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'
$ConfirmPreference = 'None'

# Upgrade all existing winget packages first
Write-Host "Upgrading all installed winget packages..."
winget upgrade --all --accept-source-agreements --accept-package-agreements --silent -h

# Run Windows Update to install all available updates (no auto-reboot mid-process)
Write-Host "Running Windows Update to install all available updates..."
Install-PackageProvider -Name NuGet -Force -Confirm:$false | Out-Null
Install-Module PSWindowsUpdate -Force -Confirm:$false
Import-Module PSWindowsUpdate
Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -Confirm:$false

# Set power plan to High Performance
Write-Host "Setting power plan to High Performance..."
powercfg -setactive SCHEME_MIN

# Define apps to install
$apps = @(
    "Brave.Brave",
    "Microsoft.VisualStudioCode",
    "Obsidian.Obsidian",
    "SteelSeries.GG",
    "Discord.Discord",
    "Valve.Steam",
    "PuTTY.PuTTY",
    "Asus.ArmouryCrate",
    "AOMEI.Backupper.Standard",
    "AOMEI.PartitionAssistant",
    "RevoUninstaller.RevoUninstaller",
    "AgileBits.1Password",
    "Nextcloud.NextcloudDesktop",
    "Apple.iCloud",
    "Proton.ProtonVPN",
    "Microsoft.PowerToys",
    "tailscale.tailscale",
    "CharlesMilette.TranslucentTB",
    "AntoineAflalo.SoundSwitch",
    "7zip.7zip",
    "Rufus.Rufus",
    "EpicGames.EpicGamesLauncher"
)

# Install apps with auto-confirmation and silent mode
foreach ($app in $apps) {
    Write-Host "Installing $app..."
    try {
        winget install --id=$app -e --silent --accept-source-agreements --accept-package-agreements -h --disable-interactivity
        Write-Host "$app installed successfully."
    }
    catch {
        Write-Warning "Failed to install $app. Error details: $_"
    }
}

# Set Brave as the default browser
Write-Host "Setting Brave Browser as default..."
$BraveProgId = "BraveHTML"

$associations = @{
    "http"  = $BraveProgId
    "https" = $BraveProgId
    ".htm"  = $BraveProgId
    ".html" = $BraveProgId
}

foreach ($assoc in $associations.GetEnumerator()) {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\$($assoc.Key)\UserChoice" -Name "ProgId" -Value $assoc.Value -ErrorAction Stop
        Write-Host "Set default for $($assoc.Key) to $($assoc.Value)"
    }
    catch {
        Write-Warning "Failed setting default for $($assoc.Key): $_"
    }
}

# Taskbar Customizations

# Center the taskbar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 1

# Hide Search from taskbar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchBoxTaskbarMode" -Value 0

# Hide Task View button
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0

# Hide Widgets
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0

# Enable auto-hide for system tray icons
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Value 1

# Set Windows to Dark Mode (for system and apps)
Write-Host "Setting Windows Dark Mode..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0

# Restart Explorer to apply visual changes
Stop-Process -Name explorer -Force
Start-Process explorer.exe

Write-Host "Setup and customizations completed. System will now restart in 15 seconds..."
Start-Sleep -Seconds 15
Restart-Computer -Force
