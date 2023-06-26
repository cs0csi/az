$ResourceGroup = "az-dev-001"
$StorageName = 'azdevst001'
$jsonParameterFilePath = "C:\Users\csocsi\Documents\GitHub\az\arm.parameters.json"
$jsonRMFilePath = "C:\Users\csocsi\Documents\GitHub\az\arm.json"

$configurationpath = "./01.ps1"
$ConfigurationName = "MyFirstConfiguration"

$jsonContent = Get-Content -Path $jsonParameterFilePath -Raw

$jsonObject = $jsonContent | ConvertFrom-Json

$vmName = $jsonObject.parameters.vmName.value

$DscConfigurationParameters = @{
    'configurationpath'  = $configurationpath
    'resourcegroupname'  = $ResourceGroup
    'StorageAccountName' = $StorageName
}

$SetDscParameters = @{
    'Version'  = '2.76'
    'resourcegroupname'  = $ResourceGroup
    'VMname' = $vmName
    'ArchiveStorageAccountName' = $Storagename
    'ArchiveBlobName' = '01.ps1.zip'
    'AutoUpdate' = $true
    'ConfigurationName' = $ConfigurationName
}

New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $jsonRMFilePath -TemplateParameterFile $jsonParameterFilePath

Publish-AzVMDscConfiguration  @DscConfigurationParameters -force -Verbose

Set-AzVMDscExtension @SetDscParameters -Verbose