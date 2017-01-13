<#
Create an encrypted password and save it to a file:

  PS> ConvertTo-SecureString -String 'password' -AsPlainText -Force | Out-File .\password.txt

Open file, copy contents, then paste it to set the'SecurePassword' key
#>
@{
	ServerInstance='SERVER';
	Username='account';
	SecurePassword='secure string here'
}