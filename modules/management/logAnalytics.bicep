param laLocation string
param logName string
param amplsName string
param dceName string
param dcrWinName string
param dcrLinuxName string
param autoId string

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

resource logLinkForAutomation 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  name: 'Automation' // this name is required. don't custmize it.
  parent: log
  properties: {
    resourceId: autoId
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

// dataCollectionEndpointId doesn't work. dataCollectionEndpointId in japaneast may not be support by 2021-09-01-preview which supports dataCollectionEndpointId.
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
            'Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4)]]'
            'Security!*[System[(band(Keywords13510798882111488))]]'
            'System!*[System[(Level=1 or Level=2 or Level=3 or Level=4)]]'
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
    //dataCollectionEndpointId: dceWin.id
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
            'Info'
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
            'Info'
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
    //dataCollectionEndpointId: dceLinux.id
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

// Create data souruces for MMA
resource dataSourceWindowsEventSystem 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'WindowsEvent'
  name: 'WindowsEventSystem'
  properties: {
    eventLogName: 'System'
    eventTypes: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
      {
        eventType: 'Information'
      }
    ]
  }
}

resource dataSourceWindowsEventApplication 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'WindowsEvent'
  name: 'WindowsEventApplication'
  properties: {
    eventLogName: 'Application'
    eventTypes: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
      {
        eventType: 'Information'
      }
    ]
  }
}

resource dataSourceLinuxSyslog 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'LinuxSyslogCollection'
  name: 'LinuxSyslogCollection'
  properties: {
    state: 'Enabled'
  }
}

resource dataSourceLinuxSyslogDaemon 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'LinuxSyslog'
  name: 'LinuxSyslogDaemon'
  properties: {
    syslogName: 'daemon'
    syslogSeverities: [
      {
        severity: 'emerg'
      }
      {
        severity: 'alert'
      }
      {
        severity: 'crit'
      }
      {
        severity: 'err'
      }
      {
        severity: 'warning'
      }
      {
        severity: 'notice'
      }
      {
        severity: 'info'
      }
    ]
  }
}

resource dataSourceLinuxSyslogSyslog 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'LinuxSyslog'
  name: 'LinuxSyslogSyslog'
  properties: {
    syslogName: 'syslog'
    syslogSeverities: [
      {
        severity: 'emerg'
      }
      {
        severity: 'alert'
      }
      {
        severity: 'crit'
      }
      {
        severity: 'err'
      }
      {
        severity: 'warning'
      }
      {
        severity: 'notice'
      }
      {
        severity: 'info'
      }
    ]
  }
}

resource dataSourceWindowsPerfMemoryAvailableBytes 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'WindowsPerformanceCounter'
  name: 'WindowsPerfMemoryAvailableBytes'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 10
    counterName: 'Available MBytes'
  }
}

resource dataSourceWindowsPerfMemoryPercentageBytes 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'WindowsPerformanceCounter'
  name: 'WindowsPerfMemoryPercentageBytes'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 10
    counterName: '% Committed Bytes in Use'
  }
}

resource dataSourceWindowsPerfProcessorPercentage 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'WindowsPerformanceCounter'
  name: 'WindowsPerfProcessorPercentage'
  properties: {
    objectName: 'Processor'
    instanceName: '_Total'
    intervalSeconds: 10
    counterName: '% Processor Time'
  }
}

resource dataSourceWindowsPerfDiskFreeSpacePercentage 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'WindowsPerformanceCounter'
  name: 'WindowsPerfDiskFreeSpacePercentage'
  properties: {
    objectName: 'Logical Disk	'
    instanceName: '*'
    intervalSeconds: 10
    counterName: '% Free Space'
  }
}

resource dataSourceWindowsPerfDiskUsedSpacePercentage 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'WindowsPerformanceCounter'
  name: 'WindowsPerfDiskUsedSpacePercentage'
  properties: {
    objectName: 'Logical Disk	'
    instanceName: '*'
    intervalSeconds: 10
    counterName: '% Used Space'
  }
}

resource dataSourceLinuxPerformanceLogicalDisk 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'LinuxPerformanceObject'
  name: 'LinuxPerformanceLogicalDisk'
  properties: {
    objectName: 'Logical Disk'
    instanceName: '*'
    intervalSeconds: 10
    performanceCounters: [
      {
        counterName: 'Free Megabytes'
      }
      {
        counterName: '% Used Space'
      }
    ]
  }
}

resource dataSourceLinuxPerformanceProcessor 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log
  kind: 'LinuxPerformanceObject'
  name: 'LinuxPerformanceProcessor'
  properties: {
    objectName: 'Processor'
    instanceName: '*'
    intervalSeconds: 10
    performanceCounters: [
      {
        counterName: '% Processor Time'
      }
      {
        counterName: '% Privileged Time'
      }
    ]
  }
}

output loganalyticsId string = log.id
output amplsId string = ampls.id
output dcrWinId string = dcrWin.id
output dcrLinuxId string = dcrLinux.id
output dceWinId string = dceWin.id
output dceLinuxId string = dceLinux.id
