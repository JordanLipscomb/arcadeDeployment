$destFol = "C:\gaim-arcade-local\ArcadeGames"
$isDeleteInProg = (Get-Item -Path $destFol).Attributes -band [System.IO.FileAttributes]::Hidden
Write-Host $isDeleteInProg
Start-Sleep 5