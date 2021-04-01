// C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /r:C:\Windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35\System.Management.Automation.dll /unsafe /platform:anycpu /out:C:\Temp\PoshWoPosh.exe C:\Temp\PoshWoPosh.cs

using System;
using System.Runtime.InteropServices;
using System.Management.Automation.Runspaces;

public class Program {
	public static void Main(string[] args) {
		pshell.Run(args[0]);
	}
}

public class pshell {
	public static void Run(string path) {
		string code = System.IO.File.ReadAllText(path);
		RunspaceConfiguration rsconfig = RunspaceConfiguration.Create();
		Runspace rs = RunspaceFactory.CreateRunspace(rsconfig);
		rs.Open();
		Pipeline pipe = rs.CreatePipeline();
		pipe.Commands.AddScript(code);
		pipe.Invoke();
	}
}