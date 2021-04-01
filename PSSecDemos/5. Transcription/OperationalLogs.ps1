(Get-WinEvent -ListLog Security).SecurityDescriptor
(Get-WinEvent -ListLog Microsoft-Windows-PowerShell/Operational).SecurityDescriptor

$evt = Get-WinEvent -ListLog 'Microsoft-Windows-PowerShell/Operational'
$evt.MaximumSizeInBytes = 100mb
$evt.SecurityDescriptor = (Get-WinEvent -ListLog Security).SecurityDescriptor
$evt.SaveChanges()