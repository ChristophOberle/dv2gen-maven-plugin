# dbtModule.psm1
# dbt Module to execute SQL statements in a Postgres dbms
#
# function dbt_run
#
# executes a dbt run command
#
function dbt_run {
    param( [ValidateNotNullOrEmpty()][string]$target = "dev"
    , [ValidateNotNullOrEmpty()][string]$select = "tag:raw+"
    , [ValidateNotNullOrEmpty()][string]$load_date = (Get-Date -format yyyy-MM-dd)
    , [switch]$full_refresh
    )

    $command = "dbt run -t $target -s $select --vars ""{load_date: $load_date}"""

    # if switch full_refresh is present, do a --full-refresh
    if($full_refresh) {
        Write-Host "$command --full-refresh"
        Invoke-Expression -Command "$command --full-refresh"
    }

    # execute the command (even after the full_refresh)
    Write-Host $command
    Invoke-Expression -Command $command
}

