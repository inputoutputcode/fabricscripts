$ErrorActionPreference = "Stop";

function Invoke-AddCertToKeyVaultAsSecret
{
<#
.SYNOPSIS
Upload certificate to Azure KeyVault

.DESCRIPTION
This command takes an existing pfx or creates a new self-signed certificate and uploads it as a secret to Azure KeyVault. The output of this command should be used during creation of secure cluster
through portal or for adding new certificates on VMs provisioned by Compute Resource Provider

.PARAMETER
.PARAMETER
.INPUTS
.OUTPUTS
.EXAMPLE
.EXAMPLE
.LINK
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

Write-Host "Switching context to SubscriptionId $SubscriptionId"
#Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

# New-AzResourceGroup is idempotent as long as the location matches
Write-Host "Ensuring ResourceGroup $ResourceGroupName in $Location"
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force | Out-Null
$resourceId = $null

try
{
    $existingKeyVault = Get-AzKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroupName
    $resourceId = $existingKeyVault.ResourceId

    Write-Host "Using existing valut $VaultName in $($existingKeyVault.Location)"
}
catch
{
}

if(!$existingKeyVault)
{
    Write-Host "Creating new vault $VaultName in $location"
    $newKeyVault = New-AzKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroupName -Location $Location -EnabledForDeployment
    $resourceId = $newKeyVault.ResourceId
}

if($CreateSelfSignedCertificate)
{
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

    $NewPfxFilePath = Join-Path $OutputPath $($CertificateName+".pfx")

    Write-Host "Creating new self signed certificate at $NewPfxFilePath"
    
    ## Changes to PSPKI version 3.2.5 New-SelfSignedCertificate replaced by New-SelfSignedCertificateEx
    ## 1.0.0.0    PKI 
    $PspkiVersion = (Get-Module PSPKI).Version
    if($PSPKIVersion.Major -ieq 3 -And $PspkiVersion.Minor -ieq 2 -And $PspkiVersion.Build -ieq 7) {
        New-SelfsignedCertificateEx -Subject "CN=$DnsName" -EKU "Server Authentication", "Client authentication" -KeyUsage "KeyEncipherment, DigitalSignature" -Path $NewPfxFilePath -Password $securePassword -Exportable
    }
    else {
        $provider = "Microsoft Enhanced RSA and AES Cryptographic Provider"
        $certPath = "Cert:\CurrentUser\My"

        New-SelfSignedCertificate -CertStoreLocation $certPath -DnsName $DnsName | Export-PfxCertificate -FilePath $NewPfxFilePath -Password $securePassword | Out-Null
    	##New-SelfSignedCertificate -NotBefore '' -NotAfter '' -DnsName -CertStoreLocation Cert:\LocalMachine\My -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -KeyExportPolicy ExportableEncrypted -Type Custom -Subject ""
}

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

Write-Host "Writing secret to $CertificateName in vault $VaultName"
$secret = Set-AzureKeyVaultSecret -VaultName $VaultName -Name $CertificateName -SecretValue $secretValue

$output = @{};
$output.SourceVault = $resourceId;
$output.CertificateURL = $secret.Id;
$output.CertificateThumbprint = $cert.Thumbprint;

return $output;
}

function Invoke-AddCertToKeyVaultAsCert
{
<#
.SYNOPSIS
Upload certificate to Azure KeyVault

.DESCRIPTION
This command takes an existing pfx or creates a new self-signed certificate and uploads it as a secret to Azure KeyVault. The output of this command should be used during creation of secure cluster
through portal or for adding new certificates on VMs provisioned by Compute Resource Provider

.PARAMETER
.PARAMETER
.INPUTS
.OUTPUTS
.EXAMPLE
.EXAMPLE
.LINK
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

Write-Host "Switching context to SubscriptionId $SubscriptionId"
#Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

# New-AzResourceGroup is idempotent as long as the location matches
Write-Host "Ensuring ResourceGroup $ResourceGroupName in $Location"
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force | Out-Null
$resourceId = $null

try
{
    $existingKeyVault = Get-AzKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroupName
    $resourceId = $existingKeyVault.ResourceId

    Write-Host "Using existing valut $VaultName in $($existingKeyVault.Location)"
}
catch
{
}

if(!$existingKeyVault)
{
    Write-Host "Creating new vault $VaultName in $location"
    $newKeyVault = New-AzKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroupName -Location $Location -EnabledForDeployment
    $resourceId = $newKeyVault.ResourceId
}

if($CreateSelfSignedCertificate)
{
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

    $NewPfxFilePath = Join-Path $OutputPath $($CertificateName+".pfx")

    Write-Host "Creating new self signed certificate at $NewPfxFilePath"
    
    ## Changes to PSPKI version 3.5.2 New-SelfSignedCertificate replaced by New-SelfSignedCertificateEx
    $PspkiVersion = (Get-Module PSPKI).Version
    if($PSPKIVersion.Major -ieq 3 -And $PspkiVersion.Minor -ieq 2 -And $PspkiVersion.Build -ieq 5) {
        New-SelfsignedCertificateEx -Subject "CN=$DnsName" -EKU "Server Authentication", "Client authentication" -KeyUsage "KeyEncipherment, DigitalSignature" -Path $NewPfxFilePath -Password $securePassword -Exportable
    }
    else {
        New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -DnsName $DnsName | Export-PfxCertificate -FilePath $NewPfxFilePath -Password $securePassword | Out-Null
    }

    $ExistingPfxFilePath = $NewPfxFilePath
}

$cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 $ExistingPfxFilePath, $Password
$passwordSecureValue = ConvertTo-SecureString -String $Password -AsPlainText -Force

Write-Host "Import $CertificateName in vault $VaultName"
$certResult = Import-AzureKeyVaultCertificate -VaultName $VaultName -Name $CertificateName -FilePath $ExistingPfxFilePath -Password $passwordSecureValue 

$output = @{};
$output.CertificateThumbprint = $cert.Thumbprint;
$output.CertificateURL = $certResult.Id;

return $output;
}

Export-ModuleMember -Function Invoke-AddCertToKeyVaultAsSecret
Export-ModuleMember -Function Invoke-AddCertToKeyVaultAsCert
