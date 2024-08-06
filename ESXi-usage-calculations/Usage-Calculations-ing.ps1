Set-PowerCLICOnfiguration -Scope User -InvalidCertificateAction Ignore -DefaultVIServerMode Single -ParticipateInCeip $false -Confirm:$false

$vCenterServer="_vCenter_IP_"
$vCenterServerAdmin="administrator@vsphere.local"
$vCenterServerPassword="VMware1!"

Connect-VIServer $vCenterServer -User $vCenterServerAdmin -Password $vCenterServerPassword
Get-Module -Name VMware.Vim* | Import-Module
Get-Module -ListAvailable 'VMware.Hv.helper' | Import-Module 

# 일자 지정
#$startDate = Read-Host "Enter the start date (YYYY-MM-DD)"
#$endDate = Read-Host "Enter the end date (YYYY-MM-DD)"

#$startDateTime = [datetime]::ParseExact($startDate, 'yyyy-MM-dd', $null)
#$endDateTime = [datetime]::ParseExact($endDate, 'yyyy-MM-dd', $null)

# 일자 지정
$year = Read-Host -Prompt "연도(yyyy)"
$month= Read-Host -Prompt "월 (mm) "
$days= Read-Host -Prompt "해당 월의 총 일자(dd) "

# CPU ?ъ슜??異붿텧 
#$vmhost = Get-VMHost "hp-03.cnd.lab"
#$cpuUsageData = $vmhost | Get-Stat -Stat "cpu.usage.average" | Select-Object -Property Timestamp, Value | Where-Object { ($_.Timestamp -ge $startDateTime) -and ($_.Timestamp -le $endDateTime) }
Get-VMHost | Sort Name | Select Name,
@{N="Cluster";E={($_ | Get-Cluster).Name}},
@{N="VMs";E={(Get-View $_).Vm.Count}},
@{N="Cpu.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Cpu.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}},
@{N="Mem.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Mem.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}} | 
Export-Csv -Path $CSVFilePath -NoTypeInformation

