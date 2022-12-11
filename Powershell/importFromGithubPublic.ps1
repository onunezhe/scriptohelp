<#
.Synopsis
   Import script from GitHub if it's public
.FUNCTIONALITY
   Can import Public GitHub code without downloading it. Allways get updated. Only depens if repo is Public.
.NOTES
   General notes
   Additional Notes, eg 
   File Name  : importFromGithubPublic.ps1 
   Author     : Óscar Núñez - net.oscar.nunez@outlook.com
   Requires   : PowerShell V5
   Appears in -full  
.OUTPUTS
   Output from this cmdlet (if any)
.PARAMETER <custom>
	Parameter <custom> accepts only <k> for K value, <y> for Y value
.EXAMPLE
   Example of how to use this cmdlet
#>

Function getCode ($url) {
    # Download HTML Font
    $webreq = Invoke-WebRequest $url
    
    # Get Raw HTML and split from newLine
    $scriptContent = $webreq.ParsedHtml.body.innerText.Split([Environment]::NewLine)
    
    # Every Raw HTML from Public GitHub Code uses following line. Search it and get it's line (start script)
    $startSearch="Open with Desktop View raw View blame"
    $startLineNumber= ($scriptContent | select-string $startSearch).LineNumber -1
    
    # Every Raw HTML from Public GitHub Code uses following line. Search it and get it's line (end script)
    $endSearch="View git blame"
    $endLineNumber= ($scriptContent | select-string $endSearch).LineNumber -6
    
    $count  = 0
    $script = ""
    ForEach ($arrValue in $startLineNumber..$endLineNumber){ 
      # Start-line must be removed because it's not part from script
      If ($count -eq 0) {
        $script = $script + $scriptContent[$arrValue].Replace($startSearch,"") + "`n"
      } Else { $script = $script + $scriptContent[$arrValue] + "`n" }
      $count = $count++
    }
    return [scriptblock]::Create($script)
}


$scriptBlock = getCode("https://github.com/onunezhe/scriptohelp/blob/main/Powershell/MSSQL.ps1")
Invoke-Command -ScriptBlock $scriptBlock
$res = doQuery -dbIdentity (Get-Credential) -dbServer "BI.girona.marlex.es" -dbQuery "SELECT GETDATE() todayDate" -dbName "MARLEX_BI"
$res
