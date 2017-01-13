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
PS> Invoke-OracleCmd -Query 'SELECT sysdate FROM dual'
cmdlet Open-Connection at command pipeline position 1
Supply values for the following parameters:
ServerInstance: prod
Username: scott
Password: *******
True

SYSDATE
-------
1/13/2017 5:54:03 AM
~~~

# Personnel

- Author: Craig Buchanan
- Contributors: ?
