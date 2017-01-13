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

    Context 'Open connection' {

        # arrange
        $Query='SELECT sysdate AS NOW FROM dual'
        $expected = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')

        It "Returns the current date/time" {
            # act
            $actual = Invoke-OracleCmd -Query $Query -Verbose | Select-Object -Expand NOW

            # assert
            $actual | Should Be $expected
        }

    }

}
