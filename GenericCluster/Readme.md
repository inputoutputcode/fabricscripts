# PowerShell Scripts - Create a generic Service Fabric Cluster in Azure

## Ideas

[ ] Extend the ARM template to open a range of known ports via deployment, it takes to long for demos to do this later usually.


## Open Tasks

[ ] I have scripts to package and deploy a bunch of Service Fabric packages by a simple path, but cannot find it currently.

[ ] I have also the scripts to create a secure cluster protected by AAD together with the needed application registration in AAD, but this is an improvement.

[ ] There is an issue with Log Analytics.

## Create-GenericCluster.ps1
The intention to create this script was the ability to create multiple clusters in the same subscription to test different configurations and code versions of applications under load.

We use two ARM templates here, the first one is just to get an unique name for DNS based deployment, this should prevent the most conflicts. So if there is a new API in Azure available, perhaps through some REST calls, this should be must more faster. Currently the creation and deletion of this temporary resource group takes 30 seconds usually.

The main ARM template includes a design for 2x 5 nodes with D3v2 VMs. There two node types, "Frontend" as primary with the SF system services and the "Backend". 

Application Insights and Log Analytics solutions are included.

The ARM template includes a lot of old event source providers which should be removed, but helps to demonstrate how this must be defined. There are some performance counters and event log messages collected to send this to the defined sink, which is Application Insights.

The scripts generates two certificates, the second one is used for the Reverse Proxy. Both certificates are uploaded to Azure Key Vault and imported in the local certificate store on Windows to enable the cluster mutual authentication in the browser to access SFX.

After the deployment you will find a text file unter C:\Temp with the unique name for the cluster DNS name and the thumbprint of the main certicate.


BTW. Vortex is a planet in Star Trek.

### Folder - MicrosoftAzureServiceFabric-AADHelpers
If you have the need to protect your cluster with AAD this scripts will handle the registration for application and the users for you. 

### Folder - ServiceFabricRPHelpers
This are some helper Methods as PowerShell Module. It makes the creation of self-signed certificates much more simpler, this pushes the certs to the Azure Key Vault instance as well. One of our PMs published this on GitHub.


## Create-GenericClusterInMCD.ps1
This is a very similar script to first one (Create-GenericCluster.ps1), but it's create a cluster in the Germany Cloud (Blackforest), so for Azure Active Directory the endpoint is different. For that I made a change in PowerShell Module in the sub directory called MicrosoftAzureServiceFabric-AADHelpers, to enable that.


## Package-ApplicationPackage.ps1
Just build the Service Fabric application package, similar to "Package" in VS.

## Deploy-ApplicationPackage.ps1
Deploy a Service Fabric application package to a cluster.


## Delete-AllBinFolders.ps1
This script is to clean up the solution folder from build files completely. We had some issues with VS to do that, so we cannot build enough trust with the "Clean" feature. 