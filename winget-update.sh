#script to update all installed applications using winget and automatically handle errors and answers yes to prompts

#!/bin/bash
# Check if winget is installed
if ! command -v winget &> /dev/null; then
    echo "winget is not installed. Please install it first."
    exit 1
fi
# Update all installed applications
winget upgrade --all --silent --accept-source-agreements --accept-package-agreements
# Check if the update command was successful
if [ $? -eq 0 ]; then
    echo "All applications have been updated successfully."
else
    echo "There was an error updating the applications. Please check the output above for details."
fi
# Optionally, you can add a log file to capture the output
LOGFILE="winget_update.log"
winget upgrade --all --silent --accept-source-agreements --accept-package-agreements > "$LOGFILE" 2>&1
# Check if the log file was created successfully
if [ -f "$LOGFILE" ]; then
    echo "The update log has been saved to $LOGFILE."
else
    echo "Failed to create the log file."
fi
# End of script
# Note: This script assumes that you have the necessary permissions to run winget commands and that your system is configured to allow script execution.
