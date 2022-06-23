param hubLocation string
param adminUserName string
@secure()
param adminPassword string
param hubVnetId string

resource NsgForVm 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'nsg-hubvm-opslab'
  location: hubLocation
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

resource hubTestVm01Nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: 'nic-hubvm01-opslab'
  location: hubLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.4.100'
          subnet: {
            id: '${hubVnetId}/subnets/iaasSubnet'
          }
        }
      }
    ]
    networkSecurityGroup: {
       id: NsgForVm.id
    }
  }
}

resource hubTestVm02Nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: 'nic-hubvm02-opslab'
  location: hubLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.4.101'
          subnet: {
            id: '${hubVnetId}/subnets/iaasSubnet'
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: NsgForVm.id
   }
  }
}

resource hubTestVM1 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: 'vm01-hub-opslab'
  location: hubLocation
  properties: {
    osProfile: {
      computerName: 'hubTestVM01'
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
          id: hubTestVm01Nic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

resource hubTestVM2 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: 'vm02-hub-opslab'
  location: hubLocation
  properties: {
    osProfile: {
      computerName: 'hubTestVM02'
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
          id: hubTestVm02Nic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}
