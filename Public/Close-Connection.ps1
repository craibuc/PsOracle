function Close-Connection {

    [CmdletBinding()]
    param()

    if ( $global:Connection ) {
        $global:Connection.Close()
        $global:Connection.Dispose()
        $global:Connection = $null
    }

}
