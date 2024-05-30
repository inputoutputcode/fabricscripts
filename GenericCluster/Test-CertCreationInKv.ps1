$azureRegion = "eastus"
$deploymentName = "chrpap" + (Get-Date).ToString("ddHHmm")
$resourceGroup = $deploymentName + "-group"
$keyVaultName = $deploymentName + "-keyvault"
$certificateName = $deploymentName + "-cert"


New-AzResourceGroup -Name $resourceGroup -Location $azureRegion -Force

New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup -Location $azureRegion -EnabledForDeployment 
$certPolicy = New-AzKeyVaultCertificatePolicy -SubjectName "CN=example.com" -IssuerName "Self" -ValidityInMonths 12 -ReuseKeyOnRenewal
Add-AzKeyVaultCertificate -VaultName $keyVaultName -Name $certificateName -CertificatePolicy $certPolicy
Start-Sleep -Seconds 60

$pfxSecretValue = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $certificateName -AsPlainText
$certBytes = [Convert]::FromBase64String($pfxSecretValue)
$certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$certCollection.Import($certBytes, $null, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

$store = New-Object System.Security.Cryptography.X509Certificates.X509Store -ArgumentList "My", "CurrentUser"
$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$store.Add($certCollection[0])
$store.Close()

cd Cert:\LocalMachine\My
certutil -v f7c231571ac65a2c28483aa49bca7a39b64828fb
