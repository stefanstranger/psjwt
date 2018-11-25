$ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Path)
$ModuleName = 'PSJwt'
$ManifestPath = "$ModulePath\$ModuleName.psd1"
if (Get-Module -Name $ModuleName) {
    Remove-Module $ModuleName -Force
}
Import-Module $ManifestPath -Verbose:$false


# test the module manifest - exports the right functions, processes the right formats, and is generally correct
Describe -Name 'Manifest' -Fixture {
    $ManifestHash = Invoke-Expression -Command (Get-Content $ManifestPath -Raw)

    It -name 'has a valid manifest' -test {
        {
            $null = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It -name 'has a valid root module' -test {
        $ManifestHash.RootModule | Should Be "$ModuleName.psm1"
    }

    It -name 'has a valid Description' -test {
        $ManifestHash.Description | Should Not BeNullOrEmpty
    }

    It -name 'has a valid guid' -test {
        $ManifestHash.Guid | Should Be '6934ef7a-f360-4d10-8e61-471823ec44c1'
    }

    It -name 'has a valid version' -test {
        $ManifestHash.ModuleVersion -as [Version] | Should Not BeNullOrEmpty
    }

    It -name 'has a valid copyright' -test {
        $ManifestHash.CopyRight | Should Not BeNullOrEmpty
    }

    It -name 'has a valid license Uri' -test {
        $ManifestHash.PrivateData.Values.LicenseUri | Should Be 'http://opensource.org/licenses/MIT'
    }

    It -name 'has a valid project Uri' -test {
        $ManifestHash.PrivateData.Values.ProjectUri | Should Be 'https://github.com/stefanstranger/PSJwt'
    }

    It -name "gallery tags don't contain spaces" -test {
        foreach ($Tag in $ManifestHash.PrivateData.Values.tags) {
            $Tag -notmatch '\s' | Should Be $true
        }
    }
}


Describe -Name 'Module PSJwt works' -Fixture {
    It -name 'Passed Module load' -test {
        Get-Module -Name 'PSJwt' | Should Not Be $null
    }
}


Describe -Name 'Test Functions in PSJwt Module' -Fixture {
    Context -Name 'Testing Public Functions' -Fixture {

        It -name 'Passes ConvertFrom-JWT Function' -test {
            $Token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJGaXJzdE5hbWUiOiJTdGVmYW4iLCJMYXN0TmFtZSI6IlN0cmFuZ2VyIiwiRGVtbyI6IkVuY29kZSBBY2Nlc3MgVG9rZW4iLCJleHAiOjEzOTMyODY4OTMsImlhdCI6MTM5MzI2ODg5M30.8-YqAPPth3o-C_xO9WFjW5RViAnDe2WrmVyqLRnNEV0'
            (ConvertFrom-JWT -Token $Token).Demo | Should Be 'Encode Access Token'
        }

        It -name 'Passes ConvertTo-JWT Function' -test {
            $Secret = 'qwerty'
            $Result = ( @{'FirstName' = 'Stefan'; 'LastName' = 'Stranger'; 'Demo' = 'Encode Access Token'; 'exp' = '1393286893'; 'iat' = '1393268893'} | ConvertTo-Jwt -secret $secret)  
            $Result | Should Be 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOiIxMzkzMjY4ODkzIiwiRGVtbyI6IkVuY29kZSBBY2Nlc3MgVG9rZW4iLCJGaXJzdE5hbWUiOiJTdGVmYW4iLCJleHAiOiIxMzkzMjg2ODkzIiwiTGFzdE5hbWUiOiJTdHJhbmdlciJ9.xOTWY783quoJwvGiSlVuC_R3GwUFXbLNDX_Arb16bhA'
        }
    }
}