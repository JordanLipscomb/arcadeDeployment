$shell = New-Object -ComObject Shell.Application
$windows = @($shell.Windows())

Start-Sleep -Seconds 5

foreach ($window in $windows) {
    Write-Host "Title: $($window.Document.Title), HWND: $($window.HWND)"
}

Start-Sleep -Seconds 20