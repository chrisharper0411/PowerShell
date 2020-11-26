$hosts = Get-Content "C:\Users\014372\Desktop\PowershellScripts\VLAN Changer\hosts.txt"                                     # Pull's list of hosts from text file

foreach ($h in $hosts)                                                                                                      # Run's the below against each host
{
echo $h                                                                                                                     # Prints host the script is running against on screen
Invoke-Command -ComputerName $h -ScriptBlock {                                                                              # Runs the below part of the script locally on the rig to prevent VSAT interfering with testing the network connection

$rtn = $null
$prefix = $Env:COMPUTERNAME.split('-')                                                                                      # Splits the hosts computer name at the - for example pulls out the R120-
$AD = $prefix[0] + "-AD"
$AD01 = $prefix[0] + "-AD0*"                                                                                                # Prepoulates the rest of the VM's computer name and stores in variable
$FS01 = $prefix[0] + "-FS*"                                                                                                 # Prepoulates the rest of the VM's computer name and stores in variable
$SQL01 = $prefix[0] + "-SQL01"                                                                                              # Prepoulates the rest of the VM's computer name and stores in variable
$EAM01 = $prefix[0] + "-EAM01"                                                                                              # Prepoulates the rest of the VM's computer name and stores in variable
$KPI = $prefix[0] + "-OpsKPI"                                                                                               # Prepoulates the rest of the VM's computer name and stores in variable
$W701 = $prefix[0] + "-W701"                                                                                                # Prepoulates the rest of the VM's computer name and stores in variable
$FWDR01 = $prefix[0] + "-FWDR01"                                                                                            # Prepoulates the rest of the VM's computer name and stores in variable
$FWDR02 = $prefix[0] + "-FWDR02"                                                                                            # Prepoulates the rest of the VM's computer name and stores in variable
$WEB01 = $prefix[0] + "-WEB01"                                                                                              # Prepoulates the rest of the VM's computer name and stores in variable
$PI01 = $prefix[0] + "-PI01"                                                                                                # Prepoulates the rest of the VM's computer name and stores in variable
$PI02 = $prefix[0] + "-PI02"                                                                                                # Prepoulates the rest of the VM's computer name and stores in variable


Do {
Remove-Variable rtn
$rtn = Test-Connection -ComputerName $W701 -Count 2 -BufferSize 16 -Quiet                                                   # Test's the network connection against a VM to see if still on network
echo "Still Pinging VM"
#echo $rtn                                                                                                                  # Prints status update on screen                                                                                                    
}

While ($rtn -match ‘True’)                                                                                                  # When the variable for the Test connection returns a negative output this kicks off the below changes
echo "Offline"                                                                                                              # Prints status update on screen
Set-VMNetworkAdapterVlan -VMName $FWDR01, $FWDR02 -Access -VlanId 2                                                         # Test line (to be deleted or edited for testing)
Set-VMNetworkAdapterVlan -VMName $AD, $AD01, $FS01, $SQL01, $EAM01, $KPI, $W701 -Access -VlanId 2                           # Changes the computers stored in the various variables to VLAN 2
Set-VMNetworkAdapterVlan -VMName $WEB01 -Access -VlanId 1121                                                                # Changes the WEB01 servers to VLAN 1121
Set-VMNetworkAdapterVlan -VMName $PI01, $PI02 -Access -VlanId 1120                                                          # Changes the PI01 and PI02 servers to VLAN 1120

echo $h "VLAN's changed successfully"                                                                                       # Prints status update on screen
}

}
