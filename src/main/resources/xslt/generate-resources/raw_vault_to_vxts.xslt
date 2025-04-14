<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault">

        <xsl:for-each select="hubs/hub[stages/stage/sat|stages/stage/ma_sat]|links/link[stages/stage/sat|stages/stage/ma_sat]">
            <xsl:if test="not(preceding-sibling::link[@name = current()/@name])">
                <xsl:call-template name="genVXts"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:call-template name="genVXtsPropertiesYml"/>
    </xsl:template>

    <xsl:template name="genVXts">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/vxts/vxts_', @name, '.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:for-each select="stages/stage[sat|ma_sat]">
                <xsl:if test="position() &gt; 1">
                    <xsl:text>union&#xA;</xsl:text>
                </xsl:if>
                <xsl:text>select * from {{ ref('xts_</xsl:text><xsl:value-of select="@name"/><xsl:text>_</xsl:text><xsl:value-of select="../../@name"/><xsl:text>') }}&#xA;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genVXtsPropertiesYml">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/vxts/properties.yml')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: 2&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>models:&#xA;</xsl:text>

            <xsl:for-each select="links/link[stages/stage/sat|stages/stage/ma_sat]">
                <xsl:if test="not(preceding-sibling::link[@name = current()/@name])">
                    <!--xsl:message>link: <xsl:value-of select="@name"/></xsl:message-->
                    <xsl:text>  - name: vxts_</xsl:text><xsl:value-of select="@name"/><xsl:text>&#xA;</xsl:text>
                    <xsl:text>    description: View for Extended Tracking Satellite on </xsl:text><xsl:value-of select="@description"/><xsl:text>&#xA;</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="hubs/hub[stages/stage/sat|stages/stage/ma_sat]">
                <!--xsl:message>hub: <xsl:value-of select="@name"/></xsl:message-->
                <xsl:text>  - name: vxts_</xsl:text><xsl:value-of select="@name"/><xsl:text>&#xA;</xsl:text>
                <xsl:text>    description: View for Extended Tracking Satellite on </xsl:text><xsl:value-of select="@description"/><xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
       </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
