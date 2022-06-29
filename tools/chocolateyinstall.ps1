$ErrorActionPreference = 'Stop'
$url = 'https://download.geogebra.org/installers/6.0/GeoGebra-Windows-Installer-6-0-718-0.msi'
$version = [version]'6.0.718.0'

$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    fileType       = 'MSI'
    url            = $url
    softwareName   = 'GeoGebra Classic*'
    checksum       = '0f65faaa0695e47a6ef947901daaeceb5e7e034f16f2b9ce2e35f3c3c5342b91'
    checksumType   = 'sha256'
    silentArgs     = "ALLUSERS=2 /qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
    validExitCodes = @(0, 3010, 1641)
}

#Uninstalls the previous version of Geogebra Classic if either version exists
Write-Output 'Searching if the previous version exists...'
[array]$checkreg = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

if ($checkreg.Count -eq 0) {
    Write-Output 'No installed old version. Process to install Geogebra Classic.'
    # No version installed, process to install
    $ExecInstall = $true
} elseif ($checkreg.count -ge 1) {
    $checkreg | ForEach-Object {
        if ($null -ne $_.PSChildName) {
            if ([version]$_.DisplayVersion -lt $version) {
                Write-Output "Uninstalling Geogebra Classic previous version : $($_.DisplayVersion)"

                $unInstallArgs = @{
                    packageName    = $env:ChocolateyPackageName
                    softwareName   = 'GeoGebra Classic*'
                    fileType       = 'MSI'
                    file           = ''
                    silentArgs     = "$($_.PSChildName) /qn /norestart"
                    validExitCodes = @(0, 3010, 1605, 1614, 1641)
                }
                Uninstall-ChocolateyPackage @unInstallArgs
                # Process to install
                Write-Output 'Installing new version of Geogebra Classic'
                $ExecInstall = $true
            } elseif (([version]$_.DisplayVersion -eq $version) -and ($env:ChocolateyForce)) {
                Write-Output "Geogebra Classic $version already installed, but --force option is passed, download and install"
                $ExecInstall = $true
            } else {
                Write-Output 'Newest version or same version of Geogebra Classic is already installed, skip install'
                $ExecInstall = $false
            }
        }
    }
}

# Check if install is required
if ($ExecInstall) {
    Install-ChocolateyPackage @packageArgs
}
