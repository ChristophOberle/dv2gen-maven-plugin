# YamlModule.psm1
# YAML Module to read config data from YAML files
#
function json_from_yaml {
    param( [ValidateNotNullOrEmpty()][string]$program_dir, [ValidateNotNullOrEmpty()][string]$yaml_file)

    $json = (python3 $program_dir/json_from_yaml.py "$yaml_file") | ConvertFrom-Json

    return $json
}
