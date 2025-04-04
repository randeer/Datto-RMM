#This script ensures that Winget is installed and up to date on the device. It performs the following actions:
#
#Installs Winget: If Winget is not already installed on the device.
#Updates Winget: If Winget is installed but the version is below v1.10.340, it will update it to the latest version.
#
#This ensures that the device always has the required version of Winget for optimal functionality.


function check_installWinget {
    # Set the path where we want to search for winget.exe
    $searchPath = "C:\Program Files\WindowsApps"

    # Use Get-ChildItem to recursively search for 'winget.exe' in the specified directory
    $wingetPaths = Get-ChildItem -Path $searchPath -Recurse -Filter "winget.exe" -ErrorAction SilentlyContinue

    # Check if winget.exe was found
    if ($wingetPaths) {
        # Initialize variables to track the highest version and its path
        $highestVersion = [version]::Parse("0.0.0.0")
        $highestPath = $null

        foreach ($path in $wingetPaths) {
            # Extract the version number from the path
            if ($path.FullName -match "_([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)_") {
                $version = [version]::Parse($matches[1])

                # Compare the extracted version with the highest version found so far
                if ($version -gt $highestVersion) {
                    $highestVersion = $version
                    $highestPath = $path.FullName
                }
            }
        }

        # Return the path of the highest version found, or a message if not found
        if ($highestPath) {
            return $highestPath
        }
    }

    return "not installed"
}


function mannual_installWinget {
    # Check if C:\temp exists, create it if it doesn't
    if (-not (Test-Path "C:\temp")) {
        New-Item -Path "C:\" -Name "temp" -ItemType "Directory" -Force | Out-Null
        Write-Output "Created C:\temp directory"
    }

    # Copy winget.zip to C:\Temp
    Copy-Item ./winget.zip -Destination 'C:\Temp\winget.zip' -Force

    # Define the source and destination paths
    $zipFile = "C:\Temp\winget.zip"
    
    # Define a destination folder for extracting the ZIP file, including a dynamic version
    $destinationFolder = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.25.340.0_x64__8wekyb3d8bbwe\"

    # Check if the destination folder exists, if not, create it
    if (-not (Test-Path -Path $destinationFolder)) {
        New-Item -ItemType Directory -Path $destinationFolder
        Write-Output "Created folder: $destinationFolder"
    }

    # Extract the ZIP file
    Expand-Archive -Path $zipFile -DestinationPath $destinationFolder -Force
    Write-Output "Extracted winget.zip to $destinationFolder"
	
	$destinationwinget = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.25.340.0_x64__8wekyb3d8bbwe\winget.exe"

    # Return the installed winget path
    return "$destinationwinget"
}


function Set-WingetRegistrySettings {
    # Define the registry path and values
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"
    $regValues = @{
        EnableAppInstaller            = 1
        EnableExperimentalFeatures    = 1
        EnableMSAppInstallerProtocol  = 1
    }

    try {
        # Check if the registry path exists, and if not, create it
        if (-not (Test-Path $regPath)) {
            Write-Output "Registry path does not exist. Creating it..."
            New-Item -Path $regPath -Force | Out-Null
        }
        
        # Update registry values to "1" if they are not already set
        foreach ($valueName in $regValues.Keys) {
            # Check if the registry key exists and get its current value
            $currentValue = Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue

            # If the registry value doesn't exist or isn't set to the desired value (1), set it
            if ($null -eq $currentValue -or $currentValue.$valueName -ne $regValues[$valueName]) {
                Write-Output "Setting registry value $valueName to $($regValues[$valueName])"
                Set-ItemProperty -Path $regPath -Name $valueName -Value $regValues[$valueName]
            }
        }

        return $true
    }
    catch {
        Write-Error "Error setting registry values: $_"
        return $false
    }
}


$success = Set-WingetRegistrySettings

if ($success) {
    Write-Host "Registry settings were successfully updated."
    
    $wingettouse
    $result = check_installWinget
    
    if ($result -eq "not installed") {
        Write-Host $result
        mannual_installWinget
		$wingettouse = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.25.340.0_x64__8wekyb3d8bbwe\winget.exe"
    } else {
		$lowestwinget = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.25.340.0_x64__8wekyb3d8bbwe\winget.exe"
		if ($lowestwinget -gt $result) {
			mannual_installWinget
			$wingettouse = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.25.340.0_x64__8wekyb3d8bbwe\winget.exe"
			#$wingettouse = $result
		} else {
			$wingettouse = $result
			#mannual_installWinget
			#$wingettouse = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.25.340.0_x64__8wekyb3d8bbwe\winget.exe"
		}
    }
    
    & $wingettouse upgrade --accept-source-agreements --accept-package-agreements --all

} else {
    Write-Host "There was an error updating the registry settings."
}

