### main.ps1 Script Overview
The PowerShell script performs the following operations:

#### 1. Connect to Azure
```powershell
Connect-AzAccount
```
This command allows you to log in to Azure using your Azure account credentials. It establishes a connection to Azure, which is necessary to manage Azure resources using PowerShell cmdlets.

#### 2. Set Variables
```powershell
$ResourceGroup = "az-dev-10"
$location = "South Central US"
$StorageName = "azdevst10"
$containerName = "webcont"
$blobName = "CoolColorsWebsite.html"
$localFilePath = "C:\Users\csocsi\Documents\GitHub\az\CoolColorsWebsite.html"
```
These variables store the values required for resource group creation, storage account creation, and file upload to Azure storage.

- `$ResourceGroup`: Specifies the name of the resource group to be created.
- `$location`: Specifies the Azure region where the resource group and storage account will be created.
- `$StorageName`: Specifies the name of the storage account to be created.
- `$containerName`: Specifies the name of the container to be created within the storage account.
- `$blobName`: Specifies the name of the blob (file) to be uploaded to the container.
- `$localFilePath`: Specifies the local file path of the blob to be uploaded.

#### 3. Create a Resource Group
```powershell
New-AzResourceGroup -Name $resourceGroup -Location $location
```
This cmdlet creates a new resource group with the provided name (`$ResourceGroup`) in the specified location (`$location`). Resource groups are logical containers that hold related Azure resources.

#### 4. Create a Storage Account
```powershell
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroup -Name $StorageName -Location $location -SkuName "Standard_LRS" -Kind "StorageV2" -AccessTier "Hot"
```
This command creates a new storage account with the provided name (`$StorageName`) in the specified resource group (`$ResourceGroup`). The storage account is created in the specified location (`$location`) and is configured with the "Standard_LRS" SKU (Standard Locally Redundant Storage), "StorageV2" kind, and "Hot" access tier.

#### 5. Create a Storage Account Context
```powershell
$storageAccountContext = $storageAccount.Context
```
This line retrieves the storage account context, which is required for performing operations on the storage account, such as creating containers and uploading files.

#### 6. Create a New Container in the Storage Account
```powershell
New-AzStorageContainer -Name $containerName -Context $storageAccountContext -Permission Blob
```
This cmdlet creates a new container with the provided name (`$containerName`) in the storage account. The container is created using the storage account context (`$storageAccountContext`), and the `-Permission Blob` parameter specifies that the container should allow blob access.

#### 7. Upload File to the Container
```powershell
Set-AzStorageBlobContent -Container $containerName -Context $storageAccountContext -File $localFilePath -Blob $

blobName
```
This cmdlet uploads a file (`$localFilePath`) to the specified container (`$containerName`) within the storage account. The storage account context (`$storageAccountContext`) is used to establish the connection and perform the upload. The uploaded file is given the name specified by `$blobName`.

#### 8. PowerShell Desired State Configuration (DSC) Configuration and Deployment
This section of the script performs operations related to PowerShell Desired State Configuration (DSC) for Azure VMs. It involves the configuration file and deployment of the DSC extension.

##### Part 2
```powershell
$configurationpath = "./ccv.ps1"

$DscConfigurationParameters = @{
    'configurationpath'  = $configurationpath
    'resourcegroupname'  = $ResourceGroup
    'StorageAccountName' = $StorageName
}

Publish-AzVMDscConfiguration  @DscConfigurationParameters -force -Verbose
```
This part sets the `$configurationpath` variable to the path of the DSC configuration file. The `$DscConfigurationParameters` hash table stores the parameters required for publishing the DSC configuration to Azure. The `Publish-AzVMDscConfiguration` cmdlet publishes the DSC configuration to the specified resource group (`$ResourceGroup`) and storage account (`$StorageName`).

##### Part 3
```powershell
$jsonParameterFilePath = "C:\Users\csocsi\Documents\GitHub\az\arm.parameters.json"
$jsonRMFilePath = "C:\Users\csocsi\Documents\GitHub\az\arm.json"

$ConfigurationName = "CCW"

$jsonContent = Get-Content -Path $jsonParameterFilePath -Raw

$jsonObject = $jsonContent | ConvertFrom-Json

$vmName = $jsonObject.parameters.vmName.value

$SetDscParameters = @{
    'Version'  = '2.76'
    'resourcegroupname'  = $ResourceGroup
    'VMname' = $vmName
    'ArchiveStorageAccountName' = $Storagename
    'ArchiveBlobName' = 'ccv.ps1.zip'
    'AutoUpdate' = $true
    'ConfigurationName' = $ConfigurationName
}

New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $jsonRMFilePath -TemplateParameterFile $jsonParameterFilePath

Set-AzVMDscExtension @SetDscParameters -Verbose
```
This part involves the deployment of the DSC extension to an Azure VM using an Azure Resource Manager (ARM) template. The script reads the ARM template parameter file (`$jsonParameterFilePath`) and ARM template file (`$jsonRMFilePath`) to retrieve necessary information.

The `$ConfigurationName` variable stores the name of the DSC configuration.

The script then extracts the value of the `vmName` parameter from the ARM template parameter file and assigns it to the `$vmName` variable.

The `$SetDscParameters` hash table contains the parameters required for setting up the DSC extension. These parameters include the DSC version, resource group name, VM name, storage account name, blob name, auto-update setting, and the configuration name.

The `New-AzResourceGroupDeployment` cmdlet deploys the ARM template to the specified resource group, using the ARM template and parameter files.

Finally, the `Set-AzVMDscExtension` cmdlet sets up the DSC extension on the Azure VM with the specified parameters.

### Conclusion
This PowerShell script provides a series of commands to manage Azure resources, specifically resource groups, storage accounts, containers, and Azure VM configurations using PowerShell cmdlets. It demonstrates how to connect to Azure, create and configure resources, upload files to storage,

 and deploy DSC configurations to Azure VMs.



 ## arm.json - ARM Template Documentation

This documentation provides an overview and explanation of an Azure Resource Manager (ARM) template written in JSON. The ARM template describes the infrastructure and configuration required to deploy a virtual machine (VM) in Azure.

### Overview

The ARM template is structured using the following sections:

- `$schema`: Specifies the URL of the ARM template schema.
- `contentVersion`: Defines the version of the ARM template.
- `parameters`: Contains the parameters used to customize the deployment.
- `variables`: Declares variables used throughout the template.
- `resources`: Describes the Azure resources to be deployed.
- `outputs`: Specifies the outputs of the ARM template.

### Parameters

The ARM template includes the following parameters:

- `vmName`: Represents the name of the virtual machine.
- `adminUsername`: Specifies the username for the virtual machine.
- `adminPassword`: Stores the password for the virtual machine (secured).
- `osVersion`: Defines the version of the operating system (with default and allowed values).
- `vmSize`: Specifies the size of the virtual machine.
- `osDiskType`: Defines the type of the operating system disk.

### Variables

The ARM template defines the following variables:

- `location`: Retrieves the location of the resource group.
- `nicName`: Constructs the name for the network interface.
- `vnetName`: Constructs the name for the virtual network.
- `subnetName`: Constructs the name for the subnet.
- `nsgName`: Constructs the name for the network security group.
- `publicIpName`: Constructs the name for the public IP address.

### Resources

The ARM template deploys the following Azure resources:

1. Virtual Network (`Microsoft.Network/virtualNetworks`): Creates a virtual network with a specified address space.
   - Subnet (`subnets`): Creates a subnet within the virtual network.

2. Network Interface (`Microsoft.Network/networkInterfaces`): Creates a network interface for the virtual machine.
   - Depends on the virtual network, subnet, network security group, and public IP address.
   - Configures the IP configuration with the assigned subnet and public IP.

3. Public IP Address (`Microsoft.Network/publicIPAddresses`): Creates a public IP address for the virtual machine.

4. Network Security Group (`Microsoft.Network/networkSecurityGroups`): Creates a network security group for the virtual machine.
   - Defines security rules for allowing RDP, web traffic (port 80), and HTTPS traffic (port 443).

5. Virtual Machine (`Microsoft.Compute/virtualMachines`): Deploys the virtual machine with the specified configurations.
   - Depends on the network interface.
   - Defines the hardware profile, OS profile, storage profile, and network profile.
   - Configures the virtual machine's size, computer name, admin credentials, OS disk, and network interfaces.

### Outputs

The ARM template includes a single output:

- `vmFQDN`: Retrieves the fully qualified domain name (FQDN) of the deployed virtual machine.

### Conclusion

This ARM template provides a structured and declarative way to define and deploy the infrastructure required for a virtual machine in Azure. It allows customization through parameters and provides flexibility in configuring the virtual machine's networking, security, and operating system settings.
