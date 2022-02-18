$subscriptionId = "13ad2c84-84fa-4798-ad71-e70c07af873f"

Try {
    Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop
  } Catch {
      Login-AzAccount
      Set-AzContext -SubscriptionId $subscriptionId
  }


  Get-AzVmImage -Location "westus" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter"

  Start-AzVmssRollingOSUpgrade -ResourceGroupName "myResourceGroup" -VMScaleSetName "myScaleSet"
