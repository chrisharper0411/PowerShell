$hosts = Get-Content "C:\Scripts\Hosts.txt"                                                                                                             # Host server list text file 
$replicahost = Get-Content "C:\Scripts\replica.txt"                                                                                                     # Replica server list text file
$sql = Get-Content "C:\Scripts\SQLVM.txt"                                                                                                               # SQL server list text file


foreach ($s in $sql)                                                                                                                                    # Run these commands in all SQL servers
{
    echo $s
    Invoke-Command -ComputerName $s -ScriptBlock {
    Stop-Service -Name 'SQLSERVERAGENT'                                                                                                                 # Stop the SQL server agent
    Set-Service SQLSERVERAGENT -startuptype "manual"                                                                                                    # Sets the service to be started manual
    Start-Sleep -Seconds 1800                                                                                                                           # Wait 30 minutes
    Stop-Computer -Force                                                                                                                                # Shutdown Server                                                         
    }
 }   



foreach ($h in $hosts)                                                                                                                                  # Run these commands in all Host (HV01) servers
{
    echo $h
    Invoke-Command -ComputerName $h -ScriptBlock {  
    $prefix=$Env:COMPUTERNAME.split('-')                                                                                                                # Get the prefix of the server name
    $VHD = $prefix[0] + "-SQL01-DATA.vhdx"                                                                                                              # Creates a variable joining the prefix with the end part of the VHD name
    $VMName = $prefix[0] + "-SQL01"                                                                                                                     # Creates a variable joining the prefix with the end part of the VM name
    $GUID = Get-VM -VMName $VMName | foreach { $_.VMId } | Select-Object -Expand GUID                                                                   # Finds the VM's GUID and stores it in a variable
    Start-Sleep -Seconds 60                                                                                                                             # Wait 1 minute
    Resize-VHD –Path "d:\Virtual Servers\Hyper-V Replica\Virtual hard disks\$GUID\$VHD" –SizeBytes 350GB                                                # Resize's the VHD to 300GB (***Still need to change for non Generic Path***)
    #Resize-VHD –Path "d:\Virtual Servers\Virtual Hard Disks\$VHD" –SizeBytes 300GB 
    Start-Sleep -Seconds 60                                                                                                                             # Wait 1 minutes
    Start-VM –Name $VMName                                                                                                                              # Starts the SQL VM
    Start-Sleep -Seconds 120                                                                                                                            # Wait 2 minutes               
    } 
}


foreach  ($r in $replicahost)                                                                                                                           # Run these commands in all Host (HV02) servers
{
    echo $r
    Invoke-Command -ComputerName $r -ScriptBlock { 
    $prefix=$Env:COMPUTERNAME.split('-')                                                                                                                # Get the prefix of the server name
    $VHD = $prefix[0] + "-SQL01-DATA.vhdx"                                                                                                              # Creates a variable joining the prefix with the end part of the VHD name
    $VMName = $prefix[0] + "-SQL01"                                                                                                                     # Creates a variable joining the prefix with the end part of the VM name
    #$GUID2 = Get-VM -VMName $VMName | foreach { $_.VMId } | Select-Object -Expand GUID                                                                 # Finds the VM's GUID and stores it in a variable
    Start-Sleep -Seconds 60                                                                                                                             # Wait 1 minute
    Resize-VHD –Path "d:\Virtual Servers\Virtual Hard Disks\$VHD" –SizeBytes 350GB                                                                      # Resize's the VHD to 300GB
    #Resize-VHD –Path "d:\Virtual Servers\Virtual Hard Disks\Hyper-V Replica\Virtual hard disks\$GUID2\$VHD" –SizeBytes 300GB           
    Start-Sleep -Seconds 60                                                                                                                             # Wait 1 minute
    #Resume-VMReplication $VMName -Resynchronize                                                                                                        # Resume replication use if set to manual and resyncronise the VHD size change (Will display red error if resync has been set need to put an IF statement in)
    Reset-VMReplicationStatistics -VMName $VMName                                                                                                       # Resets replication warnings/errors
    } 
}

foreach ($s in $sql)                                                                                                                                    # Run these commands in all SQL servers
{
    echo $s
    Invoke-Command -ComputerName $s -ScriptBlock {
    #Resize-Partition -DriveLetter S -Size (195GB)                                                                                                      # Resize the partition does not work on powershell 2.0
    "select volume S","extend","exit" | diskpart                                                                                                        # Resize the partition using diskpart works on all versions of powershell
    Start-Sleep -Seconds 60                                                                                                                             # Wait 1 minutes
    Start-Service -Name 'SQLSERVERAGENT'                                                                                                                # Start the SQL server agent
    Set-Service SQLSERVERAGENT -startuptype "automatic"                                                                                                 # Sets the service to be started automatically
    }   
}

echo "Finished"