Set-PowerCLICOnfiguration -Scope User -InvalidCertificateAction Ignore -DefaultVIServerMode Single -ParticipateInCeip $false -Confirm:$false

$vCenterServer="172.18.10.11"
$vCenterServerAdmin="wooyoung@cnd.lab"
$vCenterServerPassword="seok2022!"

Connect-VIServer $vCenterServer -User $vCenterServerAdmin -Password $vCenterServerPassword
Get-Module -Name VMware.Vim* | Import-Module
Get-Module -ListAvailable 'VMware.Hv.helper' | Import-Module 

# 현재 날짜와 시간 가져옴 
$endTime = Get-Date
$startTime = $endTime.AddMonths(-1)

# 모든 ESXi 호스트 가져옴
$hosts = Get-VMHost

# 각 호스트의 CPU 사용량 데이터 수집
$cpuUsageData = @()

foreach ($host in $hosts) {
    $metrics = Get-Stat -Entity $host -Stat cpu.usage.average -Start $startTime -Finish $endTime
    $cpuUsageData += $metrics
}

# CPU 사용량 평균 계산
$cpuUsageGrouped = $cpuUsageData | Group-Object -Property EntityId

$cpuUsageAverage = $cpuUsageGrouped | ForEach-Object {
    $entityId = $_.Name
    $averageUsage = ($_.Group | Measure-Object -Property Value -Average).Average
    [PSCustomObject]@{
        Host      = $entityId
        AvgCPUUsage = [math]::Round($averageUsage, 2)
    }
}

# 결과 출력
$cpuUsageAverage | Format-Table -AutoSize

# vCenter 서버 연결 해제
Disconnect-VIServer -Server $vCenterServer -Confirm:$false