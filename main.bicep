targetScope = 'subscription'

param envLocation string
param adminUsername string
@secure()
param adminPassword string

var suffix = '-pops-eval'
var vnetName = 'vnet${suffix}'
var logName = 'log${suffix}'
var autoName = 'auto${suffix}'
var amplsName = 'ampls${suffix}'
var dceName = 'dce${suffix}'
var dcrWinName = 'dcrWin${suffix}'
var dcrLinuxName = 'dcrLinux${suffix}'
var peAmplsName = 'peAmpls${suffix}'
var peAutoName = 'peAuto${suffix}'
var basName = 'bas${suffix}'
var nsgName = 'nsg${suffix}'
var vmName = 'vm${suffix}'

// Create Resource Groups
resource rgNet 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-net-opslab-eval'
  location: envLocation
}

resource rgMgmt 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-mgmt-opslab-eval'
  location: envLocation
}

resource rgVm 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-vm-opslab-eval'
  location: envLocation
}


// Create AutomationAccount
module autoMgmt 'modules/management/automationAccount.bicep' = {
  name: 'DeployAutomationAccount'
  scope: rgMgmt
  params: {
    autoName: autoName
    laLocation: envLocation
  }
}

// Create Log Analytics and the resources for a closed infrastructure
module logMgmt 'modules/management/logAnalytics.bicep' = {
  name: 'DeployLogAnalytics'
  scope: rgMgmt
  params: {
    logName: logName
    amplsName: amplsName
    dceName: dceName
    dcrWinName: dcrWinName
    dcrLinuxName: dcrLinuxName
    laLocation: envLocation
    autoId: autoMgmt.outputs.automationId
  }
}


// Create Vnets and private Endpoint
module vnet 'modules/network/vnet.bicep' = {
  name: 'DeployVNetAndPrivateEndpoint'
  scope: rgNet
  params: {
    netLocation: envLocation
    vnetName: vnetName
    peAmplsName: peAmplsName
    amplsId: logMgmt.outputs.amplsId
    peAutoName: peAutoName
    autoId: autoMgmt.outputs.automationId
  }
}

// Create Bastion
module bastion 'modules/network/bastion.bicep' = {
  name: 'DeployBastion'
  scope: rgNet
  params: {
    bastionLocation: envLocation
    basName: basName
    netVnetId: vnet.outputs.vnetId
    mgmtLoganalyticsId: logMgmt.outputs.loganalyticsId
  }
}

// Create four VMs and install each agents
module vm 'modules/virtualMachine/vm.bicep' = {
  name: 'DeployAmaVmAndMmaVm'
  scope: rgVm
  params: {
    vmLocation: envLocation
    nsgName: nsgName
    vmName: vmName
    adminUserName: adminUsername
    adminPassword: adminPassword
    vnetId: vnet.outputs.vnetId
    dceWinId: logMgmt.outputs.dceWinId
    dceLinuxId: logMgmt.outputs.dceLinuxId
    dcrWinId: logMgmt.outputs.dcrWinId
    dcrLinuxId: logMgmt.outputs.dcrLinuxId
    logName: logName
  }
}

// Enable Update Management
module updateManagementMgmt 'modules/management/updateManagement.bicep' = {
  name: 'EnableUpdateManagement'
  scope: rgMgmt
  params: {
    logName: logName
    laLocation: envLocation
    loganalyticsId: logMgmt.outputs.loganalyticsId
  }
  dependsOn: [
    logMgmt
    autoMgmt
  ]
}
