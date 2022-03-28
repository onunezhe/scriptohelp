<#
.Synopsis
   Common functions that helps daily tasks on SysAdmin
.FUNCTIONALITY
   Reset-VirtualTerminalServer                      #Only works directly on RDS GATEWAY
   Get-GroupedProcesses                             #Get CPU-RAM-NumberProcess-Process-Server array withing array of Hosts
   Calculate-DiskExpansion -freeGB x -totalGB y     #Calculate necessary disk expansion physical and virtual (calculates on Windows Format)
.NOTES
   File Name  : adminHelper.ps1 
   Author     : Óscar Núñez - net.oscar.nunez@outlook.com
   Requires   : PowerShell V5.1
   Appears in -full  
.EXAMPLE
   Example of how to use this cmdlet
#>

#@@@ FUNCTIONS @@@#

Function Reset-VirtualTerminalServer{
    # Get all servers on MARLEX collection
    $Connections    = Get-RDSessionHost MARLEX 
    # For each server found then
    ForEach ($Conn in $Connections) {
        Write-Host "$($Conn.SessionHost) -> ON and Started Restarting"
        If ($Conn.NewConnectionAllowed -eq "Yes") {
            Set-RDSessionHost -SessionHost $Conn.SessionHost -NewConnectionAllowed "No"
            #Restart-Computer $Conn.SessionHost -Force
            }
        Sleep -Milliseconds 250
    }
}

Function Get-GroupedProcesses{
    param(
        [string]$procsearch = "*"
    )

    # Get Credentials for remote execution
    $cred = (Get-Credential)

    # Load all TSV into array to check load
    $servers = @('TSV4','TSV5','TSV6','TSV7','TSV8','TSV9','TSV10','TSV11','TSV12','TSV17','TSV18','TSV19')
    
    $procs = @()

    # For Each Server into array
    ForEach ($server in $servers){
        Write-Output "Collecting $server Data"
        # Prepare properties to get saved
        $properties=@(
            @{Name="TSV"; Expression = {($server)}},
            @{Name="Process Name"; Expression = {($_.name).split("#")[0]}},
            @{Name="CPU (%)"; Expression = {$_.PercentProcessorTime}},    
            @{Name="Memory (MB)"; Expression = {[Math]::Round(($_.workingSetPrivate / 1mb),2)}}
        )

        # Get processes for specified server from array
        $proc = Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -Credential $cred -ComputerName $server | Select-Object $properties 

        # Get processes and group by resources
        $proc = $proc | Group-Object "Process Name" | %{
            New-Object psobject -Property @{
                TSV     =  $server
                Process =  $_.Name
                NumberProcess = ($_.Group | Measure-Object "CPU (%)" -Sum).Count
                CPU     = ($_.Group | Measure-Object "CPU (%)" -Sum).Sum
                RAM     = ($_.Group | Measure-Object "Memory (MB)" -Sum).Sum
            }
        } | Sort-Object CPU -Descending
        $procs += $proc
    }

    # If filtered then show all/only selected resources
    If($procsearch = "*"){
        return $procs
    } Else{
        return $procs | ?{$_.Process -like "*$procsearch*"}
    }
}

Function Calculate-DiskExpansion {
    Param(
        [int]$freeGB,
        [int]$totalGB
    )
    $log = "Everything seems Ok"

    # Check if necessary parameters exists
    If($freeGB -and $totalGB){
        $currentGB = $totalGB - $freeGB
        
        $diskVCenterResize = $currentGB * 1.3
        $diskWindowsResize = (($currentGB * 0.15) - $freeGB) * 1024


        # Check if VCenter must modify size
        If($diskWindowsResize -ge $totalGB) {
            $log = "vCenter: " + $diskVCenterResize + "GB $($needVCResize). Check if should be resized.`n"
        }
        # Check if Windows must modify size
        If($diskWindowsResize -gt 0){
            $log += "+$($diskWindowsResize)MB on Windows. Must be resized."
        }

    } Else {
        $log = "Incorrect or missing values."
    }
    return $log
}