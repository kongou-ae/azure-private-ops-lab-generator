param laLocation string
param logName string
param amplsName string
param dceName string
param dcrWinName string
param dcrLinuxName string

resource log 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  location: laLocation
  name: logName
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource ampls 'Microsoft.Insights/privateLinkScopes@2021-07-01-preview' = {
  location: 'global'
  name: amplsName
  properties: {
    accessModeSettings: {
      ingestionAccessMode: 'PrivateOnly'
      queryAccessMode: 'Open'
    }
  }
}

resource dceWin 'Microsoft.Insights/dataCollectionEndpoints@2021-04-01' = {
  location: laLocation
  name: '${dceName}-win'
  kind: 'Windows'
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Disabled'
    }
  }
}

resource dceLinux 'Microsoft.Insights/dataCollectionEndpoints@2021-04-01' = {
  location: laLocation
  name: '${dceName}-linux'
  kind: 'Linux'
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Disabled'
    }
  }
}

// not work. dataCollectionEndpointId in japaneast may not be support by 2021-09-01-preview which supports dataCollectionEndpointId.
resource dcrWin 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  location: laLocation
  name: dcrWinName
  kind: 'Windows'
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'Microsoft-Perf'
          streams: [
            'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: 30
          counterSpecifiers: [
            '\\Processor Information(_Total)\\% Processor Time'
            '\\Processor Information(_Total)\\% Privileged Time'
            '\\Processor Information(_Total)\\% User Time'
            '\\Processor Information(_Total)\\Processor Frequency'
            '\\System\\Processes'
            '\\Process(_Total)\\Thread Count'
            '\\Process(_Total)\\Handle Count'
            '\\System\\System Up Time'
            '\\System\\Context Switches/sec'
            '\\System\\Processor Queue Length'
            '\\Memory\\% Committed Bytes In Use'
            '\\Memory\\Available Bytes'
            '\\Memory\\Committed Bytes'
            '\\Memory\\Cache Bytes'
            '\\Memory\\Pool Paged Bytes'
            '\\Memory\\Pool Nonpaged Bytes'
            '\\Memory\\Pages/sec'
            '\\Memory\\Page Faults/sec'
            '\\Process(_Total)\\Working Set'
            '\\Process(_Total)\\Working Set - Private'
            '\\LogicalDisk(_Total)\\% Disk Time'
            '\\LogicalDisk(_Total)\\% Disk Read Time'
            '\\LogicalDisk(_Total)\\% Disk Write Time'
            '\\LogicalDisk(_Total)\\% Idle Time'
            '\\LogicalDisk(_Total)\\Disk Bytes/sec'
            '\\LogicalDisk(_Total)\\Disk Read Bytes/sec'
            '\\LogicalDisk(_Total)\\Disk Write Bytes/sec'
            '\\LogicalDisk(_Total)\\Disk Transfers/sec'
            '\\LogicalDisk(_Total)\\Disk Reads/sec'
            '\\LogicalDisk(_Total)\\Disk Writes/sec'
            '\\LogicalDisk(_Total)\\Avg. Disk sec/Transfer'
            '\\LogicalDisk(_Total)\\Avg. Disk sec/Read'
            '\\LogicalDisk(_Total)\\Avg. Disk sec/Write'
            '\\LogicalDisk(_Total)\\Avg. Disk Queue Length'
            '\\LogicalDisk(_Total)\\Avg. Disk Read Queue Length'
            '\\LogicalDisk(_Total)\\Avg. Disk Write Queue Length'
            '\\LogicalDisk(_Total)\\% Free Space'
            '\\LogicalDisk(_Total)\\Free Megabytes'
            '\\Network Interface(*)\\Bytes Total/sec'
            '\\Network Interface(*)\\Bytes Sent/sec'
            '\\Network Interface(*)\\Bytes Received/sec'
            '\\Network Interface(*)\\Packets/sec'
            '\\Network Interface(*)\\Packets Sent/sec'
            '\\Network Interface(*)\\Packets Received/sec'
            '\\Network Interface(*)\\Packets Outbound Errors'
            '\\Network Interface(*)\\Packets Received Errors'
          ]
        }

      ]
      windowsEventLogs: [
        {
          name: 'Microsoft-Event'
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'Application!*[System[(Level=1 or Level=2 or Level=3)]]'
            'Security!*[System[(band(Keywords13510798882111488))]]'
            'System!*[System[(Level=1 or Level=2 or Level=3)]]'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: log.id
          name: 'log-pops-eval'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Perf'
        ]
        destinations: [
          'log-pops-eval'
        ]
      }
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          'log-pops-eval'
        ]
      }
    ]
    dataCollectionEndpointId: dceWin.id
  }
}

resource dcrLinux 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  location: laLocation
  name: dcrLinuxName
  kind: 'Linux'
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'Microsoft-Perf'
          streams: [
            'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: 30
          counterSpecifiers: [
            'Logical Disk(*)\\Free Megabytes'
            'Logical Disk(*)\\% Free Space'
            'Processor(*)\\% Processor Time'
            'Memory(*)\\Available MBytes Memory'
            'Memory(*)\\% Available Memory'
            'Memory(*)\\Used Memory MBytes'
            'Memory(*)\\% Used Memory'
          ]
        }
      ]
      syslog: [
        {
          streams: [
            'Microsoft-Syslog'
          ]
          name: 'Microsoft-Syslog-syslog'
          facilityNames: [
            'syslog'
          ]
          logLevels: [
            'Alert'
          ]
        }
        {
          streams: [
            'Microsoft-Syslog'
          ]
          name: 'Microsoft-Syslog-daemon'
          facilityNames: [
            'daemon'
          ]
          logLevels: [
            'Alert'
          ]
        }

      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: log.id
          name: 'log-pops-eval'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Perf'
        ]
        destinations: [
          'log-pops-eval'
        ]
      }
      {
        streams: [
          'Microsoft-Syslog'
        ]
        destinations: [
          'log-pops-eval'
        ]
      }
    ]
    dataCollectionEndpointId: dceLinux.id
  }
}

resource AmplsScopeToLa 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  parent: ampls
  name: 'amplslink_${logName}'
  properties: {
    linkedResourceId: log.id
  }
}

resource AmplsScopeToDceWin 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  parent: ampls
  name: 'amplslink_${dceName}-win'
  properties: {
    linkedResourceId: dceWin.id
  }
}

resource AmplsScopeToDceLinux 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  parent: ampls
  name: 'amplslink_${dceName}-linux'
  properties: {
    linkedResourceId: dceLinux.id
  }
}


output loganalyticsId string = log.id
output amplsId string = ampls.id
output dcrWinId string = dcrWin.id
output dcrLinuxId string = dcrLinux.id
output dceWinId string = dceWin.id
output dceLinuxId string = dceLinux.id
output logWorkspaceId string = log.properties.customerId
output logKey string = listKeys(log.id, '2021-12-01-preview').primarySharedKey
