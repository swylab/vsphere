Add-Type -AssemblyName Microsoft.VisualBasic

$oRetrun=[System.Windows.Forms.MessageBox]::Show('변수 값을 자신의 값으로 설정 후 진행 바랍니다 9-17 번째 줄',"정보",[System.Windows.Forms.MessageBoxButtons]::OKCancel) 
        if ( $oRetrun -eq "OK" ) 
        { echo ' 작업이 진행 됩니다. ' } else {echo "작업이 취소 되었습니다."; break }

      
# 변수 설정 ----- 자기 자신의 값으려 변경 해야 하는 변수
$vCenterServer="_vCenterServer_IP_"
$vCenterServerAdmin="_vCenterServer_Admin_"
$vCenterServerPassword="_vCenterServer_Password_"
$myTargetVMHost = "_ResourcePool_"
$DatastoreName = "_DatastoreName_" #"Dell-vsanDatastore
$MyFolder1 = "_FolderName_"
$NetworkName = "_NetworkName_" #dell_DS_Trunk_all
$ESXiISOPath = "[Dell-vsanDatastore] 53b91567-8a45-31c7-cecb-f0d4e2e6f41c/VMware-VMvisor-Installer-7.0U3g-20328353.x86_64.iso" #ISO가 위치해있는 경로
$netCount = 3  # 포트그룹 추가 할 개수 ( 기본은 1개 +@ )
######################################################################################################################################

# vCenter 연결
Connect-VIServer -Server $vCenterServer -User $vCenterServerAdmin -Password $vCenterServerPassword

# VM 생성 함수 정의
function Create-NestedESXi {
    param (
        [string]$VMName,
        [int]$NumCPU,
        [int]$MemoryGB,
        [int]$DiskGB
    )

    # 새 가상 머신 생성
    New-VM -Name $VMName -ResourcePool $myTargetVMHost -Location $MyFolder1 -Datastore $DatastoreName `
        -NumCPU $NumCPU -MemoryGB $MemoryGB -DiskGB $DiskGB -NetworkName $NetworkName -Floppy -CD `
        -DiskStorageFormat Thin -GuestID vmkernel8guest

    # 하드웨어 지원 가상화 활성화
    $vm = Get-VM -Name $VMName
    $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $spec.NestedHVEnabled = $true
    $vm.ExtensionData.ReconfigVM($spec)

    # CD/DVD 드라이브 추가 및 ESXi ISO 연결
    $cdDrive = Get-CDDrive -VM $vm
    Set-CDDrive -CD $cdDrive -IsoPath $ESXiISOPath -StartConnected $true -Confirm:$false

    # 추가 디스크 생성
    New-HardDisk -VM $VMName -CapacityGB $Disk2GB
    New-HardDisk -VM $VMName -CapacityGB $Disk3GB

    
    # 추가 네트워크 어댑터 생성

    for ($j = 1; $j -le $netCount; $j++) {
        New-NetworkAdapter -VM $VMName -NetworkName $NetworkName -StartConnected -Type Vmxnet3
    }

    # 두 번째 디스크를 SSD로 변경
    $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $spec.ExtraConfig += New-Object VMware.Vim.OptionValue
    $spec.ExtraConfig[-1].Key = "scsi0:1.virtualSSD"
    $spec.ExtraConfig[-1].Value = "1"
    $vm.ExtensionData.ReconfigVM_Task($spec)

    # 가상 머신 시작
    Start-VM -VM $VMName
}



# VM 생성 설정
$VMBaseName = "SWY-ESXi"
$oRetrun=[System.Windows.Forms.MessageBox]::Show("VM 기본 이름이 $VMBaseName 이 맞습니까?","정보",[System.Windows.Forms.MessageBoxButtons]::OKCancel) 
        if ( $oRetrun -eq "OK" ) 
        { echo ' 작업이 진행 됩니다. ' } else {echo "작업이 취소 되었습니다."; break }

#$VMCount = Read-Host "VM 생성 수 입력"
$VMCount = [Microsoft.VisualBasic.Interaction]::InputBox("VM 생성 수 입력", "VM설정")
#$NumCPU = Read-Host "CPU  할당 수"
$NumCPU = [Microsoft.VisualBasic.Interaction]::InputBox("VM CPU  할당 수", "VM설정")
#$MemoryGB = Read-Host "Memory 할당 수"
$MemoryGB = [Microsoft.VisualBasic.Interaction]::InputBox("VM Memory 할당 수 (GB)", "VM설정")
#$Disk1GB = Read-Host "OS 영역 디스크 용량(GB)"  # OS
$Disk1GB = [Microsoft.VisualBasic.Interaction]::InputBox("OS 영역 디스크 용량(GB)", "VM설정")
#$Disk2GB = Read-Host "vSAN Cache 영역 디스크 용량(GB)"  # 캐시
$Disk2GB = [Microsoft.VisualBasic.Interaction]::InputBox("vSAN Cache 영역 디스크 용량(GB)", "VM설정")
#$Disk3GB = Read-Host "vSAN DATA 영역 디스크 용량(GB)"  # 하드
$Disk3GB = [Microsoft.VisualBasic.Interaction]::InputBox("vSAN DATA 영역 디스크 용량(GB)", "VM설정")

# 지정된 수만큼 VM 생성
for ($i = 1; $i -le $VMCount; $i++) {
    $VMName = "{0}{1:D2}" -f $VMBaseName, $i
    Write-Host "Creating VM: $VMName"
    Create-NestedESXi -VMName $VMName -NumCPU $NumCPU -MemoryGB $MemoryGB -DiskGB $Disk1GB
    Write-Host "$VMName 에 $Disk1GB GB / $Disk2GB GB / $Disk3GB GB 크기의 디스크가 추가되었습니다."
}

# vCenter 연결 해제
Disconnect-VIServer -Server $vCenterServer -Confirm:$false
