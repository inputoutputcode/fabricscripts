param azureregion string = resourceGroup().location
param deploymentId string
param certificateThumbprint string
param sourceVaultValue string
param certificateUrlValue string
param adminUserName string = 'Christian'
@secure() 
param adminPassword string

// resource names
var clusterName = '${deploymentId}-servicefabric'
var virtualNetworkName = 'virtualnetwork'
var networkSecurityRulesName = 'networksecurityrules'
var subnet1Reference = '${virtualNetworkName}/subnets/${subnet1Name}'
var networkInterfaceName = 'networkinterface'
var publicIpAddressName = 'publicipaddress'
var serviceFabricStorageAccountName = '${deploymentId}sfstorage'
var diagnosticsStorageAccountName = '${deploymentId}dgstorage'
var loadBalancerName = 'loadbalancer-${virtualMachineScaleSetName}'
var applicationInsightsName = 'applicatoninsights'
var logAnalyticsName = 'loganalytics'
var resourceTags = {
  resourceType: 'Service Fabric'
  deploymentId: deploymentId
}

// network
var subnet1Name = 'subnet-0'
var subnet1Prefix = '10.0.0.0/24'
var addressPrefix = '10.0.0.0/16'
var inboundNatPoolName = 'inboundNatPool1'
var backendAddressPoolName = 'backendAddressPool1'
var frontendIPConfigurationName = 'frontendIPConfiguration'
var gatewayHealthProbeName = 'gatewayHealthProbe'
var gatewayHttpHealthProbeName = 'gatewayHttpHealthProbe'
var gatewayHttpPublicHealthProbeName = 'gatewayHttpPublicHealthProbe'
var customWebAppPort = 80

// node type
var virtualMachineScaleSetName = 'virtualmachinescaleset1'
var virtualMachineScaleSetReferenceName = 'management'
var nodeType1InstanceCount = 5
var nodeType1Size = 'Standard_D2_v2'
var vmImagePublisher = 'MicrosoftWindowsServer'
var vmImageOffer = 'WindowsServer'
var vmImageSku = '2019-datacenter'
var vmImageVersion = 'latest'
var certificateStoreValue = 'My'
var storageAccountType = 'Standard_LRS'

// cluster
var clusterProtectionLevel = 'EncryptAndSign'
var fabricTcpGatewayPort = 19000
var fabricHttpGatewayPort = 19080

// applications
var packageUrlFabricObserver = 'https://github.com/microsoft/service-fabric-observer/releases/download/51751968/Microsoft.ServiceFabricApps.FabricObserver.Windows.SelfContained.3.1.24.sfpkg'
var applicationTypeVersionFabricObserver = '3.1.24'
var packageUrlClusterObserver = 'https://github.com/microsoft/service-fabric-observer/releases/download/51751968/Microsoft.ServiceFabricApps.ClusterObserver.Windows.SelfContained.2.1.13.sfpkg'
var applicationTypeVersionClusterObserver = '2.1.13'
var applicationTypeNameFabricObserver = 'FabricObserverType'
var applicationNameFabricObserver = 'FabricObserverApplication'
var serviceNameFabricObserver = '${applicationNameFabricObserver}~FabricObserverService'
var serviceTypeNameFabricObserver = 'FabricObserverType'
var applicationTypeNameClusterObserver = 'ClusterObserverType'
var applicationNameClusterObserver = 'ClusterObserverApplication'
var serviceNameClusterObserver = '${applicationNameClusterObserver}~ClusterObserverService'
var serviceTypeNameClusterObserver = 'ClusterObserverType'

// resources
resource serviceFabricStorage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: serviceFabricStorageAccountName
  location: azureregion
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: false
  }
  sku: {
    name: storageAccountType
  }
  tags: resourceTags
}

resource diagnosticStorage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: diagnosticsStorageAccountName
  location: azureregion
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: false
  }
  sku: {
    name: storageAccountType
  }
  tags: resourceTags
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: azureregion
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: subnet1Prefix
          networkSecurityGroup: networkSecurityRules.id == '' ? null : {
            id: networkSecurityRules.id
          }    
        }
      }
    ]
  }
  tags: resourceTags
}

resource networkSecurityRules 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: networkSecurityRulesName
  location: azureregion
  properties: {
    securityRules: [
      {
        name: 'Azure Portal'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: 'ServiceFabric'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationAddressPrefix: '*'
          destinationPortRange: '19080'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 3900
          protocol: 'Tcp'
        }
      }
      {
        name: 'Client API'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationAddressPrefix: '*'
          destinationPortRange: '19000'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 3910
          protocol: 'Tcp'
        }
      }
      {
        name: 'SFX + Client API'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationAddressPrefix: '*'
          destinationPortRange: '19080'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 3920
          protocol: 'Tcp'
        }
      }
      {
        name: 'Cluster'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationAddressPrefix: '*'
          destinationPortRange: '1025-1027'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 3930
          protocol: 'Tcp'
        }
      }
      {
        name: 'Ephemeral'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationAddressPrefix: '*'
          destinationPortRange: '49152-65534'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 3940
          protocol: 'Tcp'
        }
      }
      {
        name: 'Application'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationAddressPrefix: '*'
          destinationPortRange: '2000-3000'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 3950
          protocol: 'Tcp'
        }
      }
      {
        name: 'RDP'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationAddressPrefix: '*'
          destinationPortRange: '3389-3488'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 3960
          protocol: 'Tcp'
        }
      }
      {
        name: 'Custom Endpoint'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
          destinationPortRanges: []
          direction: 'Inbound'
          priority: 3980
          protocol: 'Tcp'
        }
      }
      {
        name: 'Resource Provider'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationAddressPrefix: 'ServiceFabric'
          destinationPortRange: '443'
          destinationPortRanges: []
          direction: 'Outbound'
          priority: 4000
          protocol: 'Tcp'
        }
      }
      {
        name: 'Download Binaries'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationAddressPrefix: 'AzureFrontDoor.FirstParty'
          destinationPortRange: ''
          destinationPortRanges: [
            '443'
          ]
          direction: 'Outbound'
          priority: 4010
          protocol: 'Tcp'
        }
      }
    ]
  }
  tags: resourceTags
}

resource publicIPAddress0 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: '${publicIpAddressName}-0'
  location: azureregion
  sku: {
    name: 'Standard'
  }
  properties: {
    dnsSettings: {
      domainNameLabel: clusterName
    }
    publicIPAllocationMethod: 'Static'
  }
  tags: resourceTags
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2021-05-01' = {
  name: loadBalancerName
  location: azureregion
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendIPConfigurationName
        properties: {
          publicIPAddress: {
            id: publicIPAddress0.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendAddressPoolName
      }
    ]
    loadBalancingRules: [
      {
        name: 'loadBalancerRule'
        properties: {
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendAddressPoolName)
          }
          backendPort: fabricTcpGatewayPort
          enableFloatingIP: false
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', loadBalancerName, frontendIPConfigurationName)
          }
          frontendPort: fabricTcpGatewayPort
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, gatewayHealthProbeName)
          }
          protocol: 'Tcp'
        }
      }
      {
        name: 'loadBalancerHttpRule'
        properties: {
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendAddressPoolName)
          }
          backendPort: fabricHttpGatewayPort
          enableFloatingIP: false
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', loadBalancerName, frontendIPConfigurationName)
          }
          frontendPort: fabricHttpGatewayPort
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, gatewayHttpHealthProbeName)
          }
          protocol: 'Tcp'
        }
      }
      {
        name: 'loadBalancerHttpPublicRule'
        properties: {
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendAddressPoolName)
          }
          backendPort: customWebAppPort
          enableFloatingIP: false
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', loadBalancerName, frontendIPConfigurationName)
          }
          frontendPort: 80
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, gatewayHttpPublicHealthProbeName)
          }
          protocol: 'Tcp'
        }
      }
    ]
    probes: [
      {
        name: gatewayHealthProbeName
        properties: {
          intervalInSeconds: 5
          numberOfProbes: 2
          port: fabricTcpGatewayPort
          protocol: 'Tcp'
        }
      }
      {
        name: gatewayHttpPublicHealthProbeName
        properties: {
          intervalInSeconds: 5
          numberOfProbes: 2
          port: customWebAppPort
          protocol: 'Tcp'
        }
      }
      {
        name: gatewayHttpHealthProbeName
        properties: {
          intervalInSeconds: 5
          numberOfProbes: 2
          port: fabricHttpGatewayPort
          protocol: 'Tcp'
        }
      }
    ]
    inboundNatPools: [
      {
        name: inboundNatPoolName
        properties: {
          backendPort: 3389
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', loadBalancerName, frontendIPConfigurationName)
          }
          frontendPortRangeEnd: 4500
          frontendPortRangeStart: 3389
          protocol: 'Tcp'
        }
      }
    ]
  }
  tags: resourceTags
  dependsOn: [
    virtualNetwork
  ]
}

resource virtualMachineScaleSet 'Microsoft.Compute/virtualMachineScaleSets@2021-11-01' = {
  name: virtualMachineScaleSetName
  location: azureregion
  properties: {
    overprovision: false
    singlePlacementGroup: true
    upgradePolicy: {
      mode: 'Automatic'
    }
    virtualMachineProfile: {
      extensionProfile: {
        extensions: [
          {
            name: '${virtualMachineScaleSetName}_ServiceFabricNode'
            properties: {
              type: 'ServiceFabricNode'
              autoUpgradeMinorVersion: true
              protectedSettings: {
                StorageAccountKey1: diagnosticStorage.listKeys().keys[0].value
                StorageAccountKey2: diagnosticStorage.listKeys().keys[1].value
              }
              publisher: 'Microsoft.Azure.ServiceFabric'
              settings: {
                clusterEndpoint: serviceFabricCluster.properties.clusterEndpoint
                nodeTypeRef: virtualMachineScaleSetReferenceName
                dataPath: 'D:\\\\SvcFab'
                durabilityLevel: 'Silver'
                enableParallelJobs: true
                nicPrefixOverride: subnet1Prefix
                certificate: {
                  thumbprint: certificateThumbprint
                  x509StoreName: certificateStoreValue
                }
              }
              typeHandlerVersion: '1.1'
            }
          }
          /*
          {
            name: 'MicrosoftMonitoringAgent'
            properties: {
              publisher: 'Microsoft.EnterpriseCloud.Monitoring'
              type: 'MicrosoftMonitoringAgent'
              typeHandlerVersion: '1.0'
              autoUpgradeMinorVersion: true
              settings: {
                workspaceId: reference(logAnalytics.id, logAnalytics.apiVersion).customerId
              }
              protectedSettings: {
                workspaceKey: listKeys(logAnalytics.id, logAnalytics.apiVersion).primarySharedKey
              }
            }
          }

          {
            name: 'IaaSDiagnostics'
            properties: {
              type: 'IaaSDiagnostics'
              autoUpgradeMinorVersion: true
              protectedSettings: {
                storageAccountName: diagnosticsStorageAccountName
                storageAccountKey: listKeys(diagnosticStorage.id, diagnosticStorage.apiVersion).keys[0].value
                storageAccountEndPoint: diagnosticStorage.properties.primaryEndpoints.web
              }
              publisher: 'Microsoft.Azure.Diagnostics'
              settings: {
                WadCfg: {
                  DiagnosticMonitorConfiguration: {
                    PerformanceCounters: {
                      PerformanceCounterConfiguration: [
                        {
                          counterSpecifier: '\\Processor(_Total)\\% Processor Time'
                          sampleRate: 'PT10S'
                        }
                        {
                          counterSpecifier: '\\Memory\\Available MBytes'
                          sampleRate: 'PT10S'
                        }
                        {
                          counterSpecifier: '\\LogicalDisk(_Total)\\Disk Read Bytes/sec'
                          sampleRate: 'PT10S'
                        }
                        {
                          counterSpecifier: '\\LogicalDisk(C:)\\Disk Write Bytes/sec'
                          sampleRate: 'PT10S'
                        }
                        {
                          counterSpecifier: '\\LogicalDisk(C:)\\Disk Read Bytes/sec'
                          sampleRate: 'PT10S'
                        }
                        {
                          counterSpecifier: '\\LogicalDisk(D:)\\Disk Write Bytes/sec'
                          sampleRate: 'PT10S'
                        }
                        {
                          counterSpecifier: '\\LogicalDisk(D:)\\Disk Read Bytes/sec'
                          sampleRate: 'PT10S'
                        }
                      ]
                    }
                    WindowsEventLog: {
                      DataSource: [
                        {
                          name: 'System!*[System[(Level=1 or Level=2)]]'
                        }
                      ]
                    }
                    EtwProviders: {
                      EtwEventSourceProviderConfiguration: [
                        {
                          provider: 'Microsoft-ServiceFabric-Actors'
                          scheduledTransferKeywordFilter: '1'
                          scheduledTransferPeriod: 'PT1M'
                          DefaultEvents: {
                            eventDestination: 'ServiceFabricReliableActorEventTable'
                          }
                        }
                        {
                          provider: 'Microsoft-ServiceFabric-Services'
                          scheduledTransferPeriod: 'PT1M'
                          DefaultEvents: {
                            eventDestination: 'ServiceFabricReliableServiceEventTable'
                          }
                        }
                        {
                          provider: 'Contoso-CustomProvider'
                          scheduledTransferPeriod: 'PT1M'
                          DefaultEvents: {
                            eventDestination: 'ETWEventTable'
                          }
                        }
                      ]
                      EtwManifestProviderConfiguration: [
                        {
                          provider: 'cbd93bc2-71e5-4566-b3a7-595d8eeca6e8'
                          scheduledTransferLogLevelFilter: 'Information'
                          scheduledTransferKeywordFilter: '4611686018427387936'
                          scheduledTransferPeriod: 'PT1M'
                          DefaultEvents: {
                            eventDestination: 'ServiceFabricSystemEventTable'
                          }
                        }
                      ]
                    }
                    overallQuotaInMB: '50000'
                    sinks: 'applicationInsights'
                  }
                  SinksConfig: {
                    Sink: [
                      {
                        name: 'applicationInsights'
                        ApplicationInsights: reference(applicationInsights.id, applicationInsights.apiVersion).InstrumentationKey
                      }
                    ]
                  }
                }
                StorageAccount: diagnosticsStorageAccountName
              }
              typeHandlerVersion: '1.5'
            }
          }
          */
        ]
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${networkInterfaceName}-1'
            properties: {
              ipConfigurations: [
                {
                  name: '${networkInterfaceName}-1'
                  properties: {
                    loadBalancerBackendAddressPools: [
                      {
                        id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendAddressPoolName)
                      }
                    ]
                    loadBalancerInboundNatPools: [
                      {
                        id: resourceId('Microsoft.Network/loadBalancers/inboundNatPools', loadBalancerName, inboundNatPoolName)
                      }
                    ]
                    subnet: {
                      id: subnet1Reference
                    }
                  }
                }
              ]
              primary: true
            }
          }
        ]
      }
      osProfile: {
        adminUsername: adminUserName
        adminPassword: adminPassword
        computerNamePrefix: virtualMachineScaleSetName
        secrets: [
          {
            sourceVault: {
              id: sourceVaultValue
            }
            vaultCertificates: [
              {
                certificateStore: certificateStoreValue
                certificateUrl: certificateUrlValue
              }
            ]
          }
        ]
      }
      storageProfile: {
        imageReference: {
          publisher: vmImagePublisher
          offer: vmImageOffer
          sku: vmImageSku
          version: vmImageVersion
        }
        osDisk: {
          caching: 'ReadOnly'
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: storageAccountType
          }
        }
      }
    }
  }
  sku: {
    name: nodeType1Size
    capacity: nodeType1InstanceCount
    tier: 'Standard'
  }
  tags: resourceTags
  dependsOn: [
    virtualNetwork
    loadBalancer
  ]
}

resource serviceFabricCluster 'Microsoft.ServiceFabric/clusters@2021-06-01' = {
  name: clusterName
  location: azureregion
  properties: {
    addOnFeatures: [
      'RepairManager'
    ]
    certificate: {
      thumbprint: certificateThumbprint
      x509StoreName: certificateStoreValue
    }
    clientCertificateCommonNames: []
    clientCertificateThumbprints: []
    diagnosticsStorageAccountConfig: {
      blobEndpoint: serviceFabricStorage.properties.primaryEndpoints.blob
      protectedAccountKeyName: 'StorageAccountKey1'
      queueEndpoint: serviceFabricStorage.properties.primaryEndpoints.queue
      storageAccountName: serviceFabricStorageAccountName
      tableEndpoint: serviceFabricStorage.properties.primaryEndpoints.table
    }
    fabricSettings: [
      {
        parameters: [
          {
            name: 'ClusterProtectionLevel'
            value: clusterProtectionLevel
          }
        ]
        name: 'Security'
      }
    ]
    managementEndpoint: 'https://${publicIPAddress0.properties.dnsSettings.fqdn}:${fabricHttpGatewayPort}'
    nodeTypes: [
      {
        name: virtualMachineScaleSetReferenceName
        applicationPorts: {
          startPort: 20000
          endPort: 30000
        }
        clientConnectionEndpointPort: fabricTcpGatewayPort
        durabilityLevel: 'Silver'
        ephemeralPorts: {
          startPort: 49152
          endPort: 65534
        }
        httpGatewayEndpointPort: fabricHttpGatewayPort
        isPrimary: true
        vmInstanceCount: nodeType1InstanceCount
      }
    ]
    reliabilityLevel: 'Silver'
    upgradeDescription: {
      forceRestart: false
      upgradeReplicaSetCheckTimeout: '00:05:00'
      healthCheckWaitDuration: '00:05:00'
      healthCheckStableDuration: '00:05:00'
      healthCheckRetryTimeout: '00:45:00'
      upgradeTimeout: '12:00:00'
      upgradeDomainTimeout: '02:00:00'
      healthPolicy: {
        maxPercentUnhealthyNodes: 100
        maxPercentUnhealthyApplications: 100
      }
      deltaHealthPolicy: {
        maxPercentDeltaUnhealthyNodes: 0
        maxPercentUpgradeDomainDeltaUnhealthyNodes: 0
        maxPercentDeltaUnhealthyApplications: 0
        applicationDeltaHealthPolicies: {
          'fabric:/System': {
            defaultServiceTypeDeltaHealthPolicy: {
              maxPercentDeltaUnhealthyServices: 0
            }
          }
        }
      }
    }
    upgradeMode: 'Manual'
    vmImage: 'Windows'
  }
  tags: resourceTags

  resource cluster_applicationTypeNameFabricObserver 'applicationTypes@2021-06-01' = {
    name: applicationTypeNameFabricObserver
    location: azureregion

    resource cluster_applicationTypeVersionFabricObserver 'versions@2021-06-01' = {
      name: applicationTypeVersionFabricObserver
      location: azureregion
      properties: {
        appPackageUrl: packageUrlFabricObserver
      }
    }
  }

  resource cluster_applicationNameFabricObserver 'applications@2021-06-01' = {
    name: applicationNameFabricObserver
    location: azureregion
    properties: {
      typeName: applicationTypeNameFabricObserver
      typeVersion: applicationTypeVersionFabricObserver
      parameters: {
        FabricSystemObserverEnabled: 'true'
      }
      upgradePolicy: {
        upgradeReplicaSetCheckTimeout: '01:00:00.0'
        forceRestart: false
        rollingUpgradeMonitoringPolicy: {
          healthCheckWaitDuration: '00:02:00.0'
          healthCheckStableDuration: '00:05:00.0'
          healthCheckRetryTimeout: '00:10:00.0'
          upgradeTimeout: '01:00:00.0'
          upgradeDomainTimeout: '00:20:00.0'
        }
        applicationHealthPolicy: {
          considerWarningAsError: false
          maxPercentUnhealthyDeployedApplications: 50
          defaultServiceTypeHealthPolicy: {
            maxPercentUnhealthyServices: 50
            maxPercentUnhealthyPartitionsPerService: 50
            maxPercentUnhealthyReplicasPerPartition: 50
          }
        }
      }
    }

    resource cluster_serviceNameFabricObserver 'services@2021-06-01' = {
      name: serviceNameFabricObserver
      location: azureregion
      properties: {
        serviceKind: 'Stateless'
        serviceTypeName: serviceTypeNameFabricObserver
        instanceCount: -1
        partitionDescription: {
          partitionScheme: 'Singleton'
        }
      }
    }
  }

  resource cluster_applicationTypeNameClusterObserver 'applicationTypes@2021-06-01' = {
    name: applicationTypeNameClusterObserver
    location: azureregion

    resource cluster_applicationTypeVersionClusterObserver 'versions@2021-06-01' = {
      name: applicationTypeVersionClusterObserver
      location: azureregion
      properties: {
        appPackageUrl: packageUrlClusterObserver
      }
    }
  }
  
  resource cluster_applicationNameClusterObserver 'applications@2021-06-01' = {
    name: applicationNameClusterObserver
    location: azureregion
    properties: {
      typeName: applicationTypeNameClusterObserver
      typeVersion: applicationTypeVersionClusterObserver
      parameters: {}
      upgradePolicy: {
        upgradeReplicaSetCheckTimeout: '01:00:00.0'
        forceRestart: false
        rollingUpgradeMonitoringPolicy: {
          healthCheckWaitDuration: '00:02:00.0'
          healthCheckStableDuration: '00:05:00.0'
          healthCheckRetryTimeout: '00:10:00.0'
          upgradeTimeout: '01:00:00.0'
          upgradeDomainTimeout: '00:20:00.0'
        }
        applicationHealthPolicy: {
          considerWarningAsError: false
          maxPercentUnhealthyDeployedApplications: 50
          defaultServiceTypeHealthPolicy: {
            maxPercentUnhealthyServices: 50
            maxPercentUnhealthyPartitionsPerService: 50
            maxPercentUnhealthyReplicasPerPartition: 50
          }
        }
      }
    }

    resource cluster_serviceNameClusterObserver 'services@2021-06-01' = {
      name: serviceNameClusterObserver
      location: azureregion
      properties: {
        serviceKind: 'Stateless'
        serviceTypeName: serviceTypeNameClusterObserver
        instanceCount: 1
        partitionDescription: {
          partitionScheme: 'Singleton'
        }
      }
    }
  }  
}

/*
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  location: azureregion
  name: logAnalyticsName
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
  tags: resourceTags
}

resource logAnalyticsStorageAccountConfig 'Microsoft.OperationalInsights/workspaces/storageinsightconfigs@2020-08-01' = {
  name: '${logAnalyticsName}/${diagnosticsStorageAccountName}${logAnalyticsName}'
  properties: {
    containers: []
    tables: [
      'WADServiceFabric*EventTable'
      'WADWindowsEventLogsTable'
      'WADETWEventTable'
    ]
    storageAccount: {
      id: diagnosticStorage.id
      key: listKeys(diagnosticStorage.id, diagnosticStorage.apiVersion).keys[0].value
    }
  }
}

resource logAnalyticsSystemConfig 'Microsoft.OperationalInsights/workspaces/datasources@2020-08-01' = {
  name: '${logAnalyticsName}/System'
  kind: 'WindowsEvent'
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

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: azureregion
  kind: 'web'
  properties:{
    Application_Type: 'web'
    RetentionInDays: 30
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Disabled'
    SamplingPercentage: 0
    WorkspaceResourceId: logAnalytics.id
  }
  tags: resourceTags
}
*/

output clusterProperties object = serviceFabricCluster.properties
