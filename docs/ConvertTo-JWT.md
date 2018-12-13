---
external help file: PSJwt-help.xml
Module Name: PSJwt
online version:
schema: 2.0.0
---

# ConvertTo-JWT

## SYNOPSIS
Creating (encoding) JSON Web Token

## SYNTAX

```
ConvertTo-JWT [-PayLoad] <Hashtable> [-Secret] <String> [<CommonParameters>]
```

## DESCRIPTION
Encodes payload to encoded JSON Web Token.

## EXAMPLES

### Example 1
```powershell
PS C:\> @{'FirstName' = 'Stefan'; 'LastName' = 'Stranger'; 'Demo' = 'Encode Access Token'; 'exp' = '1393286893'; 'iat' = '1393268893'} | ConvertTo-Jwt -secret 'qwerty'
```

Encodes Dictionary (Hashtable) payload to encoded JSON Web Token.

## PARAMETERS

### -PayLoad
Payload, which contains the claims. Claims are statements about an entity (typically, the user) and additional data. There are three types of claims: registered, public, and private claims.
The payload needs to be dictionary (HashTable) object.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Secret
JWTs can be signed using a secret (with the HMAC algorithm).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Collections.Hashtable

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
