---
external help file: PSJwt-help.xml
Module Name: PSJwt
online version:
schema: 2.0.0
---

# ConvertFrom-JWT

## SYNOPSIS
Parsing (decoding) and verifying JSON Web Token

## SYNTAX

```
ConvertFrom-JWT [-Token] <String> [<CommonParameters>]
```

## DESCRIPTION
Decodes JSON Web Token.

## EXAMPLES

### Example 1
```powershell
PS C:\>  $Token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJGaXJzdE5hbWUiOiJTdGVmYW4iLCJMYXN0TmFtZSI6IlN0cmFuZ2VyIiwiRGVtbyI6IkVuY29kZSBBY2Nlc3MgVG9rZW4iLCJleHAiOjEzOTMyODY4OTMsImlhdCI6MTM5MzI2ODg5M30.8-YqAPPth3o-C_xO9WFjW5RViAnDe2WrmVyqLRnNEV0'
ConvertFrom-JWT -Token $Token
Header                Payload
------                -------
@{typ=JWT; alg=HS256} @{FirstName=Stefan; LastName=Stranger; Demo=Encode Access Token; exp=1393286893; iat=1393268893}
```

Decoded JSON Web Token.

### Example 2
```powershell
PS C:\>  $Token = 'eyJFbnYiOiJEZW1vIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJpYXQiOiIxMzkzMjY4ODkzIiwiRGVtbyI6IkVuY29kZSBBY2Nlc3MgVG9rZW4iLCJGaXJzdE5hbWUiOiJTdGVmYW4iLCJleHAiOiIxMzkzMjg2ODkzIiwiTGFzdE5hbWUiOiJTdHJhbmdlciJ9.JFJVUaBIUJmHQUawkK1dH5Iie8tSTTXKFbZZka3_k7Y'
ConvertFrom-JWT -Token $Token
Header                          Payload
------                          -------
@{Env=Demo; typ=JWT; alg=HS256} @{iat=1393268893; Demo=Encode Access Token; FirstName=Stefan; exp=1393286893; LastName=Stranger}
```

Decoded JSON Web Token with extra header info.

### Example 3
```powershell
PS C:\>  $Token = 'eyJFbnYiOiJEZW1vIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJpYXQiOiIxMzkzMjY4ODkzIiwiRGVtbyI6IkVuY29kZSBBY2Nlc3MgVG9rZW4iLCJGaXJzdE5hbWUiOiJTdGVmYW4iLCJleHAiOiIxMzkzMjg2ODkzIiwiTGFzdE5hbWUiOiJTdHJhbmdlciJ9.JFJVUaBIUJmHQUawkK1dH5Iie8tSTTXKFbZZka3_k7Y'
ConvertFrom-JWT -Token $Token | Select-Object -Expand Payload | Select-Object @{'Name' = 'iatutc'; E= {[system.dateTimeOffset]::FromUnixTimeSeconds($_.iat).datetime}},@{'Name' = 'exptutc'; E= {[system.dateTimeOffset]::FromUnixTimeSeconds($_.exp).datetime}}
iatutc             exptutc           
------             -------           
24-2-2014 19:08:13 25-2-2014 00:08:13
```

Decoded JSON Web Token with conversation of Unix Time.

## PARAMETERS

### -Token
JSON Web Token

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
