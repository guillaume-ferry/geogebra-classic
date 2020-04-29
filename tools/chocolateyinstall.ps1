$ErrorActionPreference = 'Stop'
$url        = 'https://download.geogebra.org/installers/6.0/GeoGebra-Windows-Installer-6-0-579-0.msi'
$version    = '6.0.579.0'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'MSI'
  url           = $url
  softwareName  = 'GeoGebra Classic*'
  checksum      = '046fd060be604570304f06bd2df273c175e9540a579c0ed22032fe37837146f1'
  checksumType  = 'sha256'
  silentArgs    = "ALLUSERS=2 /qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes= @(0, 3010, 1641)
}

#Uninstalls the previous version of Geogebra Classic if either version exists
Write-Output "Searching if the previous version exists..."
$InstallerVersion = $version.Replace('.', '')
[array]$checkreg = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

if ($checkreg.Count -eq 0) {
    Write-Output 'No installed old version. Process to install Geogebra Classic.'
    # No version installed, process to install
    Install-ChocolateyPackage @packageArgs
} elseif ($checkreg.count -ge 1) {
    $checkreg | ForEach-Object {
        if ($null -ne $_.PSChildName) {
            if ($_.DisplayVersion.Replace('.', '') -lt $InstallerVersion) {
                Write-Output "Uninstalling Geogebra Classic previous version : $($_.DisplayVersion)"
                $msiKey = $_.PSChildName
                Start-ChocolateyProcessAsAdmin "/qn /norestart /X$msiKey" -exeToRun "msiexec.exe" -validExitCodes @(0, 1605, 3010)

                # Process to install
                Write-Output "Installing new version of Geogebra Classic"
                Install-ChocolateyPackage @packageArgs
            } elseif (($_.DisplayVersion.Replace('.', '') -eq $InstallerVersion) -and ($env:ChocolateyForce)) {
                Write-Output "Geogebra Classic $version already installed, but --force option is passed, download and install"
                Install-ChocolateyPackage @packageArgs
            }
        }
    }
}
