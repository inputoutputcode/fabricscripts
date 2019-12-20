        Write-Output "Starting runbook."
		$connectionName = "AzureRunAsConnection"
		$envName = "{{Release.EnvironmentName}}"

		try
		{
			# Get the connection "AzureRunAsConnection "
			$servicePrincipalConnection = Get-AutomationConnection -Name $connectionName  
		
    		Write-Output "Logging in to Azure..."
    		Add-AzAccount `
                -ServicePrincipal `
                -TenantId $servicePrincipalConnection.TenantId `
                -ApplicationId $servicePrincipalConnection.ApplicationId `
                -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
        		
    		Set-AzContext -SubscriptionID $servicePrincipalConnection.SubscriptionID
		}
		catch {
    		if (!$servicePrincipalConnection)
    		{
        		$ErrorMessage = "Connection $connectionName not found."
        		throw $ErrorMessage
    		} else{
        		Write-Error -Message $_.Exception
        		throw $_.Exception
    		}
		}

        Write-Output "Parameters"
		$resourceGroupName = "spp-automation-$($envName)"
        $automationAccountName = "spp-automation-$($envName)"

		Write-Output "Start"

		$modules = Get-AzAutomationModule -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName | Select Name, IsGlobal
		ForEach ($module in $modules) {
            $name = $module.Name
            $isGlobal = $module.IsGlobal
            if($isGlobal)
            {
				Write-Output "Ignored Global Module $name"
            }
			elseif($name.StartsWith("Azure"))
			{
				Write-Output "Try to remove Module $name"
				Remove-AzAutomationModule -AutomationAccountName $automationAccountName -Name $name -ResourceGroupName $resourceGroupName -Confirm:$false -Force
				Write-Output "Removed Module $name"
			}
		}
