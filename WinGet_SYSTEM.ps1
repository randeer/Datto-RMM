# Define the registry path and values
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"
$regValues = @{
    EnableAppInstaller            = 1
    EnableExperimentalFeatures    = 1
    EnableMSAppInstallerProtocol  = 1
}

# Check if the registry path exists, and if not, create it
if (-not (Test-Path $regPath)) {
    Write-Output "Registry path does not exist. Creating it..."
    New-Item -Path $regPath -Force
}

# Update registry values to "1" if they are not already set
foreach ($valueName in $regValues.Keys) {
    $currentValue = Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue

    # If the registry value doesn't exist or isn't set to 1, set it
    if ($null -eq $currentValue -or $currentValue.$valueName -ne $regValues[$valueName]) {
        Write-Output "Setting registry value $valueName to 1"
        Set-ItemProperty -Path $regPath -Name $valueName -Value $regValues[$valueName]
    }
}

# Now proceed with the original winget search and upgrade process
$wingetPaths = Get-ChildItem -Path "C:\Program Files\WindowsApps" -Recurse -Filter "winget.exe"

# If we find multiple versions, select the one with the highest version based on the folder name
if ($wingetPaths.Count -gt 0) {
    # Extract the version numbers from the parent directories
    $versionedPaths = $wingetPaths | ForEach-Object {
        $parentDir = $_.DirectoryName
        # Extract version from the folder name (the last part of the folder path)
        if ($parentDir -match "Microsoft.DesktopAppInstaller_(\d+\.\d+\.\d+\.\d+)") {
            [PSCustomObject]@{
                Path = $_.FullName
                Version = [version]$matches[1]
            }
        }
    }

    # Find the highest version
    $latestVersionPath = $versionedPaths | Sort-Object Version -Descending | Select-Object -First 1

    # Run winget upgrade with the latest version of winget.exe
    if ($latestVersionPath) {
        Write-Output "Using winget version $($latestVersionPath.Version) located at: $($latestVersionPath.Path)"
        & $latestVersionPath.Path upgrade --accept-source-agreements --accept-package-agreements --all
    } else {
        Write-Output "No valid winget.exe found!"
    }
} else {
    Write-Output "winget.exe not found!"
}
