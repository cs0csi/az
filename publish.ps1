#region
$resourceGroup = 'az-dev-001'

$storageName = 'azdevst001'

$parameters = @{
    'configurationpath'  = './01.ps1'
    'resourcegroupname'  = $resourceGroup
    'StorageAccountName' = $storagename
}


Publish-AzVMDscConfiguration  @parameters -force -Verbose



#########


$xparameters = @{
    'Version'  = '2.76'
    'resourcegroupname'  = $resourceGroup
    'VMname' = 'TESTVM-77'
    'ArchiveStorageAccountName' = $storagename
    'ArchiveBlobName' = '01.ps1.zip'
    'AutoUpdate' = $true
    'ConfigurationName' = 'MyFirstConfiguration'
}

Set-AzVMDscExtension @xparameters -Verbose