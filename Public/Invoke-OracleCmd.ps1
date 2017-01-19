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
        # [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        # [string[]]$Query,
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Query,

        # TODO: handle these?
        [string]$ServerInstance,
        [string]$Username,
        [SecureString]$Password

    )

    BEGIN {
        Write-Debug "$($MyInvocation.MyCommand.Name)::BEGIN"

        # Write-Debug '---- PARAMS ----'
        # Write-Debug "Query: $Query"
        # Write-Debug "ServerInstance: $ServerInstance"
        # Write-Debug "Username: $Username"
        # Write-Debug '---- /PARAMS ----'

        if ( !$global:connection ) {
            Open-Connection | Out-Null # don't add the token to the pipeline, as this will confuse 'down stream' processing
        }

    } # /Begin
    PROCESS {
        Write-Debug "$($MyInvocation.MyCommand.Name)::PROCESS"

        # foreach ($Q In $Query) {

            try {

                Write-Verbose "Executing $Query"
                $command = New-Object System.Data.OracleClient.OracleCommand($Query, $global:connection)
                # $command = New-Object Oracle.DataAccess.Client.OracleCommand($Query,$connection)

                Write-Debug "Filling DataSet"
                $dataSet = New-Object System.Data.DataSet
                (New-Object System.Data.OracleClient.OracleDataAdapter($command)).Fill($dataSet) | Out-Null
                # (New-Object Oracle.DataAccess.Client.OracleDataAdapter($command)).Fill($dataSet) | Out-Null

                # return the results
                $dataSet.Tables[0]

            } # /try
            catch [System.Data.OracleClient.OracleException] {

                Write-Debug ("{0} [{1}]" -F $_.Exception.Message.Replace("`n",'') , $_.Exception.Code)

                # save for use in switch
                $ex = $_

                switch ( $_.Exception.Code ) {
                    {$_ -In 904 } {
                        # non-terminating error
                        Write-Error -Message ("Invalid identifier: {0}`n`r" -F ($ex.Exception.Message -Split ': ')[1]) # -Exception $_ -ErrorId $ex.Exception.Code -Category InvalidData -TargetObject $command
                    }
                    {$_ -Eq 923 } {
                        # non-terminating error
                        Write-Error -Message "Invalid SQL statement`n`r" # -Exception $_ -ErrorId $ex.Exception.Code -Category InvalidData -TargetObject $command
                    }
                    default {
                        # terminating error
                        throw
                    }
                } # /switch

            } # /catch

        # } # /foreach

    } # /PROCESS
    END {  Write-Debug "$($MyInvocation.MyCommand.Name)::END" }

}

Set-Alias oracle Invoke-OracleCmd
