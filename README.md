# `scriptohelp`
Repository based on different languages to import as library or module. Using different scripting lang.

# `PowerShell`
ATTENTION: Basic use to execute some commands on powershell
- Executes a script without changing local policy

    `PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command ".\defaultStructure.ps1"`

- Changes current policy to avoid warning about executions

    `PowerShell.exe -ExecutionPolicy Bypass`


Contains functions done usint Powershell V5. Current work:
- `./Powershell/MSSQL.ps1` -> Have functions to execute queries into SQL Server and instrucions to use it.

# `Python2.7`
Contains functions done using Python 2.7. Current work:
- `./Python2.7/MSSQL.py` -> Have functions to execute queries into SQL Server and instructions to use it.
