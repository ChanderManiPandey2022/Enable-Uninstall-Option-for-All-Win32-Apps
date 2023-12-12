<# 
.NOTES
Onjuective:      Script to Enable Uninstall Apps in Company Portal for All Win32 Application
Version:         1.0
Author:          Chander Mani Pandey
Creation Date:   7 Aug 2023
Find Author on 
Youtube:-        https://www.youtube.com/@chandermanipandey8763
Twitter:-        https://twitter.com/Mani_CMPandey
LinkedIn:-       https://www.linkedin.com/in/chandermanipandey

#>

#Note: this scrit is installing all Microsoft graph module but you can litit this to specific like Microsoft.Graph.Intune ,Microsoft.Graph.Authentication


Set-ExecutionPolicy -ExecutionPolicy Bypass


# Check if the Microsoft.Graph module is installed
if (-not (Get-Module -Name Microsoft.Graph -ListAvailable)) {
    Write-Host "Microsoft.Graph module not found. Installing..."
    
    # Module is not installed, so install it
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
    
    Write-Host "Microsoft.Graph module installed successfully."
}
else {
    Write-Host "Microsoft.Graph module is already installed."
}

Write-Host "Importing Microsoft.Graph module..."
# Import the Microsoft.Graph module
Import-Module Microsoft.Graph.Authentication

Write-Host "Microsoft.Graph.Authentication module imported successfully."

$RequiredScopes = ("DeviceManagementManagedDevices.Read.All", "DeviceManagementManagedDevices.ReadWrite.All", "AuditLog.Read.All", "User.Read.All","DeviceManagementApps.Read.All","DeviceManagementApps.ReadWrite.All")
Connect-MgGraph -Scope $RequiredScopes 
Write-host "Successfully Connected to MG graph"
$uri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?$filter=(isof('microsoft.graph.win32LobApp'))&$select=id,displayName,allowAvailableUninstall"
$Win32Apps = Invoke-MgGraphRequest -Uri $uri -Method Get -OutputType PSObject | Get-MsGraphAllPages | Where-Object { ( $_.'@odata.type' -eq '#microsoft.graph.win32LobApp') -and ($_.allowAvailableUninstall -eq $false) }
Write-host""

foreach ($Apps in $Win32Apps) 
{
       
        $Apps.allowAvailableUninstall = $True
        $Appid = $Apps.id
        $AppName = $Apps.displayName
        Write-host "Enabling Uninstall option for Application Name:- $AppName"-ForegroundColor Yellow
        $Apps = $Apps | Select-Object * -ExcludeProperty  supersedingAppCount, supersededAppCount, committedContentVersion, size, minimumSupportedOperatingSystem ,createdDateTime, id, lastModifiedDateTime, uploadState, publishingState, isAssigned, dependentAppCount
        $Appjson = $Apps | ConvertTo-Json -Depth 10
        $Appuri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/$Appid"
        Invoke-MgGraphRequest -Uri $appuri -Method Patch -Body $appjson
        Write-host "Enabled Uninstall option for $appName" -ForegroundColor Green
        Write-host""
}
       
        
Disconnect-MgGraph
