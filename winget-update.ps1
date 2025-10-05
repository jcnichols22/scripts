#Powershell script to update all installed applications using winget and log the output to a file. and answer yes to all prompts.
# Usage: Run this script in PowerShell with administrative privileges.
# Define the log file path
$logFile = "C:\winget-update-log.txt"
# Start logging
Start-Transcript -Path $logFile -Append
# Update all installed applications using winget
winget upgrade --all --silent --accept-source-agreements --accept-package-agreements *>&1 | Tee-Object -FilePath $logFile
# Stop logging
Stop-Transcript
# Output the log file path
Write-Host "The update log has been saved to $logFile."
# Check if the log file exists
if (Test-Path $logFile) {
    Write-Host "The log file was created successfully."
}
else {
    Write-Host "Failed to create the log file."
}
# Open the log file in the default text editor
Invoke-Item $logFile
# End of script
# Note: Ensure that you have the necessary permissions to run this script and that winget is installed on your system.