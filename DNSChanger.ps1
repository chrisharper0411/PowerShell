####################################################################################################################################
# Description   :- Powershell script to change the tertiary dns server for multiple hosts.                                         #
# Author        :- Chris Harper                                                                                                    #
# Created       :- 04/03/2022                                                                                                      #
# Updated       :- NA                                                                                                              #
# Version       :- 0.1                                                                                                             #
# License       :- MIT                                                                                                             #
# Notes         :-                                                                                                                 #
####################################################################################################################################

# Defines Global Variables
$Hosts = Get-Content "C:\Users\chris.harper\Desktop\Hosts.txt"


# Loop to target multiple hosts
foreach ($h in $hosts)                                                                                                                                                            
{

echo $h

Invoke-Command -ComputerName $h -ScriptBlock {
    
# Defines local variables
$PrimaryServer = 
$SecondaryServer = 
$TertiaryServer = "10.207.16.54"    

# Configure DNS on Network Connections
function configure_DNS {
  
  Write-Host "Configuring DNS servers"
  Write-Host "------------------------------------------------------------------------"



}

# Check current DNS configuration 
$dns_stat = Get-WindowsFeature -Name SNMP-Service

# Install/Enable SNMP-Service 
If ($dns_stat -eq "True") {
 
  Write-Host "Configuring DNS addresses `n"

  configure_SNMP $MonitoringNode 

}

ElseIf ($snmp_stat.Installed -ne "True") {

  Write-Host "Network Connections DNS is configured differently"
  configure_SNMP $MonitoringNode $CommunityString

}

Else {

  Write-Host "Network Connections DNS Configuration Failed.!"

}

}
}