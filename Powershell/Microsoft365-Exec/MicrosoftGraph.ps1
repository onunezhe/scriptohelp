




Function Get-MgRecordInformation {
    # Import & connect to Microsoft Graph
    Import-Module Microsoft.Graph.CloudCommunications
    Connect-Graph
    $prcCountTasks  = 3
    $prcCurrentTask = 0

}


# client 98d0a364-a0af-4af4-96ea-d992181b4dc0
# object 4e4ddebd-d259-4bac-91fb-78ade7ede968
# inquilino b1035c3e-d11b-48e5-a19f-bc91d6a4ad80

# secret (24meses)
# secret id:    a54d21f5-2616-422e-8d45-33292ee30bf6
# secret value: vtB7Q~VAxflVgNtrkr02Km1mDtWYZal9agwtb


Connect-MgGraph -ClientID 98d0a364-a0af-4af4-96ea-d992181b4dc0 -TenantId b1035c3e-d11b-48e5-a19f-bc91d6a4ad80

 -CertificateName YOUR_CERT_SUBJECT ## Or -CertificateThumbprint instead of -CertificateName
