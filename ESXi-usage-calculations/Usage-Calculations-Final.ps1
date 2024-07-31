Set-PowerCLICOnfiguration -Scope User -InvalidCertificateAction Ignore -DefaultVIServerMode Single -ParticipateInCeip $false -Confirm:$false

# 정보 입력
$vCenterServer="_vCenter_IP_"
$vCenterServerAdmin="administrator@vsphere.local"
$vCenterServerPassword="_vCenter_PW_"

# vCenter 연결
Connect-VIServer $vCenterServer -User $vCenterServerAdmin -Password $vCenterServerPassword
Get-Module -Name VMware.Vim* | Import-Module
Get-Module -ListAvailable 'VMware.Hv.helper' | Import-Module 

# 한달 일자 계산
$currentDate = Get-Date

$nextMonth = $currentDate.AddMonths(1)
$firstDayNextMonth = [datetime]::new($nextMonth.Year, $nextMonth.Month, 1)

$lastDayCurrentMonth = $firstDayNextMonth.AddDays(-1)
$lastDayCurrentMonth.Day

### 당일 일자로 자동 파일 생성 
# 파일명 : Server20240731.csv
# 파일저장경로 설정 필요

$currentDate = Get-Date
$dateString = $currentDate.ToString("yyyyMMdd")
$CSVfilePath = "C:\Users\HP\Downloads\Server$dateString.csv"

# 호스트 CPU, Memory 사용량 확인
Get-VMHost | Sort Name | Select Name,
@{N="Cluster";E={($_ | Get-Cluster).Name}},
@{N="VMs";E={(Get-View $_).Vm.Count}},
@{N="Cpu.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Cpu.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}},
@{N="Mem.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Mem.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}} | 
Export-Csv -Path $CSVFilePath -NoTypeInformation
#Write-Output "File created at: $CSVfilePath"

# vCenter 연결 해제
Disconnect-VIServer -Server $vCenterServer -Confirm:$false