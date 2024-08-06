
# 정보 입력
$vCenterServer="_vCenter_IP_"
$vCenterServerAdmin="administrator@vsphere.local"
$vCenterServerPassword="VMware1!"

##vCenter 연결**
Connect-VIServer $vCenterServer -User $vCenterServerAdmin -Password $vCenterServerPassword -Protocol https

echo " "


$month= Read-Host -Prompt "평균 월 입력(mm) "
$days= Read-Host -Prompt "월 전체 일수 입력(dd) "
$year = "2024" # 해마다 변경 해야 함

##########cpu 
$vmhost = Get-VMHost "hp-03.cnd.lab"
$vmhost | Get-Stat -Stat "cpu.usage.average" | Select-Object -Property Timestamp,value | findstr "$year-$month" > ./cpulist.txt
gc .\cpulist.txt | %{ $_.Split(' ')[3-4]; } > cpu_use_list.txt


$sum = 0
foreach ($i in get-content "./cpu_use_list.txt") {

$sum += $i
}
$cpu_avr = $sum/$days
echo " $month 월 cpu 평균값 : $cpu_avr"