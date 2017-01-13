function Open-Connection {

    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$ServerInstance,

        [Parameter(Position=1,Mandatory=$true)]
        [string]$Username,

        [Parameter(Position=2,Mandatory=$true)]
        [SecureString]$Password

        # [int]$Timeout=20
    )

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $PlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    $connectionString = "Data Source=$ServerInstance;User Id=$Username;Password=$PlainText;Integrated Security=no"
    # remove password
    Write-Debug $connectionString.Replace($PlainText,"*" * ($PlainText.Length))

    try {
        Write-Verbose "Connecting $Username to $ServerInstance"

        # open it
        $connection = New-Object System.Data.OracleClient.OracleConnection($connectionString)
        $connection.Open()
        # save in session
        $global:connection = $connection
        # return it
        $connection
    }
    catch [System.Data.OracleClient.OracleException] {
        # reset
        $global:connection = $null

        switch ( $_.Exception.Code ) {
            {$_ -In 1005,1017 } {
                # Write-Error -Message "Invalid credentials`n" -Exception $_ -ErrorId $ex.Exception.Code -Category AuthenticationError -TargetObject $connection
                Throw 'Invalid credentials', $_
            }
            {$_ -In 12560,12154} {
                # Write-Error  -Message "Invalid server`n" -Exception $_ -ErrorId $ex.Exception.Code -Category ConnectionError -TargetObject $connection
                Throw 'Invalid server', $_
            }
        }
        
    }

}
