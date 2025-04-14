<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/business_vault/pit_tables">

        <xsl:for-each select="pit_table">
            <xsl:call-template name="genPitTable"/>
        </xsl:for-each>
        <xsl:call-template name="genPitPropertiesYml"/>
    </xsl:template>

    <xsl:template name="genPitTable">
        <xsl:variable name="ref_name" select="@ref_name"/>
        <xsl:variable name="as_of_date" select="@as_of_date"/>
        <xsl:variable name="ref_pk" select="@ref_pk"/>
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s07_business_vault/pit/pit_', $as_of_date, '_', $ref_name,'.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:text>{%- set yaml_metadata -%}&#xA;</xsl:text>
            <xsl:text>source_model: </xsl:text><xsl:value-of select="$ref_name"/><xsl:text>&#xA;</xsl:text>
            <xsl:text>src_pk: </xsl:text><xsl:value-of select="$ref_pk"/><xsl:text>&#xA;</xsl:text>
            <xsl:text>as_of_dates_table: </xsl:text><xsl:value-of select="$as_of_date"/><xsl:text>&#xA;</xsl:text>
            <xsl:text>satellites:&#xA;</xsl:text>
            <xsl:for-each select="stage/sat|stage/ma_sat">
                <xsl:text>  v</xsl:text><xsl:value-of select="@name"/><xsl:text>_seen:&#xA;</xsl:text>
                <xsl:text>    pk:&#xA;</xsl:text>
                <xsl:text>      PK: </xsl:text><xsl:value-of select="$ref_pk"/><xsl:text>&#xA;</xsl:text>
                <xsl:text>    ldts:&#xA;</xsl:text>
                <xsl:text>      LDTS: LOAD_DATE&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>stage_tables_ldts:&#xA;</xsl:text>
            <xsl:for-each select="stage">
                <xsl:text>  stg_</xsl:text><xsl:value-of select="@name"/><xsl:text>: LOAD_DATE&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>src_ldts: LOAD_DATE&#xA;</xsl:text>
            <xsl:text>{%- endset -%}&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{% set metadata_dict = fromyaml(yaml_metadata) %}&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{% set source_model = metadata_dict['source_model'] %}&#xA;</xsl:text>
            <xsl:text>{% set src_pk = metadata_dict['src_pk'] %}&#xA;</xsl:text>
            <xsl:text>{% set as_of_dates_table = metadata_dict['as_of_dates_table'] %}&#xA;</xsl:text>
            <xsl:text>{% set satellites = metadata_dict['satellites'] %}&#xA;</xsl:text>
            <xsl:text>{% set stage_tables_ldts = metadata_dict['stage_tables_ldts'] %}&#xA;</xsl:text>
            <xsl:text>{% set src_ldts = metadata_dict['src_ldts'] %}&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{{ automate_dv.pit(source_model=source_model, src_pk=src_pk,&#xA;</xsl:text>
            <xsl:text>                   as_of_dates_table=as_of_dates_table,&#xA;</xsl:text>
            <xsl:text>                   satellites=satellites,&#xA;</xsl:text>
            <xsl:text>                   stage_tables_ldts=stage_tables_ldts,&#xA;</xsl:text>
            <xsl:text>                   src_ldts=src_ldts) }}&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genPitPropertiesYml">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s07_business_vault/pit/properties.yml')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: 2&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>models:&#xA;</xsl:text>
            <xsl:for-each select="pit_table">
                <xsl:variable name="ref_name" select="@ref_name"/>
                <xsl:text>  - name: pit_</xsl:text><xsl:value-of select="@as_of_date"/>_<xsl:value-of select="$ref_name"/><xsl:text>&#xA;</xsl:text>
                <xsl:text>    description: PIT for as_of_date </xsl:text><xsl:value-of select="@as_of_date"/> and <xsl:value-of select="@ref_name"/><xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
