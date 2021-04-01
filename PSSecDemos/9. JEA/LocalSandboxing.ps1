New-PSSessionConfigurationFile -Path C:\Temp\sandbox.pssc `
 	-SessionType RestrictedRemoteServer `
    		-RunAsVirtualAccount -VisibleFunctions TabExpansion2 `
        		-VisibleExternalCommands C:\Windows\System32\whoami.exe 

Register-PSSessionConfiguration -name sandbox -Path C:\temp\sandbox.pssc


$key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ConsoleSessionConfiguration'
New-Item -Path $key –Force
New-ItemProperty -Path $key -Name ConsoleSessionConfigurationName -Value sandbox
New-ItemProperty -Path $key -Name EnableConsoleSessionConfiguration -Value 1
