param bastionLocation string
param netVnetId string
param mgmtLoganalyticsId string
param basName string

resource bastionPip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  location: bastionLocation
  name: 'pip-${basName}'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: basName
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
            id: bastionPip.id
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

resource bastionDiagsetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'netBastionDiagsetting'
  scope: bastion
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
