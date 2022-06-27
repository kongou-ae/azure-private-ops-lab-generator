param laLocation string
param autoName string

resource automation 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  location: laLocation
  name: autoName
  properties: {
    sku: {
      name: 'Basic'
    }
    publicNetworkAccess: false
  }
}

output automationId string = automation.id
