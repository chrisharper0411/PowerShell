$hosts = Get-Content "C:\Users\014372\Desktop\PowershellScripts\servers.txt"                                                                                                       # Gets list of Hosts

 
foreach ($h in $hosts){                                                                                                                                                             # Runs the task on each host                                                                                                                                                                                                              

echo $h 

Invoke-Command -ComputerName $h -ScriptBlock {                                                                                                                                      # Run's the script within the block on all hosts stored in the $hosts variable                                                                                                                                                                        # Displays the hosts name within the powershell window to help with troubleshooting any error that may arise                                                                                                               

$adapters=(gwmi win32_networkadapterconfiguration)                                                                                                                                  # Variable for storing each hosts network adapters configuration                                      

Foreach ($adapter in $adapters){                                                                                                                                                    # Loop to gather each adapters config and store on the $adapters variable 
#Write-Host $adapter                                                                                                                                                                # Prints adapter info
$adapter.settcpipnetbios(2)                                                                                                                                                         # Sets the DWORD value to 2 (Disabled) for each network interface
}
                                          
New-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Services\LanManServer\Parameters -Name EnableSecuritySignature -PropertyType DWord -Value 1 -Force                             # Enable SMB Signing

New-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Services\LanManServer\Parameters -Name RequireSecuritySignature -PropertyType DWord -Value 1 -Force                            # Enforce SMB Signing 

New-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Services\Dnscache\Parameters -Name EnableMulticast -PropertyType DWord -Value 0 -Force                                         # Disables LLMNR for all network adapters

New-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Name DisabledByDefault -PropertyType DWord -Value 1 -Force      # Disables TLS 1.0 on applications servers IIS

Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters SMB1 -Type DWORD -Value 0 –Force                                                      
#Set-SmbServerConfiguration -EnableSMB1Protocol $false                                                                                                                              # Disables SMB v1 Server 2012 ** Requires a reboot **                                                                                                                 
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart                                                                                                         # Disables SMB v1 Server 2012 R2 and 2016** Requires a reboot ** 


}
}