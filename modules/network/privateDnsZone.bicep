param peAmplsCustomDnsConfigs array

param zones array = [
  'monitor.azure.com'
  'oms.opinsights.azure.com'
  'ods.opinsights.azure.com'
  'agentsvc.azure.automation.net'
  'blob.core.windows.net'
]

resource privateDnsZoneForAmpls 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zone in zones: {
  location: 'global'
  name: 'privatelink.${zone}'
  properties: {
  }
}]

resource privateDnsZoneForMonitor 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.${zones[0]}'
}

resource privateDnsZoneForOms 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.${zones[1]}'
}

resource privateDnsZoneForOds 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.${zones[2]}'
}

resource privateDnsZoneForAgentsvc 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.${zones[3]}'
}

resource privateDnsZoneForBlob 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.${zones[4]}'
}

resource pvtEndpointDnsGroupForAmpls 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: 'peampls-opslab-eval'
  name: 'pvtEndpointDnsGroupForAmpls'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {          
          privateDnsZoneId: privateDnsZoneForMonitor.id
        }
      }
      {
        name: 'config2'
        properties: {
          privateDnsZoneId: privateDnsZoneForOms.id
        }
      }
      {
        name: 'config3'
        properties: {
          privateDnsZoneId: privateDnsZoneForOds.id
        }
      }
      {
        name: 'config4'
        properties: {
          privateDnsZoneId: privateDnsZoneForAgentsvc.id
        }
      }
      {
        name: 'config5'
        properties: {
          privateDnsZoneId: privateDnsZoneForBlob.id
        }
      }
    ]
  }
}



/*
{
  name: 'config2'
  properties: {
    privateDnsZoneId: privateDnsZoneForOms.id
  }
}
{
  name: 'config3'
  properties: {
    privateDnsZoneId: privateDnsZoneForOds.id
  }
}
{
  name: 'config4'
  properties: {
    privateDnsZoneId: privateDnsZoneForAgentsvc.id
  }
}
{
  name: 'config5'
  properties: {
    privateDnsZoneId: privateDnsZoneForBlob.id
  }
}
*/
