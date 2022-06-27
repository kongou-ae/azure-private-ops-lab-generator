# Deploying resources
New-AzSubscriptionDeployment -Name (Get-date -format yyMMdd) -Location "japaneast" -TemplateFile .\main.bicep -TemplateParameterFile "param.json"

# Deleting resources
Remove-AzResourceGroup -Name rg-net-opslab -Force 
Remove-AzResourceGroup -Name rg-mgmt-opslab -Force -AsJob
Remove-AzResourceGroup -Name rg-vm-opslab -Force -AsJob