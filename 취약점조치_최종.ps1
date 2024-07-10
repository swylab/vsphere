#Set-PowerCLICOnfiguration -Scope User -InvalidCertificateAction Ignore -DefaultVIServerMode Single -ParticipateInCeip $false -Confirm:$false

$vCenterServer="_vCenter_IP_"
$vCenterServerAdmin="administrator@vsphere.local"
$vCenterServerPassword="VMware1!"
#$ConnectionServer="_Connection_IP_"
#$ConnectionServerAdmin="_Connection_Server_admin_"

Connect-VIServer $vCenterServer -User $vCenterServerAdmin -Password $vCenterServerPassword
Get-Module -Name VMware.Vim* | Import-Module
Get-Module -ListAvailable 'VMware.Hv.helper' | Import-Module 

#Connection Server 
#Connect-HVServer -server $ConnectionServer -User $ConnectionServerAdmin -Password $vCenterServerPassword


# 예) 서버이름 : esxi*



########################## 적용할 클러스터를 입력 ######################################
### $VMcluster="*"

### ForEach($VMcluster in (Get-Cluster -Name "클러스터 명 입력") | sort)

### {

### Write-Host $VMcluster

### }

### Get-Cluster $VMcluster | get-VMhost | Get-AdvancedSetting -Name UserVars.ESXiShellInteractiveTimeOut | ft -AutoSize
### Get-Cluster $VMcluster | get-VMhost | Get-AdvancedSetting -Name UserVars.ESXiShellInteractiveTimeOut | Set-AdvancedSetting -Value "0" | ft -AutoSize
##########################################################################################



# 1. 비밀번호 복잡도 정책 생성
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name Security.PasswordQualityControl | ft -AutoSize
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name Security.PasswordQualityControl | Set-AdvancedSetting -Value "retry=3 min=disabled,disabled,disabled,8,8" | ft -AutoSize

# min=n1/n2/n3/n4/n5 자리 수 확인 -> 최종 확인 필요!!
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name Security.PasswordQualityControl | Set-AdvancedSetting -Value "retry=3 min=disabled,disabled,8,7,7" | ft -AutoSize


# 3. LockDown 모드 설정
Get-VMHost -Name esxi* | Select Name,@{N="Lockdown";E={$_.Extensiondata.Config.LockdownMode}}
Get-VMHost -Name esxi* | Select Name,@{N="Lockdown";E={$_.ExtensionData.ConfigManager}}

# 활성화
(Get-VMHost -Name esxi* | Get-View).EnterLockdownMode()

# 비활성화
(Get-VMHost -Name esxi* | Get-View).ExitLockdownMode()

# 5. 예외 사용자 리스트 확인 
$vmhost = Get-VMHost -Name esxi* | Get-View
$lockdown = Get-View $vmhost.ConfigManager.HostAccessManager
$lockdown.QueryLockdownExceptions()

# 5. 예외 사용자 추가 (accountName에 추가할 사용자 입력)
$accountName = "root"
$vmhost = Get-VMHost -Name esxi* | Get-View
$lockdown = Get-View $vmhost.ConfigManager.HostAccessManager
$lockdown.UpdateLockdownExceptions($accountName)


# 7.ESXi Shell 서비스 타임아웃 설정 => SSH 시간 자동 종료됨.
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name UserVars.ESXiShellTimeOut | ft -AutoSize
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name UserVars.ESXiShellTimeOut | Set-AdvancedSetting -Value "3600" | ft -AutoSize

# 8. ESXi Shell 세션 서비스 타임아웃 설정
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name UserVars.ESXiShellInteractiveTimeOut | ft -AutoSize
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name UserVars.ESXiShellInteractiveTimeOut | Set-AdvancedSetting -Value "900" | ft -AutoSize


# 연결 끊기
Disconnect-VIServer -Server $vCenterServer -Confirm:$false
#Disconnect-HVServer -Server $ConnectionServer -Confirm:$false


