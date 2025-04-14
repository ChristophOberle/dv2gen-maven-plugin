<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault/links">

        <xsl:for-each select="link">
            <xsl:if test="not(preceding-sibling::link[@name = current()/@name])">
                <xsl:call-template name="genLinks"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:call-template name="genLinkPropertiesYml"/>
    </xsl:template>

    <xsl:template name="genLinks">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/link/',@name,'.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <!-- indexes
                 link_pk, load_date
                 pk1, pk2, ... pkn, load_date
                 -->
            <xsl:text>{{&#xA;</xsl:text>
            <xsl:text>    config(&#xA;</xsl:text>
            <xsl:text>        indexes=[&#xA;</xsl:text>
            <xsl:text>        {'columns': ['</xsl:text><xsl:value-of select="@prefix"/><xsl:text>_PK', 'LOAD_DATE'], 'unique': True},&#xA;</xsl:text>
            <xsl:text>        {'columns': [</xsl:text>
            <xsl:for-each select="nat_keys/nat_key">
                <xsl:if test="position() &gt; 1">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:text>'</xsl:text><xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/><xsl:text>_PK'</xsl:text>
            </xsl:for-each>
            <xsl:text>, 'LOAD_DATE'], 'unique': True}&#xA;</xsl:text>
            <xsl:text>        ]&#xA;</xsl:text>
            <xsl:text>    )&#xA;</xsl:text>
            <xsl:text>}}&#xA;</xsl:text>
            <xsl:text>{%- set source_model = [</xsl:text>
            <xsl:for-each select="stages/stage">
                <xsl:if test="position() &gt; 1">, </xsl:if>
                <xsl:text>"stg_</xsl:text><xsl:value-of select="@name"/><xsl:text>"</xsl:text>
            </xsl:for-each>
            <xsl:text>] -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_pk = "</xsl:text><xsl:value-of select="@prefix"/><xsl:text>_PK" -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_fk = [</xsl:text>
            <xsl:for-each select="nat_keys/nat_key">
                <xsl:if test="position() &gt; 1">, </xsl:if>
                <xsl:text>"</xsl:text><xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/><xsl:text>_PK"</xsl:text>
            </xsl:for-each>
            <xsl:text>] -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_ldts = "LOAD_DATE" -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_source = "RECORD_SOURCE" -%}&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{{ automate_dv.link(src_pk=src_pk,&#xA;</xsl:text>
            <xsl:text>                 src_fk=src_fk,&#xA;</xsl:text>
            <xsl:text>                 src_ldts=src_ldts,&#xA;</xsl:text>
            <xsl:text>                 src_source=src_source,&#xA;</xsl:text>
            <xsl:text>                 source_model=source_model) }}&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genLinkPropertiesYml">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/link/properties.yml')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: 2&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>models:&#xA;</xsl:text>
            <xsl:for-each select="link">
                <xsl:if test="not(preceding-sibling::link[@name = current()/@name])">
                    <xsl:text>  - name: </xsl:text><xsl:value-of select="@name"/><xsl:text>&#xA;</xsl:text>
                    <xsl:text>    description: </xsl:text><xsl:value-of select="@description"/><xsl:text>&#xA;</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
