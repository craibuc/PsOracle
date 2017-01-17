Import-Module PsOracle -Force

# $here = Split-Path -Parent $MyInvocation.MyCommand.Path
# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
# . "$here\$sut"

Describe "Open-Connection" {

    BeforeAll {

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

        # alternately, prompt for credentials
        # $params = @{
        #     ServerInstance=Read-Host 'Server'
        #     Username=Read-Host 'User'
        #     Password = Read-Host 'Password' -AsSecureString
        # }

    }

    BeforeEach { 
        # ensure the connection is closed
        Close-Connection 
    }

    Context "Valid credentials supplied" {

        It "Opens a conection" {
            # act
            $actual = Open-Connection @params -Verbose

            # assert
            $actual | Should BeOfType System.Data.OracleClient.OracleConnection
        }

    }

    Context "Inalid credentials supplied" {

        $username='invalid_user'
        $password=ConvertTo-SecureString 'invalid_password' -AsPlainText -Force

        It "Throws an exeption" {
            # act / assert
            { Open-Connection $params.ServerInstance $username $password -Verbose } | Should Throw 'Invalid credentials'
        }

    }

    Context "Invalid server supplied" {

        $serverInstance='invalid_server'

        It -skip "Throws an exeption" {
            # act / assert
            { Open-Connection $serverInstance $params.Username $params.Password -Verbose } | Should Throw 'Invalid server'
        }

    }
    
}
