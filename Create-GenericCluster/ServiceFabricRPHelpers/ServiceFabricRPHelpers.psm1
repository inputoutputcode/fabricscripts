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
  [string] $SubscriptionId,

  [Parameter(Mandatory=$true)]
  [string] $ResourceGroupName,

  [Parameter(Mandatory=$true)]
  [string] $Location,

  [Parameter(Mandatory=$true)]
  [string] $VaultName,

  [Parameter(Mandatory=$true)]
  [string] $CertificateName,
   
  [Parameter(Mandatory=$true)]
  [string] $Password,   

  [Parameter(Mandatory=$true, ParameterSetName="CreateNewCertificate")]
  [switch] $CreateSelfSignedCertificate,

  [Parameter(Mandatory=$true, ParameterSetName="CreateNewCertificate")]
  [string] $DnsName,

  [Parameter(Mandatory=$true, ParameterSetName="CreateNewCertificate")]
  [string] $OutputPath,

  [Parameter(Mandatory=$true, ParameterSetName="UseExistingCertificate")]
  [switch] $UseExistingCertificate,

  [Parameter(Mandatory=$true, ParameterSetName="UseExistingCertificate")] 
  [string] $ExistingPfxFilePath
)

$ErrorActionPreference = 'Stop'

$resourceId = $null
$existingKeyVault = Get-AzKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroupName
$resourceId = $existingKeyVault.ResourceId

Write-Host "Using existing vault $VaultName in $($existingKeyVault.Location)"

if($CreateSelfSignedCertificate)
{
  Write-Host "Creating new self signed certificate at $NewPfxFilePath"

  $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
  $NewPfxFilePath = Join-Path $OutputPath $($CertificateName+".pfx")
  $provider = "Microsoft Enhanced RSA and AES Cryptographic Provider"
  $certPath = "Cert:\CurrentUser\My"
  $notBeforeDate = Get-Date -Format "yyyy-MM-dd"
  $notAfterDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
  New-SelfSignedCertificate -NotBefore $notBeforeDate -NotAfter $notAfterDate -DnsName $DnsName -CertStoreLocation $certPath -Provider $provider -KeyExportPolicy ExportableEncrypted | Export-PfxCertificate -FilePath $NewPfxFilePath -Password $securePassword | Out-Null
  $ExistingPfxFilePath = $NewPfxFilePath
}

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

