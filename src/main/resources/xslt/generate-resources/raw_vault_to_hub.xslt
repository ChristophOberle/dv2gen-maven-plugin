<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault/hubs">

        <xsl:for-each select="hub">
            <xsl:call-template name="genHubs"/>
        </xsl:for-each>
        <xsl:call-template name="genHubPropertiesYml"/>
    </xsl:template>

    <xsl:template name="genHubs">
        <xsl:result-document href="{concat('file://',$baseDir, '/target/classes/DataVault/models/s04_raw_vault/hub/', @name,'.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:variable name="nat_key_name" select="/raw_vault/nat_keys/nat_key[@id = current()/nat_key/@idref]/@name"/>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{{&#xA;</xsl:text>
            <xsl:text>    config(&#xA;</xsl:text>
            <xsl:text>        indexes=[&#xA;</xsl:text>
            <xsl:text>        {'columns': ['</xsl:text><xsl:value-of select="$nat_key_name"/><xsl:text>_PK', '</xsl:text><xsl:value-of select="$nat_key_name"/><xsl:text>_KEY', 'LOAD_DATE'], 'unique': True}&#xA;</xsl:text>
            <xsl:text>        ]&#xA;</xsl:text>
            <xsl:text>    )&#xA;</xsl:text>
            <xsl:text>}}&#xA;</xsl:text>
            <xsl:text>{%- set source_model = </xsl:text>
            <xsl:variable name="stages_count" select="count(stages/stage)"/>
            <xsl:if test="$stages_count &gt; 1">[</xsl:if>
            <xsl:for-each select="stages/stage">
                <xsl:if test="position() &gt; 1">, </xsl:if><xsl:text>"stg_</xsl:text><xsl:value-of select="@name"/><xsl:text>"</xsl:text>
            </xsl:for-each>
            <xsl:if test="$stages_count &gt; 1">]</xsl:if><xsl:text> -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_pk = "</xsl:text><xsl:value-of select="$nat_key_name"/><xsl:text>_PK" -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_nk = "</xsl:text><xsl:value-of select="$nat_key_name"/><xsl:text>_KEY" -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_ldts = "LOAD_DATE" -%}</xsl:text><xsl:text>&#xA;</xsl:text>
            <xsl:text>{%- set src_source = "RECORD_SOURCE" -%}</xsl:text><xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,&#xA;</xsl:text>
            <xsl:text>                src_source=src_source, source_model=source_model) }}&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genHubPropertiesYml">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/hub/properties.yml')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: 2</xsl:text><xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>models:</xsl:text><xsl:text>&#xA;</xsl:text>
            <xsl:for-each select="hub">
                <xsl:text>  - name: </xsl:text><xsl:value-of select="@name"/><xsl:text>&#xA;</xsl:text>
                <xsl:text>    description: </xsl:text><xsl:value-of select="@description"/><xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
