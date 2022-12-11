<#
.Synopsis
   Close all profiles from RDP Gateway to RDP Host
.FUNCTIONALITY
   Only need to call script with one argument (collection). Can be comma separated. Recommended create event task on RDP Gateway directly
.NOTES
   File Name  : CloseRDPSessions.ps1 
   Author     : Óscar Núñez Hernández - net.oscar.nunez@outlook.com
   Requires   : PowerShell V5.1
   Appears in -full  
.ROLE
   The role this cmdlet belongs to SysAdmin
.PARAMETER -Collection
	Parameter Collection accepts only string value that specify collection name from RDP Gateway
.EXAMPLE
   ./CloseRDPSession.ps1 -Collection <collectionName>[,<collectionName>]
#>

# MARLEX COLLECTIONS -> MARLEX,MARLEXTEST
Param(
    [Parameter(Mandatory=$true)]
    [string]$inputCollections
)

# If wants to delete all sessions and not specific sessions on collection, $Sessions get all hosts connected to RDP Gateway
##$Sessions = (Get-RDUserSession).HostServer | Sort | Get-Unique -AsString

# Custom Path to save Logs
$logPath   = "C:\Scripts\automate_schedule_reboot\CloseRDPSessions.log"
$logString = ""

# Get All Collections
$GWCollections = Get-RDSessionCollection

ForEach ($Collection in $inputCollections.Split(",")){
    # If Collection exists between collections then
    If($Collection -in $GWCollections.CollectionName){
        $logString += "Collection $Collection found. Getting RDP Hosts configured`n" 

        # Get Hosts into collection
        $Connections = Get-RDSessionHost $Collection

        # Loop each RDP Host
        ForEach ($Conn in $Connections.SessionHost) {
            # Force user desconnections for all RDP Host in specific collection
            Get-RDUserSession | Invoke-RDUserLogoff -HostServer $Conn -Force
            If($?){
                $logString += "--> INFO:  $Conn users disconnected successfully`n" 
            } Else {
                $logString += "--> ERROR: $Conn failed user disconnection`n" 
            }
        }

    # If Collection not exists
    } Else {
        $logString += "Collection $Collection not found. Exiting..`n" 
    }

    # Sleep 30 seconds between RDP Hosts
    Start-Sleep -Seconds 30
}
$logString += "#################################################################`n"

# Close SMB connections on RDP Gateway. Will left clean RDP Gateway and Hosts
Get-SmbOpenFile | Close-SmbOpenFile -Force
If($?){
    $logString += "INFO:  RDP Gateway SMB sessions disconnected successfully"
} Else {
    $logString += "ERROR: RDP Gateway SMB sessions failed disconnection"
}

# Save log execution into logpath
Write-Output $logString > $logPath