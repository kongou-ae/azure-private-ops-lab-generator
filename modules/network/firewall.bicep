param fwLocation string
param fwName string
param vnetId string
param loganalyticsId string

resource hubPipFirewall 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: 'pip-${fwName}'
  location: fwLocation
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource hubFirewallPolicy 'Microsoft.Network/firewallPolicies@2021-08-01' = {
  name: 'afwp-${fwName}'
  location: fwLocation
  properties: {
    sku: {
      tier: 'Standard'
    }
  }
}

/*
resource hubFirewallNetworkPolicyCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-08-01' = {
  parent: hubFirewallPolicy
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: []
  }
}
*/

resource hubFirewallApplicationPolicyCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-08-01' = {
  parent: hubFirewallPolicy
  /*
  dependsOn: [
    hubFirewallNetworkPolicyCollectionGroup
  ]
  */
  name: 'DefaultApplicationRuleCollectionGroup'
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'Permit-Outbound-Web-by-FQDNtag'
        priority: 310
        rules: [
          {
            ruleType: 'ApplicationRule'
            sourceAddresses: [
              '192.168.0.0/16'
            ]
            name: 'WindowsUpdate'
            protocols: [
              {
                port: 80
                protocolType: 'Http'
              }
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            fqdnTags:[
              'WindowsUpdate'
            ]
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'Permit-Outbound-Web-by-FQDN'
        priority: 320
        rules: [
          {
            ruleType: 'ApplicationRule'
            sourceAddresses: [
              '192.168.0.0/16'
            ]
            name: 'SpecificFqdn'
            protocols: [
              {
                port: 80
                protocolType: 'Http'
              }
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            targetFqdns:[
              replace(replace(environment().resourceManager,'https://',''),'/','')
              'azure.archive.ubuntu.com'
            ]
          }
        ]
      }
    ]
  }
}

resource hubFirewall 'Microsoft.Network/azureFirewalls@2021-08-01' = {
  name: fwName
  location: fwLocation
  dependsOn: [
    hubFirewallApplicationPolicyCollectionGroup
    //hubFirewallNetworkPolicyCollectionGroup
  ]
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          publicIPAddress: {
            id: hubPipFirewall.id
          }
          subnet: {
            id: '${vnetId}/subnets/AzureFirewallSubnet'
          }
        }
      }
    ]
    firewallPolicy: {
      id: hubFirewallPolicy.id
    }
  }
}

resource hubFirewallDiagsetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'hubFirewallDiagsetting'
  scope: hubFirewall
  properties: {
    workspaceId: loganalyticsId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}
