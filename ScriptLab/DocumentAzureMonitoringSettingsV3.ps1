#region - Header
<#
----------------------------------
Author: Brinkmann, Dirk (dirk.brinkmann@microsoft.com)
Script Template Type: AZURE
Script Template Version: MS 2.7.0
Script Status: Test (Draft|Test|Production|Deprecated)

Disclaimer:
This sample script is not supported under any Microsoft standard support program or service. This sample
script is provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties
including, without limitation, any implied warranties of merchantability or of fitness for a particular
purpose. The entire risk arising out of the use or performance of this sample script and documentation
remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation,
production, or delivery of this script be liable for any damages whatsoever (including, without limitation,
damages for loss of business profits, business interruption, loss of business information, or other
pecuniary loss) arising out of the use of or inability to use this sample script or documentation, even
if Microsoft has been advised of the possibility of such damages.

Purpose and detailed description: Use get-help <scriptname.ps1> -full

History:
Date          Version       Author     Category (NEW | CHANGE | DELETE | BUGFIX): Description
14.06.2018    1.0.0         DirkBri    NEW: First release
----------------------------------
#>
#requires -version 3
#endregion - Header
#region - Help
# Comment based Help - Please place all script documentation in here

<# 
       .SYNOPSIS
       Exports diagnostic settings and [optional] collected metrics and alert rule settings for Azure resources in a subscription or a resource group.
       .DESCRIPTION
       This script creates a report of all diagnostic settings for resources in an Azure subscription or in a particular Resource group. It returns the
       defined diagnostic settings and optionally the defined metrics for a resource and all configured Alert rules in a subscription.

       CAUTION - current limitations of this script:
       - It returns only the settings for the FIRST diagnostic setting. There can be multiple applied to a Resource. Please see DiagnosticSettingCount for
         the current amount of configured settings.
       - There are current limits with the Azure PowerShell Cmdlets and the REST API:
         - Script uses a mixture of Cmdlets and REST API. This is not 100% clean/exact, so there might be information missing in rare cases
         - REST API currently returns no data for scheduled query based alerts, so these alerts will not be reported
       - Text based report is currently not complete. All information gathered via REST API is not contained.

       PLEASE SEE THE  YYYY-MM-DD_Subscription-<SubscriptionID>_Error.txt FOR ANY ERRORS!

       RUNTIME
       Please be aware that the runtime of this script can be quiet long (> 15min), depending on the amount of resources contained within a subscription!

        .PARAMETER ExportMetricsForResource
       Switch. If set the script will export all available metrics for the selected resources.

       .PARAMETER ExportAlertRulesForSubscription
       Switch. If set the script will export all available Alert rules for the selected Azure subscription (not filtered on a resource group).

       .PARAMETER DontShowDisclaimer
        Suppress the default Disclaimer message. Used in automation scenarios.

       .PARAMETER ResourcegroupName
       If this parameter is applied, only resources from this resource group will be exported.

       .PARAMETER SubscriptionID
       If this parameter is applied, only resources from this Azure Subscription will be exported. If this parameter is not used, the script will use the currently selected Azure subscription of the logged in user.

       .PARAMETER OutputDirectory
       Name of the folder (must exists) where the script will store all exported data. Default: C:\Temp

      
       .INPUTS
       None.

       .OUTPUTS
       The script returns several output files:

       YYYY-MM-DD_Subscription-<SubscriptionID>_Monitoringsettings.csv:
       CSV file containing all available settings from Azure Diagnostics like linked workspace, Eventhub, collected Logs etc. Metric and Alert data will only be available with the
       specific script switches, otherwise these fields will be empty.
       Contained fields are:
       - ResourceName	
       - ResourceID	
       - ResourceType	
       - DiagnosticSettingEnabled	: Are any diagnostic settings enabled? CAUTION: Not enabled does not mean that there are no Metrics available. See DiagnosticSettingLogMetricsCount
       - DiagnosticSettingCount	: How many Diagnostic settings are defined for this resource?
       - DiagnosticSettingWorkspaceEnabled	: Is a LogAnalytics workspace enabled for this resource
       - DiagnosticSettingWorkspaceID	: Name of Loganalytics workspace where diagnostic data is stored
       - DiagnosticSettingStorageAccountID	: Name of Storage account where diagnostic data is stored
       - DiagnosticSettingEventHubName	: Name of eventhub where data is exported to
       - DiagnosticSettingLogsEnabled	: Is the log collection enabled?
       - DiagnosticSettingLogNames	: Names of collected log files
       - DiagnosticSettingLogMetricsEnabled	: Is metric collected enabled?
       - DiagnosticSettingLogMetricsCount	: Count of all collected metrics. Only available if metrics will be exported
       - AlertRuleCountForResource : Only available if Alert rules will also be exported


       YYYY-MM-DD_Subscription-<SubscriptionID>_DiagnosticSettings.txt:
       Text based report for all resources.

       YYYY-MM-DD_Subscription-<SubscriptionID>_Error.txt:
       Text based report for any generic errors.

       [optional, if switch is set] YYYY-MM-DD_Subscription-<SubscriptionID>_Metrics.csv:
       CSV file containing all available metrics from Azure Diagnostics for the resource.

       [optional, if switch is set] YYYY-MM-DD_Subscription-<SubscriptionID>_MetricsBadRequests.csv:
       CSV file containing all failed request to gather Metric data for the resource. For troubleshooting purposes only.

       [optional, if switch is set] YYYY-MM-DD_Subscription-<SubscriptionID>_AlertRules.csv:
       CSV file containing all available Alert rules of the Azure subscription.

       
       
       
       .NOTES
    Author:     Brinkmann, Dirk (dirk.brinkmann@microsoft.com)

       DISCLAIMER:
       This sample script is not supported under any Microsoft standard support program or service. This sample
       script is provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties
       including, without limitation, any implied warranties of merchantability or of fitness for a particular
       purpose. The entire risk arising out of the use or performance of this sample script and documentation
       remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation,
       production, or delivery of this script be liable for any damages whatsoever (including, without limitation,
       damages for loss of business profits, business interruption, loss of business information, or other
       pecuniary loss) arising out of the use of or inability to use this sample script or documentation, even
       if Microsoft has been advised of the possibility of such damages.
       
       .LINK
       https://blogs.technet.microsoft.com/germanageability

       .EXAMPLE
       <PS> E:\DocumentAzureMonitoringSettings.ps1
       Exports all Diagnosticsettings for the current selected subscription. Does not export AlertRules or Metric data.

       .EXAMPLE
       <PS> E:\DocumentAzureMonitoringSettings.ps1 -resourcegroupname my-resource-group
       Exports all Diagnosticsettings for the current selected subscription and ONLY for the specified resource group. Does not export AlertRules or Metric data.

        .EXAMPLE
       <PS> E:\DocumentAzureMonitoringSettings.ps1 -resourcegroupname my-resource-group -subscriptionid 1234567890
       Exports all Diagnosticsettings for the specified subscription and ONLY for the specified resource group. Does not export AlertRules or Metric data.

       .EXAMPLE
       <PS> E:\DocumentAzureMonitoringSettings.ps1 -resourcegroupname my-resource-group -subscriptionid 1234567890 -ExportAlertRulesForSubscription -ExportMetricsForResource
       Exports all Diagnosticsettings for the specified subscription and ONLY for the specified resource group including metric data AND Alert rules for the whole subscription.

      .EXAMPLE
       <PS> get-azurermsubscription | % {E:\DocumentAzureMonitoringSettings.ps1 -subscriptionid $_.id -ExportAlertRulesForSubscription -ExportMetricsForResource -dontshowdisclaimer}
       Exports all Diagnosticsettings for all available subscriptions of this user including metric data AND Alert rules for the whole subscription.



#>

#endregion - Help


#region - Parameter
[cmdletbinding()]
param( #Place your own parameter here
              
    [Switch]$ExportMetricsForResource,
    [Switch]$ExportAlertRulesForSubscription,
    [Switch]$DontShowDisclaimer,
    [String]$ResourcegroupName,
    [string]$SubscriptionID,
    [String]$OutPutDirectory="C:\Temp"
            )

#endregion - Parameter

#region - Initialization
#----------------------------------
# Some helpful intitialization Cmdlets
Set-PSDebug -Strict
$Error.Clear()
$script:ScriptStopWatch  = [System.Diagnostics.stopwatch]::startnew()
[Threading.Thread]::CurrentThread.CurrentCulture = "en-US"        
[Threading.Thread]::CurrentThread.CurrentUICulture = "en-US"
# Check if user is logged in to Azure
$blnLoggedInToAzure = $true
Try 
{
    $AzureContext = Get-AzureRmContext
} 
Catch 
{
    $blnLoggedInToAzure = $false
}
if ($AzureContext) 
{
    if([string]::IsNullOrEmpty($AzureContext.Account)){$blnLoggedInToAzure=$false}
} 
if (!$blnLoggedInToAzure)
{
    $strMessage = "It seems that you are not logged in to Azure. Please use Login-AzureRmAccount to authenticate!"
    Write-Host $strMessage -ForegroundColor red -BackgroundColor Yellow
    exit -1
}
#----------------------------------
#endregion - Initialization

#region - Variable
#----------------------------------
#  Variables that might need to be changed
#----------------------------------
$dtmStartTime = get-date
$LineChar1 = "#"
$LineChar2 = "-"
$LineLength = 200
$strLine1 = $LineChar1 * $LineLength
$strLine2 = $LineChar2 * $LineLength
if ($SubscriptionID){Select-AzureRmSubscription -SubscriptionId $SubscriptionID | Out-Null}
else {$SubscriptionID = $AzureContext.Subscription}
$ReportFile = "{0:yyyy-MM-dd}_Subscription-{1}_Diagnosticsettings.txt" -f (get-date),$AzureContext.Subscription
$GeneralErrorFile = "{0:yyyy-MM-dd}_Subscription-{1}_Errors.txt" -f (get-date),$AzureContext.Subscription
$MonitoringSettingsCSVFile = "{0:yyyy-MM-dd}_Subscription-{1}_Monitoringsettings.csv" -f (get-date),$AzureContext.Subscription
$MetricsCSVFile = "{0:yyyy-MM-dd}_Subscription-{1}_Metrics.csv" -f (get-date),$AzureContext.Subscription
$AlertRulesCSVFile = "{0:yyyy-MM-dd}_Subscription-{1}_AlertRules.csv" -f (get-date),$AzureContext.Subscription
$MetricsBadRequestsCSVFile = "{0:yyyy-MM-dd}_Subscription-{1}_MetricsBadRequests.csv" -f (get-date),$AzureContext.Subscription
$ReportFullFile = Join-Path $OutPutDirectory $ReportFile
$GeneralErrorFullFile = Join-Path $OutPutDirectory $GeneralErrorFile
$MonitoringSettingsCSVFullFile = Join-Path $OutPutDirectory $MonitoringSettingsCSVFile
$MetricsCSVFullFile = Join-Path $OutPutDirectory $MetricsCSVFile
$AlertRulesCSVFullFile = Join-Path $OutPutDirectory $AlertRulesCSVFile
$MetricsBadRequestsCSVFullFile = Join-Path $OutPutDirectory $MetricsBadRequestsCSVFile
$MonitoringEnabled = "Enabled"
$MonitoringNotEnabled = "Not enabled"
$MonitoringNotSupportedForResourceType = "Not supported for Resource Type"

$global:colCustomResourceObjects = @()
$global:colCustomMetricObjects = @()
$global:colCustomAlertRuleObjects = @()
$global:colCustomMetricBadRequestObjects = @()


#----------------------------------
# Other Variables  - don't change, can break the script
#----------------------------------
[String]$MyInvocationScriptName = $MyInvocation.MyCommand.Name
[String]$script:ExecutingUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

#----------------------------------
#endregion - Variable


#region - Main
#----------------------------------
# Main function - place all Code here
#----------------------------------
function start-main ()
{
    Clear-Host

    #Show Disclaimer
    if (!$DontShowDisclaimer){show-customdiclaimer}

    #Get Azure Resources
    $strTemp = "Report created on: {0}" -f (get-date)
    $strTemp | out-file -FilePath $ReportFullFile
    $AzureContext | out-file -FilePath $ReportFullFile -Append
    if ($ResourcegroupName)
    {
        $colAllresources = Get-AzureRmResource -ResourceGroupName $ResourcegroupName
        $strTemp = "ResourceGroupt`t: {0}" -f $ResourcegroupName
        $strTemp | Out-File -FilePath $ReportFullFile -Append
    }
    else {
        $colAllresources = Get-AzureRmResource
    }

    $strTemp = "Report created on: {0}" -f (get-date)
    $strTemp | out-file -FilePath $ReportFullFile
    $AzureContext | out-file -FilePath $ReportFullFile -Append

    #Process data
    $BearerToken = get-AzureRmCachedAccessToken
    $colResourceTypes = @($colAllresources | Sort-Object -Property ResourceType -Unique | Select-Object ResourceType).ResourceType
    $i=0
    foreach ($ResourceType in $colResourceTypes)
    {
        $i++
        Write-Progress -Activity "Processing Resource Types" -Status Progress -PercentComplete ($i/$colResourceTypes.count*100)

        $strLine1 | out-file -FilePath $ReportFullFile -Append
        $strTemp = "ResourceType = {0}" -f $ResourceType
        $strTemp | out-file -FilePath $ReportFullFile -Append
        $strLine1 | out-file -FilePath $ReportFullFile -Append
        $colResourcesOfType = @($colAllresources | Where-Object {$_.resourcetype -eq $ResourceType})
        $blnDiagnosticSettingAvailable = $true
        $x=0
        [int]$intResourceCount = $colResourcesOfType.count
        foreach ($resource in $colResourcesOfType)
        {
            $x++
            [double]$PercentageComplete = ($x/$intResourceCount)*100
            Write-Progress -id 1 -Activity "Processing Resources" -Status Progress -PercentComplete ($PercentageComplete) -ErrorAction SilentlyContinue

            $customResource = new-custommonitoringobject
            $customResource.ResourceName = $Resource.name
            $customResource.ResourceID = $Resource.resourceid
            $customResource.ResourceType = $ResourceType

            if ($ExportMetricsForResource)
            {
            $Result =  get-custommetricforresource -ResourceID $Resource.resourceid -ResourceName $Resource.name -ResourceType $ResourceType
            $customResource.DiagnosticSettingLogMetricsCount = $Result[0]
            if ($Result[0] -gt 0){$customResource.DiagnosticSettingLogMetricsEnabled = $true}
            }
        
            $strTemp = "Resource name [ID]: {0} [{1}]" -f $Resource.name, $resource.resourceid
            $strTemp | out-file -FilePath $ReportFullFile -Append
            if ($blnDiagnosticSettingAvailable)
            {
                try {
                    $ResoureDiagnosticSettings = $resource | Get-AzureRmDiagnosticSetting -ErrorAction Stop
                }
                catch {
                    $blnDiagnosticSettingAvailable = $false
                    $strMessage = "Error: {0} from Get-AzureRmDiagnosticSetting for resource [{1}]" -f $Error[0].exception,$Resource.ResourceID
                    $strMessage | Out-File $GeneralErrorFile -Append
                }
                if ($blnDiagnosticSettingAvailable)
                {
                    if ($ResoureDiagnosticSettings.Name -eq "service")
                    {
                        $strMessage = "PoSh Cmdlet get-azurermdiagnosticsettings did not work for resource [{0}]" -f $resource.resourceid
                        $strMessage | Out-File $GeneralErrorFile -Append
                        Write-Verbose $strMessage 
                        $ResoureDiagnosticSettingsAPI = get-customdiagnosticsettingapi -BearerToken $BearerToken -ResourceID $resource.resourceid
                        get-customdiagnosticsettings -DiagnosticSetting $ResoureDiagnosticSettingsAPI -CustomObject $customResource -Type API
                    }
                    else {
                            get-customdiagnosticsettings -DiagnosticSetting $ResoureDiagnosticSettings -CustomObject $customResource -Type Cmdlet
                    }
                }
                else
                {
                    $strTemp = "`t`t*** No Diagnostic settings for resource type available ***" 
                    $strTemp | out-file -FilePath $ReportFullFile -Append
                    $customResource.DiagnosticSettingEnabled = $MonitoringNotSupportedForResourceType
    
                }
            }
            else
            {
                $customResource.DiagnosticSettingEnabled = $MonitoringNotSupportedForResourceType
            }
            if ($ExportMetricsForResource)
            {
            $Result[1] | Select-Object metric*,unit,PrimaryAggregationType | out-file -FilePath $ReportFullFile -Append
            }
            $strTemp ="{0}`n" -f $strline2
            $strTemp | out-file -FilePath $ReportFullFile -Append

            $global:colCustomResourceObjects+= $customResource
        }

    }



    #Dump AlertRule Information
    if ($ExportAlertRulesForSubscription)
    {
        $MetricAlertRules = get-custommetricalertruleapi -BearerToken $BearerToken -SubscriptionID $AzureContext.Subscription.Id
        foreach($Rule in $MetricAlertRules.value) {set-customalertruledata -RuleData $Rule}
        $ActivityAlertRules = get-customactivityalertruleapi -BearerToken $BearerToken -SubscriptionID $AzureContext.Subscription.Id
        foreach($Rule in $ActivityAlertRules.value) {set-customalertruledata -RuleData $Rule}
        $ScheduledQueryAlertRules = get-customscheduledqueryalertruleapi -BearerToken $BearerToken -SubscriptionID $AzureContext.Subscription.Id
        foreach($Rule in $ScheduledQueryAlertRules.value) {set-customalertruledata -RuleData $Rule}

      
        #Write CSV
        $global:colCustomAlertRuleObjects | Export-Csv $AlertRulesCSVFullFile -NoTypeInformation
        $strTemp = "Alert Rules CSV file written to [{0}]" -f $AlertRulesCSVFullFile
        Write-Host $strTemp -ForegroundColor Green

        #Correlate AlertRules to Azure Resources
        foreach ($AlertRuleObject in $global:colCustomAlertRuleObjects)
        {
            $tempObject = $global:colCustomResourceObjects | Where-Object {$_.ResourceID -eq $AlertRuleObject.AlertRuleTarget}
            if ($tempObject){$tempObject.AlertRuleCountForResource = $tempObject.AlertRuleCountForResource + 1}

        }

    }

    #Report close
    $global:colCustomResourceObjects | Export-Csv $MonitoringSettingsCSVFullFile -NoTypeInformation
    $strTemp = "Monitoring settings CSV file written to [{0}]" -f $MonitoringSettingsCSVFullFile
    Write-Host $strTemp -ForegroundColor Green


    if ($ExportMetricsForResource)
    {
        $global:colCustomMetricObjects | Export-Csv $MetricsCSVFullFile -NoTypeInformation
        $strTemp = "Metrics CSV file written to [{0}]" -f $MetricsCSVFullFile
        Write-Host $strTemp -ForegroundColor Green

        if ($global:colCustomMetricBadRequestObjects.count -gt 0)
        {
            $global:colCustomMetricBadRequestObjects | Export-Csv $MetricsBadRequestsCSVFullFile -NoTypeInformation
            $strTemp = "There were [{0}] errors getting Metrics for resources. See [{1}] for details." -f $global:colCustomMetricBadRequestObjects.count,$MetricsBadRequestsCSVFullFile
            Write-Host $strTemp -ForegroundColor red -BackgroundColor Yellow
        }
    }

    $strTemp ="{0}`n" -f $strline2
    $strTemp | out-file -FilePath $ReportFullFile -Append
    $dtmRuntime = New-TimeSpan -Start $dtmStartTime -End (get-date)
    $strRuntime=$strTemp = "Report Runtime in seconds: {0}" -f $dtmRuntime.TotalSeconds
    $strTemp | out-file -FilePath $ReportFullFile -Append
    $strTemp ="{0}`n" -f $strline2
    $strTemp | out-file -FilePath $ReportFullFile -Append

    #Dump all PoSh Errors
    $strLine1 | Out-File $GeneralErrorFullFile -Append
    $strTemp = "List of all PowerShell Errors:"
    $strTemp | Out-File $GeneralErrorFullFile -Append
    $Error | Select-Object exception | ForEach-Object {$_.exception | Out-File $GeneralErrorFullFile -Append}

    $strTemp = "Report written to [{0}]" -f $ReportFullFile
    Write-Host $strTemp -ForegroundColor Green
    Write-Host $strRuntime -ForegroundColor Green

}
#----------------------------------
#endregion - Main


#region - Functions
#----------------------------------
# Functions - place all supporting functions here
#----------------------------------

function show-customdiclaimer
{
    Write-Host $strLine1
    $strMessage = "This script does not change anything in your Azure subscription [{0}].`nIt only requires READ access to the subscription." -f $SubscriptionID
    Write-Host $strMessage
    $strMessage = "Please ensure that you have read the included command based help of this script BEFORE running."
    Write-Host $strMessage -ForegroundColor Red -BackgroundColor Yellow
    $strMessage = "This gives you an understanding of its purpose, output and limitations!" 
    Write-Host $strMessage
    Write-Host $strLine1
    $strMessage = "Do you want to continue? (y/n)" 
    $Return = Read-Host -Prompt $strMessage
    if ($Return -ne "y")
    {
        exit 0
    }
    Clear-Host
 
}

function get-custommetricalertruleapi
{
    param($BearerToken,
          $SubscriptionID)

    $URI = "https://management.azure.com/subscriptions/{0}/providers/Microsoft.Insights/metricAlerts?api-version=2018-03-01" -f $SubscriptionID
    $params = @{
        ContentType = 'application/json'
        Headers = @{
            'authorization' = "$($BearerToken)"
        }
        Method = 'Get'
        URI = $URI
    }
    $blnSuccess = $true
    try {
        $response = Invoke-RestMethod @params -ErrorAction SilentlyContinue
        }
    catch {
        $blnSuccess = $false
        $strMessage = "REST API Call [GET {0}] failed. Exception: [{1}]" -f $URI,$Error[0].exception
        $strMessage | Out-File $GeneralErrorFullFile -Append
    }
    if ($blnSuccess) {    return $response }
    else {return $null}

}

function get-customactivityalertruleapi
{
    param($BearerToken,
          $SubscriptionID)
 
          $URI = "https://management.azure.com/subscriptions/{0}/providers/microsoft.insights/activityLogAlerts?api-version=2017-04-01" -f $SubscriptionID
    $params = @{
        ContentType = 'application/json'
        Headers = @{
            'authorization' = "$($BearerToken)"
        }
        Method = 'Get'
        URI = $URI
    }
    $blnSuccess = $true
    try {
        $response = Invoke-RestMethod @params -ErrorAction SilentlyContinue
        }
    catch {
        $blnSuccess = $false
        $strMessage = "REST API Call [GET {0}] failed. Exception: [{1}]" -f $URI,$Error[0].exception
        $strMessage | Out-File $GeneralErrorFullFile -Append
    }
    if ($blnSuccess) {    return $response }
    else {return $null}

}

function get-customscheduledqueryalertruleapi
{
    param($BearerToken,
          $SubscriptionID)
 
          $URI = "https://management.azure.com/subscriptions/{0}/providers/microsoft.insights/scheduledQueryRules?api-version=2018-04-16" -f $SubscriptionID
    $params = @{
        ContentType = 'application/json'
        Headers = @{
            'authorization' = "$($BearerToken)"
        }
        Method = 'Get'
        URI = $URI
    }
    $blnSuccess = $true
    try {
        $response = Invoke-RestMethod @params -ErrorAction SilentlyContinue
        }
    catch {
        $blnSuccess = $false
        $strMessage = "REST API Call [GET {0}] failed. Exception: [{1}]" -f $URI,$Error[0].exception
        $strMessage | Out-File $GeneralErrorFullFile -Append

    }
    if ($blnSuccess) {    return $response }
    else {return $null}

}
function Get-AzureRmCachedAccessToken() {
  
    if (-not (Get-Module AzureRm.Profile)) {
        Import-Module AzureRm.Profile
    }
    $azureRmProfileModuleVersion = (Get-Module AzureRm.Profile).Version
    # refactoring performed in AzureRm.Profile v3.0 or later
    if ($azureRmProfileModuleVersion.Major -ge 3) {
        $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        if (-not $azureRmProfile.Accounts.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    }
    else {
        # AzureRm.Profile < v3.0
        $azureRmProfile = [Microsoft.WindowsAzure.Commands.Common.AzureRmProfileProvider]::Instance.Profile
        if (-not $azureRmProfile.Context.Account.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    }
  
    $currentAzureContext = Get-AzureRmContext
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    Write-Debug ("Getting access token for tenant" + $currentAzureContext.Subscription.TenantId)
    $token = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId)
    "Bearer " + $token.AccessToken
    # $token = Get-AzureRmCachedAccessToken
}

function get-customdiagnosticsettingapi
{
    param($BearerToken,
          $ResourceID)

    $URI = "https://management.azure.com/{0}/providers/microsoft.insights/diagnosticSettings?api-version=2017-05-01-preview" -f $ResourceID
    $params = @{
        ContentType = 'application/json'
        Headers = @{
            'authorization' = "$($BearerToken)"
        }
        Method = 'Get'
        URI = $URI
    }
    $blnSuccess = $true
    try {
        $response = Invoke-RestMethod @params -ErrorAction SilentlyContinue
        }
    catch {$blnSuccess = $false}
    if ($blnSuccess) {    return $response }
    else {return $null}

}


function Get-AzureRmCachedAccessToken() {
  
    if (-not (Get-Module AzureRm.Profile)) {
        Import-Module AzureRm.Profile
    }
    $azureRmProfileModuleVersion = (Get-Module AzureRm.Profile).Version
    # refactoring performed in AzureRm.Profile v3.0 or later
    if ($azureRmProfileModuleVersion.Major -ge 3) {
        $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        if (-not $azureRmProfile.Accounts.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    }
    else {
        # AzureRm.Profile < v3.0
        $azureRmProfile = [Microsoft.WindowsAzure.Commands.Common.AzureRmProfileProvider]::Instance.Profile
        if (-not $azureRmProfile.Context.Account.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    }
  
    $currentAzureContext = Get-AzureRmContext
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    Write-Debug ("Getting access token for tenant" + $currentAzureContext.Subscription.TenantId)
    $token = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId)
    "Bearer " + $token.AccessToken
    # $token = Get-AzureRmCachedAccessToken
}

function new-customalertruleobject
{

    $tempObject = New-OBject -TypeName pscustomobject

    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleName -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleId -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleType -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleDescription -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleSeverity -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleTarget -Value $Null  
    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleEnabled -Value $false
    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleEvaluationFrequency -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleWindowSize -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleActionGroupCount -Value 0
    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleActionGroupList -Value $Null
    


    return $tempObject



}

function new-custommonitoringobject
{

    $tempObject = New-OBject -TypeName pscustomobject

    $tempObject | Add-Member -MemberType NoteProperty -Name ResourceName -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name ResourceID -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name ResourceType -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name DiagnosticSettingEnabled -Value $MonitoringNotEnabled
    $tempObject | Add-Member -MemberType NoteProperty -Name DiagnosticSettingCount -Value 0   
    $tempObject | Add-Member -MemberType NoteProperty -Name DiagnosticSettingWorkspaceEnabled -Value $false
    $tempObject | Add-Member -MemberType NoteProperty -Name DiagnosticSettingWorkspaceID -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name DiagnosticSettingStorageAccountID -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name DiagnosticSettingEventHubName -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name DiagnosticSettingLogsEnabled -Value $false
    $tempObject | Add-Member -MemberType NoteProperty -Name DiagnosticSettingLogNames -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name DiagnosticSettingLogMetricsEnabled -Value $false
    $tempObject | Add-Member -MemberType NoteProperty -Name DiagnosticSettingLogMetricsCount -Value 0
    $tempObject | Add-Member -MemberType NoteProperty -Name AlertRuleCountForResource -Value 0


    return $tempObject



}


function new-custommetricobject
{

    $tempObject = New-OBject -TypeName pscustomobject

    $tempObject | Add-Member -MemberType NoteProperty -Name ResourceName -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name ResourceID -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name ResourceType -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name MetricName -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name MetricLocalizedName -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name Unit -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name PrimaryAggregationType -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name ID -Value $Null
  

    return $tempObject



}

function new-custommetricbadrequestobject
{

    $tempObject = New-OBject -TypeName pscustomobject

    $tempObject | Add-Member -MemberType NoteProperty -Name ResourceName -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name ResourceID -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name ResourceType -Value $Null
    $tempObject | Add-Member -MemberType NoteProperty -Name ErrorMessage -Value $Null
     

    return $tempObject



}

function get-custommetricforresource
{
    param ($ResourceID,
            $ResourceName,
            $ResourceType)

    try {
        $MetricDefinition = Get-AzureRmMetricDefinition -ResourceId $ResourceID -WarningAction SilentlyContinue -ErrorAction Stop
    }
    catch {
        $tempBadRequestObject = new-custommetricbadrequestobject
        $tempBadRequestObject.ResourceName = $ResourceName
        $tempBadRequestObject.ResourceID = $ResourceID
        $tempBadRequestObject.ResourceType = $ResourceType
        $tempBadRequestObject.ErrorMessage = $Error[0].Exception.Message
        $global:colCustomMetricBadRequestObjects+= $tempBadRequestObject
        $strMessage = "Get-AzureRmMetricDefinition returned an error for resource [{0}]" -f $ResourceID
        Write-Verbose $strMessage
        return 0, $null
    }
    $intMetricCount = 0
    $colMetricsForResource = @()
    foreach ($Metric in $MetricDefinition)
    {
        $intMetricCount++
        $tempMetric = new-custommetricobject
        $tempMetric.ResourceName = $ResourceName
        $tempMetric.ResourceID = $ResourceID
        $tempMetric.ResourceType = $ResourceType
        $tempMetric.MetricName = $Metric.Name.Value
        $tempMetric.MetricLocalizedName = $Metric.Name.LocalizedValue
        $tempMetric.Unit = $Metric.Unit
        $tempMetric.PrimaryAggregationType = $Metric.PrimaryAggregationType
        $tempMetric.ID = $Metric.id

        $global:colCustomMetricObjects+=$tempMetric
        $colMetricsForResource +=$tempMetric

    }

    return $intMetricCount, $colMetricsForResource
}

function get-customdiagnosticsettings
{
    param($DiagnosticSetting,
          $CustomObject,
          [ValidateSet("API","Cmdlet")]
          $Type)


    $strMonitoringEnabledState = $MonitoringNotEnabled

    if ($Type -eq "Cmdlet")
    {

        $colPropertiesWithValues = $DiagnosticSetting.psobject.Properties | Where-Object {$_.name -in ("StorageAccountId","ServiceBusRuleId","EventHubAuthorizationRuleId","WorkspaceId","Type","Location")} | Where-Object {$_.value} 
        If ($colPropertiesWithValues.count -gt 0)
        {
            $strTemp = "`nImportant Diagnostic properties:"
            $strTemp  | out-file -FilePath $ReportFullFile -Append
            $colPropertiesWithValues | ForEach-Object {$_.name + " : " + $_.value} | out-file -FilePath $ReportFullFile -Append
            $strTemp = "`n"
            $strTemp  | out-file -FilePath $ReportFullFile -Append
        
            $CustomObject.DiagnosticSettingWorkspaceID = $DiagnosticSetting.WorkspaceID
            if ($customobject.DiagnosticSettingWorkspaceID.length -gt 1)
            {   $CustomObject.DiagnosticSettingWorkspaceEnabled = $true
                $strMonitoringEnabledState = $MonitoringEnabled}
        
        }
 
        if (@($DiagnosticSetting.Logs | ? {$_.enabled -eq $true}).count -gt 0)
        {   
            $strMonitoringEnabledState = $MonitoringEnabled
            $CustomObject.DiagnosticSettingLogsEnabled = $true
            $CustomObject.DiagnosticSettingLogNames = @($DiagnosticSetting.Logs | ? {$_.enabled -eq $true} | Select-Object category).category -join ";"
            $strTemp = "`nLogs enabled:"
            $strTemp  | out-file -FilePath $ReportFullFile -Append
            $DiagnosticSetting.Logs| out-file -FilePath $ReportFullFile -Append
        }
   
        if (@($DiagnosticSetting.Metrics | ? {$_.enabled -eq $true}).count -gt 0)
        {
            $strTemp = "`nMetrics enabled:"
            $strTemp  | out-file -FilePath $ReportFullFile -Append
            $DiagnosticSetting.Metrics | out-file -FilePath $ReportFullFile -Append
            $CustomObject.DiagnosticSettingLogMetricsEnabled = $true
            $strMonitoringEnabledState = $MonitoringEnabled
        
        }
    }
    if ($Type -eq "API")
    {
        $CustomObject.DiagnosticSettingCount = $DiagnosticSetting.value.count
        if ($DiagnosticSetting.value.count -eq 0)
        {
            $strMessage = "REST API returned and empty DiagnosticSetting Array for resource [{0}]" -f $CustomObject.ResourceID
            $strMessage | Out-File $GeneralErrorFullFile -Append
            return
        }
        $DiagnosticData = $DiagnosticSetting.value[0].properties
                
        $CustomObject.DiagnosticSettingWorkspaceID = $DiagnosticData.WorkspaceID
        $CustomObject.DiagnosticSettingEventHubName = $DiagnosticData.eventHubName
        $CustomObject.DiagnosticSettingStorageAccountID = $DiagnosticData.StorageAccountId
        

        if ($customobject.DiagnosticSettingWorkspaceID.length -gt 1)
        {
            $strMonitoringEnabledState = $MonitoringEnabled
            $CustomObject.DiagnosticSettingWorkspaceEnabled = $true
        }
        
        if (@($DiagnosticData.Logs | ? {$_.enabled -eq $true}).count -gt 0)
        {   
            $strMonitoringEnabledState = $MonitoringEnabled
            $CustomObject.DiagnosticSettingLogsEnabled = $true
            $CustomObject.DiagnosticSettingLogNames = @($DiagnosticData.Logs | ? {$_.enabled -eq $true} | Select-Object category).category -join ";"
            $strTemp = "`nLogs enabled:"
            $strTemp  | out-file -FilePath $ReportFullFile -Append
            $DiagnosticData.Logs| out-file -FilePath $ReportFullFile -Append
        }
   
        if (@($DiagnosticData.Metrics | ? {$_.enabled -eq $true}).count -gt 0)
        {
            $strTemp = "`nMetrics enabled:"
            $strTemp  | out-file -FilePath $ReportFullFile -Append
            $DiagnosticData.Metrics | out-file -FilePath $ReportFullFile -Append
            $CustomObject.DiagnosticSettingLogMetricsEnabled = $true
            $strMonitoringEnabledState = $MonitoringEnabled
        
        }
    }
   
    $CustomObject.DiagnosticSettingEnabled = $strMonitoringEnabledState
}

function set-customalertruledata
{
    param($RuleData)

    $tempAlertRule = new-customalertruleobject
    $tempAlertRule.AlertRuleName = $RuleData.name
    $tempAlertRule.AlertRuleId = $RuleData.id
    $tempAlertRule.AlertRuleDescription = $RuleData.properties.description
    $tempAlertRule.AlertRuleEnabled = $RuleData.properties.enabled
    $tempAlertRule.AlertRuleEvaluationFrequency = $RuleData.properties.evaluationFrequency
    $tempAlertRule.AlertRuleWindowSize = $RuleData.properties.windowSize
    $tempAlertRule.AlertRuleTarget = $RuleData.properties.scopes[0]
    $tempAlertRule.AlertRuleSeverity = $RuleData.properties.Severity
    $tempAlertRule.AlertRuleType = $RuleData.type
    $tempAlertRule.AlertRuleActionGroupCount = $RuleData.properties.actions.count
    if ($RuleData.properties.actions.count -gt 1)
    {
        $strTemp = @($RuleData.properties.actions | % {$_.ActionGroupID}) -join "###"
    }
    else {
        $strTemp = $RuleData.properties.actions[0].ActionGroupID
    }
    $tempAlertRule.AlertRuleActionGroupList = $strTemp

    $global:colCustomAlertRuleObjects+=$tempAlertRule

}



#----------------------------------
#endregion - Functions

#region - ScriptStart
#----------------------------------
# Place code here, which cannot be executed in Main(), but after all function definition
#----------------------------------

#----------------------------------
#endregion - Scriptstart

#----------------------------------
# Call function Main
#----------------------------------

start-main







