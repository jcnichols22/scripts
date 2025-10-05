# Run PowerShell as Administrator!

# Upgrade all existing winget packages first
Write-Host "Upgrading all installed winget packages..."
winget upgrade --all --accept-source-agreements --accept-package-agreements

# Run Windows Update to get OS, drivers, and service updates
Write-Host "Running Windows Update to install all available updates..."
Install-Module PSWindowsUpdate -Force -Confirm:$false
Import-Module PSWindowsUpdate
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

# Set power plan to High Performance
Write-Host "Setting power plan to High Performance..."
powercfg -setactive SCHEME_MIN

# Define apps to install
$apps = @(
    "Brave.Brave",                     # Brave Browser
    "Microsoft.VisualStudioCode",      # VS Code
    "Obsidian.Obsidian",               # Obsidian Notes
    "SteelSeries.GG",                  # SteelSeries GG
    "Discord.Discord",                 # Discord
    "Valve.Steam",                     # Steam
    "PuTTY.PuTTY",                     # PuTTY
    "Asus.ArmouryCrate",               # Asus Armoury Crate
    "AOMEI.Backupper.Standard",        # AOMEI Backupper
    "AOMEI.PartitionAssistant",        # AOMEI Partition Assistant
    "RevoUninstaller.RevoUninstaller", # Revo Uninstaller
    "AgileBits.1Password",             # 1Password
    "Nextcloud.NextcloudDesktop",      # Nextcloud Client
    "Apple.iCloud",                    # iCloud
    "Proton.ProtonVPN",                # Proton VPN
    "Microsoft.PowerToys",             # PowerToys
    "tailscale.tailscale",             # Tailscale
    "CharlesMilette.TranslucentTB",    # TranslucentTB
    "AntoineAflalo.SoundSwitch",       # SoundSwitch
    "7zip.7zip",                       # 7-Zip
    "Rufus.Rufus"                      # Rufus
    "EpicGames.EpicGamesLauncher"      # Epic Games Launcher
)

foreach ($app in $apps) {
    Write-Host "Installing $app..."
    try {
        winget install --id=$app -e --silent --accept-source-agreements --accept-package-agreements -h
        Write-Host "$app installed successfully."
    }
    catch {
        Write-Warning "Failed to install $app. Error details: $_"
    }
}

# Set Brave as the default browser
Write-Host "Setting Brave Browser as default..."
$BraveProgId = "BraveHTML"  # Typical ProgId for Brave; verify on target system if needed

# Function to set default apps for protocols and file types
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

# Restart Explorer to apply all changes
Stop-Process -Name explorer -Force
Start-Process explorer.exe

Write-Host "Setup and customizations completed."
