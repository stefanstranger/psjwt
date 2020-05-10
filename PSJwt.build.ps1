<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
#>

param ($Configuration = 'Development')

#region use the most strict mode
Set-StrictMode -Version Latest
#endregion

#region Task to Update the PowerShell Module Help Files.
# Pre-requisites: PowerShell Module PlatyPS.
task UpdateHelp {
    Import-Module .\PSJwt.psd1 -Force
    Update-MarkdownHelp .\docs 
    New-ExternalHelp -Path .\docs -OutputPath .\en-US -Force
}
#endregion

#region Task to retrieve latest version of JWT Packages
# More info: https://www.nuget.org/packages/JWT
task GetLatestJWTPackage {
    & nuget list JWT | Where-Object { $_ -match '^JWT.\d.\d.\d' }
}
#endregion

#region Task to Update JWT Package if newer version is released
task UpdateJWTPackage {
    # Check current JWT Package version
    # Get jwt.dll file properties
    $File = Get-ChildItem -Path .\lib\ -Filter jwt.dll -Recurse | Select-Object -First 1
    [Version]$ProductVersion = $File.VersionInfo.ProductVersionRaw
    Write-Output -InputObject ('ProductVersion for jwt {0}' -f $ProductVersion)

    # Check latest version JWTPackage
    [Version]$LatestVersion = ((& nuget list JWT | Where-Object { $_ -match '^JWT.\d.\d.\d' }).split(' '))[1]
    Write-Output -InputObject ('Latest Version for jwt {0}' -f $LatestVersion)

    #Download latest version when newer
    If ($LatestVersion -gt $ProductVersion) {
        Write-Output -InputObject ('Newer version {0} available' -f $LatestVersion)
        #Install jwt package to temp folder
        nuget install JWT -OutputDirectory ([IO.Path]::GetTempPath())

        Write-Output -InputObject ('Copy JWT binaries to PSJwt Module')
        $libpath = Resolve-Path -Path ("$([IO.Path]::GetTempPath())" + "*jwt*\lib*")
        Copy-Item -Path ($($libpath.path) + '\*') -Destination .\lib\jwt -Recurse -Force

        Write-Output -InputObject ('Copy Newtonsoft binaries to PSJwt Module')
        $libpath = Resolve-Path -Path ("$([IO.Path]::GetTempPath())" + "*newtonsoft*\lib*")
        $libpathnewtonsoftstandard = $libpath | Get-ChildItem -Filter netstandard* | Sort-Object -Property Name -Descending | Select-Object -First 1
        Copy-Item -Path ($($libpathnewtonsoftstandard.FullName) + '\*') -include *.xml, *.dll -Destination (".\lib\Newtonsoft\$($libpathnewtonsoftstandard.name)") -Force

        $libpathnewtonsoftnet = $libpath | Get-ChildItem -Filter net* | Sort-Object -Property Name -Descending | Select-Object -First 1
        Copy-Item -Path ($($libpathnewtonsoftnet.FullName) + '\*') -include *.xml, *.dll -Destination (".\lib\Newtonsoft\$($libpathnewtonsoftnet.name)") -Force

        #Remove temp newtonsoft folder
        $NewtonsoftPathToRemove = Resolve-Path .\lib\Newtonsoft.json*
        Write-Output -InputObject ('Removing folder {0}' -f ($($NewtonsoftPathToRemove).Path))
        Remove-Item -Path $($NewtonsoftPathToRemove).Path -Recurse -Force

    }
    else {
        Write-Output -InputObject ('Current local version {0}. Latest version {1}' -f $ProductVersion, $LatestVersion)
    }
}
#endregion

#region Task to Copy PowerShell Module files to output folder for release as Module
task CopyModuleFiles {

    # Copy Module Files to Output Folder
    if (-not (Test-Path .\output\PSJwt)) {

        $null = New-Item -Path .\output\PSJwt -ItemType Directory

    }

    Copy-Item -Path '.\en-US\' -Filter *.* -Recurse -Destination .\output\PSJwt -Force
    Copy-Item -Path '.\lib\' -Filter *.* -Recurse -Destination .\output\PSJwt -Force
    Copy-Item -Path '.\public\' -Filter *.* -Recurse -Destination .\output\PSJwt -Force
    Copy-Item -Path '.\tests\' -Filter *.* -Recurse -Destination .\output\PSJwt -Force

    #Copy Module Manifest files
    Copy-Item -Path @(
        '.\README.md'
        '.\PSJwt.psd1'
        '.\PSJwt.psm1'
    ) -Destination .\output\PSJwt -Force        
}
#endregion

#region Task to run all Pester tests in folder .\tests
task Test {
    $Result = Invoke-Pester .\tests -PassThru
    if ($Result.FailedCount -gt 0) {
        throw 'Pester tests failed'
    }

}
#endregion

#region Task to update the Module Manifest file with info from the Changelog in Readme.
task UpdateManifest {
    # Import PlatyPS. Needed for parsing README for Change Log versions
    Import-Module -Name PlatyPS

    # Find Latest Version in README file from Change log.
    $README = Get-Content -Path .\README.md
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    [regex]$regex = '\d\.\d\.\d'
    $Versions = $regex.Matches($MarkdownObject.ParseString($README).Children.Spans.Text) | foreach-object { $_.value }
    ($Versions | Measure-Object -Maximum).Maximum

    $manifestPath = '.\PSJwt.psd1'
 
    # Start by importing the manifest to determine the version, then add 1 to the Build
    $manifest = Test-ModuleManifest -Path $manifestPath
    [System.Version]$version = $manifest.Version
    [String]$newVersion = New-Object -TypeName System.Version -ArgumentList ($version.Major, $version.Minor, ($version.Build + 1))
    Write-Output -InputObject ('New Module version: {0}' -f $newVersion)

    # Update Manifest file with Release Notes
    $README = Get-Content -Path .\README.md
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    $ReleaseNotes = ((($MarkdownObject.ParseString($README).Children.Spans.Text) -match '\d\.\d\.\d') -split ' - ')[1]
    
    #Update Module with new version
    Update-ModuleManifest -ModuleVersion $newVersion -Path .\PSJwt.psd1 -ReleaseNotes $ReleaseNotes
}
#endregion

#region Task to Publish Module to PowerShell Gallery
task PublishModule -If ($Configuration -eq 'Production') {
    Try {
        # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
        $params = @{
            Path        = ('{0}\Output\PSJwt' -f $PSScriptRoot )
            NuGetApiKey = $env:psgallery
            ErrorAction = 'Stop'
        }
        Publish-Module @params
        Write-Output -InputObject ('PSJwt PowerShell Module version published to the PowerShell Gallery')
    }
    Catch {
        throw $_
    }
}
#endregion

#region Task clean up Output folder
task Clean {
    # Clean output folder
    if ((Test-Path .\output)) {

        Remove-Item -Path .\Output -Recurse -Force

    }
}
#endregion

#region Default Task. Runs Clean, Test, CopyModuleFiles Tasks
task . Clean, Test, CopyModuleFiles, PublishModule
#endregion