Set-PowerCLICOnfiguration -Scope User -InvalidCertificateAction Ignore -DefaultVIServerMode Single -ParticipateInCeip $false -Confirm:$false

$vCenterServer="10.10.166.10"
$vCenterServerAdmin="administrator@vsphere.local"
$vCenterServerPassword="VMware1!!"
#$ConnectionServer="_Connection_IP_"
#$ConnectionServerAdmin="_Connection_Server_admin_"

Connect-VIServer $vCenterServer -User $vCenterServerAdmin -Password $vCenterServerPassword
Get-Module -Name VMware.Vim* | Import-Module
Get-Module -ListAvailable 'VMware.Hv.helper' | Import-Module 

#Connection Server 
#Connect-HVServer -server $ConnectionServer -User $ConnectionServerAdmin -Password $vCenterServerPassword

# 예) 서버이름 : esxi*
# 1. 비밀번호 복잡도 정책 생성
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name Security.PasswordQualityControl | ft -AutoSize
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name Security.PasswordQualityControl | Set-AdvancedSetting -Value "retry=3 min=disabled,disabled,disabled,8,8" | ft -AutoSize

# 3. LockDown 모드 설정
Get-VMHost -Name esxi* | Select Name,@{N="Lockdown";E={$_.Extensiondata.Config.LockdownMode}}
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

# 7.ESXi Shell 서비스 타임아웃 설정
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name UserVars.ESXiShellTimeOut | ft -AutoSize
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name UserVars.ESXiShellTimeOut | Set-AdvancedSetting -Value "3600" | ft -AutoSize

# 8. ESXi Shell 세션 서비스 타임아웃 설정
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name UserVars.ESXiShellInteractiveTimeOut | ft -AutoSize
Get-VMHost -Name esxi* | Get-AdvancedSetting -Name UserVars.ESXiShellInteractiveTimeOut | Set-AdvancedSetting -Value "900" | ft -AutoSize

Disconnect-VIServer -Server $vCenterServer -Confirm:$falsec
#Disconnect-HVServer -Server $ConnectionServer -Confirm:$false

