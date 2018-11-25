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

catch { }

task UpdateHelp {
    Import-Module .\PSJwt.psd1 -Force
    Update-MarkdownHelp .\docs
}