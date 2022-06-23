targetScope = 'subscription'

param envLocation string
param adminUsername string
@secure()
param adminPassword string

// Create Resource Groups

resource rgHubVnet 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-hubVnet-opslab'
  location: envLocation
}

resource rgMgmt 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-mgmt-opslab'
  location: envLocation
}

// Create Log Analytics

module mgmtLog 'modules/management/logAnalytics.bicep' = {
  name: 'mgmtLog-opslab'
  scope: rgMgmt
  params: {
    laLocation: envLocation
  }
}

// Create AutomationAccount

module mgmtAuto 'modules/management/automationAccount.bicep' = {
  name: 'mgmtauto-opslab'
  scope: rgMgmt
  params: {
    laLocation: envLocation
  }
}

// Create Vnets

module hubVnet 'modules/hub/hubVnet.bicep' = {
  name: 'hubVnet-opslab'
  scope: rgHubVnet
  params: {
    hubLocation: envLocation
    amplsId: mgmtLog.outputs.mgmtAmplsId
  }
}

// Create Azure Firewall in Hub Vnet

// Create Azure Bastion in Hub Vnet

module hubBastion 'modules/hub/hubBastion.bicep' = {
  name: 'hubBastion'
  scope: rgHubVnet
  params: {
    bastionLocation: envLocation
    hubVnetId: hubVnet.outputs.hubVnetId
    mgmtLoganalyticsId: mgmtLog.outputs.mgmtLoganalyticsId
  }
}

module HubVm 'modules/hub/hubVm.bicep' = {
  name: 'spokeVmMMA'
  scope: rgHubVnet
  params: {
    hubLocation: envLocation
    adminUserName: adminUsername
    adminPassword: adminPassword
    hubVnetId: hubVnet.outputs.hubVnetId
  }
}

