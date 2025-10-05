# Ensure script runs with admin privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run as Administrator"
    exit
}

# 1. Update Windows
Write-Host "Checking for Windows Updates..."
Install-Module PSWindowsUpdate -Force -Confirm:$false
Import-Module PSWindowsUpdate
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

# 2. Update Microsoft Store apps
Write-Host "Updating Microsoft Store apps..."
Get-AppxPackage -AllUsers | Foreach {
    try {
        Start-Process "ms-windows-store://downloadsandupdates"
    } catch { Write-Host "Store update trigger failed: $_" }
}

# 3. Update Winget packages
Write-Host "Updating all Winget packages..."
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements

# 4. Optional: Update Chocolatey packages (if installed)
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Updating Chocolatey packages..."
    choco upgrade all -y
}

Write-Host "All updates completed."
