


# Connect into Microsoft On-Line service
Connect-MsolService

Function Download-ExchangeGroupMembers {
    # Get all groups
    $groups = Get-MsolGroup

    # Prepare Headers
    $arrayGroups       = "DisplayName;EmailAddress;GroupType;ProxyAddresses" + "`n"
    $arrayGroupMembers = "GroupEmailAddress;MemberType;MemberEmailAddress;MemberDisplayName" + "`n"
    
    # Counter to calculate Progress
    $count = 0
    
    ForEach ($group in $groups) {
    
        # Progress activity
        Write-Progress -Activity "Getting members from Microsoft Exchange On-Line" -Status "$count / $($groups.Count) Complete:      $($group.EmailAddress)" -PercentComplete ($count*100/($groups.Count))
        
        # Save Groups
        $arrayGroups = $arrayGroups + "$($group.DisplayName);$($group.EmailAddress);$($group.GroupType);$($group.ProxyAddresses)" + "`n"
        
        # Get Members of current group
        $members =  Get-MsolGroupMember -GroupObjectId  $group.ObjectId.ToString()
        ForEach ($member in $members) {
            # Save Members
            $arrayGroupMembers = $arrayGroupMembers + "$($group.EmailAddress);$($member.GroupMemberType);$($member.EmailAddress);$($member.DisplayName)" + "`n"
        }
        $count = $count + 1
    }
    return $arrayGroups,$arrayGroupMembers
}




