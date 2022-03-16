cd "C:\Program Files\Microsoft SDKs\Service Fabric\ClusterSetup"
.\DevClusterSetup.ps1 -PathToClusterDataRoot "c:\SfDevCluster\Data" -PathToClusterLogRoot "c:\SfDevCluster\Log" -AsSecureCluster -CreateOneNodeCluster

.\DevClusterSetup.ps1 -PathToClusterDataRoot "c:\SfDevCluster\Data" -PathToClusterLogRoot "c:\SfDevCluster\Log" -CreateOneNodeCluster