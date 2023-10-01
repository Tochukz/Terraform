# This script installs and starts Internet Information Services (IIS)

# Install IIS
Add-WindowsFeature Web-Server

# Start the IIS service
Start-Service -Name W3SVC

# Set the IIS service to start automatically on boot
Set-Service -Name W3SVC -StartupType 'Automatic'
