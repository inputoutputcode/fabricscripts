

$a = (Get-WmiObject -Query "
select * from Win32_QuickFixEngineering" | sort -Property "InstalledOn" -Descending | select -First 1 )

$b  = (Get-WmiObject -Query "
select * from Win32_QuickFixEngineering where 
HotFixID = 'KB4338819' or 
HotFixID = 'KB4338825' or
HotFixID = 'KB4338826' or 
HotFixID = 'KB4338814' or
HotFixID = 'KB4338829' or 
HotFixID = 'KB4338824' or
HotFixID = 'KB4338815' or
HotFixID = 'KB4338820' or
HotFixID = 'KB4338830' or
HotFixID = 'KB4338823' or
HotFixID = 'KB4338818' or
HotFixID = 'KB4338818'" | sort -Property "InstalledOn" -Descending | select -First 1 )

#set of KBs known to fix it. Not exhaustive.
$c = (Get-WmiObject -Query "
select * from Win32_QuickFixEngineering where 
HotFixID = 'KB4338816' or
HotFixID = 'KB4338821' or
HotFixID = 'KB4338831' or
HotFixID = 'KB4345397' or
HotFixID = 'KB4345418' or
HotFixID = 'KB4345419' or
HotFixID = 'KB4345420' or
HotFixID = 'KB4345421' or
HotFixID = 'KB4345424' or
HotFixID = 'KB4345425' or
HotFixID = 'KB4345455' or
HotFixID = 'KB4345459'" | sort -Property "InstalledOn" -Descending | select -First 1 )

$v = (Get-WmiObject -Query "
select * from Win32_OperatingSystem")

$found="BreakingKBFound"

if ($b -eq $null)
{
    $found="NoBreakingKB"
}

if ($c -ne $null)
{
    $found="FixingKBFound"
}

#Write-Host("#ScriptStatsus,machineName,BuildNumber,BreakingKBStatus,BreakingKB,BreakingInstallDate,FixingKB,FixingInstallDate,LastKB,LastInstallDate")
Write-Host("ScriptSuccess,$($env:COMPUTERNAME),$($v.BuildNumber),$found,$($b.HotFixID),$($b.InstalledOn),$($c.HotFixID),$($c.InstalledOn),$($a.HotFixID),$($a.InstalledOn)")

