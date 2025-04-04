# Step 1: Check if "C:\temp" folder exists, and create it if it doesn't
$folderPath = "C:\temp"
if (-Not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
    Write-Output "Created folder: $folderPath"
} else {
    Write-Output "Folder already exists: $folderPath"
}

# Step 2: Check if the "mpam-fe.exe" file exists, and delete it if it does
$fileDestination = "C:\temp\mpam-fe.exe"
if (Test-Path -Path $fileDestination) {
    Remove-Item -Path $fileDestination -Force
    Write-Output "Deleted existing file: $fileDestination"
}

# Step 3: Download the file using Invoke-WebRequest
$fileUrl = "https://go.microsoft.com/fwlink/?LinkID=121721&arch=x64"
Invoke-WebRequest -Uri $fileUrl -OutFile $fileDestination
Write-Output "Download completed: $fileDestination"

# Step 4: Install the downloaded file (mpam-fe.exe)
Write-Host "Installing the signature file..."
Start-Process -FilePath $fileDestination -ArgumentList "/quiet /install" -Wait

# Step 5: Output completion message
Write-Output "Installation completed successfully."
