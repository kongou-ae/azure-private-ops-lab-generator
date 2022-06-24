param laLocation string

resource mgmtLa 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  location: laLocation
  name: 'log-opslab-eval'
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Enabled'
  }

}

resource mgmtAmpls 'Microsoft.Insights/privateLinkScopes@2021-07-01-preview' = {
  location: 'global'
  name: 'ampls-opslab-eval'
  properties: {
    accessModeSettings: {
      ingestionAccessMode: 'PrivateOnly'
      queryAccessMode: 'Open'
    }
  }
}



resource mgmtDce 'Microsoft.Insights/dataCollectionEndpoints@2021-04-01' = {
  location: laLocation
  name: 'dce-opslab-eval'
  kind: 'Windows'
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Disabled'
    }
  }
}

resource mgmtDcr 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  location: laLocation
  name: 'dcr-opslab-eval'
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
          workspaceResourceId: mgmtLa.id
          name: 'log-mgmt-opslab'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Perf'
        ]
        destinations: [
          'log-mgmt-opslab'
        ]
      }
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          'log-mgmt-opslab'
        ]
      }
    ]
    dataCollectionEndpointId: mgmtDce.id
  }
}

resource mgmtAmplsScopeToLa 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  parent: mgmtAmpls
  name: 'amplscopetola-opslab-eval'
  properties: {
    linkedResourceId: mgmtLa.id
  }
}

resource mgmtAmplsScopeToDce 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  parent: mgmtAmpls
  name: 'amplsscopetodcs-opslab-eval'
  properties: {
    linkedResourceId: mgmtDce.id
  }
}


output mgmtLoganalyticsId string = mgmtLa.id
output mgmtAmplsId string = mgmtAmpls.id
