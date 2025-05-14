# ParmsFromXml.psm1
# Module to retrieve parms from an XML file
#
# function Read-Xml
# function Get-XmlNodes
# function Get-XmlAttributeValues
# function Get-SingleXmlAttributeValue
#
# Example uses:
#
# $rv = Read-Xml -XmlFile RawVault.xml
# $table_names = Get-XmlAttributeValues -Xml $rv -XPath "/raw_vault/db_sources/db_source[@name = 'config']/table/@name"
# $timestamp = Get-SingleXmlAttributeValue -Xml $rv -XPath "/raw_vault/db_sources/db_source[@name = 'config']/file_import/@timestamp"

function Read-Xml {
    param( [string]$XmlFile )
    [xml]$result = Get-Content $XmlFile
    return $result
}

function Get-XmlNodes {
    param( [xml]$Xml, [string]$XPath )
    $result = @()
    $result = Select-Xml -Xml $Xml -XPath $XPath | ForEach-Object { $_.Node }
    return $result
}

function Get-XmlAttributeValues {
    param( [xml]$Xml, [string]$XPath )
    $result = Get-XmlNodes -Xml $Xml -XPath $XPath | ForEach-Object { $_.Value }
    return $result
}

function Get-SingleXmlAttributeValue {
    param( [xml]$Xml, [string]$XPath )
    $result = Get-XmlAttributeValues -Xml $Xml -XPath $XPath
    return $result
}

