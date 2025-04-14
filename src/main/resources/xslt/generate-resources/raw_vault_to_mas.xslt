<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault/db_sources">

        <xsl:for-each select="db_source/table/stage/(hub|link)/ma_sat">
            <xsl:call-template name="genMass"/>
        </xsl:for-each>
        <xsl:call-template name="genMasPropertiesYml"/>
    </xsl:template>

    <xsl:template name="genMass">
        <xsl:variable name="stage_name" select="../../@name"/>
        <!--xsl:message><xsl:value-of select="$stage_name"/></xsl:message-->
        <xsl:variable name="hub_name" select="concat('hub_', ..[local-name() = 'hub']/nat_key/@idref)"/>
        <!--xsl:message><xsl:value-of select="$hub_name"/></xsl:message-->
        <xsl:variable name="link_name" select="concat('link_', string-join(../nat_key/@idref, '_'))"/>
        <!--xsl:message><xsl:value-of select="$link_name"/></xsl:message-->
        <xsl:variable name="hub_key_prefix" select="/raw_vault/nat_keys/nat_key[@id = current()/../nat_key/@idref]/@name"/>
        <xsl:variable name="link_key_prefix" select="/raw_vault/links/link[@name = $link_name and not(preceding-sibling::link[@name = $link_name])]/@prefix"/>
        <xsl:variable name="sat_name">
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:value-of select="concat('mas_', $stage_name, '_', $hub_name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('mas_', $stage_name, '_', $link_name)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="@sat_suffix">
                <xsl:value-of select="concat('_', @sat_suffix)"/>
            </xsl:if>
        </xsl:variable>
        <!--xsl:message><xsl:value-of select="$sat_name"/></xsl:message-->
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/mas/', $sat_name,'.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <!-- sats
                  link_pk bzw. hub_pk, load_date
                  -->
            <xsl:text>{{&#xA;</xsl:text>
            <xsl:text>    config(&#xA;</xsl:text>
            <xsl:text>        indexes=[&#xA;</xsl:text>
            <xsl:text>        {'columns': ['</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:value-of select="$hub_key_prefix"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$link_key_prefix"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>_PK', 'LOAD_DATE', '</xsl:text><xsl:value-of select="upper-case($sat_name)"/><xsl:text>_HASHDIFF']}&#xA;</xsl:text>
            <xsl:text>        ]&#xA;</xsl:text>
            <xsl:text>    )&#xA;</xsl:text>
            <xsl:text>}}&#xA;</xsl:text>
            <xsl:text>{%- set source_model = "stg_</xsl:text><xsl:value-of select="$stage_name"/><xsl:text>" -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_pk = "</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:value-of select="$hub_key_prefix"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$link_key_prefix"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>_PK" -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_hashdiff = "</xsl:text><xsl:value-of select="upper-case($sat_name)"/><xsl:text>_HASHDIFF" -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_cdk = [</xsl:text>
            <xsl:for-each select="child_dependent_keys/field">
                <xsl:if test="position() &gt; 1">,  </xsl:if>
                <xsl:text>"</xsl:text><xsl:value-of select="@name"/><xsl:text>"&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>] -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_payload = [</xsl:text>
            <xsl:for-each select="payload/field">
                <xsl:if test="position() &gt; 1">, </xsl:if>
                <xsl:text>"</xsl:text><xsl:value-of select="@name"/><xsl:text>"&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:if test="payload[@existenceFlag = 'yes']">
                <xsl:if test="payload/field">, </xsl:if>
                <xsl:text>"</xsl:text><xsl:value-of select="'EXISTENCE_FLAG'"/><xsl:text>"&#xA;</xsl:text>
            </xsl:if>
            <xsl:text>] -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_eff = "EFFECTIVE_FROM" -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_ldts = "LOAD_DATE" -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_source = "RECORD_SOURCE" -%}&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{{ automate_dv.ma_sat(src_pk=src_pk, src_cdk=src_cdk,&#xA;</xsl:text>
            <xsl:text>                src_payload=src_payload, src_hashdiff=src_hashdiff, src_eff=src_eff,&#xA;</xsl:text>
            <xsl:text>                src_ldts=src_ldts, src_source=src_source,&#xA;</xsl:text>
            <xsl:text>                source_model=source_model) }}&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genMasPropertiesYml">
        <xsl:if test="/raw_vault/db_sources/db_source/table/stage/(hub|link)/ma_sat">
            <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/mas/properties.yml')}" method="text" omit-xml-declaration="yes">
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>version: 2&#xA;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>models:&#xA;</xsl:text>

                <xsl:for-each select="/raw_vault/db_sources/db_source/table/stage/(hub|link)/ma_sat">
                    <xsl:variable name="stage_name" select="../../@name"/>
                    <xsl:variable name="hub_name" select="concat('hub_', ..[local-name() = 'hub']/nat_key/@idref)"/>
                    <xsl:variable name="link_name" select="concat('link_', string-join(../nat_key/@idref, '_'))"/>
                    <xsl:variable name="hub_key_prefix" select="/raw_vault/nat_keys/nat_key[@id = current()/..[local-name() = 'hub']/nat_key/@idref]/@name"/>
                    <xsl:variable name="link_key_prefix" select="/raw_vault/links/link[@name = $link_name and not(preceding-sibling::link[@name = $link_name])]/@prefix"/>
                    <xsl:variable name="sat_name">
                        <xsl:choose>
                            <xsl:when test="local-name(..) = 'hub'">
                                <xsl:value-of select="concat('mas_', $stage_name, '_', $hub_name)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('mas_', $stage_name, '_', $link_name)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="@sat_suffix">
                            <xsl:value-of select="concat('_', @sat_suffix)"/>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:text>  - name: </xsl:text><xsl:value-of select="$sat_name"/><xsl:text>&#xA;</xsl:text>
                    <xsl:text>    description: </xsl:text><xsl:value-of select="@description"/><xsl:text>&#xA;</xsl:text>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
