function Decrypt-SecureString {
    param([System.Security.SecureString]$SecureString)
    return [System.Runtime.InteropServices.Marshal]::PtrToStringUni(
        [System.Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode(
            $SecureString)
    ) 
}

$pass = Read-Host 'Enter password' -AsSecureString
Decrypt-SecureString -SecureString $pass

$creds = Get-Credential
$creds.GetNetworkCredential().Password


function ConvertFrom-Base64Encoding {
    param([string]$string)
    [System.Text.Encoding]::Ascii.GetString([Convert]::FromBase64String($string))
}

ConvertFrom-Base64Encoding -string UzNjdXIzZFBANTV3MHJk
