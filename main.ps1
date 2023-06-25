New-AzResourceGroupDeployment -ResourceGroupName "az-dev-001" -TemplateFile "C:\Users\csocsi\Documents\GitHub\az\arm.json" -TemplateParameterFile "C:\Users\csocsi\Documents\GitHub\az\arm.parameters.json"



# Import-AzAutomationDscConfiguration -Published -ResourceGroupName az-dev-001 -SourcePath ./MyFirstConfiguration.ps1 -Force -AutomationAccountName aazaadev01