## Install Modules
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
Import-Module ServerManager
Install-WindowsFeature -Name RSAT-AD-PowerShell


## Get all wind
Import-Module ActiveDirectory
$Computers = (get-adcomputer -filter {operatingsystem -like "*server*"}).name

$ErrorActionPreference = "SilentlyContinue"
$Report = @()
foreach ($Computer in $Computers)
{
	write-output "Processing - $Computer"
    if (test-connection $Computer -quiet -count 1)
    {
        #Computer is online
        $path = "\\" + $Computer + "\c$\Windows\System32\Tasks"
        $tasks = Get-ChildItem -recurse -Path $path -File
        foreach ($task in $tasks)
        {
            $Details = "" | select ComputerName, Task, User, Enabled, Application
            $AbsolutePath = $task.directory.fullname + "\" + $task.Name
            $TaskInfo = [xml](Get-Content $AbsolutePath)
            $Details.ComputerName = $Computer
            $Details.Task = $task.name
            $Details.User = $TaskInfo.task.principals.principal.userid
            $Details.Enabled = $TaskInfo.task.settings.enabled
            $Details.Application = $TaskInfo.task.actions.exec.command
            $Details
            $Report += $Details
        }
    }
    else
    {
        #Computer is offline
    }
}
$Report | ft