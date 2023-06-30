### Initialization

# Lock the computer
rundll32.exe user32.dll, LockWorkStation

## Variables
# Set if the game delpoyment process to true if you want to run this process.
$runGameDeployment = $true
# Get the current PowerShell process ID
$scriptProcessId = $PID

### Primary tasks

## Close active windows task
Write-Host "Looking for active windows."
# Close File Explorer
Get-Process -Name "explorer" | Stop-Process -Force
# Specify the program process name to close that has an active window
$procWithWindows = Get-Process | Where-Object { $_.MainWindowTitle -ne "" -and $_.ProcessName -ne "powershell" -and $_.Id -ne $scriptProcessId}
# Finds if there are active windows and closes them, continues until all windows are closed
while ($procWithWindows) {
    foreach ($process in $procWithWindows) {
        # Gets the handle ID of the window
        $appPID = $process.Id
        # Write-Host $procWithWindows
        Write-Host $process
        # Write-Host $appPID
        # Force quit the program using the PID
        Stop-Process -Id $appPID -Force
        Start-Sleep -Seconds 2
        #Resets the active window count
        $procWithWindows = Get-Process | Where-Object { $_.MainWindowTitle -ne "" -and $_.ProcessName -ne "powershell" -and $_.Id -ne $scriptProcessId}
    }
}
Write-Host "No active windows found."
Start-Sleep -Seconds 3

## Checks if the game delpoyment will run when Task Scheduler activates this script.
if($runGameDeployment -eq $true){

    ## Variables
    # Specify the source folder where files are being copied from
    $sourFol = "C:\gaim-arcade\ArcadeGames"
    # Specify the destination folder where files are being copied to
    $destFol = "C:\gaim-arcade-local\ArcadeGames"
    # Bool for successful copy task
    $allFilesCopied = $false

    ## Deleting files task
    # Check if the destination folder is empty
    $emptyDestFol = (Get-ChildItem -Path $destFol -Force -Recurse).Count -gt 0
    Write-Host "$destFol has files in it: $emptyDestFol."
    # Loop until the folder is empty
    while ($emptyDestFol) {
        # Checks if the destination folder is hidden
        $isDeleteInProg = (Get-Item -Path $destFol).Attributes -band [System.IO.FileAttributes]::Hidden
        if (-not $isDeleteInProg) {
            # Delete all files and subfolders within the destination folder
            Get-ChildItem -Path $destFol -Force | Remove-Item -Force -Recurse
        }
        # Wait for a short period before checking again
        Start-Sleep -Milliseconds 500
        $emptyDestFol = (Get-ChildItem -Path $destFol -Force -File).Count -gt 0
        Write-Host "$destFol has files in it: $emptyDestFol."
    }
    Write-Host "$destFol has files in it: $emptyDestFol."
    Start-Sleep -Seconds 3

    ## Copying files task
    # Run the copy function
    function gameCopyTask {
        param([ref]$allFilesCopied)
        # Copy the contents of the source folder to the destination folder
        Write-Host "Copying files from $sourFol to $destFol..."
        Copy-Item -Path $sourFol\* -Destination $destFol -Force -Recurse -PassThru
        # Check if the children files in the source folder are the same as the destination folder
        $sourceFiles = Get-ChildItem -Path $sourFol -File -Recurse | Select-Object -ExpandProperty FullName
        $destinationFiles = Get-ChildItem -Path $destFol -File -Recurse | Select-Object -ExpandProperty FullName
        Write-Host "Scanning the $sourFol and $destFol folders."
        Start-Sleep -Seconds 3
        $areFilesEqual = Compare-Object -ReferenceObject $sourceFiles -DifferenceObject $destinationFiles -IncludeEqual
        Write-Host "Comparing the $sourFol and $destFol folders."
        Start-Sleep -Seconds 3
        # Write-Host $areFilesEqual
        if ($null -ne $areFilesEqual) {
            Write-Host "All files have been successfully copied to $destFol."
            $allFilesCopied.Value = $true
        }
        else {
            Write-Host "Some files were not copied correctly. Differences found:"
            $areFilesEqual | ForEach-Object {
                if ($_.SideIndicator -eq "==") {
                    Write-Host "File exists in both folders: $($_.InputObject)"
                }
                elseif ($_.SideIndicator -eq "=>") {
                    Write-Host "File was not copied correctly: $($_.InputObject)"
                }
                elseif ($_.SideIndicator -eq "<=") {
                    Write-Host "File exists in destination folder but not in source folder: $($_.InputObject)"
                }
            }
        }
    }
    # Runs copy tasks until the source folder matches the destination folder
    while($allFilesCopied -eq $false){
        gameCopyTask -allFilesCopied ([ref]$allFilesCopied)
        if ($allFilesCopied -eq $true) {
            # Files have copied successfully, the computer will restart now.
            Write-Host "All files were copied successfully, restarting in 10."
            Start-Sleep -Seconds 10
            Restart-Computer -Force
        }
        else{# Attempt another copy task
            Write-Host "Attempting another copy task."
            Start-Sleep -Seconds 3
        }
    }
}
else {
    # Computer will restart.
    Write-Host "Restarting in 10."
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}