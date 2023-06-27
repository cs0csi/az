# Connect to Azure (login using your Azure account)
Connect-AzAccount

# Set variables
$ResourceGroup = "az-dev-10"
$location = "South Central US"
$StorageName = "azdevst10"
$containerName = "webcont"
$blobName = "CoolColorsWebsite.html"
$localFilePath = "C:\Users\csocsi\Documents\GitHub\az\CoolColorsWebsite.html"


# Create a resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create a storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroup -Name $StorageName -Location $location -SkuName "Standard_LRS" -Kind "StorageV2" -AccessTier "Hot"

# Create a storage account context
$storageAccountContext = $storageAccount.Context

# Create a new container in the storage account
New-AzStorageContainer -Name $containerName -Context $storageAccountContext -Permission Blob

# Upload file to the container

Set-AzStorageBlobContent -Container $containerName -Context $storageAccountContext -File $localFilePath -Blob $blobName

Read-Host "Part2"

$configurationpath = "./ccv.ps1"

$DscConfigurationParameters = @{
    'configurationpath'  = $configurationpath
    'resourcegroupname'  = $ResourceGroup
    'StorageAccountName' = $StorageName
}

Publish-AzVMDscConfiguration  @DscConfigurationParameters -force -Verbose

Read-Host "Part 3"


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
