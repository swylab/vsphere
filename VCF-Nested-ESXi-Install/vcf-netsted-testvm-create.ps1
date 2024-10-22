# 변수 설정
$vCenterServer="_vCenterServer_IP_"
$vCenterServerAdmin="_vCenterServer_Admin_"
$vCenterServerPassword="_vCenterServer_Password_"
$myTargetVMHost = "_ResourcePool_"
$DatastoreName = "_DatastoreName_" #"Dell-vsanDatastore
$MyFolder1 = "_FolderName_"
$NetworkName = "_NetworkName_" #dell_DS_Trunk_all
$ESXiISOPath = "[Dell-vsanDatastore] 53b91567-8a45-31c7-cecb-f0d4e2e6f41c/VMware-VMvisor-Installer-7.0U3g-20328353.x86_64.iso" #ISO가 위치해있는 경로

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
    for ($j = 1; $j -le 2; $j++) {
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

# ★ VM 생성 설정 ★
$VMBaseName = "SWY-ESXi"
$VMCount = 3
$NumCPU = 16
$MemoryGB = 10
$Disk1GB = 40  # OS
$Disk2GB = 50   # 캐시
$Disk3GB = 100  # 하드

# 지정된 수만큼 VM 생성
for ($i = 1; $i -le $VMCount; $i++) {
    $VMName = "{0}{1:D2}" -f $VMBaseName, $i
    Write-Host "Creating VM: $VMName"
    Create-NestedESXi -VMName $VMName -NumCPU $NumCPU -MemoryGB $MemoryGB -DiskGB $Disk1GB
    Write-Host "$VMName 에 $Disk1GB GB / $Disk2GB GB / $Disk3GB GB 크기의 디스크가 추가되었습니다."
}

# vCenter 연결 해제
Disconnect-VIServer -Server $vCenterServer -Confirm:$false