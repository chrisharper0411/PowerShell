####################################################################################################################################
# Description   :- Powershell Script To Install/Configure SNMP Services (SNMP Service, SNMP WMI Provider) in multiple locations.   #
# Author        :- Chris Harper                                                                                                    #
# Created       :- 15/12/2020                                                                                                      #
# Updated       :- NA                                                                                                              #
# Version       :- 0.1                                                                                                             #
# License       :- MIT                                                                                                             #
# Notes         :- Requires -RunAsAdministrator                                                                                    #
####################################################################################################################################

$Hosts = Get-Content "C:\Users\014372\Desktop\PowershellScripts\Hosts.txt"
$MonitoringNode = "10.207.16.54" # Your SNMP Monioring Node (IP or DNS name) 
$CommunityString = "winsnmp" # Your community string configured with Monitoring node.

# Loop to target multiple hosts
foreach ($h in $hosts)                                                                                                                                                                 # Run these commands in all Host servers
{
    echo $h
    Invoke-Command -ComputerName $h -ScriptBlock {

# Configure SNMP service
function configure_SNMP {
  
  Write-Host "Configuring SNMP-Services with your Community string and Monitoring Node"
  Write-Host "------------------------------------------------------------------------"
  
  reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v 1 /t REG_SZ /d localhost /f | Out-Null
  Write-Host "1. Configuration of PermittedManger localhost: Done!"
  
  reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v 2 /t REG_SZ /d $MonitoringNode /f | Out-Null
  Write-Host "2. Configuration of PermittedManger $MonitoringNode : Done!"
  
  reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $CommunityString /t REG_DWORD /d 4 /f | Out-Null
  Write-Host "3. Configuration of Community String - $CommunityString : Done!"
  
}


Import-Module ServerManager

# Check if SNMP-Service Feature is enabled
$snmp_stat = Get-WindowsFeature -Name SNMP-Service

# Install/Enable SNMP-Service 
If ($snmp_stat.Installed -ne "True") {
 
  Write-Host "Enabling SNMP-Service Feature `n"
  Get-WindowsFeature -name SNMP* | Add-WindowsFeature -IncludeManagementTools | Out-Null

  configure_SNMP $MonitoringNode $CommunityString

}
ElseIf ($snmp_stat.Installed -eq "True") {

  Write-Host "SNMP Services Already Installed `n"
  configure_SNMP $MonitoringNode $CommunityString

}
Else {

  Write-Host "SNMP Configuration Failed.!"

}

}
}