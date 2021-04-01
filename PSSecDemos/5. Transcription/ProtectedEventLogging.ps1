function Enable-ProtectedEventLogging {
    param([Parameter(Mandatory)]$Certificate)

    $basePath = 'HKLM:\Software\Policies\Microsoft\Windows\EventLog\ProtectedEventLogging'
    if(-not (Test-Path $basePath)) { $null = New-Item $basePath –Force }

    Set-ItemProperty $basePath -Name EnableProtectedEventLogging -Value '1'
    Set-ItemProperty $basePath -Name EncryptionCertificate -Value $Certificate
}

function Disable-ProtectedEventLogging{
    Remove-Item HKLM:\Software\Policies\Microsoft\Windows\EventLog\ProtectedEventLogging -Force –Recurse
}


# Create the certificate:
$cert = New-SelfSignedCertificate -DnsName PSPEL -CertStoreLocation cert:\LocalMachine\my `
    -KeyUsage KeyEncipherment, DataEncipherment, KeyAgreement -Type DocumentEncryptionCert

$cert = dir cert:\LocalMachine\My -DocumentEncryptionCert
Enable-ProtectedEventLogging -Certificate $cert.Thumbprint


$events = Get-WinEvent -FilterHashtable @{
    ProviderName='Microsoft-Windows-PowerShell'; Id=4104 } |
        Select-Object -First 5

$events | Out-GridView -PassThru | ForEach-Object {
    Unprotect-CmsMessage -Content $_.Message -IncludeContext
}