function Invoke-AddCertToKeyVaultAsSecret
{
<#
.SYNOPSIS
Upload certificate to Azure KeyVault

.DESCRIPTION
This command takes an existing pfx or creates a new self-signed certificate and uploads it as a secret to Azure KeyVault. The output of this command should be used during creation of secure cluster
through portal or for adding new certificates on VMs provisioned by Compute Resource Provider

#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string] $ResourceGroupName,

  [Parameter(Mandatory=$true)]
  [string] $VaultName,

  [Parameter(Mandatory=$true)]
  [string] $CertificateName,
   
  [Parameter(Mandatory=$true)]
  [string] $Password,   

  [Parameter(Mandatory=$true)]
  [string] $DnsName,

  [Parameter(Mandatory=$true)]
  [string] $OutputPath,

  [Parameter(Mandatory=$false)]
  [int] $NotAfterInDays = 2,

  [Parameter(Mandatory=$false)]
  [int] $NotBeforeInDays = 0

)

$ErrorActionPreference = 'Stop'

$resourceId = $null
$existingKeyVault = Get-AzKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroupName
$resourceId = $existingKeyVault.ResourceId

Write-Host "Using existing vault $VaultName in $($existingKeyVault.Location)"
Write-Host "Creating new self signed certificate at $NewPfxFilePath"

$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$NewPfxFilePath = Join-Path $OutputPath $($CertificateName+".pfx")
$provider = "Microsoft Enhanced RSA and AES Cryptographic Provider"
$certPath = "Cert:\CurrentUser\My"
$notBeforeDate = (Get-Date).AddDays($NotBeforeInDays).ToString("yyyy-MM-dd")
$notAfterDate = (Get-Date).AddDays($NotAfterInDays).ToString("yyyy-MM-dd")
New-SelfSignedCertificate -NotBefore $notBeforeDate -NotAfter $notAfterDate -DnsName $DnsName -CertStoreLocation $certPath -Provider $provider -KeyExportPolicy ExportableEncrypted | Export-PfxCertificate -FilePath $NewPfxFilePath -Password $securePassword | Out-Null
$ExistingPfxFilePath = $NewPfxFilePath

Write-Host "Reading pfx file from $ExistingPfxFilePath"
$cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 $ExistingPfxFilePath, $Password

$bytes = [System.IO.File]::ReadAllBytes($ExistingPfxFilePath)
$base64 = [System.Convert]::ToBase64String($bytes)

$jsonBlob = @{
   data = $base64
   dataType = 'pfx'
   password = $Password
   } | ConvertTo-Json

$contentbytes = [System.Text.Encoding]::UTF8.GetBytes($jsonBlob)
$content = [System.Convert]::ToBase64String($contentbytes)
$secretValue = ConvertTo-SecureString -String $content -AsPlainText -Force

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
Write-Host "Writing secret to $CertificateName in vault $VaultName"
$secret = Set-AzKeyVaultSecret -VaultName $VaultName -Name $CertificateName -SecretValue $secretValue

$output = @{};
$output.SourceVault = $resourceId;
$output.CertificateURL = $secret.Id;
$output.CertificateThumbprint = $cert.Thumbprint;

return $output;
}

Export-ModuleMember -Function Invoke-AddCertToKeyVaultAsSecret

