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

# Capture update installation results
$updateResults = Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -Confirm:$false

# Check if reboot is pending from Windows Update registry key
$rebootRequired = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"

# Set power plan to High Performance
Write-Host "Setting power plan to High Performance..."
powercfg -setactive SCHEME_MIN

# Define apps to install
$apps = @(
    # (your list of apps as before)
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
    "EpicGames.EpicGamesLauncher",
    "Git.Git"
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

# Set Brave as default browser
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
# (same as before)
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchBoxTaskbarMode" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Value 1

# Windows Dark Mode
Write-Host "Setting Windows Dark Mode..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0

# Restart Explorer to apply visual changes
Stop-Process -Name explorer -Force
Start-Process explorer.exe

# Conditional reboot logic: reboot only if updates installed or reboot pending
if (($updateResults -and $updateResults.Count -gt 0) -or $rebootRequired) {
    Write-Host "Updates installed or reboot required. System will reboot in 15 seconds..."
    Start-Sleep -Seconds 15
    Restart-Computer -Force
} else {
    Write-Host "No updates or reboot needed. Setup completed."
}
