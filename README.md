# PsOracle
A PowerShell module to interact with Oracle.

#Installation
- Download the most-recent [release](https://github.com/craibuc/PsOracle/releases)
- Decompress archive
- Move to C:\Users\<username>\Documents\WindowsPowerShell\Modules

# Usage

~~~PowerShell
# import the module's functions into the PowerShell session
PS> Import-Module PsOracle

# Execute query; allow function to prompt for password
PS> Invoke-OracleCmd -Query 'SELECT sysdate FROM dual' -ServerInstance 'PROD' -Username 'SCOTT'
Password: ******

SYSDATE
-------
11/1/2016 4:02:32 PM
~~~

# Personnel

- Author: Craig Buchanan
- Contributors: 