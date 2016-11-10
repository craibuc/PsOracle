@{
    QUERY_SYSDATE=@"
SELECT  sysdate NOW
FROM    dual
"@
    QUERY_USERENV=@"
SELECT  sys_context('USERENV','SERVER_HOST') SERVER_HOST, sys_context('USERENV', 'IP_ADDRESS') IP_ADDRESS
        ,sys_context('USERENV', 'INSTANCE_NAME') INSTANCE_NAME, sys_context('USERENV', 'SERVICE_NAME') SERVICE_NAME 
        ,sys_context('USERENV', 'SESSION_USER') SESSION_USER
        ,sys_context('USERENV', 'MODULE') MODULE
FROM    dual
"@
    QUERY_ALL_IND_COLUMNS=@"
SELECT  table_name, index_name, listagg(column_name, ', ') WITHIN GROUP (ORDER BY column_position) COLUMNS
FROM    (
        SELECT  index_owner, index_name, table_name, column_name, column_position 
        FROM    all_ind_columns
        WHERE   table_name = {0}
        ORDER BY index_name, column_position
        )
GROUP BY table_name,index_name
"@
    QUERY_ALL_TABLES=@"
SELECT  owner, table_name, num_rows, last_analyzed
FROM    all_tables
WHERE   table_name LIKE '{0}'
"@
    QUERY_VSQL=@"
SELECT  sql_text, sql_id, last_active_time, parsing_schema_name, module
FROM    v`$sql
WHERE   sql_text like '%USER=''{0}''%'
ORDER BY last_active_time DESC
"@
}