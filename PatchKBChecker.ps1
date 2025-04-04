#to check a patch is installed or not

$Patch = cmd.exe /c "wmic qfe | findstr $env:PatchKB"

#Write-Output $env:PatchKB

$deviceName = [System.Net.Dns]::GetHostName()

#Write-Output $deviceName

if ($Patch -ne $null) { 
    Write-Output "The Patch $env:PatchKB is installed on device $deviceName"
    #Write-Host "The Patch $PatchKB is installed on device $deviceName" -ForegroundColor Green
} else { 
    Write-Output "The Patch $env:PatchKB is not installed"
    #Write-Host "The Patch $PatchKB is not installed" -ForegroundColor Red
    # You can also throw an error if you want to terminate or alert
    throw "Patch $env:PatchKB is not installed on device $deviceName"
}
