Function ConvertTo-JWT {
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [HashTable]
        $PayLoad,
        [Parameter(Mandatory = $false)]
        [HashTable]
        $Header,
        [Parameter(Mandatory = $true)]
        [String]
        $Secret        
    )

    begin {
        #region initialize Encoder Object
        $Algorithm = [JWT.Algorithms.HMACSHA256Algorithm]::new()
        $Serializer = [JWT.Serializers.JsonNetSerializer]::new()
        $UrlEncoder = [JWT.JwtBase64UrlEncoder]::new()

        $Encoder = [JWT.JwtEncoder]::new($Algorithm, $Serializer, $UrlEncoder)
        #endregion
    }
    process {
        #region Encode JWT Token
        if ($Header) {
            $extraHeaders = [Collections.Generic.Dictionary[string, object]]::new()
            $Header.GetEnumerator() | ForEach-Object { $extraHeaders.Add(([string]$_.Key), $_.Value) }
            $result = $Encoder.Encode($extraHeaders, $PayLoad, [system.Text.Encoding]::UTF8.GetBytes($Secret))
        }
        else {
            $extraHeaders = [Collections.Generic.Dictionary[string, object]]::new()
            $result = $Encoder.Encode($extraHeaders, $PayLoad, [system.Text.Encoding]::UTF8.GetBytes($Secret))
        }

        return $result
        #endregion
    }
    end {
        Remove-Variable -Name Encoder
    }
}
