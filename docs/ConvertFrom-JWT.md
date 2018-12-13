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
FirstName : Stefan
LastName  : Stranger
Demo      : Encode Access Token
exp       : 1393286893
iat       : 1393268893
```

Decode JSON Web Token to object to validate.

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
