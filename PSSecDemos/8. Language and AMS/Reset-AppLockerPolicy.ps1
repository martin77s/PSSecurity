@'
<AppLockerPolicy Version="1">

<RuleCollection Type="Exe" EnforcementMode="NotConfigured" />

<RuleCollection Type="Msi" EnforcementMode="NotConfigured" />

<RuleCollection Type="Script" EnforcementMode="NotConfigured" />

<RuleCollection Type="Dll" EnforcementMode="NotConfigured" />

</AppLockerPolicy>
'@ | Out-File -FilePath C:\Temp\clear.xml -Verbose
Import-Module AppLocker
Set-AppLockerPolicy -XMLPolicy C:\Temp\clear.xml -Verbose

dir $env:windir\System32\AppLocker\ | Remove-Item -Force -Verbose


$null = Read-Host 'Press Enter to continue'