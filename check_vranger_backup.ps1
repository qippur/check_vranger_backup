if (-not (Get-PSSnapin vRanger.API.PowerShell -ErrorAction SilentlyContinue)) 
	{
	Add-PSSnapin vRanger.API.PowerShell > $null
	}

$Now = Get-Date
$TwoDaysAgo = $Now.AddDays(-2)
$ThreeDaysAgo = $Now.AddDays(-3)
$FourDaysAgo = $Now.AddDays(-4)
$TenDaysAgo = $Now.AddDays(-10)
$OneWeekAgo = $Now.AddDays(-7)
$LastMonth = $Now.AddMonths(-1)
$ReturnString = ""

$Statuses = @(0,3,1,2);
$OverallStatus = 0

$AllJobTemplates = Get-JobTemplate -type Backup | Where-Object {$_.Schedule -ne $NULL -and $_.IsCurrent -eq $True -and $_.IsDeleted -eq $False -and $_.IsEnabled -eq $True}
$AllJobTemplates | ForEach-Object {
	$TemplateVersionID = $_.TemplateVersionID
	$TemplateID = $_.Id
	# $Job = Get-Job -JobTemplateIDs $TemplateID | Where-Object {$_.StartedOn -gt $FourDaysAgo} | Sort-Object -Property StartedOn | Select -Last 1
	$Job = Get-Job -starttime $FourDaysAgo | Where-Object {$_.ParentJobTemplateId -eq $TemplateVersionID} | Sort-Object -Property StartedOn | Select -Last 1
	if ($Job -eq $NULL) {
		if ($OverallStatus -lt 1) {$OverallStatus = 1}
		Return
	}
	$Job.JobTasks | ForEach-Object {
		if ($_.Status.State -eq 'Completed') {
			if ($_.Status.Status -eq 'Success') {
				$ReturnString = $ReturnString + "OK Backup " + $_.VmName + "`n"
			} else {
				$OverallStatus = 3
				$ReturnString = $ReturnString + "FAILED Backup " + $_.VmName + "`n"
			}
		} ElseIf ($_.Status.State -eq 'Running') {
			if ($_.StartedOn -lt $TwoDaysAgo) {
				$ReturnString = $ReturnString + "FAILED Backup " + $_.VmName + " still running`n"
				if ($OverallStatus -lt 2) {$OverallStatus = 2}
			}
		} else {
			$ReturnString = $ReturnString + "UNKNOWN Backup " + $_.VmName + " is " + $_.Status + " - check console`n"
			if ($OverallStatus -lt 1) {$OverallStatus = 1}
		}
	}
}
$ReturnString.SubString(0,$ReturnString.Length - 1)
exit $Statuses[$OverallStatus]
