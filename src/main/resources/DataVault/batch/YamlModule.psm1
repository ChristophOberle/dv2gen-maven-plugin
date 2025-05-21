# YamlModule.psm1
# YAML Module to read config data from YAML files
#
function get_profile_from_project {
    param( [ValidateNotNullOrEmpty()][string]$program_dir, [ValidateNotNullOrEmpty()][string]$project_file)

    $dbt_profile = (python3 $program_dir/get_profile_from_project.py "$project_file")
    return $dbt_profile
}

function get_target_from_profile {
    param( [ValidateNotNullOrEmpty()][string]$program_dir,  [ValidateNotNullOrEmpty()][string]$profiles_file,  [ValidateNotNullOrEmpty()][string]$dbt_profile)

    $target = (python3 $program_dir/get_target_from_profile.py "$profiles_file" "$dbt_profile")
    return $target
}

function get_user_from_profile {
    param( [ValidateNotNullOrEmpty()][string]$program_dir,  [ValidateNotNullOrEmpty()][string]$profiles_file,  [ValidateNotNullOrEmpty()][string]$dbt_profile,  [ValidateNotNullOrEmpty()][string]$target)

    $user = (python3 $program_dir/get_user_from_profile.py "$profiles_file" "$dbt_profile" "$target")
    return $user
}
