# Get rid of certs in Machine personal store, based on ISSUER thumbprint.

$issuerThumbprints = @(
    "e8bdc647a30df8380fa0243a3425612de629a86e",
    "31f7f7a67454e693675dbd57aa141c7e4498a292",
    "1414ba96d1639f22bc76d483f7cd4ac253a84fec",
    "d05a530070dabc487f5df8d3b0f7b917551d8847"
)


Function Test-IssuerThumbprint([System.Security.Cryptography.X509Certificates.X509Certificate2]$Cert,[string]$thumbprint){
    # Build Certificate Chain from supplied Cert
    $certChain = [System.Security.Cryptography.X509Certificates.X509Chain]::new()
    $chainBuilt = $certChain.Build($cert)

    if ($chainBuilt){
        # If a cert has a chain, test all, intermediates included:
        #$certsMatchingThumbprint = $certChain.ChainElements.Certificate | Where-Object {$_.Thumbprint.ToLower() -eq $thumbprint.ToLower()}
        foreach ($link in $certChain.ChainElements.Certificate){
            If ($link.Thumbprint.ToLower() -eq $thumbprint.ToLower()) {
                return $true
            }
        }
    } else {
        # Not a cert with a chain, may be a CA Cert or one of those MS certs, but we don't care if it is - we'd want to leave it alone:
        return $false
    }
}

# Get all Certs out of local personal store:
$localcerts = get-item "cert:\LocalMachine\My\*"

# Loop and test for offending issuers:
foreach ($localcert in $localcerts) {
    # Reset variable:
    $shouldBeDeleted = $false

    # Test each for all thumbprints:
    foreach ($print in $issuerThumbprints){
        if (Test-IssuerThumbprint -cert $localcert -thumbprint $print){$shouldBeDeleted = $true}
    }

    if ($shouldBeDeleted) {
        # Delete by thumbprint
            write-host "* Would have deleted $($localcert.subject)"
            #Get-ChildItem "Cert:\LocalMachine\My\$($localcert.thumbprint)" | Remove-Item -DeleteKey
    }
}


