﻿$ErrorActionPreference = 'Stop'
$url        = 'https://download.geogebra.org/installers/6.0/GeoGebra-Windows-Installer-6-0-593-0.msi'
$version    = [version]'6.0.593.0'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'MSI'
  url           = $url
  softwareName  = 'GeoGebra Classic*'
  checksum      = '68c868f6ad237ca12b57c9681e04c58bad2586130d8150d3631462bbd568a3f1'
  checksumType  = 'sha256'
  silentArgs    = "ALLUSERS=2 /qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes= @(0, 3010, 1641)
}

#Uninstalls the previous version of Geogebra Classic if either version exists
Write-Output "Searching if the previous version exists..."
[array]$checkreg = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

if ($checkreg.Count -eq 0) {
    Write-Output 'No installed old version. Process to install Geogebra Classic.'
    # No version installed, process to install
    Install-ChocolateyPackage @packageArgs
} elseif ($checkreg.count -ge 1) {
    $checkreg | ForEach-Object {
        if ($null -ne $_.PSChildName) {
            if ([version]$_.DisplayVersion -lt $version) {
                Write-Output "Uninstalling Geogebra Classic previous version : $($_.DisplayVersion)"
                $msiKey = $_.PSChildName
                Start-ChocolateyProcessAsAdmin "/qn /norestart /X$msiKey" -exeToRun "msiexec.exe" -validExitCodes @(0, 1605, 3010)

                # Process to install
                Write-Output "Installing new version of Geogebra Classic"
                Install-ChocolateyPackage @packageArgs
            } elseif (([version]$_.DisplayVersion -eq $version) -and ($env:ChocolateyForce)) {
                Write-Output "Geogebra Classic $version already installed, but --force option is passed, download and install"
                Install-ChocolateyPackage @packageArgs
            }
        }
    }
}
