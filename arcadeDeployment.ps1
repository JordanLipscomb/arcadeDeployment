### Questions

##
## In the while loops, like the one for deleting folder contents starting on line 54,
## will it restart the delete action if the while loop doesn't return false?
## 
## On line 28, does the while($procWithWindows) statment, the way it is written, return a true boolean
## if there are active windows?
##

### Initialization

# Lock the computer
############rundll32.exe user32.dll, LockWorkStation

## Set variables
# Bool for successful copy task
#$allFilesCopied = $null
# Specify the source folder where files are being copied from
#$sourFol = "C:\Path\to\source\folder"
# Specify the destination folder where files are being copied to
#$destFol = "C:\Path\to\destination\folder"
# Check if the destination folder is empty
#$emptyDestFol = (Get-ChildItem -Path $destFol -Force -File).Count -gt 0

### Primary tasks

## Close active windows task
# Get the current PowerShell process ID
$currentProcessId = $PID
# Specify the program process name to close that has an active window
$procWithWindows = Get-Process | Where-Object { $_.MainWindowTitle -ne "" -and $_.ProcessName -ne "powershell" -and $_.Id -ne $currentProcessId }
# Finds if there are active windows and checks every 5 seconds until there are no active windows
while ($procWithWindows) {
    Write-Host "Active Windows Found:"
    foreach ($process in $procWithWindows) {
        #Specific active windows in the log
        Write-Host "Process Name: $($process.ProcessName)"
        Write-Host "Window Title: $($process.MainWindowTitle)"
        Write-Host "Process ID: $($process.Id)"
        Write-Host "----------------------"
        # Close the specified active windows
        Stop-Process -Id $process.Id -Force
    }
    Start-Sleep -Seconds 5
}
Write-Host "No active windows found."

# ## Deleting files task
# Write-Host "Deleting contents of $destFol..."
# # Loop until the folder is empty
# while ($emptyDestFol) {
#     # Delete all files and subfolders within the destination folder
#     Get-ChildItem -Path $destFol -Force | Remove-Item -Force -Recurse
#     # Wait for a short period before checking again
#     Start-Sleep -Seconds 5
# }
# Write-Host "Folder is empty."

# ## Copying files task
# # Run the copy function
# gameCopyTask

# if ($allFilesCopied -eq $true) {
#     Write-Host "All files were copied successfully."
#     # Restart the computer
#     Write-Host "Restarting the computer..."
#     #################Restart-Computer -Force
# }
# else {
#     Write-Host "There were some errors copying the files. Attempting another copy task"
#     gameCopyTask
# }

# ### Functions
# function gameCopyTask {
#     # Copy the contents of the source folder to the destination folder
#     Write-Host "Copying files from $sourFol to $destFol..."
#     $copyTask = Copy-Item -Path $sourFol\* -Destination $destFol -Force -Recurse -PassThru
#     # Check if the copying action is still ongoing
#     while ($copyTask.Status -eq "Running") {
#         # Wait for a short duration before checking again
#         Start-Sleep -Seconds 5
#     }
#     # Check if the children files in the source folder are the same as the destination folder
#     $sourceFiles = Get-ChildItem -Path $sourFol -File -Recurse | Select-Object -ExpandProperty FullName
#     $destinationFiles = Get-ChildItem -Path $destFol -File -Recurse | Select-Object -ExpandProperty FullName
#     $areFilesEqual = Compare-Object -ReferenceObject $sourceFiles -DifferenceObject $destinationFiles -IncludeEqual
#     if ($null -eq $areFilesEqual) {
#         Write-Host "All files have been successfully copied to $destFol."
#         global:$allFilesCopied = $true
#     }
#     else {
#         Write-Host "Some files were not copied correctly. Differences found:"
#         $areFilesEqual | ForEach-Object {
#             if ($_.SideIndicator -eq "==") {
#                 Write-Host "File exists in both folders: $($_.InputObject)"
#             }
#             elseif ($_.SideIndicator -eq "=>") {
#                 Write-Host "File was not copied correctly: $($_.InputObject)"
#             }
#             elseif ($_.SideIndicator -eq "<=") {
#                 Write-Host "File exists in destination folder but not in source folder: $($_.InputObject)"
#             }
#         }
#         global:$allFilesCopied = $false
#     }
# }
