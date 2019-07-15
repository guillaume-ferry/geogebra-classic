$ErrorActionPreference = 'Stop'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://download.geogebra.org/installers/6.0/GeoGebra-Windows-Installer-6-0-546-0.msi'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'MSI'
  url           = $url
  softwareName  = 'GeoGebra Classic*'
  checksum      = '8B6CFBBFE102081F62C5399B3A61AF84AE928491000749FC96A608CBFCBA77AA'
  checksumType  = 'sha256'
  silentArgs    = " ALLUSERS=2 /qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs