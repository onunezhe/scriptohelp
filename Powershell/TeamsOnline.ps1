



#### @@@ TEAMS AUTOMATION @@@ ####

# Delete Users without license from Marlex Call Queue
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

# Get all users from 
Function Get-CsQueuesFTUsers {
    # Import & connect to Microsoft Teams
    Import-Module MicrosoftTeams
    Connect-MicrosoftTeams

    # Collect Microsoft On-line Data
    $Users  = Get-CSOnlineUser
    $Queues = Get-CSCallQueue
    #Get-CsOnlineApplicationInstanceAssociation


    # Get Queues & UserName
    $header = "queueName;queueDDI;userName;userDDI;userLicensed"
    $result = @()

    # Collect Data
    $result += $header
    ForEach ($queue in $queues) {
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