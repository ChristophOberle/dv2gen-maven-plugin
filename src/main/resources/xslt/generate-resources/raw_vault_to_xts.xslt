<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault/db_sources">

        <xsl:for-each select="db_source/table/stage/(hub|link)/(sat|ma_sat)">
            <xsl:if test="not(preceding-sibling::sat) and not(preceding-sibling::ma_sat)">
                <!-- es gibt nur eine XTS-Tabelle für jede Kombination von Stage und Hub bzw. Link
                     deshalb wird nur der erste sat bzw. ma_sat berücksichtigt -->
                <xsl:call-template name="genXtss"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:call-template name="genXtsPropertiesYml"/>
    </xsl:template>

    <xsl:template name="genXtss">
        <xsl:variable name="stage_name" select="../../@name"/>
        <xsl:variable name="hub_name" select="concat('hub_', ..[local-name() = 'hub']/nat_key/@idref)"/>
        <xsl:variable name="link_name" select="concat('link_', string-join(../nat_key/@idref, '_'))"/>
        <xsl:variable name="hub_key_prefix" select="/raw_vault/nat_keys/nat_key[@id = current()/../nat_key/@idref]/@name"/>
        <xsl:variable name="link_key_prefix" select="/raw_vault/links/link[@name = $link_name and not(preceding-sibling::link[@name = $link_name])]/@prefix"/>
        <xsl:variable name="xts_name">
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:value-of select="concat('xts_', $stage_name, '_', $hub_name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('xts_', $stage_name, '_', $link_name)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/xts/', $xts_name,'.sql')}" method="text" omit-xml-declaration="yes">
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
            <xsl:text>_PK', 'LOAD_DATE', 'SATELLITE_NAME', 'HASHDIFF'], 'unique': True}&#xA;</xsl:text>
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
            <xsl:text>{%- set src_satellite = { </xsl:text>
            <xsl:for-each select="../sat|../ma_sat">
                <xsl:variable name="sat_name">
                    <xsl:choose>
                        <xsl:when test="local-name() = 'sat'">
                            <xsl:choose>
                                <xsl:when test="local-name(..) = 'hub'">
                                    <xsl:value-of select="concat('sat_', $stage_name, '_', $hub_name)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('sat_', $stage_name, '_', $link_name)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="local-name(..) = 'hub'">
                                    <xsl:value-of select="concat('mas_', $stage_name, '_', $hub_name)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('mas_', $stage_name, '_', $link_name)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="@sat_suffix">
                        <xsl:value-of select="concat('_', @sat_suffix)"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:if test="position() > 1">                        , </xsl:if>
                <xsl:text>"</xsl:text><xsl:value-of select="$sat_name"/><xsl:text>": {&#xA;</xsl:text>
                <xsl:text>                            "sat_name": {"SATELLITE_NAME": "</xsl:text>
                <xsl:choose>
                    <xsl:when test="local-name() = 'sat'">
                        <xsl:text>SAT_</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>MAS_</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="concat(upper-case($stage_name), '_')"/>
                <xsl:choose>
                    <xsl:when test="local-name(..) = 'hub'">
                        <xsl:value-of select="upper-case($hub_name)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="upper-case($link_name)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="@sat_suffix">
                    <xsl:value-of select="concat('_', @sat_suffix)"/>
                </xsl:if>
                <xsl:text>_NAME"},&#xA;</xsl:text>
                <xsl:text>                            "hashdiff": {"HASHDIFF": "</xsl:text>
                <xsl:choose>
                    <xsl:when test="local-name() = 'sat'">
                        <xsl:text>SAT_</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>MAS_</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="concat(upper-case($stage_name), '_')"/>
                <xsl:choose>
                    <xsl:when test="local-name(..) = 'hub'">
                        <xsl:value-of select="upper-case($hub_name)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="upper-case($link_name)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="@sat_suffix">
                    <xsl:value-of select="concat('_', @sat_suffix)"/>
                </xsl:if>
                <xsl:text>_HASHDIFF"}&#xA;</xsl:text>
                <xsl:text>                          }&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>                        } -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_source = "RECORD_SOURCE" -%}&#xA;</xsl:text>
            <xsl:text>{%- set src_ldts = "LOAD_DATE" -%}&#xA;</xsl:text>
            <xsl:text>{{ automate_dv.xts(src_pk=src_pk, src_satellite=src_satellite,&#xA;</xsl:text>
            <xsl:text>                src_ldts=src_ldts, src_source=src_source,&#xA;</xsl:text>
            <xsl:text>                source_model=source_model) }}&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genXtsPropertiesYml">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/xts/properties.yml')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: 2&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>models:&#xA;</xsl:text>
            <xsl:for-each select="/raw_vault/db_sources/db_source/table/stage/(hub|link)/(sat|ma_sat)">
                <xsl:if test="not(preceding-sibling::sat) and not(preceding-sibling::ma_sat)">
                    <!-- es gibt nur eine XTS-Tabelle für jede Kombination von Stage und Hub bzw. Link
                         deshalb wird nur der erste sat bzw. ma_sat berücksichtigt -->
                    <xsl:variable name="stage_name" select="../../@name"/>
                    <xsl:variable name="hub_name" select="concat('hub_', ..[local-name() = 'hub']/nat_key/@idref)"/>
                    <xsl:variable name="link_name" select="concat('link_', string-join(../nat_key/@idref, '_'))"/>
                    <xsl:variable name="hub_key_prefix" select="/raw_vault/nat_keys/nat_key[@id = current()/..[local-name() = 'hub']/nat_key/@idref]/@name"/>
                    <xsl:variable name="link_key_prefix" select="/raw_vault/links/link[@name = $link_name and not(preceding-sibling::link[@name = $link_name])]/@prefix"/>
                    <xsl:variable name="xts_name">
                        <xsl:choose>
                            <xsl:when test="local-name(..) = 'hub'">
                                <xsl:value-of select="concat('xts_', $stage_name, '_', $hub_name)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('xts_', $stage_name, '_', $link_name)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                   <xsl:text>  - name: </xsl:text><xsl:value-of select="$xts_name"/><xsl:text>&#xA;</xsl:text>
                    <xsl:choose>
                        <xsl:when test="local-name(..) = 'hub'">
                            <xsl:text>    description: </xsl:text><xsl:value-of select="concat('Extended Tracking Satellite for all satellites on ', local-name(..), ' ', $hub_name, ', served from stage ', $stage_name)"/><xsl:text>&#xA;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>    description: </xsl:text><xsl:value-of select="concat('Extended Tracking Satellite for all satellites on ', local-name(..), ' ', $link_name, ', served from stage ', $stage_name)"/><xsl:text>&#xA;</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
