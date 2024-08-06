Set-PowerCLICOnfiguration -Scope User -InvalidCertificateAction Ignore -DefaultVIServerMode Single -ParticipateInCeip $false -Confirm:$false

# 정보 입력
$vCenterServer="_vCenter_IP_"
$vCenterServerAdmin="administrator@vsphere.local"
$vCenterServerPassword="VMware1!"

# vCenter 연결
Connect-VIServer $vCenterServer -User $vCenterServerAdmin -Password $vCenterServerPassword


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
$CSVfilePath = "C:\Users\jjlee1215-nb\Desktop\script\$dateString.csv"

#################### 호스트 CPU, Memory 사용량 확인 = # 전체 호스트 대상

<# Get-VMHost | Sort Name | Select Name,
@{N="Cluster";E={($_ | Get-Cluster).Name}},
@{N="VMs";E={(Get-View $_).Vm.Count}},
@{N="Cpu.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Cpu.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}},
@{N="Mem.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Mem.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}} | 
Export-Csv -Path $CSVFilePath -NoTypeInformation


Write-Output "File created at: $CSVfilePath" #>


#################### 호스트 CPU, Memory 사용량 확인 = # 특정 호스트 대상 # 입력해야함.

 $GetHost= Read-Host -Prompt "호스트 명 입력"

Get-VMHost -Name $GetHost | Sort Name | Select Name,
@{N="Cluster";E={($_ | Get-Cluster).Name}},
@{N="VMs";E={(Get-View $_).Vm.Count}},
@{N="Cpu.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Cpu.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}},
@{N="Mem.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Mem.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}} | 
Export-Csv -Path $CSVFilePath -NoTypeInformation


Write-Output "File created at: $CSVfilePath" 

write-host " 완료" $esx -ForegroundColor Green
write-host "################################################################################" $esx -ForegroundColor Green #>

################### 호스트 CPU, Memory 사용량 확인 = # 특정 클러스터 대상 # 입력해야함.

<# Get-Cluster | Format-table

$GetCluster= Read-Host -Prompt "클러스트 명 입력" # 특정 클러스터 대상

Get-Cluster -name $getCluster | Get-VMHost | Sort Name | Select Name,
@{N="Cluster";E={($_ | Get-Cluster).Name}},
@{N="VMs";E={(Get-View $_).Vm.Count}},
@{N="Cpu.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Cpu.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}},
@{N="Mem.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Mem.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}} | 
Export-Csv -Path $CSVFilePath -NoTypeInformation


Write-Output "File created at: $CSVfilePath" #>

# vCenter 연결 해제
Disconnect-VIServer -Server $vCenterServer -Confirm:$false