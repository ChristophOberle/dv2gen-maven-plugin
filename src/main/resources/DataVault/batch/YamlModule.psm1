# YamlModule.psm1
# YAML Module to read config data from YAML files
#
function ConvertFrom-Yaml {
    param( [ValidateNotNullOrEmpty()][string]$ProgramDir, [ValidateNotNullOrEmpty()][string]$YamlFile)

    $result = (python3 $ProgramDir/json_from_yaml.py "$YamlFile") | ConvertFrom-Json

    return $result
}
