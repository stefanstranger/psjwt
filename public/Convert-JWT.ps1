Function Convert-JWT {
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Token
    )

    begin {
        $Serializer = [JWT.Serializers.JsonNetSerializer]::new()
        $Provider = [JWT.UtcDateTimeProvider]::new()
        $Validator = [JWT.JwtValidator]::new($Serializer, $provider)
        $UrlEncoder = [JWT.JwtBase64UrlEncoder]::new()

        $Decoder = [JWT.JwtDecoder]::new($Serializer, $Validator, $UrlEncoder)
    }
    process {
        $result = $Decoder.Decode($token) | ConvertFrom-Json

        return $result
    }
}