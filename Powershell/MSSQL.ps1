<#
.Synopsis
   Execute sql server query using Domain user
.NOTES
   Additional Notes, eg 
   File Name  : MSSQL.ps1 
   Author     : Óscar Núñez - net.oscar.nunez@outlook.com>
   Requires   : PowerShell V5
   Appears in -full  
.EXAMPLE
   doQuery -dbIdentity (Get-Credential) -dbQuery "SELECT GETDATE()" -dbName "database_name" -dbServer "servername.domain.com"
#>

# Functions
Function doQuery (){
    param(
            $dbServer,
            $dbIdentity,
            $dbQuery,
            $dbName
        )

  $sqlusername    = $dbIdentity[0]
	$sqlpassword    = $dbIdentity[1]
	
  # Set Object to Return
    $array = [System.Collections.ArrayList]::new() 

  # Open SQL Connection
    $connSS = "Server=$dbServer;Database=$dbName;UID=$sqlusername;PWD=$sqlpassword;Integrated Security=true;"
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = $connSS
    $SqlConnection.Open()

  # Prepare Query
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $dbQuery

    $SqlCmd.Connection = $SqlConnection
    $reader = $SqlCmd.ExecuteReader()

  # Read the result of reader
    while ($reader.Read())
    {
        $x = New-Object -TypeName PSObject
        for ($i = 0; $i -lt $reader.FieldCount; ++$i)
        {
		    $x | Add-Member -Type NoteProperty -Name $reader.GetName($i) -Value $reader[$i]
	    }
        $array += $x
    }
    
  # Close connection once done
    $SqlConnection.Close()

  # Return SQL Result inside objarray *PSObject
    return $array
}