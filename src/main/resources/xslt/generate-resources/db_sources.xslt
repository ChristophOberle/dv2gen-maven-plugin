<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault">

        <xsl:for-each select="db_sources">
            <xsl:call-template name="genSchemaYml"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="genSchemaYml">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/schema.yml')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: 2</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>sources:</xsl:text>
            <xsl:text>&#xA;</xsl:text>

            <xsl:for-each select="db_source">
                <xsl:variable name="source_name" select="@name"/>
                <xsl:text>  - name: </xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    description: </xsl:text>
                <xsl:value-of select="@description"/>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    database: |</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:for-each select="../../system/target">
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <xsl:text>      {%- if   target.name == "</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>      {%- elif target.name == "</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="@name"/>
                    <xsl:text>" -%} </xsl:text>
                    <xsl:value-of select="source[@name=$source_name]/@database"/>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:for-each>
                <xsl:text>      {%- else -%} invalid_database</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      {%- endif -%}</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    schema: |</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:for-each select="../../system/target">
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <xsl:text>      {%- if   target.name == "</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>      {%- elif target.name == "</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="@name"/>
                    <xsl:text>" -%} </xsl:text>
                    <xsl:value-of select="source[@name=$source_name]/@schema"/>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:for-each>
                <xsl:text>      {%- else -%} invalid_database</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      {%- endif -%}</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    tables:</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:for-each select="table">
                    <xsl:text>      - name: </xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:text>        description: </xsl:text>
                    <xsl:value-of select="@description"/>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
