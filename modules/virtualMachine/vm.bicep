param vmLocation string
param adminUserName string
@secure()
param adminPassword string
param vnetId string
param nsgName string
param vmName string
param numberOfVms int = 4
param dcrWinId string
param dcrLinuxId string
param dceWinId string
param dceLinuxId string
param logName string


resource NsgForVm 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: nsgName
  location: vmLocation
  properties: {
    securityRules: [
      {
        name: 'Out-Allow-Arm'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          protocol: '*'
          destinationAddressPrefix: 'AzureResourceManager'
          destinationPortRange: '*'
          priority: 150
          sourceAddressPrefix: '192.168.0.0/16'
          sourcePortRange: '*'
        }
      }
      {
        name: 'Out-Deny-Internet'
        properties: {
          access: 'Deny'
          direction: 'Outbound'
          protocol: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '*'
          priority: 200
          sourceAddressPrefix: '192.168.0.0/16'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

resource vmForNic 'Microsoft.Network/networkInterfaces@2021-08-01' = [for i in range(1, numberOfVms): {
  name: 'nic-${vmName}-0${i}'
  location: vmLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.4.10${i}'
          subnet: {
            id: '${vnetId}/subnets/iaasSubnet'
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: NsgForVm.id
    }
  }
}]

resource amaUbVm01 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: '${vmName}-amaub01'
  location: vmLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    osProfile: {
      computerName: 'amaUbVm01'
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    hardwareProfile: {
      vmSize: 'Standard_B1ms'
    }
    storageProfile: {
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmForNic[0].id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

resource mmaUbVm01 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: '${vmName}-mmaub01'
  location: vmLocation
  properties: {
    osProfile: {
      computerName: 'mmaUbVm01'
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    hardwareProfile: {
      vmSize: 'Standard_B1ms'
    }
    storageProfile: {
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmForNic[1].id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

resource mmaWinVm01 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: '${vmName}-mmawin01'
  location: vmLocation
  properties: {
    osProfile: {
      computerName: 'mmaWinVm01'
      adminUsername: adminUserName
      adminPassword: adminPassword
      windowsConfiguration: {
        patchSettings: {
          enableHotpatching: true
          patchMode: 'AutomaticByPlatform'
        }
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition-core-smalldisk'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmForNic[2].id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

resource amaWinVm01 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: '${vmName}-amawin01'
  location: vmLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    osProfile: {
      computerName: 'amaWinVm01'
      adminUsername: adminUserName
      adminPassword: adminPassword
      windowsConfiguration: {
        patchSettings: {
          enableHotpatching: true
          patchMode: 'AutomaticByPlatform'
        }
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition-core-smalldisk'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmForNic[3].id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

resource amalinuxAgent 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: '${amaUbVm01.name}/AzureMonitorLinuxAgent'
  location: vmLocation
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.5'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

resource amaWindowsAgent 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: '${amaWinVm01.name}/AzureMonitorWindowsAgent'
  location: vmLocation
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

// Connect AMA to Log Analytics by Data connection rules and endpoints
resource dceAssociationAmaUbVm01 'Microsoft.Insights/dataCollectionRuleAssociations@2021-04-01' = {
  scope: amaUbVm01
  name: 'configurationAccessEndpoint'
  properties: {
     dataCollectionEndpointId: dceLinuxId
  }
}

resource dcrAssociationAmaUbVm01 'Microsoft.Insights/dataCollectionRuleAssociations@2021-04-01' = {
  scope: amaUbVm01
  name: 'rule'
  properties: {
    dataCollectionRuleId: dcrLinuxId
  }
}

resource dceAssociationAmaWinVm01 'Microsoft.Insights/dataCollectionRuleAssociations@2021-04-01' = {
  scope: amaWinVm01
  name: 'configurationAccessEndpoint'
  properties: {
    dataCollectionEndpointId: dceWinId
  }
}

resource dcrAssociationAmaWinVm01 'Microsoft.Insights/dataCollectionRuleAssociations@2021-04-01' = {
  scope: amaWinVm01
  name: 'rule'
  properties: {
    dataCollectionRuleId: dcrWinId
  }
}

// Get the existing Log analytics for onboarding
resource existinglog 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing= {
  name: logName
  scope: resourceGroup('rg-mgmt-opslab-eval')
}

// Connect MMA to Log analytics by onboarding
resource omsOnboardingMmaUb01 'Microsoft.Compute/virtualMachines/extensions@2017-03-30' = {
  name: '${mmaUbVm01.name}/omsOnboarding'
  location: vmLocation
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.13'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: existinglog.properties.customerId
    }
    protectedSettings: {
      workspaceKey: (listKeys(existinglog.id, '2021-12-01-preview').primarySharedKey)
    }
  }
}

resource omsOnboardingMmaWin01 'Microsoft.Compute/virtualMachines/extensions@2017-03-30' = {
  name: '${mmaWinVm01.name}/omsOnboarding'
  location: vmLocation
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: existinglog.properties.customerId
    }
    protectedSettings: {
      workspaceKey: (listKeys(existinglog.id, '2021-12-01-preview').primarySharedKey)
    }
  }
}
