<#
.Synopsis
   Library of functions that contains Teams Cloud utilities
.DESCRIPTION
   Contains Teams Cloud utilities to easy export/set/delete data. Some functions require install MicrosoftTeams Module
.FUNCTIONALITY
   Contains following Functions:
   Get-CsQueuesFTUsers              ## Get all users joined with its Call Queue and return result as CSV
   Remove-CsUsersOfflineFromQueues  ## Remove all users not licensed from all queues under Teams Cloud
.NOTES
   Developed by
   File Name  : TeamsOnline.ps1 
   Author     : Óscar Núñez Hernández - net.oscar.nunez@outlook.com
   Requires   : PowerShell V5.1.22000.282
.COMPONENT
   Needs MicrosoftTeams
.ROLE
   The role this cmdlet belongs to
.INPUTS
   No imputs required
.OUTPUTS
   Depends on each function
.PARAMETER <custom>
   Depends on each function
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>

Function Remove-CsUsersOfflineFromQueues {
    # Import & connect to Microsoft Teams
    Import-Module MicrosoftTeams
    Connect-MicrosoftTeams

    # Collect Microsoft On-line Data
    $Users  = Get-CSOnlineUser
    $Queues = Get-CSCallQueue

    # Get users Off-line (without license / with DNI)
    $UsersOffline = @()
    
    ForEach ($user in $users){
        If($user.UserPrincipalName.Split("@")[0] -match "^[0-9XYZ]{1}[0-9]{7}[a-zA-Z]{1}$"){
            $UsersOffLine += $($user | Select-Object ObjectId,DisplayName,LineUri,UserRoutingGroupId,UserPrincipalName,InterpretedUserType)
        } ElseIf($user.InterpretedUserType -match "NotLicensed"){
            $UsersOffLine += $($user | Select-Object ObjectId,DisplayName,LineUri,UserRoutingGroupId,UserPrincipalName,InterpretedUserType)
        }
    }

    # Get Queues -> UnSet off-line user
    ForEach ($queue in $queues) {
        $usersBefore = $queue.Users.Count
        If ($queue.Users.Count -ne 0){
            Write-Host "Before -> $($queue.Users.Count)"
            ForEach($quser in $queue.Users.Guid){
                $found = $UsersOffLine.ObjectId.Guid.IndexOf($quser)
                $userFound = $UsersOffLine[$UsersOffLine.ObjectId.Guid.IndexOf($quser)]

                If ($found -ne -1){
                    Write-Host "Found $($quser)"
                    # Delete Users Found without license From Queues to set Later
                    #$queue.Users.RemoveAt($queue.Users.Guid.IndexOf($quser))
                    Write-Host "Removed $($userFound.UserPrincipalName)..."
                }
            }
            Write-Host "After -> $($queue.Users.Count)"
        }
        $usersAfter = $queue.Users.Count

        If ($usersBefore -ne $usersAfter){
            # Set Users Array without any user not licensed
            #Set-CSCallQueue -Identity $queue.Identity -Users $queue.Users.Guid
        }

    }

}

Function Get-CsQueuesFTUsers {
    # Import & connect to Microsoft Teams
    Import-Module MicrosoftTeams
    Connect-MicrosoftTeams
    $prcCountTasks  = 3
    $prcCurrentTask = 0

    # Collect Microsoft On-line Data    
    Write-Progress -Id 0 -Activity "Collect Microsoft Users" -Status "$prcCurrentTask/$prcCountTasks" -PercentComplete (($prcCurrentTask/$prcCountTasks)*100); $prcCurrentTask += 1
    $Users  = Get-CSOnlineUser
    Write-Progress -Id 0 -Activity "Collect Microsoft Queues" -Status "$prcCurrentTask/$prcCountTasks" -PercentComplete (($prcCurrentTask/$prcCountTasks)*100); $prcCurrentTask += 1
    $Queues = Get-CSCallQueue
    #Get-CsOnlineApplicationInstanceAssociation

    # Collect Data
    $result += $header
    $header = "queueName;queueDDI;userName;userDDI;userLicensed"
    $result = @()

    Write-Progress -Id 0 -Activity "Processing CallQueues Data" -Status "$prcCurrentTask/$prcCountTasks" -PercentComplete (($prcCurrentTask/$prcCountTasks)*100); $prcCurrentTask += 1
    $currentQueue = 0
    ForEach ($queue in $queues) {
        Write-Progress -Id 1 -Activity "Getting Queue Info" -Status "$currentQueue/$($Queues.Count)" -PercentComplete (($currentQueue/$($Queues.Count))/100); $currentQueue += 1

        # Join Information
        $queueInstance = $queue.ApplicationInstances
        $queueInstanceInformation = Get-CsOnlineApplicationInstance -Identity $queueInstance

        # Data to Export
        $queueName   = $queue.Name
        #$queueAgents = $queue.Users.Count #Show number of Agents assigned to CallQueue
        $queueDDI    = $queueInstanceInformation.PhoneNumber

        # If Queue not empty then
        If ($queue.Users.Count -ne 0){
            ForEach($quser in $queue.Users.Guid){
                $foundUser          = $Users[$Users.ObjectId.Guid.IndexOf($quser)]
                $userName           = $foundUser.WindowsEmailAddress
                $userOnPremLineURI  = $foundUser.OnPremLineURI
                $userLineURI        = $foundUser.LineURI
                $userDDI            = If ($userOnPremLineURI) {$userOnPremLineURI} Else {$userLineURI}
                $userDDI            = $userDDI.ToLower().Replace("tel:+","")
                $userLicensed       = $foundUser.InterpretedUserType -match "NotLicensed"
                $result += "$queueName;$queueDDI;$userName;$userDDI;$userLicensed"
            }

        } # If Queue empty then
        Else {
            Write-Host "$queueName;$queueDDI;NULL;NULL;NULL"
        }
    }
    
    return $result
}