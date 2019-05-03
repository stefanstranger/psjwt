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
        $Secret,
        [HashTable]
        $Headers
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
        if($Headers)
        {
            $extraHeaders = [Collections.Generic.Dictionary[string,object]]::new()
            $Headers.GetEnumerator() |ForEach-Object {$extraHeaders.Add(([string]$_.Key),$_.Value)}
            $result = $Encoder.Encode($extraHeaders, $PayLoad, $Secret)
        }
        else
        {
            $result = $Encoder.Encode($PayLoad, $Secret)
        }

        return $result
        #endregion
    }
    end {
        Remove-Variable -Name Encoder
    }
}
