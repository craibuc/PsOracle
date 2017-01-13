$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Invoke-OracleCmd" {

    BeforeAll {

        # Write-Host 'BeforeAll'

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

        Open-Connection @params

    }
    AfterAll {
        # Write-Host 'AfterAll'
        Close-Connection
    }

    Context 'Valid SQL' {

        # arrange
        $Query='SELECT sysdate AS NOW FROM dual'
        $expected = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')

        It "Returns a DataRow containing the expected data" {
            # act
            $actual = Invoke-OracleCmd -Query $Query -Verbose # | Select-Object -Expand NOW

            # assert
            $actual | Should BeOfType System.Data.DataRow
            $actual | Select-Object -Expand NOW | Should Be $expected
        }

    }

    Context 'Invalid SQL' {

        # arrange
        $Query='SELECT foobar'

        It "Generates a non-terminating exception" {
            # act / assert
            { Invoke-OracleCmd -Query $Query -Verbose } | Should Throw 'Invalid SQL statement'
        }

    }

}
