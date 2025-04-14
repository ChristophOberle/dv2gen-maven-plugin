<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/business_vault/as_of_dates">

        <xsl:for-each select="as_of_date">
            <xsl:call-template name="genAsOfDateTable"/>
        </xsl:for-each>
        <xsl:call-template name="genAsOfDatePropertiesYml"/>
    </xsl:template>

    <xsl:template name="genAsOfDateTable">
        <xsl:variable name="name" select="@name"/>
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s07_business_vault/as_of_date/', $name,'.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:for-each select="date">
                <xsl:if test="position() > 1">
                    <xsl:text>union&#xA;</xsl:text>
                </xsl:if>
                <xsl:text>-- </xsl:text><xsl:value-of select="@description"/><xsl:text>&#xA;</xsl:text>
                <xsl:text>select </xsl:text><xsl:value-of select="@definition"/><xsl:text> as AS_OF_DATE&#xA;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genAsOfDatePropertiesYml">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s07_business_vault/as_of_date/properties.yml')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: 2&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>models:&#xA;</xsl:text>
            <xsl:for-each select="as_of_date">
                <xsl:text>  - name: </xsl:text><xsl:value-of select="@name"/><xsl:text>&#xA;</xsl:text>
                <xsl:text>    description: as_of_date </xsl:text><xsl:value-of select="@name"/><xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
