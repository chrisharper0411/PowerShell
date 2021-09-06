####################################################################################################################################
# Description   :- Powershell script to exctract split archive containing Window MSU patch with 7 Zip and installing the patch.    #
# Author        :- Chris Harper                                                                                                    #
# Created       :- 15/12/2020                                                                                                      #
# Updated       :- NA                                                                                                              #
# Version       :- 0.1                                                                                                             #
# License       :- MIT                                                                                                             #
# Notes         :-                                                                                                                 #
####################################################################################################################################


### Variable to store path to zip directory ###
$zipfolder = "$env:SystemDrive\CMS files\RMM Downloads\2021-07 Cumulative Update\Archive\"

### Variables to set the location of where the zips should reside ###
$zipsource1 = "$zipfolder\windows10.0-kb5004238-x64_e3dd1cf22b1146f2469ef31f5fec0f47c8b5960b.zip.001" 
$zipsource2 = "$zipfolder\windows10.0-kb5004238-x64_e3dd1cf22b1146f2469ef31f5fec0f47c8b5960b.zip.002"
$zipsource3 = "$zipfolder\windows10.0-kb5004238-x64_e3dd1cf22b1146f2469ef31f5fec0f47c8b5960b.zip.003"
$zipsource4 = "$zipfolder\windows10.0-kb5004238-x64_e3dd1cf22b1146f2469ef31f5fec0f47c8b5960b.zip.004"

### Variable to store the name of the patch ###
$patchname = "windows10.0-kb5004238-x64_e3dd1cf22b1146f2469ef31f5fec0f47c8b5960b.msu"

### Variable to store patch to extract patch zip to ###
$extractedpatch = "$env:SystemDrive\CMS files\RMM Downloads\2021-07 Cumulative Update\Extracted\"

### Variable to store destination to extract MSU file to ###
$patchsource = "$extractedpatch\$patchname"

### Checks if zip exists and extracts the zips
if ((Test-Path -Path "$zipsource1" -PathType Leaf) -and (Test-Path -Path "$zipsource2" -PathType Leaf) -and (Test-Path -Path "$zipsource3" -PathType Leaf) -and (Test-Path -Path "$zipsource4" -PathType Leaf)) {
    Write-Host "Zip file has successfuly been copied." -ForegroundColor Green
    Write-Host "Extracting zip.." -ForegroundColor Green
    Set-Alias 7z "$env:ProgramFiles\7-Zip\7z.exe"
    7z e -o"$extractedpatch" "$zipsource1"
}

else {
    Write-Host "Unable to extract zip as zip does not exist at the source."
}

### Installation of the required Update ###
if (Test-Path -Path "$patchsource" -PathType Leaf) {
    Write-Host "Installing update.." -ForegroundColor Green
    wusa.exe "$patchsource" /quiet /norestart
}

else {
    Write-Host "Installation failed as patch does not exist at the source."
}

### Wait for patch to install ###
Start-Sleep -Seconds 1800

### Checks the update has installed ###
if (Get-HotFix -Id KB5004238) {
    Write-Host "Update KB5004238 has been installed successfully." -ForegroundColor Green
}

else {
    Write-Host "Update has not installed." -ForegroundColor Red
}

### Clean Up ###
Remove-Item -Path "$env:SystemDrive\CMS files\RMM Downloads\2021-07 Cumulative Update\" -Recurse -Force