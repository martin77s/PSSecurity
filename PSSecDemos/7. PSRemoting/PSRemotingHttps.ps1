 # Create the HTTPS Listener
$listnerParams = @{
    ItemType              = 'Listener'
    Path                  = 'WSMan:\LocalHost\Listener'
    Address               = '*'
    Transport             = 'HTTPS'
    CertificateThumbPrint = '73DCBA53D8EC5EBF2702F7093222269AE6A0D549'
}
New-Item @listnerParams



# Copy the HTTP Rule to create HTTPS Rule
Get-NetFirewallRule -Name WINRM-HTTP-In-TCP |
   Copy-NetFirewallRule -NewName WINRM-HTTPS-In-TCP

Get-NetFirewallRule -Name WINRM-HTTPS-In-TCP |
   Set-NetFirewallRule -LocalPort 5986 `
      -NewDisplayName 'Inbound rule for Windows Remote Management [TCP 5986]' 
