param netLocation string
param adminUserName string
@secure()
param adminPassword string
param netVnetId string

resource NsgForVm 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'nsg-opslab-eval'
  location: netLocation
  properties: {
    securityRules: [
      {
        name: 'Out-Deny-Internet'
        properties: {
          access: 'Deny'
          direction: 'Outbound'
          protocol: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '*'
          priority: 100
          sourceAddressPrefix: '192.168.0.0/16'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

resource netTestVm01Nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: 'nic-vm01-opslab-eval'
  location: netLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.4.100'
          subnet: {
            id: '${netVnetId}/subnets/iaasSubnet'
          }
        }
      }
    ]
    networkSecurityGroup: {
       id: NsgForVm.id
    }
  }
}

resource netTestVm02Nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: 'nic-vm02-opslab-eval'
  location: netLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.4.101'
          subnet: {
            id: '${netVnetId}/subnets/iaasSubnet'
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: NsgForVm.id
   }
  }
}

resource netTestVM1 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: 'vm01-opslab-eval'
  location: netLocation
  properties: {
    osProfile: {
      computerName: 'netTestVM01'
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
          id: netTestVm01Nic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

resource netTestVM2 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: 'vm02-opslab-eval'
  location: netLocation
  properties: {
    osProfile: {
      computerName: 'netTestVM02'
      adminUsername: adminUserName
      adminPassword: adminPassword
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
          id: netTestVm02Nic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}
