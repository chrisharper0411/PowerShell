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
$PrimaryServer = "10.165.16.8"
$SecondaryServer = "10.165.16.9"
$TertiaryServer = "10.165.16.20"   

# Check DNS setting
function check_DNS {
  
  Write-Host "Checking configured DNS servers"
  Write-Host "------------------------------------------------------------------------"
  Get-DnsClientServerAddress -InterfaceIndex ? 

}

# Configure DNS on Network Connections
function configure_DNS {
  
  Write-Host "Configuring DNS servers"
  Write-Host "------------------------------------------------------------------------"

  Set-DnsClientServerAddress -InterfaceIndex ? -ServerAddresses ($PrimaryServer, $SecondaryServer, $TertiaryServer)
  Write-Host "DNS has been configured"

}

# Check current DNS configuration 
$dns_stat = check_DNS $PrimaryServer, $SecondaryServer, $TertiaryServer

# Configure DNS settings 
If ($dns_stat -eq "True") {
 
  Write-Host "Configuring DNS addresses `n"

  configure_DNS $PrimaryServer, $SecondaryServer, $TertiaryServer

}

Else {

  Write-Host "Network Connections DNS Configuration Failed.!"

}

}
}