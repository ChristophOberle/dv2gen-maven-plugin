# DataVault
# data load of a db_source into the source specific schema of the DWH database
#
# Example use:
# ./0102_import.ps1 -db_user testuser -target dev -db_source "Willibald" -load_date "2023-07-06"
# runs the script for target dev, DbSource Willibald and load_date 2023-07-06
#
# Parameter db_user - the database user used for the connection to the database
# Parameter target - controls the dbt target environment
# Parameter db_source - controls for which db source the CSV files from the file import directory will be read into the source schema
# Parameter load_date - controls for which load_date the data from the sources will be loaded into the PSA tables
#                       Default is: current date minus 1 day
#
# Process
# - evaluate target and db_source
# - (re)create the source tables
# - read file import directory and filter files for the given load_date
#   - load the data from the import files into the source tables
#
# Used Modules
# - DbModule.psm1     - a db module to execute SQL statements in a Postgres dbms
# - ParmsFromXml.psm1 - a module to retrieve parms from an XML file
#
#

param([string]$db_user, [string]$target = "dev", [string]$db_source = "", [string]$load_date = ((Get-Date).AddDays(-1).ToString("yyyy-MM-dd")))

function evaluate_target_and_db_source {
    param([ValidateNotNullOrEmpty()][string]$target = "prod", [ValidateNotNullOrEmpty()][string]$db_source)

    # read RawVault.xml file
    # assuming the script is running in <Maven-target-dir>/classes/DataVault/batch
    [xml]$RawVault = Read-Xml -XmlFile '../generated-sources/xml/RawVault.xml'
    $importdir = Get-SingleXmlAttributeValue -Xml $RawVault -XPath ("/raw_vault/system/target[@name = '" + $target + "']/@import_dir")
    $fileimportdirectory = $importdir + '/' + $db_source + '/'
    $datavaultdirectory = Get-SingleXmlAttributeValue -Xml $RawVault -XPath ("/raw_vault/system/target[@name = '" + $target + "']/@datavault_dir")
    $programdirectory = $datavaultdirectory + '/sql_scripts/DataVault_import/' + $db_source + '/'
    $logdirectory = Get-SingleXmlAttributeValue -Xml $RawVault -XPath ("/raw_vault/system/target[@name = '" + $target + "']/@log_dir")
    $server = Get-SingleXmlAttributeValue -Xml $RawVault -XPath ("/raw_vault/system/target[@name = '" + $target + "']/@server")
    $port = Get-SingleXmlAttributeValue -Xml $RawVault -XPath ("/raw_vault/system/target[@name = '" + $target + "']/@port")
    $database = Get-SingleXmlAttributeValue -Xml $RawVault -XPath ("/raw_vault/system/target[@name = '" + $target + "']/source[@name = '" + $db_source + "']/@database")
    $dbschema = Get-SingleXmlAttributeValue -Xml $RawVault -XPath ("/raw_vault/system/target[@name = '" + $target + "']/source[@name = '" + $db_source + "']/@schema")
    $tables = Get-XmlAttributeValues -Xml $RawVault -XPath ("/raw_vault/db_sources/db_source[@name = '" + $db_source + "']/table/@name")
    $csv_names = Get-XmlAttributeValues -Xml $RawVault -XPath ("/raw_vault/db_sources/db_source[@name = '" + $db_source + "']/table/import/@csv_name")
    $timestamp = Get-SingleXmlAttributeValue -Xml $RawVault -XPath ("/raw_vault/db_sources/db_source[@name = '" + $db_source + "']/file_import/@timestamp")

    $rc = New-Item $logdirectory -ItemType Directory -ea 0

    return $fileimportdirectory, $programdirectory, $logdirectory, $server, $port, $database, $dbschema, $tables, $csv_names, $timestamp
}

function recreate_source_tables {
    param( [ValidateNotNullOrEmpty()][string]$programdirectory
     , [ValidateNotNullOrEmpty()][string]$logdirectory
     , [ValidateNotNullOrEmpty()][string]$server
     , [ValidateNotNullOrEmpty()][string]$port
     , [ValidateNotNullOrEmpty()][string]$database
     , [ValidateNotNullOrEmpty()][string]$dbschema
     , [ValidateNotNullOrEmpty()][string]$DbUser
     , [ValidateNotNullOrEmpty()][string[]]$tables
    )

    foreach ($table in $tables) {
        Write-Host "**************************************"
        Write-Host "* $table"
        Write-Host "**************************************"

        # String Array with variables for the SQL script
        $StringArray = @()

        $StringArray += "DATABASE=$database"
        $StringArray += "DBSCHEMA=$dbschema"

        Write-Host "StringArray: $StringArray"

        $programname = $table
        $logname = $logdirectory + '/' + $programname + ".log"
        Write-Host $logname

        $program1name = "Drop_$programname"
        $program2name = "Create_$programname"

        $program1name = $programdirectory + $program1name + ".sql"
        $program2name = $programdirectory + $program2name + ".sql"
        Write-Host $programname

        # write log file header
        Out-File -FilePath "$logname" -Append -InputObject "--------------------------------"
        Out-File -FilePath "$logname" -Append -InputObject "$(date)"
        Out-File -FilePath "$logname" -Append -InputObject "$program1name"

        # execute drop table statement
        InvokePgSqlCmd -InputFile "$program1name" `
              -Server $server `
              -Port $port `
              -Database $database `
              -User $DbUser `
              -Variable $StringArray `
        | Out-File -FilePath "$logname" -Append

        # write log filehHeader
        Out-File -FilePath "$logname" -Append -InputObject "--------------------------------"
        Out-File -FilePath "$logname" -Append -InputObject "$(date)"
        Out-File -FilePath "$logname" -Append -InputObject "$program2name"

        # execute create table statement
        InvokePgSqlCmd -InputFile "$program2name" `
              -Server $server `
              -Port $port `
              -Database $database `
              -User $DbUser `
              -Variable $StringArray `
        | Out-File -FilePath "$logname" -Append

    }
    return $null
}

function read_file_import_directory {
    param( [ValidateNotNullOrEmpty()][string]$load_date
    , [ValidateNotNullOrEmpty()][string]$fileimportdirectory
    , [ValidateNotNullOrEmpty()][string]$timestamp
    )

    $files = Get-ChildItem -Path $fileimportdirectory -File

    if ($timestamp -eq "yes") {
        $test_date = "$($load_date.substring(0,4))$($load_date.substring(5,2))$($load_date.substring(8,2))"
        Write-Host $test_date

        $files_at_load_date = @()
        $dates = @()

        foreach ($file in $files) {
            $parts = $file -split "_"
            $date = $parts[$parts.Length - 2]
            $time = $parts[$parts.Length - 1]

            $dates += "$($date.substring(0,4))-$($date.substring(4,2))-$($date.substring(6,2))"
            if ($date -eq $test_date) {
                $files_at_load_date += $file.Name
                $count = $count + 1
            }
        }

        $dates = ($dates | Sort-Object -Unique)
    }
    else {
        $files_at_load_date = @()
        $dates = @()

        foreach ($file in $files) {
            $files_at_load_date += $file.Name
        }
        $dates += "none"
    }
    return $dates, $files_at_load_date
}

function load_data {
    param( [ValidateNotNullOrEmpty()][string]$fileimportdirectory
    , [ValidateNotNullOrEmpty()][string]$programdirectory
    , [ValidateNotNullOrEmpty()][string]$logdirectory
    , [ValidateNotNullOrEmpty()][string]$server
    , [ValidateNotNullOrEmpty()][string]$port
    , [ValidateNotNullOrEmpty()][string]$database
    , [ValidateNotNullOrEmpty()][string]$dbschema
    , [ValidateNotNullOrEmpty()][string]$DbUser
    , [ValidateNotNullOrEmpty()][string[]]$files
    , [ValidateNotNullOrEmpty()][string[]]$csv_names
    , [ValidateNotNullOrEmpty()][string[]]$tables
    , [ValidateNotNullOrEmpty()][string]$timestamp
    )

    foreach ($file in $files) {
        Write-Host "**************************************"
        Write-Host "* $file"
        Write-Host "**************************************"

        # fill string array with variables for the SQL script
        $StringArray = @()

        # Variable FILENAME is set to STDIN. This enforces a client side load in the COPY FROM statement
        $StringArray += "FILENAME=STDIN"
        $StringArray += "DATABASE=$database"
        $StringArray += "DBSCHEMA=$dbschema"

        Write-Host "StringArray: $StringArray"

        $parts = @()
        $parts = $file -split "_"

        Write-Host "file: $file"
        # get csv_name from file
        if ($timestamp -eq "yes") {
            $csv_name = ""
            for ($i = 0; $i -lt ($parts.Count - 2); $i++) {
                if ($i -gt 0) {
                    $csv_name = $csv_name + "_"
                }
                $csv_name = $csv_name + $parts[$i]
            }
        }
        else {
            $csv_name = Split-Path -Path $file -LeafBase
        }
        # get table name for csv_name
        $table = ""
        for ($i = 0; $i -lt $csv_names.Count; $i++) {
            Write-Host $csv_name
            Write-Host $csv_names[$i]
            if ($csv_name -eq $csv_names[$i]) {
                $table = $tables[$i]
                break
            }
        }
        $programname = $table
        $logname = $logdirectory + '/' + $programname + ".log"
        $program3name = "Bulk_insert_$programname"
        $program3name = $programdirectory + $program3name + ".sql"

        # write Logfile Header
        Out-File -FilePath "$logname" -Append -InputObject "--------------------------------"
        Out-File -FilePath "$logname" -Append -InputObject "$(date)"
        Out-File -FilePath "$logname" -Append -InputObject "$program3name"
        Out-File -FilePath "$logname" -Append -InputObject "$fileimportdirectory$file"

        # because of the client side load from STDIN we are composing query and data into the SQL
        # compose Query from Programm and Data file
        $Query = Get-Content -Path "$program3name" -raw
        $Data = Get-Content -Path "$fileimportdirectory$file" -raw

        $Query = $Query + $Data

        # if the Data end with CRLF then psql returns an error
        # -> remove CRLF at file end
        $cr = [char]0x0D
        $lf = [char]0x0A

        if ($Query[-1] -eq $lf) {
            $Query = $Query.Substring(0, $Query.length - 1)
        }
        if ($Query[-1] -eq $cr) {
            $Query = $Query.Substring(0, $Query.length - 1)
        }
        # execute Bulk Insert  statement
        InvokePgSqlCmd -InputFile "$program3name" `
              -Query $Query `
              -Server $server `
              -Port $port `
              -Database $database `
              -User $DbUser `
              -Variable $StringArray `
        | Out-File -FilePath "$logname" -Append
    }
    return $null
}

#################
# here we go ...
#################

Import-Module -Name ./DbModule.psm1
Import-Module -Name ./ParmsFromXml.psm1

$FileName = Split-Path -Path $PSCommandPath -Leaf
Write-Host "***************************************"
Write-Host "* $FileName Start"
Write-Host "***************************************"
Write-Host "db_user:              $db_user"
Write-Host "target:               $target"
Write-Host "db_source:            $db_source"
Write-Host "load_date:            $load_date"
Write-Host "***************************************"

# evaluate target and db_source
$fileimportdirectory, $programdirectory, $logdirectory, $server, $port, $database, $dbschema, $tables, $csv_names, $timestamp = evaluate_target_and_db_source -target $target -db_source $db_source

Write-Host "fileimportdirectory:  $fileimportdirectory"
Write-Host "programdirectory:     $programdirectory"
Write-Host "logdirectory:         $logdirectory"
Write-Host "server:               $server"
Write-Host "port:                 $port"
Write-Host "database:             $database"
Write-Host "dbschema:             $dbschema"
Write-Host "tables:               $tables"
Write-Host "csv_names:            $csv_names"
Write-Host "timestamp:            $timestamp"

# recreate source tables
$results = recreate_source_tables -programdirectory $programdirectory `
                               -logdirectory $logdirectory `
                               -server $server `
                               -port $port `
                               -database $database `
                               -dbschema $dbschema `
                               -DbUser $db_user `
                               -tables $tables

# read file import directory
$dates, $files = read_file_import_directory -load_date $load_date -fileimportdirectory $fileimportdirectory -timestamp $timestamp
if ($files.Length -eq 0)
{
    Write-Host "No files found for load_date $load_date in directory $fileimportdirectory!"
    Write-Host "For the following load_dates files are available:"
    $dates | Write-Host
}
else {
    $results = load_data       -fileimportdirectory $fileimportdirectory `
                               -programdirectory $programdirectory `
                               -logdirectory $logdirectory `
                               -server $server `
                               -port $port `
                               -database $database `
                               -dbschema $dbschema `
                               -DbUser $db_user `
                               -files $files `
                               -csv_names $csv_names `
                               -tables $tables `
                               -timestamp $timestamp

}

Write-Host "***************************************"
Write-Host "* $FileName Ende"
Write-Host "***************************************"
