# check_vranger_backup
Nagios plugin to check vranger backup results

This plugin uses VRanger PowerShell extensions to provide the result of all recent scheduled (not on-demand) backups.
This version does not provide the possibility to check individual backups.
For this, there is a version by consol_labs: https://labs.consol.de/nagios/check_vranger_jobstatus/
Their site also provides the directions to install Vranger powershell extension:

Setup

First, check if the Snapin is already installed:

`Get-PSSnapin`

If it does not appear in the list of installed PS-Snap-Ins, it has to be installed first:

`C:\Windows\Microsoft.NET\Framework\v2.0.50727>installutil.exe C:\Program Files (x86)\Quest Software\vRanger\PowerShell\vRanger.API.PowerShell.dll`

Then execute

`Set-ExecutionPolicy RemoteSigned`

to allow also the execution of custom scripts.

In nsclient.ini, this is how I implemented the check:

```[/settings/external scripts/scripts]
check_vranger_backup = cmd /c echo scripts\\check_vranger_backup.ps1; exit($lastexitcode) | %SystemRoot%\\syswow64\\WindowsPowerShell\\v1.0\\powershell.exe -command -```
