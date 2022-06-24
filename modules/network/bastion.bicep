param bastionLocation string
param netVnetId string
param mgmtLoganalyticsId string

resource netBastionPip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  location: bastionLocation
  name: 'pip-bas-opslab-eval'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource netBastion 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: 'bas-opslab-eval'
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
            id: netBastionPip.id
          }
          subnet: {
            id: '${netVnetId}/subnets/AzureBastionSubnet'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource netBastionDiagsetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'netBastionDiagsetting'
  scope: netBastion
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
