Function ConvertTo-JWT {
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [HashTable]
        $PayLoad,
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
        $result = $Encoder.Encode($PayLoad, $Secret)

        return $result
        #endregion
    }
    end {
        Remove-Variable -Name Encoder
    }
}