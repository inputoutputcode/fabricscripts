function Get-CertificateEKUProperty {
    [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [Security.Cryptography.X509Certificates.X509Certificate2]$Cert
        )
    $signature = @"[DllImport("Crypt32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern bool CertGetCertificateContextProperty(
        IntPtr pCertContext,
        uint dwPropId,
        Byte[] pvData,
        ref uint pcbData
    );
    "@

        Add-Type -MemberDefinition $signature -Namespace PKI -Name Crypt32
        # check if X509Certificate2 object is not empty
        if (!$Cert.Equals([IntPtr]::Zero)) {
            $pcbData = 0
            # if the function returns True, then certificate purposes are either disabled or constrained
            # otherwise (False) valid purposes are determined by certificate's EKU
            if ([PKI.Crypt32]::CertGetCertificateContextProperty($Cert.Handle,0x9,$null,[ref]$pcbData)) {
                # create a buffer for ASN.1 encoded byte array
                $pvData = New-Object byte[] -ArgumentList $pcbData
                # call the function again to write actual data
                [void][PKI.Crypt32]::CertGetCertificateContextProperty($Cert.Handle,0x9,$pvData,[ref]$pcbData)
                # instantiate AsnEncodedData object with ASN.1 encoded byte array
                $asn = New-Object Security.Cryptography.AsnEncodedData (,$pvData)
                # instaintiate X509EnhancedKeyUsageExtension to retrieve OIDs in a readable form
                $eku = New-Object Security.Cryptography.X509Certificates.X509EnhancedKeyUsageExtension $asn, $false
                # if none OIDs are defined, then all certificate purposes are explicitly disabled in the properties
                if ($eku.EnhancedKeyUsages.Count -eq 0) {
                    Write-Warning "All purposes for this certificate are explicitly disabled."
                } else {
                    # return constrained OIDs
                    $eku.EnhancedKeyUsages
                }
            } else {Write-Warning "Valid purposes are determined by the certificate EKU extension."}
        } else {
            Write-Error -Category InvalidArgument -ErrorId "InvalidArgumentException" `
    
            -Message "An attempt was made to access an uninitialized object."
        }
    }
