# psjwt
PowerShell Module for JWT (JSON Web Tokens)

# Library
The PowerShell Module is using the <a href="https://github.com/jwt-dotnet/jwt" target="_blank">Jwt.Net</a> library.

This library supports generating and decoding <a href="https://tools.ietf.org/html/rfc7519
" target="_blank">JSON Web Tokens</a>.

# JSON Web Tokens
From <a href="https://en.wikipedia.org/wiki/JSON_Web_Token" target="_blank">Wikipedia</a>:

JSON Web Token (JWT) is a <a href="https://en.wikipedia.org/wiki/JSON" target="_blank">JSON</a>-based open standard (RFC 7519) for creating <a href="https://en.wikipedia.org/wiki/Access_token" target="_blank">access tokens</a> that assert some number of claims. For example, a server could generate a token that has the claim "logged in as admin" and provide that to a client. The client could then use that token to prove that it is logged in as admin. The tokens are signed by one party's private key (usually the server's), so that both parties (the other already being, by some suitable and trustworthy means, in possession of the corresponding public key) are able to verify that the token is legitimate. The <a href="https://en.wikipedia.org/wiki/Session_token" target="_blank">tokens</a> are designed to be compact, URL-safe, and usable especially in a web-browser single-sign-on (SSO) context. JWT claims can be typically used to pass identity of authenticated users between an <a href="https://en.wikipedia.org/wiki/Identity_provider" target="_blank">identity provider</a> and a <a href="https://en.wikipedia.org/wiki/Service_provider" target="_blank">service provider</a>, or any other type of claims as required by business processes.
JWT relies on other JSON-based standards: JWS (<a href="https://en.wikipedia.org/wiki/JSON_Web_Signature" target="_blank">JSON Web Signature</a>) <a href="https://tools.ietf.org/html/rfc7515" target="_blank">RFC 7515</a> and JWE (<a href="https://en.wikipedia.org/wiki/JSON_Web_Encryption" target="_blank">JSON Web Encryption</a>) <a href="https://tools.ietf.org/html/rfc7516" target="_blank">RFC 7516</a>

# Change log
* 25-11-2018: 

  Version 0.0.2 - Function ConvertTo-JWT added
* 24-11-2018:

  Version 0.0.1 - Function ConvertFrom-JWT added
