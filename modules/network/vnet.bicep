param netLocation string
param amplsId string
param autoId string
param vnetName string
param peAmplsName string
param peAutoName string
param rtName string

param zones array = [
  'monitor.azure.com'
  'oms.opinsights.azure.com'
  'ods.opinsights.azure.com'
  'agentsvc.azure-automation.net'
  'blob.${environment().suffixes.storage}'
]


resource routetable 'Microsoft.Network/routeTables@2021-08-01' = {
  name: rtName
  location: netLocation
  properties: {
    routes: [
      {
        id: '100'
        name: 'defaultRoute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '192.168.2.4'
        }
      }
    ] 
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
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
          routeTable: {
             id: routetable.id
          }
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
      {
        name: 'peArmSubnet'
        properties: {
          addressPrefix: '192.168.7.0/24'
        }
      }
    ]
  }
}

resource peAmpls 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: peAmplsName
  location: netLocation
  properties: {
    subnet: {
      id: '${vnet.id}/subnets/peAmplsSubnet'
    }
    privateLinkServiceConnections: [
      {
        name: 'conn-${peAmplsName}'
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

resource privateDnsZoneForAmpls 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zone in zones: {
  location: 'global'
  name: 'privatelink.${zone}'
  properties: {
  }
}]

// Connect Private Dns Zones to VNet
resource privateDnsZoneForAmplsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (zone, i) in zones: {
  name: 'privateDnsZoneForAmplsVnetLink${i}'
  location: 'global'
  parent: privateDnsZoneForAmpls[i]
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}]

resource peDnsGroupForAmpls 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: peAmpls
  name: 'pvtEndpointDnsGroupForAmpls'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneForAmpls[0].id
        }
      }
      {
        name: 'config2'
        properties: {
          privateDnsZoneId: privateDnsZoneForAmpls[1].id
        }
      }
      {
        name: 'config3'
        properties: {
          privateDnsZoneId: privateDnsZoneForAmpls[2].id
        }
      }
      {
        name: 'config4'
        properties: {
          privateDnsZoneId: privateDnsZoneForAmpls[3].id
        }
      }
      {
        name: 'config5'
        properties: {
          privateDnsZoneId: privateDnsZoneForAmpls[4].id
        }
      }
    ]
  }
}

resource peAuto 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: peAutoName
  location: netLocation
  properties: {
    subnet: {
      id: '${vnet.id}/subnets/peAutoSubnet'
    }
    privateLinkServiceConnections: [
      {
        name: 'conn-${peAutoName}'
        properties: {
          groupIds: [
            'DSCAndHybridWorker'
          ]
          privateLinkServiceId: autoId
        }
      }
    ]
  }
}

resource privateDnsZoneForAuto 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  location: 'global'
  name: 'privatelink.azure-automation.net'
  properties: {
  }
}

resource peDnsGroupForAuto 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: peAuto
  name: 'pvtEndpointDnsGroupForAuto'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneForAuto.id
        }
      }
    ]
  }
}

resource privateDnsZoneForAutoVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privateDnsZoneForAutoVnetLink'
  location: 'global'
  parent: privateDnsZoneForAuto
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

output vnetId string = vnet.id
