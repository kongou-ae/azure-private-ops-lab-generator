param hubLocation string
param amplsId string

resource hubVnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: 'vnet-hub-opslab'
  location: hubLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '192.168.2.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '192.168.3.0/24'
        }
      }
      {
        name: 'IaasSubnet'
        properties: {
          addressPrefix: '192.168.4.0/24'
        }
      }
      {
        name: 'peAmplsSubnet'
        properties: {
          addressPrefix: '192.168.5.0/24'
        }
      }
      {
        name: 'peAutoSubnet'
        properties: {
          addressPrefix: '192.168.6.0/24'
        }
      }
    ]
  }
}

resource peAmpls 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: 'peampls-hub-opslab'
  location: hubLocation
  properties: {
    subnet: {
      id: '${hubVnet.id}/subnets/peAmplsSubnet'
    }
    privateLinkServiceConnections: [
      {
        name:'peampls-hub-opslab'
        properties: {
          groupIds: [
            'azuremonitor'
          ]
          privateLinkServiceId: amplsId
        }
      }
    ]
  }
}

output hubVnetId string = hubVnet.id
