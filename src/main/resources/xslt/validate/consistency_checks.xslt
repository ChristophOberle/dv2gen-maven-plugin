<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/raw_vault">
        <xsl:call-template name="test_all_referenced_nat_keys_are_provided"/>
        <xsl:call-template name="test_sats_all_payload_fields_are_provided"/>
        <xsl:call-template name="test_hubs_all_stages_are_used"/>
        <xsl:call-template name="test_stages_all_nat_keys_create_hubs"/>
        <xsl:call-template name="test_stages_all_source_tables_exist"/>
        <xsl:call-template name="test_stages_all_nat_key_source_fields_are_defined"/>
    </xsl:template>

    <xsl:template name="test_all_referenced_nat_keys_are_provided">
        <xsl:for-each select="db_sources/db_source/table/stage/link/nat_key[@idref]">
            <xsl:variable name="idref" select="@idref"/>
            <xsl:if test="not(/raw_vault/nat_keys/nat_key[@id = $idref])">
                <xsl:message>Für den nat_key mit idref <xsl:value-of select="@idref"/> gibt es keine Definition</xsl:message>
                <xsl:text>failed</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="test_sats_all_payload_fields_are_provided">
        <xsl:for-each select="dv_tables/sat/payload/field">
            <xsl:variable name="stage" select="../../@stage"/>
            <xsl:variable name="source" select="/raw_vault/stages/dir[stage/@name = $stage]/@source"/>
            <xsl:variable name="table" select="/raw_vault/stages/dir/stage[@name = $stage]/@table"/>
            <xsl:if test="not(/raw_vault/db_sources/db_source[@name = $source]/table[@name = $table]/fields/field/@name = current()/@name) and
                          not(../../../../stages/dir/stage[@name=current()/../../@stage]/nat_keys/nat_key/@name = substring-before(current()/@name, '_KEY'))">
                <xsl:message><xsl:value-of select="../../@name"/> uses payload field <xsl:value-of select="@name"/> which is not a field or nat_key of <xsl:value-of select="../../@stage"/></xsl:message>
                <xsl:text>failed</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="test_hubs_all_stages_are_used">
        <xsl:for-each select="dv_tables/hub">
            <xsl:variable name="hub" select="."/>
            <xsl:for-each select="/raw_vault/stages/dir/stage[nat_keys/nat_key/@name = $hub/nat_key/@name]">
                <xsl:if test="not($hub/stages/stage[@name = current()/@name])">
                    <xsl:message><xsl:value-of select="$hub/@name"/> does not use stage <xsl:value-of select="@name"/> with nat_key <xsl:value-of select="nat_keys/nat_key[@name = $hub/nat_key/@name]/@name"/></xsl:message>
                    <xsl:text>failed</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="test_stages_all_nat_keys_create_hubs">
        <xsl:for-each select="stages/dir/stage/nat_keys/nat_key">
            <xsl:variable name="nat_key" select="."/>
            <xsl:if test="not(/raw_vault/dv_tables/hub[nat_key/@name = $nat_key/@name]/stages/stage[@name = $nat_key/../../@name])">
                <xsl:choose>
                    <xsl:when test="/raw_vault/dv_tables/hub[nat_key/@name = $nat_key/@name]/@name">
                        <xsl:message>stage <xsl:value-of select="$nat_key/../../@name"/> is not used in <xsl:value-of select="/raw_vault/dv_tables/hub[nat_key/@name = $nat_key/@name]/@name"/> with nat_key <xsl:value-of select="$nat_key/@name"/></xsl:message>
                        <xsl:text>failed</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>stage <xsl:value-of select="$nat_key/../../@name"/> is not used in any hub with nat_key <xsl:value-of select="$nat_key/@name"/></xsl:message>
                        <xsl:text>failed</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="test_stages_all_source_tables_exist">
        <xsl:for-each select="stages/dir/stage">
            <xsl:variable name="stage" select="."/>
            <xsl:variable name="dir_source" select="../@source"/>
            <xsl:if test="not(/raw_vault/db_sources/db_source[@name = $dir_source]/table[@name = $stage/@table])">
                <xsl:message>stage <xsl:value-of select="$stage/@name"/> uses unknown source <xsl:value-of select="$stage/@table"/></xsl:message>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="test_stages_all_nat_key_source_fields_are_defined">
        <xsl:for-each select="stages/dir/stage/nat_keys/nat_key/@source_field">
            <xsl:variable name="source_field" select="."/>
            <xsl:variable name="source" select="../../../../@name"/>
            <xsl:variable name="table" select="../../../@table"/>
            <xsl:if test="not(/raw_vault/db_sources/db_source[@name = $source]/table[@name = $table]/fields/field/@name = $source_field)">
                <xsl:message>stage <xsl:value-of select="../../../@name"/>: nat_key <xsl:value-of select="../@name"/> uses source_field <xsl:value-of select="."/> which is not a field of the stage</xsl:message>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
