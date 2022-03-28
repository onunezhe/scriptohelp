# Pre-config
# Install-Module MSOnline




Function Download-ExchangeGroupMembers {
    # Connect into Microsoft On-Line service
    Connect-MsolService

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

Function Get-OWASignatures {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet("SignatureText", "SignatureHTML", "ValidateSignature")]
        [string]
        $output 
    )

    # Get secure credentials
    $Credentials = Get-Credential
    # Connect to Microsoft Exchange OWA
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credentials -Authentication Basic -AllowRedirection
    # Import session to get all commands from OWA
    Import-PSSession $Session -DisableNameChecking

    # Get all mailbox created
    $mailboxes = Get-Mailbox -RecipientTypeDetails UserMailbox

    # Get Ready Value 2 return
    $arrSignature = @()

    # Loop all signatures (depens parameter) /*Under Work*/
    Switch ($output){
        'SignatureText' {
            $mailboxes | Get-MailboxMessageConfiguration | select Identity,Signature* | Format-List
        }
        'SignatureHTML' {
            
        }
        'ValidateSignature' {
            ForEach ($mail in $mailboxes){
                $mailAdress = $mail.PrimarySmtpAddress
                $mailSignatureHTML = ($mailboxes[0] | Get-MailboxMessageConfiguration).SignatureHtml
                
            }
        }
    }

    
}