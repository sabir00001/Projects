# Install Azure PowerShell module if not already installed
#Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser

# Connect to your Azure account
#Connect-AzAccount

# Define variables for AKS cluster
$resourceGroupName = "AKS-prcatice"
$aksClusterName = "vpro-cluster"
$location = "East US"  # e.g., "eastus"
$vmSize = "Standard_B2ms"

# Create a new resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

# Define variables for virtual network and subnet
$vnetName = "aks-practice-vnet-01"
$vnetAddressPrefix = "10.0.0.0/16"
$subnetName = "aks-practice-subnet-01"
$subnetAddressPrefix = "10.0.1.0/24"

# Create virtual network and subnet
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName `
    -Location $location -AddressPrefix $vnetAddressPrefix
$subnet = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix `
    -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork 

# Create AKS cluster configuration
$aksConfig = @{
    ResourceGroupName = $resourceGroupName
    Name = $aksClusterName
    Location = $location
    #NodeCount = 2  # Number of nodes in the default pool
   # NodeVmSize = $vmSize  # Size of the VMs for the default pool
    KubernetesVersion = "1.27.7"  # Kubernetes version
    VnetSubnetId = $subnet.Id  # Associate AKS with the subnet
    #EnableAzureActiveDirectory = $true  # Enable Azure AD integration with RBAC
    #AadTenantId = "YourAADTenantId"  # Azure AD tenant ID
    #AadClientId = "YourAADClientId"  # Azure AD client ID
    #AadServerAppSecret = "YourAADServerAppSecret"  # Azure AD server application secret
    #DnsPrefix = "YourDNSPrefix"  # DNS name prefix for the AKS cluster
    NetworkPlugin = "calico"  # Use Calico for network policies
}

# Create AKS cluster
New-AzAksCluster -Name $aksClusterName @aksConfig -Confirm@{Force = $true}

# Get AKS credentials
$aksContext = Import-AzAksCredential -ResourceGroupName $resourceGroupName -Name $aksClusterName
$aksCred = Import-AzAksCredential -ResourceGroupName $resourceGroupName -Name $aksClusterName -Admin
Set-AzContext -Context $aksContext

# Add a user node pool
$userNodePoolConfig = @{
    ClusterName = $aksClusterName
    Name = "apppool"
    Count = 2  # Number of nodes in the user pool
    VmSize  = $vmSize  # Size of the VMs for the user pool
    
}

New-AzAksNodePool @userNodePoolConfig

# Add a system node pool
$systemNodePoolConfig = @{
    ResourceGroupName = $resourceGroupName
    ClusterName = $aksClusterName
    Name = "systempool"
    Count = 1  # Number of nodes in the system pool
    VmSize = $vmSize # Size of the VMs for the system pool
    EnableAutoScaling = $true  # Enable autoscaling for the system pool
    MinCount = 1  # Minimum number of nodes in the system pool
    MaxCount = 1  # Maximum number of nodes in the system pool
    Mode = "System"  # Specify the node pool as a system pool
    Taints = @("key=CriticalAddonsOnly:true")  # Add taints to the system pool
}
New-AzAksNodePool @systemNodePoolConfig 
