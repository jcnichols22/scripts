# Empty Recycle Bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Delete temp files in user's temp directory
Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue

# Delete temp files in Windows temp directory
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Stop Windows Update service before cleaning update cache
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue

# Delete Windows Update cache files
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue

# Restart Windows Update service
Start-Service -Name wuauserv -ErrorAction SilentlyContinue

# Run Disk Cleanup quietly (sagerun uses settings saved with sageset 1)
cleanmgr /sagerun:1

# Run DISM to clean component store and restore health
dism.exe /Online /Cleanup-Image /RestoreHealth
dism.exe /Online /Cleanup-Image /StartComponentCleanup
dism.exe /Online /Cleanup-Image /SPSuperseded

# Optional: clean thumbnail cache (uncomment if needed)
# Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue

Write-Host "Recycle Bin emptied and Windows cleanup completed."
