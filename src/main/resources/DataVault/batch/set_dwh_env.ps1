# this script sets the data warehouse environment at run time
#
# it uses dbt_project.yml from the parent directory of this script
#    from dbt_project.yml the profile name is taken
# from .dbt/profiles.yml in the user's home directory at $HOME
#   it uses the default target of the profile
#   and the user specified for this target in the profile
#
# Variable          Source
# $project_dir      the directory of the current dbt project
# $home_dir         the runtime user's home directory
# $db_user          the DB user used to connect to the database
# $target           the target used

Import-Module -name $PSScriptRoot/YamlModule.psm1

# assuming the project directory is the parent directory of the script's path
$project_dir = Split-Path -Path $PSScriptRoot -Parent

# set home_dir
$home_dir = $HOME

# set target and db_user for current profile from .dbt/profiles.yml
$dbt_project = (json_from_yaml -program_dir ($project_dir + "/batch") -yaml_file ($project_dir + "/dbt_project.yml") -json_file ($project_dir + "/dbt_project.json"))
$profiles = (json_from_yaml -program_dir ($project_dir + "/batch") -yaml_file ($home_dir + "/.dbt/profiles.yml") -json_file ($home_dir + "/.dbt/profiles.json"))

$profile = $dbt_project.profile
Write-Host "profile: $profile"

$target = $profiles."$profile".target
$db_user = $profiles."$profile".outputs."$target".user

# $db_password is not set
# It is specified in file .pgpass in the user's home directory for the combination of server, port, database and user

Write-Host "project_dir: $project_dir"
Write-Host "home_dir:    $home_dir"
Write-Host "target:      $target"
Write-Host "db_user:     $db_user"
