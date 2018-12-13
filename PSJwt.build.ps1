<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
#>

# use the most strict mode
Set-StrictMode -Version Latest

try {

    $script:IsWindows = (-not (Get-Variable -Name IsWindows -ErrorAction Ignore)) -or $IsWindows
    $script:IsLinux = (Get-Variable -Name IsLinux -ErrorAction Ignore) -and $IsLinux
    $script:IsMacOS = (Get-Variable -Name IsMacOS -ErrorAction Ignore) -and $IsMacOS
    $script:IsCoreCLR = $PSVersionTable.ContainsKey('PSEdition') -and $PSVersionTable.PSEdition -eq 'Core'

}

catch {
    Write-Error -Message ('Unsupported OS')
}

task UpdateHelp {
    Import-Module .\PSJwt.psd1 -Force
    Update-MarkdownHelp .\docs 
    New-ExternalHelp -Path .\docs -OutputPath .\en-US -Force
}
 
task GetLatestJWTPackage {
    & nuget list JWT | Where-Object {$_ -match '^JWT.\d.\d.\d'}
}

task UpdateJWTPackage {
    # Check current JWT Package version
    # Get jwt.dll file properties
    $File = Get-ChildItem -Path .\lib\ -Filter jwt.dll -Recurse | Select-Object -First 1
    [Version]$ProductVersion = $File.VersionInfo.ProductVersion
    Write-Output -InputObject ('ProductVersion {0}' -f $ProductVersion)

    # Check latest version JWTPackage
    [Version]$LatestVersion = ((& nuget list JWT | Where-Object {$_ -match '^JWT.\d.\d.\d'}).split(' '))[1]
    Write-Output -InputObject ('Latest Version {0}' -f $LatestVersion)

    #Download latest version when newer
    If ($LatestVersion -gt $ProductVersion) {
        Write-Output -InputObject ('Newer version {0} available' -f $LatestVersion)
        #Install jwt package to temp folder
        nuget install JWT -OutputDirectory ([IO.Path]::GetTempPath())

        Write-Output -InputObject ('Copy JWT binaries to PSJwt Module')
        $libpath = Resolve-Path -Path ("$([IO.Path]::GetTempPath())" + "*jwt*\lib*")
        Copy-Item -Path ($($libpath.path) + '\*') -Destination .\lib\jwt -Recurse

        Write-Output -InputObject ('Copy Newtonsoft binaries to PSJwt Module')
        $libpath = Resolve-Path -Path ("$([IO.Path]::GetTempPath())" + "*newtonsoft*\lib*")
        $libpathnewtonsoftstandard = $libpath | Get-ChildItem -Filter netstandard*| Sort-Object -Property Name -Descending | Select-Object -First 1
        Copy-Item -Path ($($libpathnewtonsoftstandard.FullName) + '\*') -include *.xml, *.dll -Destination (".\lib\Newtonsoft\$($libpathnewtonsoftstandard.name)") 

        $libpathnewtonsoftnet = $libpath | Get-ChildItem -Filter net*| Sort-Object -Property Name -Descending | Select-Object -First 1
        Copy-Item -Path ($($libpathnewtonsoftnet.FullName) + '\*') -include *.xml, *.dll -Destination (".\lib\Newtonsoft\$($libpathnewtonsoftnet.name)")
    }
    else {
        Write-Output -InputObject ('Current local version {0}. Latest version {1}' -f $ProductVersion, $LatestVersion)
    }
}

# Synopsis: Build, test and clean all.

task . UpdateHelp, UpdateJWTPackage