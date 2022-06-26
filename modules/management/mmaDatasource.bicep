param logName string

resource log2 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
   name: logName
}

resource dataSourceWindowsEventSystem 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log2
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
  parent: log2
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
  parent: log2
  kind: 'LinuxSyslogCollection'
  name: 'LinuxSyslogCollection'
  properties: {
    state: 'Enabled'
  }
}

resource dataSourceLinuxSyslogKernel 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log2
  kind: 'LinuxSyslog'
  name: 'LinuxSyslogKernel'
  properties: {
    syslogName: 'kern'
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
  parent: log2
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
    ]
  }
}

resource dataSourceWindowsPerfMemoryAvailableBytes 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: log2
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
  parent: log2
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
  parent: log2
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
  parent: log2
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
  parent: log2
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
  parent: log2
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
  parent: log2
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


