## https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage

$locName="eastus"
Get-AzVMImagePublisher -Location $locName | Select PublisherName

$pubName="MicrosoftWindowsServer"
Get-AzVMImageOffer -Location $locName -PublisherName $pubName | Select Offer

$offerName="WindowsServer"
Get-AzVMImageSku -Location $locName -PublisherName $pubName -Offer $offerName | Select Skus

$skuName="2019-datacenter-core-smalldisk-g2"
Get-AzVMImage -Location $locName -PublisherName $pubName -Offer $offerName -Sku $skuName | Select Version

