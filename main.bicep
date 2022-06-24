targetScope = 'subscription'

param envLocation string
param adminUsername string
@secure()
param adminPassword string

// Create Resource Groups

resource rgnetVnet 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-netVnet-opslab'
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

// Create Vnets and private Endpoint

module netVnet 'modules/network/vnet.bicep' = {
  name: 'netVnet-opslab'
  scope: rgnetVnet
  params: {
    netLocation: envLocation
    amplsId: mgmtLog.outputs.mgmtAmplsId
  }
}


module privateDnsZone 'modules/network/privateDnsZone.bicep' = {
  name: 'privateDnsZone-opslab'
  scope: rgnetVnet
  params: {
    peAmplsCustomDnsConfigs: netVnet.outputs.peAmplsCustomDnsConfigs
  }
}



/*
module netBastion 'modules/network/bastion.bicep' = {
  name: 'netBastion'
  scope: rgnetVnet
  params: {
    bastionLocation: envLocation
    netVnetId: netVnet.outputs.netVnetId
    mgmtLoganalyticsId: mgmtLog.outputs.mgmtLoganalyticsId
  }
}

module netVm 'modules/network/vm.bicep' = {
  name: 'netVmMMA'
  scope: rgnetVnet
  params: {
    netLocation: envLocation
    adminUserName: adminUsername
    adminPassword: adminPassword
    netVnetId: netVnet.outputs.netVnetId
  }
}
*/
