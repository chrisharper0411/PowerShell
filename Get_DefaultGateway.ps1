####################################################################################################################################
# Description   :- Powershell script to gather the default gatewa for multiple hosts.                                              #
# Author        :- Chris Harper                                                                                                    #
# Created       :- 30/03/2022                                                                                                      #
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

Get-NetIPConfiguration | Foreach IPv4DefaultGateway

}

}