param laLocation string
param autoName string

resource mgmtAutomation 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  location: laLocation
  name: autoName
  properties: {
    sku: {
      name: 'Basic'
    }
    publicNetworkAccess: false
  }
}

output mgmgAutomationId string = mgmtAutomation.id
