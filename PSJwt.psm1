if ($PSEdition -eq "Core") {
    Import-Module -Name "$PSScriptRoot/lib/jwt/netstandard1.3/JWT.dll" | Out-Null
    Import-Module -Name "$PSScriptRoot/lib/Newtonsoft.json.9.0.1/netstandard1.0/Newtonsoft.Json.dll" | Out-Null
}
else {
    Import-Module -Name "$PSScriptRoot/lib/jwt/net46/JWT.dll" | Out-Null
    Import-Module -Name "$PSScriptRoot/lib/Newtonsoft.json.9.0.1/net45/Newtonsoft.Json.dll" | Out-Null
}

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}


Export-ModuleMember -Function $Public.Basename