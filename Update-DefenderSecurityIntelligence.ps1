#This PowerShell script updates the Security Intelligence for Microsoft Defender Antivirus, ensuring that your system is equipped with the latest definitions and protection against emerging threats. It is designed to run as part of regular maintenance to keep Microsoft Defender up to date and enhance your system's security by downloading the latest security intelligence updates.

# Ensure PSWindowsUpdate module is installed and loaded
$moduleName = "PSWindowsUpdate"
$module = Get-Module -ListAvailable -Name $moduleName

if ($null -eq $module) {
    Write-output "$moduleName is not installed. Attempting to install..."

    try {
        # Install PSWindowsUpdate module
        Install-Module -Name $moduleName -Force -Scope CurrentUser -Repository PSGallery -ErrorAction Stop
        Write-output "$moduleName installed successfully."

        # Load the module after installation
        Import-Module $moduleName -ErrorAction Stop
        Write-output "$moduleName loaded successfully."
    } catch {
        # If installation or loading fails, throw an error
        throw "Failed to install or load $moduleName. Error: $_"
    }
} else {
    Write-output "$moduleName is already installed. Attempting to load..."

    try {
        # Load the module if already installed
        Import-Module $moduleName -ErrorAction Stop
        Write-output "$moduleName loaded successfully."
    } catch {
        # If loading the module fails, throw an error
        throw "Failed to load $moduleName. Error: $_"
    }
}

# Define the KBs to check
$KBsToCheck = @("KB4052623", "KB2267602")

# Get Windows update info
$updateInfo = Get-WindowsUpdate

# Check if the KBs are available in the system updates
$KBsToCheck | ForEach-Object {
    $kb = $_
    $update = $updateInfo | Where-Object { $_.KB -eq $kb }
    
    if ($update) {
        Write-output "$kb is available in the system updates."
    } else {
        Write-output "$kb is NOT available in the system updates."
    }
}

# Proceed with the installation of the available KBs
try {
    Write-output "Attempting to install KB4052623 and KB2267602..."
    $installResult = Install-WindowsUpdate -KBArticleID "KB4052623", "KB2267602" -AcceptAll -ErrorAction Stop

    if ($installResult) {
        Write-output "Installation of the KBs was successful."
    }
} catch {
    # If installation fails, throw an error
    throw "Installation of KBs failed. Error: $_"
}

Write-output "Script completed."

