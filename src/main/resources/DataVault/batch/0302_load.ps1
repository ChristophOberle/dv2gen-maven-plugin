# DataVault
# load the DWH without option full_refresh (normal load)
#
# Example use:
# ./0302_load.ps1 -target dev -load_date "2023-07-06"
# runs the script for target dev and load_date 2023-07-06
#
# Parameter target - controls the dbt target environment
# Parameter select - controls which dbt modules are run
#                    Default is "tag:raw+"
# Parameter load_date - controls for which load_date the data from the PSA tables will be loaded to the Data Vault
#                       Default is: current date minus 1 day
#
param([string]$target = "dev", [string]$select = "tag:raw+", [string]$load_date = ((Get-Date).AddDays(-1).ToString("yyyy-MM-dd")))

#################
# here we go ...
#################

Import-Module -Name ./dbtModule.psm1

$FileName = Split-Path -Path $PSCommandPath -Leaf
Write-Host "***************************************"
Write-Host "* $FileName Start"
Write-Host "***************************************"
Write-Host "target:               $target"
Write-Host "select:               $select"
Write-Host "load_date:            $load_date"
Write-Host "***************************************"

dbt_run -target $target `
        -select $select `
        -load_date $load_date

Write-Host "***************************************"
Write-Host "* $FileName Ende"
Write-Host "***************************************"
