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
        # $server=Read-Host 'Server'
        # $user=Read-Host 'User'
        # $password=Read-Host 'Password' -AsSecureString

        # $params = @{
        #     ServerInstance=$Credentials.ServerInstance;
        #     Username=$Credentials.Username;
        #     # convert secure text to a SecureString object
        #     Password = $Credentials.SecurePassword | ConvertTo-SecureString
        # }

    }

    Context "Valid credentials supplied" {

        It "Opens a conection" {
            # act
            $actual = Open-Connection @params -Verbose

            # assert
            $actual | Should Be $true
        }

    }

    Context "Inalid credentials supplied" {

        $user='invalid'
        $password=ConvertTo-SecureString 'invalid' -AsPlainText -Force

        It "Throws an exeption" {
            # act
            # $actual = Open-Connection $server $user $password -Verbose

            # act / assert
            { Open-Connection $server $user $password -Verbose } | Should Throw
        }

    }

    Context "Invalid server supplied" {

        $server='invalid'

        It "Throws an exeption" {
            # act
            # $actual = Open-Connection $server $user $password -Verbose

            # act / assert
            { Open-Connection $server $user $password -Verbose } | Should Throw
        }

    }
    
}
