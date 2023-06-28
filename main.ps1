# Connect to Azure (login using your Azure account)
Write-Host "Connecting to Azure..."
Connect-AzAccount

# Set variables
$ResourceGroup = "az-dev-10000"
$Location = "westeurope"
$StorageName = "azdevst10000"
$ContainerName = "webcont"
$BlobName = "CoolColorsWebsite.html"
$LocalFilePath = "C:\Users\csocsi\Documents\GitHub\az\CoolColorsWebsite.html"

# Create a resource group
Write-Host "Creating resource group..."
New-AzResourceGroup -Name $ResourceGroup -Location $Location

# Create a storage account
Write-Host "Creating storage account..."
$StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $StorageName -Location $Location -SkuName "Standard_LRS" -Kind "StorageV2" -AccessTier "Hot"

# Create a storage account context
$StorageAccountContext = $StorageAccount.Context

# Create a new container in the storage account
Write-Host "Creating storage container..."
New-AzStorageContainer -Name $ContainerName -Context $StorageAccountContext -Permission Blob

# Upload file to the container
Write-Host "Uploading file to storage container..."
Set-AzStorageBlobContent -Container $ContainerName -Context $StorageAccountContext -File $LocalFilePath -Blob $BlobName

Read-Host "Part 2"

$ConfigurationPath = "./ccv.ps1"

$DscConfigurationParameters = @{
    'configurationpath'  = $ConfigurationPath
    'resourcegroupname'  = $ResourceGroup
    'StorageAccountName' = $StorageName
}

Write-Host "Publishing Azure VM DSC configuration..."
Publish-AzVMDscConfiguration @DscConfigurationParameters -Force

Read-Host "Part 3"

$jsonParameterFilePath = "C:\Users\csocsi\Documents\GitHub\az\arm.parameters.json"
$jsonRMFilePath = "C:\Users\csocsi\Documents\GitHub\az\arm.json"

$ConfigurationName = "CCW"

$jsonContent = Get-Content -Path $jsonParameterFilePath -Raw

$jsonObject = $jsonContent | ConvertFrom-Json

$VmName = $jsonObject.parameters.vmName.value

$SetDscParameters = @{
    'Version'  = '2.76'
    'resourcegroupname'  = $ResourceGroup
    'VMname' = $VmName
    'ArchiveStorageAccountName' = $StorageName
    'ArchiveBlobName' = 'ccv.ps1.zip'
    'AutoUpdate' = $true
    'ConfigurationName' = $ConfigurationName
}

Write-Host "Deploying Azure Resource Manager template..."
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $jsonRMFilePath -TemplateParameterFile $jsonParameterFilePath

Read-Host "Part 4"

Write-Host "Setting VM DSC extension..."
Set-AzVMDscExtension @SetDscParameters
