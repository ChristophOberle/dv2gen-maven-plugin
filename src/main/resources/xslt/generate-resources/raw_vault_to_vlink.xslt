<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault/links">

        <xsl:for-each select="link">
            <xsl:if test="not(preceding-sibling::link[@name = current()/@name])">
                <xsl:call-template name="genViewsOnLinks"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:call-template name="genVLinkPropertiesYml"/>
    </xsl:template>

    <xsl:template name="genViewsOnLinks">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/vlink/vlink_',substring(@name, 6),'.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text> SELECT link.</xsl:text><xsl:value-of select="@prefix"/><xsl:text>_PK&#xA;</xsl:text>
            <xsl:for-each select="nat_keys/nat_key">
                <xsl:text>      , link.</xsl:text><xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/><xsl:text>_PK&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:for-each select="nat_keys/nat_key">
                <xsl:text>      , _</xsl:text><xsl:value-of select="@idref"/><xsl:text>_.</xsl:text><xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/><xsl:text>_KEY&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>      , link.LOAD_DATE&#xA;</xsl:text>
            <xsl:text>FROM {{ ref('</xsl:text><xsl:value-of select="@name"/><xsl:text>') }} link&#xA;</xsl:text>
            <xsl:for-each select="nat_keys/nat_key">
                <xsl:text>JOIN {{ ref('</xsl:text><xsl:value-of select="/raw_vault/hubs/hub[nat_key/@idref = current()/@idref]/@name"/><xsl:text>') }} _</xsl:text><xsl:value-of select="@idref"/><xsl:text>_&#xA;</xsl:text>
                <xsl:text>ON _</xsl:text><xsl:value-of select="@idref"/><xsl:text>_.</xsl:text><xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/><xsl:text>_PK = link.</xsl:text><xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/><xsl:text>_PK&#xA;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genVLinkPropertiesYml">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/vlink/properties.yml')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: 2&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>models:&#xA;</xsl:text>
            <xsl:for-each select="link">
                <xsl:if test="not(preceding-sibling::link[@name = current()/@name])">
                    <xsl:text>  - name: v</xsl:text><xsl:value-of select="@name"/><xsl:text>&#xA;</xsl:text>
                    <xsl:text>    description: View on </xsl:text><xsl:value-of select="@description"/><xsl:text>&#xA;</xsl:text>
                </xsl:if>
          </xsl:for-each>
        </xsl:result-document>
     </xsl:template>

</xsl:stylesheet>
