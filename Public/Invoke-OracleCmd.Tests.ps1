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

        # https://github.com/pester/Pester/issues/366
        It 'Generates a non-terminating exception 2' {
            # act
            $error.clear()
            Invoke-OracleCmd -Query $Query -Verbose -ErrorVariable err

            # assert
            $err.Count | Should Not Be 0
            $err[1].Exception.Message | Should Be "Invalid SQL statement`n`r"
        }

    }

    Context 'Invalid identifier' {

        # arrange
        $Query='SELECT sys FROM dual'

        # https://github.com/pester/Pester/issues/366
        It 'Generates a non-terminating exception 2' {
            # act
            $error.clear()
            Invoke-OracleCmd -Query $Query -Verbose -ErrorVariable err

            # assert
            $err.Count | Should Not Be 0
            $err[1].Exception.Message | Should Be "Invalid identifier: ""SYS""`n`r"
        }

    }

    # Context 'Queries supplied via pipeline' {

    #     # arrange
    #     $Queries='SELECT sysdate FROM dual','SELECT sysdate+1 TOMORROW FROM dual'

    #     It 'Creates multiple recordsets' {
    #         $actual = $Queries | Invoke-OracleCmd -Verbose

    #         $actual.Count | Should Be 2
    #         $actual[0] | Should BeOfType System.Data.DataRow
    #         $actual[1] | Should BeOfType System.Data.DataRow
    #     }
    # }

    # Context 'Invalid query supplied in the midst of valid queries' {

    #     # arrange
    #     $Queries='SELECT sysdate FROM dual','SELECT foo','SELECT sysdate+1 TOMORROW FROM dual'

    #     It 'Creates multiple recordsets, ignoring the invalid query' {
    #         $actual = $Queries | Invoke-OracleCmd -Verbose

    #         $actual.Count | Should Be 2
    #         $actual[0] | Should BeOfType System.Data.DataRow
    #         $actual[1] | Should BeOfType System.Data.DataRow
    #     }
    # }

}
