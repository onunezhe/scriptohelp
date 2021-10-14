<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.FUNCTIONALITY
   The functionality that best describes this cmdlet
.NOTES
   General notes
   Additional Notes, eg 
   File Name  : <yourfilename>.ps1 
   Author     : <Yor Name> - <yourmail@domain.com>
   Requires   : PowerShell V<versionCode>
   Appears in -full  
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.PARAMETER <custom>
	Parameter <custom> accepts only <k> for K value, <y> for Y value
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>

##Start Script

#Standar libraries

#3rd party libraries
  Import-Module MsOnline
  #Install-Module Microsoft.Online.SharePoint.PowerShell 
  #Install-Module SharePointPnPPowerShellOnline 

#Local source
  Import-Module 'C:\Users\onunez\OneDrive - EKM GROUP HUMAN CAPITAL, S.L.U\Documentos\GitHub\scriptohelp\Powershell\MSSQL.ps1'


# Connect to MSonline and SPonline
  #Get Credentials to connect
  $cred = Get-Credential
  [System.Net.WebRequest]::DefaultWebProxy.Credentials = $cred


# Connect to Intranet Site
  Connect-MsolService -Credential $cred
  Connect-SPOService -Url "https://ekmgroup-admin.sharepoint.com/" -Credential $cred

# Get Intranet Files from SharePoint
  $sites     = Get-SPOSite -Detailed
  $intrasite = $sites[($sites.url -replace ("https://ekmgroup.sharepoint.com/sites/")).IndexOf('intradrive')]
  #$intrasite = "https://ekmgroup.sharepoint.com/sites/intradrive"

  Connect-PnPOnline -Url $intrasite.URL -credentials $cred
  $Library = "Documentos%20compartidos"
  $Items   = $null
  $Items   = Get-PnPListItem -List $Library  -Query "<View Scope='RecursiveAll'><Query><Where><Eq><FieldRef Name='FSObjType' /><Value Type='Integer'>0</Value></Eq></Where><OrderBy><FieldRef Name='ID' /></OrderBy></Query></View>"


$item = $items[500]

$item | format-list


# ServerRedirectedEmbedUri -> link bueno


https://ekmgroup.sharepoint.com/:p:/s/intradrive/EQhBUvM2huVOpRVF44Sd8BABS37RNZ5DQ011RyboYfL_GA?e=EbNb0s

$ctx = $null
$ctx = Get-PnPContext  

$web = $null
$web = Get-PnPWeb 

$list = Get-PnPListItem -List $Library
$item = $list[500]

Write-host "List: " $list.Title

$ctx.Load($item)
$ctx.ExecuteQuery()

Write-host "Item: " $item.Id " // " $item["FileLeafRef"]
$itemUrl = $web.Url  + $list.RootFolder.ServerRelativeUrl + "/" + $item["FileLeafRef"]

$ctxClient = New-Object Microsoft.SharePoint.Client.ClientContext("https://ekmgroup-admin.sharepoint.com/")
$ctxClient.Credentials = $cred

$link = [Microsoft.SharePoint.Client.Web]::CreateAnonymousLink($ctxClient,$itemUrl,$false)
$ctxClient.ExecuteQuery()
Write-host "Link (view): "$link.Value

$link2 = [Microsoft.SharePoint.Client.Web]::CreateAnonymousLink($ctxClient,$itemUrl,$true)
$ctxClient.ExecuteQuery()
Write-host "Link (edit): "$link2.Value

$ctx = $null

Write-Host "End" -f Green -b DarkGreen
Write-host " "
Write-host " "













$query = "SELECT * FROM INTRANET"
$list = doQuery -dbIdentity $SQLCredentials -dbQuery $query -dbName "ANGULAR_GPI" -dbServer "BI"
$file = $list[30]











 
#sharepoint online get all site collections PowerShell
$SiteColl = Get-SPOSite
 
#sharepoint online PowerShell iterate through all site collections
ForEach($Site in $SiteColl)
{
    Write-host $Site.Url
}