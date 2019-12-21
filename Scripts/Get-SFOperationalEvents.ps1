[xml]$doc = Get-Content "C:\Program Files\Microsoft Service Fabric\bin\Fabric\Fabric.Code\Microsoft-ServiceFabric-Events.man"

$templates = $doc.assembly.instrumentation.events.provider.templates.template
$templateLookup = @{}
$templates | %{ $templateLookup[$_.tid] = $_ }

$messages = $doc.assembly.localization.resources.stringTable.string
$messageLookup = @{}
$messages | %{ $messageLookup[$_.id] = $_.value }

#FMM_Service*Operational removed
# node events remove ", isSeedNode: %6, versionInstance: %7, id: %8, dca instance: %9"
# application change format to remove redundancy



# To query operational traces : | ? { $_.channel -eq "Operational"} `
$operationalEvents = $doc.assembly.instrumentation.events.provider.events.event `
    | ? { $_.task -eq "CRM"} `
    | % { Add-Member -InputObject $_ -Name "params" -MemberType NoteProperty -Value $templateLookup[$_.template].data -PassThru } `
    | % { Add-Member -InputObject $_ -Name "msg" -MemberType NoteProperty -Value $messageLookup[$_.message.Substring(9, $_.message.Length - 10)] -PassThru }

#foreach ($event in $operationalEvents) {
#  @{ "Level" = $event.level.Substring(4); "Id" = $event.value }
#}
$operationalEvents