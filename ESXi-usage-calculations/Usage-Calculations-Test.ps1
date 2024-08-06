Set-PowerCLICOnfiguration -Scope User -InvalidCertificateAction Ignore -DefaultVIServerMode Single -ParticipateInCeip $false -Confirm:$false

$vCenterServer="_vCenter_IP_"
$vCenterServerAdmin="administrator@vsphere.local"
$vCenterServerPassword="VMware1!"

Connect-VIServer $vCenterServer -User $vCenterServerAdmin -Password $vCenterServerPassword
Get-Module -Name VMware.Vim* | Import-Module
Get-Module -ListAvailable 'VMware.Hv.helper' | Import-Module 

# 현재 날짜와 시간 가져옴 
$endTime = Get-Date
$startTime = $endTime.AddMonths(-1)

$endTime | Format-Table -AutoSize
$startTime | Format-Table -AutoSize

# 일자 지정
$startDate = Read-Host "Enter the start date (YYYY-MM-DD)"
$endDate = Read-Host "Enter the end date (YYYY-MM-DD)"

$startDateTime = [datetime]::ParseExact($startDate, 'yyyy-MM-dd', $null)
$endDateTime = [datetime]::ParseExact($endDate, 'yyyy-MM-dd', $null)


# 모든 ESXi 호스트 가져옴
$hosts = Get-VMHost
$hosts | Format-Table -AutoSize

# 각 호스트의 CPU 사용량 데이터 수집
$cpuUsageData = @{}

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



#######################
# Get the current date
$currentDate = Get-Date

# Get the first day of the next month
$nextMonth = $currentDate.AddMonths(1)
$firstDayNextMonth = [datetime]::new($nextMonth.Year, $nextMonth.Month, 1)

# Get the last day of the current month by subtracting one day from the first day of the next month
$lastDayCurrentMonth = $firstDayNextMonth.AddDays(-1)

# Output the last day of the current month
$lastDayCurrentMonth.Day


######################

# Get the current date
$currentDate = Get-Date

# Format the date as YYYYMMDD
$dateString = $currentDate.ToString("yyyyMMdd")

# Define the file path (you can change the directory and file extension as needed)
$CSVfilePath = "C:\Users\HP\Downloads\Server$dateString.csv"

# Create the file
#New-Item -Path $CSVfilePath -ItemType File

Get-VMHost | Sort Name | Select Name,
@{N="Cluster";E={($_ | Get-Cluster).Name}},
@{N="VMs";E={(Get-View $_).Vm.Count}},
@{N="Cpu.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Cpu.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}},
@{N="Mem.Usage.Max(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.Average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Mem.Usage.Avg(%)";E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (Get-Date).AddDays(-$lastDayCurrentMonth.Day) | Measure-Object Value -Average).Average),2)}} | 
Export-Csv -Path $CSVFilePath -NoTypeInformation

# Output the file path to confirm creation
Write-Output "File created at: $CSVfilePath"
