# DbModule.psm1
# DB Module to execute SQL statements in a Postgres dbms
#
# function InvokePgSqlCmd
#
# executes a Postgres SQL cmd
#
# The SQL can be specified as a query string in parameter Query
# or as an input filename in parameter InputFile.
# Even if the SQL is specified in Query, the parameter InputFile must be given.
# It is used to create some temporary file names during execution.
#
# The Postgres connection is specified as Server, Port, Database and User.
#
# The SQL string may contain variables which have to be assigned values in the parameter Variable:
#   Variable is a string array and each string has the format <variable>=<value>
#   Every occurance of $(<variable>) in the SQL string is replaced by <value>

function InvokePgSqlCmd {
    param( [string]$InputFile
    , [string]$Query
    , [ValidateNotNullOrEmpty()][string]$Server
    , [ValidateNotNullOrEmpty()][string]$Port
    , [ValidateNotNullOrEmpty()][string]$Database
    , [ValidateNotNullOrEmpty()][string]$User
    , [ValidateNotNullOrEmpty()][string[]]$Variable
    )

    $result = $null

    if ($Query -eq '') {
        # read InputFile into Query
        $Query = Get-Content $InputFile -Raw
    }

    # replace variables
    foreach ($Replacement in $Variable) {
        $from, $to = $Replacement -split '='
        $from = '\$\(' + $from + '\)'
        $Query = $Query -replace $from, $to
    }
    #Write-Host "Query: $Query"

    $RunFile = $InputFile + '_temp'
    $Query | Out-File -FilePath $RunFile

    # Execute statements
    $OutputFile = $InputFile + '_output'
    Out-File -FilePath $OutputFile -InputObject ''

    $ErrorFile = $InputFile + '_error'
    Out-File -FilePath $ErrorFile -InputObject ''

    $result = (psql --username=$User --host=$Server --port=$Port --dbname=$Database --echo-errors --no-password --tuples-only --output=$OutputFile --file=$RunFile 2>>$ErrorFile)

    #Write-Host "result: $result"

    $output = Get-Content $OutputFile -Raw
    Write-Host "output: $output"

    $errortext = Get-Content $ErrorFile -Raw
    if ($errortext -match '\S')
    {
        Write-Host "error: $errortext"
    }

    # purge temp.files
    Remove-Item -LiteralPath $RunFile
    Remove-Item -LiteralPath $OutputFile
    Remove-Item -LiteralPath $ErrorFile

    $result = $output

    return $result
}

