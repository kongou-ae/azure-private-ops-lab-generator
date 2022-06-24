param netLocation string
param amplsId string

resource netVnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: 'vnet-opslab-eval'
  location: netLocation
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
  name: 'peampls-opslab-eval'
  location: netLocation
  properties: {
    subnet: {
      id: '${netVnet.id}/subnets/peAmplsSubnet'
    }
    privateLinkServiceConnections: [
      {
        name:'peampls-net-opslab'
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

output netVnetId string = netVnet.id
output peAmplsCustomDnsConfigs array = peAmpls.properties.customDnsConfigs
