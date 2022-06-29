param laLocation string
param logName string
param loganalyticsId string

resource updateManagement 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'Updates(${logName})' // This format is needed
  location: laLocation
  properties: {
    workspaceResourceId: loganalyticsId
  }
  plan: {
    name: 'Updates(${logName})' // This format is needed
    promotionCode: ''
    product: 'OMSGallery/Updates'
    publisher: 'Microsoft'
  }
}

resource changeTracking 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'ChangeTracking(${logName})' // This format is needed
  location: laLocation
  properties: {
    workspaceResourceId: loganalyticsId
  }
  plan: {
    name: 'ChangeTracking(${logName})' // This format is needed
    promotionCode: ''
    product: 'OMSGallery/ChangeTracking'
    publisher: 'Microsoft'
  }
}
