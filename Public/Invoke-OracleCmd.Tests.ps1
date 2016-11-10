$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Invoke-OracleCmd" {

    # load credentials from PSD1 file
    Import-LocalizedData -FileName 'com.oracle.credentials.psd1' -BindingVariable Credentials
    Write-Debug $Credentials.ServerInstance
    Write-Debug $Credentials.Username
    Write-Debug $Credentials.SecurePassword

    $params = @{
        ServerInstance=$Credentials.ServerInstance;
        Username=$Credentials.Username;
        # convert secure text to a SecureString object
        Password = $Credentials.SecurePassword | ConvertTo-SecureString
    }

    $Query='SELECT sysdate AS NOW FROM dual'
    Write-Debug $Query

    Context 'When the Oracle client isn''t installed' {
        It -skip 'Throws an error' {
            {Invoke-OracleCmd -Query $Query @params} | Should Throw
        }
    }

    Context 'When the Oracle client isn''t available' {
        It  -skip 'Throws an error' {
            {Invoke-OracleCmd -Query $Query @params} | Should Throw
        }
    }

    # Context 'When the database is not available' {
    #     It "Throws an exception" {
    #         $actual = Invoke-OracleCmd -Query $Query @params
    #         $actual.GetType() | Should Be ([System.Object[]])
    #     }
    # }

    Context 'When the Oracle client is installed' {

        It -skip 'Returns an object array' {

            Mock Invoke-OracleCmd {
                [PSCustomObject]@{ NOW = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss') }
                # $array = @()
                # $array += New-Object System.Object
                # $array += New-Object System.Object
                # $array
            }

            $actual = Invoke-OracleCmd -Query $Query @params
            $actual.GetType() | Should Be ([System.Object[]])
        }

        It "Returns the current date/time" {

            # Mock Invoke-OracleCmd {
            #     [PSCustomObject]@{ NOW = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss') }
            # }

            $actual = Invoke-OracleCmd -Query $Query @params -Verbose | Select-Object -Expand NOW
            $expected = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')
            $actual | Should Be $expected
        }

    }

    Context "Invalid credentials are supplied" {
        It 'Throws an error' {
            { Invoke-OracleCmd -Query $Query -ServerInstance $params['ServerInstance'] -Username '' -Password '' -Verbose } | Should Throw
        }
    }

}
