
####################################################################################################################################
# Description   :- Powershell script to complete the initial configuration of CMS staff users PC prior to imaging.                 #
# Author        :- Chris Harper                                                                                                    #
# Created       :- 24/05/2021                                                                                                      #
# Updated       :- NA                                                                                                              #
# Version       :- 0.1                                                                                                             #
# License       :- MIT                                                                                                             #
# Notes         :-                                                                                                                 #
####################################################################################################################################


# Set Windows update settings

$WuRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971F918-A847-4430-9279-4A52D1EFE18D"
$WuRegName = "RegisteredWithAU"
$WuRegValue = Get-ItemProperty -Path $WuRegpath -ErrorAction SilentlyContinue | Select-Object $WuRegName | Format-Table -HideTableHeaders | Out-String
$WuNewRegValue = "1"

if ($WuRegValue -notlike "*1*") {
    Write-Host -ForegroundColor Green("Creating registry key to enabling receive updates for other Microsoft products when you update Windows.")
    New-Item -Path $WuRegPath -Name $WuRegName -Force
    New-ItemProperty -Path $WuRegPath -Name $WuRegName -Value $WuNewRegValue -Type DWORD -Force | Out-Null
}

else {
    Write-Host -ForegroundColor Red("Receive updates for other Microsoft products when you update Windows has already been removed.")
}


# Disable Windows paging file

$PagingFile = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
$PFregname = 'PagingFiles'
$PagingFileExist =  Get-ItemProperty -Path $PagingFile -Name $PFregname -ErrorAction SilentlyContinue | Select-Object PagingFiles | Format-Table -HideTableHeaders | Out-String

if ($PagingFileExist -like "*pagefile.sys*") {
    Write-Host -ForegroundColor Green("Disabling Windows paging file.")
    Remove-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name $PFregname
}

else {
    Write-Host -ForegroundColor Red("Paging file has already been removed.")
}


# Remove unrequired Window features (Maybe required in future)

#$CurrentWinFeatures = Get-WindowsOptionalFeature -Online | Where-Object state -eq "Enabled" | Select-Object FeatureName | Format-Table -HideTableHeaders | Out-String
#$RequiredWinFeatures = @("Internet-Explorer-Optional-amd64", "Printing-PrintToPDFServices-Features", "Printing-XPSServices-Features", "MicrosoftWindowsPowerShellV2")

#if ($CurrentWinFeatures -notcontains $RequiredWinFeatures) {
    #Write-Host -ForegroundColor Green("Removing unrequired and adding the required Windows features...")
    #Disable-WindowsOptionalFeature -Online -FeatureName $CurrentWinFeatures
    #Write-Host -ForegroundColor Green("Adding required and adding the required Windows features...")
    #Enable-WindowsOptionalFeature -Online -FeatureName $RequiredWinFeatures 
#}

#else {
    #Write-Host -ForegroundColor Red("Required features already exist.")
#}


# Create local folders

$KioskFolderPath = Test-Path -Path "C:\Kiosk\"
$TempFolderPath = Test-Path -Path "C:\Temp\"
$biodbFolderPath = Test-Path -Path "C:\biodb\"

if ($KioskFolderPath -ne "True") {
    Write-Host -ForegroundColor Green("Creating Kiosk folder path...")
    New-Item -Path "C:\" -Name "Kiosk" -ItemType "directory"
}

else {
    Write-Host -ForegroundColor Red("Kisok folder already exists.")
}

if ($TempFolderPath -ne "True") {
    Write-Host -ForegroundColor Green("Creating Temp folder path...")
    New-Item -Path "C:\" -Name "Temp" -ItemType "directory"
}

else {
    Write-Host -ForegroundColor Red("Temp folder already exists.")
}

if ($biodbFolderPath -ne "True") {
    Write-Host -ForegroundColor Green("Creating biodb folder path...")
    New-Item -Path "C:\" -Name "biodb" -ItemType "directory"
}

else {
    Write-Host -ForegroundColor Red("biodb folder already exists.")
}


# Configure power settings

$currentpowerplan = Get-WmiObject -Class win32_Powerplan -Namespace root/cimv2/power -Filter "isActive='true'"  | Select-Object ElementName | Format-Table -HideTableHeaders | Out-String

if($currentpowerplan -notlike "*High performance*"){
    Write-Host -ForegroundColor Green("Selecting correct power plan...")
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
}

else {
    Write-Host -ForegroundColor Red("No change required power plan has already been configured correctly")
}


# Disable DEP (Secure boot needs to be disabled in BIOS first)

$DEPStatus = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object DataExecutionPrevention_SupportPolicy | Format-Table -HideTableHeaders | Out-String

if ($DEPStatus -notlike "*0*") {
    Write-Host -ForegroundColor Green("Disabling DEP...")
    bcdedit.exe /set "{current}" nx AlwaysOff 
}

else {
    Write-Host -ForegroundColor Red("No change required DEP has already been disabled")
}


# Disable IPv6

$IPv6Status = Get-NetAdapterBinding -ComponentID ms_tcpip6 | Select-Object Enabled | Format-Table -HideTableHeaders | Out-String

if ($IPv6Status -notlike "*False*") {
    Write-Host -ForegroundColor Green("Disabling IPv6...")
    Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
}

else {
    Write-Host -ForegroundColor Red("IPv6 has already been disabled on all adapters.")
}


# Remove unused network adapters

$UnusedNetAdapter = Get-NetAdapter | Where-Object Status -eq "Disconnected"

if($UnusedNetAdapter.Status -eq "Disconnected") {
    Write-Host -ForegroundColor Green("Disabling unused network adapters...")
    Disable-NetAdapter -Name $UnusedNetAdapter.Name -Confirm:$False
}

else {
    Write-Host -ForegroundColor Red("All disconnected adapter have been disabled.")
}


# Disable network location wizard

#$NlwRegPath = "HKLM\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff"
#$NlwTestPath = Get-ItemProperty -Path $NlwRegPath -ErrorAction SilentlyContinue | Format-Table -HideTableHeaders | Out-String

#if ($NlwTestPath -like $null) {
#    Write-Host -ForegroundColor Green("Creating registry key to disable the network location wizard.")
#    New-Item -Path $NlwRegPath -Force | Out-Null
#}

#else {
#    Write-Host -ForegroundColor Red("Network location wizard has already been disabled.")
#}

Get-NetFirewallRule -DisplayGroup 'Network Discovery'|Set-NetFirewallRule -Profile 'Private, Public, Domain' -Enabled false


# Enable fix apps that are blurry

$BlurRegPath = "HKCU:\Control Panel\Desktop\"
$BlurRegName = "EnablePerProcessSystemDPI"
$BlurTestPath = Get-ItemProperty -Path $BlurRegPath -ErrorAction SilentlyContinue | Select-Object $BlurRegName | Format-Table -HideTableHeaders | Out-String
$BlurNewRegValue = "1"

if ($BlurTestPath -notlike "*1*") {
    Write-Host -ForegroundColor Green("Creating registry key to enable blur fix setting..")
    New-ItemProperty -Path $BlurRegPath -Name $BlurRegName -Value $BlurNewRegValue -Type DWORD -Force | Out-Null
}

else {
    Write-Host -ForegroundColor Red("Blur fix setting has already been enabled")
}


# Enable Windows Defender

$WDVirusEnabled = Get-MpComputerStatus | Select-Object "AntivirusEnabled" | Format-Table -HideTableHeaders | Out-String

if($WDVirusEnabled -notlike "*True*") {
    Write-Host -ForegroundColor Green("Enabling Defenders AV protection...")
    Set-MpPreference -DisableRealtimeMonitoring $false
}

else {
    Write-Host -ForegroundColor Red("No change required Windows Defender is currently enabled.")
}


# Pause 5 seconds

Start-Sleep -Seconds 5


# Reboot to finish configuring DEP

Restart-Computer -Force