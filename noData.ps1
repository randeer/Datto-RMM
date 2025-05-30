function Create-TempFolder {
    $folderPath = "C:\temp"
    
    # Check if the folder exists
    if (-Not (Test-Path -Path $folderPath)) {
        # Create the folder if it doesn't exist
        New-Item -Path $folderPath -ItemType Directory
        Write-output "C:\temp folder created."
    } else {
        Write-output "C:\temp folder already exists."
    }
}


function Copy-FilesToTemp {
    $files = @(
        @{ Source = "./LGPO.exe"; Destination = "C:\Temp\LGPO.exe" },
        @{ Source = "./WindowsUpdateSourceFix.txt"; Destination = "C:\Temp\WindowsUpdateSourceFix.txt" }
    )
    
    foreach ($file in $files) {
        $source = $file.Source
        $destination = $file.Destination
        
        if (Test-Path -Path $source) {
            # Copy the file to the destination
            Copy-Item -Path $source -Destination $destination -Force
            Write-output "Copied '$source' to '$destination'."
        } else {
            Write-output "Source file '$source' not found."
        }
    }
}

function Restart-WindowsUpdateService {
    # Define the service name
    $serviceName = 'wuauserv'
    
    # Stop the Windows Update service
    Write-output "Stopping Windows Update service..."
    Stop-Service -Name $serviceName -Force
    Write-output "Windows Update service stopped."
    
    # Wait for 20 seconds
    Start-Sleep -Seconds 20
    
    # Start the Windows Update service
    Write-output "Starting Windows Update service..."
    Start-Service -Name $serviceName
    Write-output "Windows Update service started."
    
    # Wait for another 20 seconds
    Start-Sleep -Seconds 20
    
    # Restart the Windows Update service
    Write-output "Restarting Windows Update service..."
    Restart-Service -Name $serviceName
    Write-output "Windows Update service restarted."
}



Create-TempFolder
Copy-FilesToTemp
$lgpoPath = "C:\Temp\LGPO.exe"
& $lgpoPath /t "C:\Temp\WindowsUpdateSourceFix.txt"
Restart-WindowsUpdateService
