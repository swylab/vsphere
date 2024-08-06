### Datacenter 내에 있는 모든 호스트의 CPU 사용량이 일자별로 나옴!!!!!!!!!!!!!!! 
## 일자별로 나오는게 아닌 월 별로 나와야 됨!!!!!!!!!!!!!

Set-PowerCLICOnfiguration -Scope User -InvalidCertificateAction Ignore -DefaultVIServerMode Single -ParticipateInCeip $false -Confirm:$false

$vCenterServer="_vCenter_IP_"
$vCenterServerAdmin="administrator@vsphere.local"
$vCenterServerPassword="VMware1!"

Connect-VIServer $vCenterServer -User $vCenterServerAdmin -Password $vCenterServerPassword
Get-Module -Name VMware.Vim* | Import-Module
Get-Module -ListAvailable 'VMware.Hv.helper' | Import-Module 

# 파일 생성
# Get the current date
$currentDate = Get-Date

# Format the date as YYYYMMDD
$dateString = $currentDate.ToString("yyyyMMdd")

# Define the file path (you can change the directory and file extension as needed)
$CSVfilePath = "C:\Users\HP\Downloads\Server$dateString.csv"
$CSVfilePath_Final = "C:\Users\HP\Downloads\ServerFinal$dateString.csv"
# Create the file
#New-Item -Path $CSVfilePath -ItemType File

# 날짜 지정
$year= Read-Host -Prompt "년도(yyyy) "
$month= Read-Host -Prompt "평균 월 입력(mm) "
$days= Read-Host -Prompt "월 전체 일수 입력(dd) "

Get-VMHost | Get-Stat -Stat cpu.usage.average | Select-Object -Property Timestamp,value | findstr "$year-$month" > $CSVfilePath
gc $CSVfilePath | %{ $_.Split(' ')[3-4]; } > $CSVfilePath_Final

