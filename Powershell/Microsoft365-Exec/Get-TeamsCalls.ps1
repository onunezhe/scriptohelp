<#
Get all calls
Get all queues
Match queues to get agent atendee <working some times>
Only pending agent working
#>

<#
.SYNOPSIS

    Get-TeamsPSTNCallRecords.ps1 - Retrieve Microsoft Teams PSTN call records for Calling Plan and Direct Routing users

.DESCRIPTION
    Author: Lee Ford
    This tool allows you retireve PSTN call records for Calling Plan and Direct Routing users and save to a file. You can request how many days far back (from now) you wish to retrieve
.LINK
    Blog: https://www.lee-ford.co.uk
    Twitter: http://www.twitter.com/lee_ford
    LinkedIn: https://www.linkedin.com/in/lee-ford/

.EXAMPLE
    .\Get-TeamsPSTNCallRecords.ps1 -SavePath C:\Temp -Days 10 -SaveFormat JSON
    Retrieve call records for the last 10 days and save as JSON files
    .\Get-TeamsPSTNCallRecords.ps1 -SavePath C:\Temp -Days 50 -SaveFormat CSV
    Retrieve call records for the last 50 days and save as CSV files

.CREATOR
    https://github.com/leeford/Get-TeamsPSTNCallRecords
#>

# Execute on linux -> powershell Get-TeamsPSTNCallRecords.ps1 -SavePath ./ -Days 1 -SaveFormat CSV

# @@@ Necessary Params @@@ #
param (
    [Parameter(mandatory = $true)][string]$SavePath,
    [Parameter(mandatory = $true)][int]$Days,
    [Parameter(mandatory = $true)][ValidateSet("JSON", "CSV")]$SaveFormat
 )

# @@@ Necessary Modules @@@ #
#Import-Module Microsoft.Graph
 Import-Module MicrosoftTeams
 Import-Module MSAL.PS

# @@@ Credential and Connections @@@ #

# Client (application) ID, tenant (directory) ID and secret
#Graph
 $clientId = "98d0a364-a0af-4af4-96ea-d992181b4dc0"
 $tenantId = "b1035c3e-d11b-48e5-a19f-bc91d6a4ad80"
 $clientSecret = 'dxJ7Q~gR4zrokqzr31sJ176TZuQJkvJNT32iT'
#API
 $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
 $body = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type    = "client_credentials"
 }
 $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing
 $token = ($tokenRequest.Content | ConvertFrom-Json).access_token
#Powershell
# $MsalToken = Get-MsalToken -TenantId $tenantId -ClientId $clientId -ClientSecret ($clientSecret | ConvertTo-SecureString -AsPlainText -Force)
# Connect-Graph -AccessToken $MsalToken.AccessToken

#Teams
 $user = "bot.trmmanager@marlex.net"
 $pass = ConvertTo-SecureString "Fan59231" -AsPlainText -Force
 $cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($user, $pass)
 Connect-MicrosoftTeams -Credential $cred

# @@@ Necessary Functions @@@ #

function Get-Calls { #Graph
    param (
        [Parameter(mandatory = $true)][string]$type
    )

    $remainingDays = $Days

    # Set initial to date of date range to end of today/start of tomorrow
    $toDateTime = (Get-Date).AddDays(+1)

    while ($remainingDays -gt 0) {

        $totalRecords = 0

        # If remaining days is < 89 set specifically
        if ($remainingDays -lt 89) {
            $dayBatchSize = $remainingDays
        } else {
            $dayBatchSize = 89
        }

        # New remaining days based on new batch
        $remainingDays -= $dayBatchSize

        # Set from date to be minus day batch size from now
        $fromDateTime = ($toDateTime).AddDays(-$dayBatchSize)

        # Set dates to correctly formatted strings for query
        $toDateTimeString = $toDateTime | Get-Date -Format "yyyy-MM-dd"
        $fromDateTimeString = $fromDateTime | Get-Date -Format "yyyy-MM-dd"

        $currentUri = "https://graph.microsoft.com/beta/communications/callRecords/$type(fromDateTime=$fromDateTimeString,toDateTime=$toDateTimeString)"

        Write-Host "        - Checking for call records between $fromDateTimeString and $toDateTimeString..." -NoNewline

        $content += while (-not [string]::IsNullOrEmpty($currentUri)) {

            $apiCall = Invoke-RestMethod -Method "GET" -Uri $currentUri -ContentType "application/json" -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop

            $currentUri = $null

            if ($apiCall) {

                # Check if any data is left
                $currentUri = $apiCall.'@odata.nextLink'

                # Count total records so far
                $totalRecords += $apiCall.'@odata.count'

                $apiCall.value

            }

        }

        # Set the to date to start from the previous from date
        $toDateTime = $fromDateTime

        if ($totalRecords -gt 0) {
            Write-Host " Retrieved $totalRecords call records" -ForegroundColor Green
        } else {
            Write-Host " No records found" -ForegroundColor Yellow
        }


    }

    return $content

}

function Get-CallAgent { # Graph
    param (
        [Parameter(mandatory = $true)][string]$correlationID,
        [bool]$callQueue = $false
    )

    $totalRecords = 0
    $currentUri = "https://graph.microsoft.com/v1.0/communications/callRecords('$correlationId')/sessions"

    if ($callQueue) {
        $content = Invoke-RestMethod -Method "GET" -Uri $currentUri -ContentType "application/json" -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop
        $totalRecords = 1
    }

    if ($totalRecords -gt 0) {
        $agentPhoneID           = $content.value.callee.identity.phone.id
        $agentCalleeDisplayName = if($content.value.callee.identity.user.displayName) {[String]::Join('; ',($content.value.callee.identity.user.displayName))} else {$null}
        $agentModalities        = $content.value.modalities | unique
    } else {
        $agentPhoneID           = $null
        $agentCalleeDisplayName = $null
        $agentModalities        = $null
    }

    return New-Object -TypeName psobject -Property @{agentPhoneID=$agentPhoneID;agentCalleeDisplayName=$agentCalleeDisplayName;agentModalities=$agentModalities}

}

function Get-Queues { #Teams
    
    $queues = Get-CsCallQueue

    $resumeQueues = @()
    ForEach ($queue in $queues){
        $resumeQueues += New-Object -TypeName psobject -Property @{Name=$queue.Name;AppIdentity=($queue.ApplicationInstances)[0]}
    }
    
    return $resumeQueues
}

# @@@ MAIN @@@ #

#Check Days is a postive number
 if ($Days -lt 0)   { Write-Host "Please specify a valid date range (greater than 0 days)" -ForegroundColor Red; break }
 if ($Days -gt 365) { Write-Warning "Call records are typically only stored for 365 days" }

#Check Save Path exists
 if (-not (Test-Path -Path $SavePath)) { Write-Host "$SavePath does not exist, please specify a valid path" -ForegroundColor Red; break }

#Get Direct Routing calls
 Write-Host "`r`n- Retrieving PSTN call records for the last $Days days"
 Write-Host "    - Retrieving Direct Routing call records"
 $directRoutingCalls = Get-Calls -type "getDirectRoutingCalls"

pause

#Get Phones from all Call Queues
 $callQueues = Get-Queues
 $callQueuesPhones = @()

#Get only queues and phones (match Teams Query and Graph Query)
 ForEach ($dirRouCall in $directRoutingCalls){
    If( ($dirRouCall.userId -in $callQueues.appIdentity) -and -not ($dirRouCall.userId -in $callQueuesPhones.userId)){
        $callQueuesPhones += New-Object -TypeName psobject -Property @{userPrincipalName=$dirRouCall.userPrincipalName;userId=$dirRouCall.userId;phoneNumber=$dirRouCall.calleeNumber}
    }
 }
 $callQueuesPhones = $callQueuesPhones | sort

#Get Agent from all Call Queues
ForEach ($dirRouCall in $directRoutingCalls){
    $agentProperties = $null

    If( ($dirRouCall.callerNumber -in $callQueuesPhones.phoneNumber) ){
        write-host "hello"
        $agentProperties = Get-CallAgent -correlationID $dirRouCall.correlationId -callQueue $True # Collect data & Properties if Call Queue
    } Else {
        $agentProperties = Get-CallAgent -correlationID $dirRouCall.correlationId                  # Collect Properties Only (Force Null)
    }

    
    
    ForEach ($property in $($agentProperties | Get-Member -MemberType NoteProperty)){
        $directRoutingCalls[$directRoutingCalls.correlationId.IndexOf($dirRouCall.correlationId)] | Add-Member -MemberType NoteProperty -Name $property.Name -Value $agentProperties.$($property.Name) -Force
    }
    
}


# Get Calling Plan calls
Write-Host "    - Retrieving Calling Plan call records"
$callingPlanCalls = Get-Calls -type "getPstnCalls"

# Save to file
Write-Host "`r`n- Saving PSTN call records to $SaveFormat files"

if ($SaveFormat -eq "JSON") {

    if ($directRoutingCalls) {
        try {
            Write-Host "    - Saving Direct Routing call records in JSON format to $SavePath\DirectRoutingCalls.json..." -NoNewline
            $directRoutingCalls | ConvertTo-Json | Out-File -FilePath "$SavePath\DirectRoutingCalls.json"
            Write-Host " SUCCESS" -ForegroundColor Green
        }
        catch {
            Write-Host " FAILED" -ForegroundColor Red
        }
    }

    if ($callingPlanCalls) {
        try {
            Write-Host "    - Saving Calling Plan call records in JSON format to $SavePath\CallingPlanCalls.json..." -NoNewline
            $callingPlanCalls | ConvertTo-Json | Out-File -FilePath "$SavePath\CallingPlanCalls.json"
            Write-Host " SUCCESS" -ForegroundColor Green
        }
        catch {
            Write-Host " FAILED" -ForegroundColor Red
        }
    }

}
elseif ($SaveFormat -eq "CSV") {

    if ($directRoutingCalls) {
        try {
            Write-Host "    - Saving Direct Routing call records in CSV format to $SavePath\DirectRoutingCalls.csv..." -NoNewline
            $directRoutingCalls | Export-Csv -Path "$SavePath\DirectRoutingCalls.csv"
            Write-Host " SUCCESS" -ForegroundColor Green
        }
        catch {
            Write-Host " FAILED" -ForegroundColor Red
        }

    }

    if ($callingPlanCalls) {
        try {
            Write-Host "    - Saving Calling Plan call records in CSV format to $SavePath\CallingPlanCalls.csv..." -NoNewline
            $callingPlanCalls | Export-Csv -Path "$SavePath\CallingPlanCalls.csv"
            Write-Host " SUCCESS" -ForegroundColor Green
        }
        catch {
            Write-Host " FAILED" -ForegroundColor Red
        }

    }

}
