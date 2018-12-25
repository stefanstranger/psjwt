<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
#>

# use the most strict mode
Set-StrictMode -Version Latest

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

task CopyModuleFiles {

    # Copy Module Files to Output Folder
    if (-not (Test-Path .\output)) {

        $null = New-Item -Path .\output -ItemType Directory

    }

    Copy-Item -Path '.\en-US\' -Filter *.* -Recurse -Destination .\output -Force
    Copy-Item -Path '.\lib\' -Filter *.* -Recurse -Destination .\output -Force
    Copy-Item -Path '.\public\' -Filter *.* -Recurse -Destination .\output -Force
    Copy-Item -Path '.\tests\' -Filter *.* -Recurse -Destination .\output -Force

    #Copy Module Manifest files
    Copy-Item -Path @(
        '.\README.md'
        '.\PSJwt.psd1'
        '.\PSJwt.psm1'
    ) -Destination .\output -Force        
}

task Test {
    Invoke-Pester .\tests
}

task UpdateManifest {
    # Import PlatyPS. Needed for parsing README for Change Log versions
    Import-Module -Name PlatyPS

    # Find Latest Version in README file from Change log.
    $README = Get-Content -Path .\README.md
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    [regex]$regex = '\d\.\d\.\d'
    $Versions = $regex.Matches($MarkdownObject.ParseString($README).Children.Spans.Text) | foreach-object {$_.value}
    ($Versions | Measure-Object -Maximum).Maximum

    $manifestPath = '.\PSJwt.psd1'
 
    # Start by importing the manifest to determine the version, then add 1 to the Build
    $manifest = Test-ModuleManifest -Path $manifestPath
    [System.Version]$version = $manifest.Version
    [String]$newVersion = New-Object -TypeName System.Version -ArgumentList ($version.Major, $version.Minor, ($version.Build + 1))
    Write-Output -InputObject ('New Module version: {0}' -f $newVersion)
    
    #Update Module with new version
    Update-ModuleManifest -ModuleVersion $newVersion -Path .\PSJwt.psd1
}

task PublishModule {
    # Get Release Not info from README Change log
    if (!(Get-Module PlatyPS)) {
        Import-Module PlatyPS
    }
    $README = Get-Content -Path .\README.md
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    $ReleaseNotes = ((($MarkdownObject.ParseString($README).Children.Spans.Text) -match '\d\.\d\.\d') -split ' - ')[1]

    Try {
        # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
        $params = @{
            Path         = '.\Output'
            NuGetApiKey  = $env:psgallery
            Name         = 'PSJwt'
            ErrorAction  = 'Stop'
            ReleaseNotes = $ReleaseNotes
        }
        Publish-Module @params
        Write-Output -InputObject ('PSJwt PowerShell Module version {0} published to the PowerShell Gallery' -f $newVersion)
    }
    Catch {
        throw $_
    }
}



task Clean {
    # Clean output folder
    if ((Test-Path .\output)) {

        Remove-Item -Path .\Output -Recurse -Force

    }
}

# Synopsis: Build, test and clean all.

task . Clean, UpdateHelp, UpdateJWTPackage, CopyModuleFiles, Test, PublishModule