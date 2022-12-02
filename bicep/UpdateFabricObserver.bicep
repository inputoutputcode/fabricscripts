param azureregion string = resourceGroup().location
param deploymentId string
var clusterName = '${deploymentId}-servicefabric'

var packageUrlFabricObserver = 'https://github.com/microsoft/service-fabric-observer/releases/download/53065403/Microsoft.ServiceFabricApps.FabricObserver.Windows.SelfContained.3.1.25.sfpkg'
var applicationTypeVersionFabricObserverName = '3.1.25'
var applicationTypeNameFabricObserverName = 'FabricObserverType'
var applicationNameFabricObserverName = 'FabricObserverApplication'
var serviceNameFabricObserverName = '${applicationNameFabricObserverName}~FabricObserverService'
var serviceTypeNameFabricObserver = 'FabricObserverType'

resource applicationTypeNameFabricObserver 'Microsoft.ServiceFabric/clusters/applicationTypes@2021-06-01' = {
  name: '${clusterName}/${applicationTypeNameFabricObserverName}'
  location: azureregion
}

resource applicationTypeVersionFabricObserver 'Microsoft.ServiceFabric/clusters/applicationTypes/versions@2021-06-01' = {
  name: applicationTypeVersionFabricObserverName
  parent: applicationTypeNameFabricObserver
  location: azureregion
  properties: {
    appPackageUrl: packageUrlFabricObserver
  }
}

resource applicationNameFabricObserver 'Microsoft.ServiceFabric/clusters/applications@2021-06-01' = {
  name: '${clusterName}/${applicationNameFabricObserverName}'
  location: azureregion
  properties: {
    typeName: applicationTypeNameFabricObserverName
    typeVersion: applicationTypeVersionFabricObserverName
    parameters: {
      FabricSystemObserverEnabled: 'true'
    }
    maximumNodes: 3
    minimumNodes: 1
    removeApplicationCapacity: false

    upgradePolicy: {
      upgradeMode: 'Monitored'
      upgradeReplicaSetCheckTimeout: '01:00:00.0'
      forceRestart: false
      rollingUpgradeMonitoringPolicy: {
        failureAction: 'Rollback'
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
  dependsOn: [
    applicationTypeVersionFabricObserver
  ]
}

resource serviceNameFabricObserver 'Microsoft.ServiceFabric/clusters/applications/services@2021-06-01' = {
  name: '${applicationNameFabricObserverName}~${serviceNameFabricObserverName}'
  parent: applicationNameFabricObserver
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


