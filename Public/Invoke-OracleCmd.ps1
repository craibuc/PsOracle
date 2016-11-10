<#
.SUMMARY

.PARAMETER Query
The SQL statement to be executed.

.PARAMETER ServerInstance
The server's name or SID.

.PARAMETER Username
The user account.

.PARAMETER Password
The account's Password.

.EXAMPLE
# Execute query; allow function to prompt for password
PS> Invoke-OracleCmd -Query 'SELECT sysdate FROM dual' -ServerInstance 'PROD' -Username 'SCOTT'
Password: ******

SYSDATE
-------
11/1/2016 4:02:32 PM

#>
function Invoke-OracleCmd {

    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [string]$Query,

        # [Parameter(Position=1,Mandatory=$true)]
        [string]$ServerInstance = $PSCmdlet.SessionState.PSVariable.Get('ServerInstance').Value,

        # [Parameter(Position=2,Mandatory=$true)]
        [string]$Username = $PSCmdlet.SessionState.PSVariable.Get('Username').Value,

        # [Parameter(Position=3,Mandatory=$true)]
        [SecureString]$Password = $PSCmdlet.SessionState.PSVariable.Get('Password').Value

    )

    BEGIN {
        Write-Debug "BEGIN"

        $temp = $ErrorActionPreference  # save setting
        # $ErrorActionPreference = "Stop" # make all errors terminating

        #
        # store credentials in session variable
        #

        # ServerInstance
        if (!$PSCmdlet.SessionState.PSVariable.Get('ServerInstance') -And !$ServerInstance) {
            $ServerInstance = Read-Host "ServerInstance"
        }

        if ($ServerInstance) {
            $PSCmdlet.SessionState.PSVariable.Set('ServerInstance',$ServerInstance)
        }

        # Username
        if (!$PSCmdlet.SessionState.PSVariable.Get('Username') -And !$Username) {
            $Username = Read-Host "Username"
        }

        if ($Username) {
            $PSCmdlet.SessionState.PSVariable.Set('Username',$Username)
        }

        # Password
        if (!$PSCmdlet.SessionState.PSVariable.Get('Password') -And !$Password) {
            $Password = Read-Host "Password" -AsSecureString
        }

        if ($Password) {
            $PSCmdlet.SessionState.PSVariable.Set('Password',$Password)

            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
            $PlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        }

        # if ($Password) {
        #     $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        #     $PlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        # }

        $connectionString = "Data Source=$ServerInstance;User Id=$Username;Password=$PlainText;Integrated Security=no"
        Write-Debug $connectionString

        # load assembly
        [System.Reflection.Assembly]::LoadWithPartialName("System.Data.OracleClient") | Out-Null
        # [Reflection.Assembly]::LoadWithPartialName('Oracle.DataAccess') # | Out-Null

        try {
            Write-Verbose "Connecting to $ServerInstance"
            $connection = New-Object System.Data.OracleClient.OracleConnection($connectionString)
            $connection.Open()
            # $connection = New-Object Oracle.DataAccess.Client.OracleConnection($connectionString)
            # $connection.Open()
        }
        catch [System.Data.OracleClient.OracleException] {

            $message = "$( $_.Exception.Message.Substring(0,$_.Exception.Message.Length-1) ) [$($_.Exception.Code)]"
            Write-Host $message

            switch ( $_.Exception.Code ) {
                # {$_ -In 1005,1017 } {
                #     # Write-Error -Message "Invalid credentials`n" -Exception $_ -ErrorId $ex.Exception.Code -Category AuthenticationError -TargetObject $connection
                #     Throw 'Invalid credentials'
                # }
                # {$_ -In 12560,12154} {
                #     # Write-Error  -Message "Invalid server`n" -Exception $_ -ErrorId $ex.Exception.Code -Category ConnectionError -TargetObject $connection
                #     Throw 'Invalid server'
                # }
                default {
                    Write-Error  -Message $message -Exception $_ -ErrorId $_.Exception.Code -Category NotSpecified -TargetObject $connection
                    # Throw $_.Exception
                }
            }

        }
        catch {
            Write-Error  -Message $_.Exception.Message -Exception $_ -ErrorId $_.Exception.Code -Category NotSpecified -TargetObject $connection
        }
        finally {
            $ErrorActionPreference = $temp  # restore setting
        }
    }
    PROCESS {
        Write-Debug "PROCESS"

        try {
            # $ErrorActionPreference = "Stop"; #Make all errors terminating

            Write-Verbose "Executing $Query"
            $command = New-Object System.Data.OracleClient.OracleCommand($query, $connection)
            # $command = New-Object Oracle.DataAccess.Client.OracleCommand($Query,$connection)

            Write-Verbose "Filling DataSet"
            $dataSet = New-Object System.Data.DataSet
            (New-Object System.Data.OracleClient.OracleDataAdapter($command)).Fill($dataSet) | Out-Null
            # (New-Object Oracle.DataAccess.Client.OracleDataAdapter($command)).Fill($dataSet) | Out-Null

            # return the results
            $dataSet.Tables[0]

        }
        # catch [System.Management.Automation.PSArgumentException] { write-debug 'foobarbaz'}
        catch {
            Write-Error $_.Exception
            # Write-Host $_.Exception.GetType()
            # Write-Host $_.CategoryInfo.Category

            # switch ($_.CategoryInfo.Category) {
            #     ([System.Management.Automation.ErrorCategory]::InvalidType) {Write-Debug "InvalidType"}
            #     ([System.Management.Automation.ErrorCategory]::InvalidOperation) {Write-Debug "InvalidOperation"}
            #     default { write-debug "Category: $($_)" }
            # }
            # write-host "Failure (Error:"  $_.Exception.Message ")"
            # write-host "Failure (Error:"  $_.CategoryInfo ")"
            # write-host $_
            # Throw

        }
        finally {}
    }
    END {
        Write-Debug "END"

        if ( $Connection ) {
            $Connection.Close()
            $Connection.Dispose()
        }

        # $ErrorActionPreference = $temp; #Reset the error action pref to default
    }

}

Set-Alias oracle Invoke-OracleCmd
