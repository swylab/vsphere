$vCenterServerName = vcsa.cnd.lab
$UserName =
$Password = 

Connect-VIServer -Server $vCenterServerName -User $UserName -Password $Password

# 리소스 풀 이름
$resourcePoolName = "suk.wooyoung"

# 리소스 풀 객체 가져오기
$resourcePool = Get-ResourcePool -Name $resourcePoolName

# "swy"로 시작하는 VM 목록 가져오기
$vmsToMove = Get-VM | Where-Object { $_.Name -like "swy*" }

# 각 VM을 A 리소스 풀로 이동
foreach ($vm in $vmsToMove) {
    Move-VM -VM $vm -Destination $resourcePool
    Write-Host "VM '$($vm.Name)' has been moved to the resource pool '$resourcePoolName'."
}
