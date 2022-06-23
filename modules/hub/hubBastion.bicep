param bastionLocation string
param hubVnetId string
param mgmtLoganalyticsId string

resource hubBastionPip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  location: bastionLocation
  name: 'pip-hubbas-eval'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource hubBastion 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: 'bas-hub-eval'
  location: bastionLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    disableCopyPaste: false
    enableFileCopy: true
    enableIpConnect: true
    enableShareableLink: false
    enableTunneling: true
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          publicIPAddress: {
            id: hubBastionPip.id
          }
          subnet: {
            id: '${hubVnetId}/subnets/AzureBastionSubnet'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource hubBastionDiagsetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'hubBastionDiagsetting'
  scope: hubBastion
  properties: {
    workspaceId: mgmtLoganalyticsId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}
