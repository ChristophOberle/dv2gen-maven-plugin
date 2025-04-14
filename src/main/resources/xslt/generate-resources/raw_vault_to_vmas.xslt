<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault/db_sources">

        <xsl:for-each select="db_source/table/stage/(hub|link)/ma_sat">
            <xsl:call-template name="genVMass"/>
        </xsl:for-each>
        <xsl:call-template name="genVMasPropertiesYml"/>
    </xsl:template>

    <xsl:template name="genVMass">
        <xsl:variable name="stage_name" select="../../@name"/>
        <!--xsl:message><xsl:value-of select="$stage_name"/></xsl:message-->
        <xsl:variable name="hub_name" select="concat('hub_', ..[local-name() = 'hub']/nat_key/@idref)"/>
        <!--xsl:message><xsl:value-of select="$hub_name"/></xsl:message-->
        <xsl:variable name="link_name" select="concat('link_', string-join(../nat_key/@idref, '_'))"/>
        <!--xsl:message><xsl:value-of select="$link_name"/></xsl:message-->
        <xsl:variable name="hub_key_prefix" select="/raw_vault/nat_keys/nat_key[@id = current()/..[local-name() = 'hub']/nat_key/@idref]/@name"/>
        <xsl:variable name="link_key_prefix" select="/raw_vault/links/link[@name = $link_name and not(preceding-sibling::link[@name = $link_name])]/@prefix"/>
        <!--xsl:message><xsl:value-of select="$link_key_prefix"/></xsl:message-->
        <xsl:variable name="vsat_name">
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:value-of select="concat('vmas_', $stage_name, '_', $hub_name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('vmas_', $stage_name, '_', $link_name)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="@sat_suffix">
                <xsl:value-of select="concat('_', @sat_suffix)"/>
            </xsl:if>
        </xsl:variable>
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
        <xsl:variable name="vxts_name">
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:value-of select="concat('vxts_', $hub_name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('vxts_', $link_name)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Views _seen auf die Satellites mit allen gesehenen Daten -->
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/vmas/', $vsat_name,'_seen.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- </xsl:text><xsl:value-of select="$sat_name"/><xsl:text>: View on all seen data&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>SELECT </xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:text>hub.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_KEY&#xA;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="../nat_key">
                        <xsl:if test="position() &gt; 1">     , </xsl:if>
                        <xsl:text>link.</xsl:text><xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/><xsl:text>_PK&#xA;</xsl:text>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>     , sat.</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:value-of select="$hub_key_prefix"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$link_key_prefix"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>_PK&#xA;</xsl:text>
            <xsl:for-each select="child_dependent_keys/field">
                <xsl:text>     , sat.</xsl:text><xsl:value-of select="@name"/><xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <!-- wenn bei Satellites auf einen Hub bei den Payload-Feldern des Satellite
                 der KEY des zugehörigen Hubs enthalten ist, wird er nicht übernommen -->
            <xsl:for-each select="payload/field[@name != concat($hub_key_prefix, '_KEY')]">
                <xsl:text>     , sat.</xsl:text><xsl:value-of select="@name"/><xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>     , sat.EFFECTIVE_FROM&#xA;</xsl:text>
            <xsl:text>     , sat.LOAD_DATE&#xA;</xsl:text>
            <xsl:text>     , sat.RECORD_SOURCE&#xA;</xsl:text>
            <xsl:text>     , xts.LOAD_DATE as LAST_SEEN&#xA;</xsl:text>
            <xsl:text>FROM {{ ref('</xsl:text><xsl:value-of select="$sat_name"/><xsl:text>') }} sat&#xA;</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:text>JOIN {{ ref('</xsl:text><xsl:value-of select="$hub_name"/><xsl:text>') }} hub</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>JOIN {{ ref('</xsl:text><xsl:value-of select="$link_name"/><xsl:text>') }} link</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xA;</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:text>ON hub.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK = sat.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="link_name" select="@link"/>
                    <xsl:text>ON link.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK = sat.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>JOIN {{ ref('</xsl:text><xsl:value-of select="$vxts_name"/><xsl:text>') }} xts&#xA;</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:text>ON xts.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK = sat.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="link_name" select="@link"/>
                    <xsl:text>ON xts.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK = sat.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>AND xts.SATELLITE_NAME = '</xsl:text><xsl:value-of select="$sat_name"/><xsl:text>'&#xA;</xsl:text>
            <xsl:text>AND xts.LOAD_DATE >= sat.LOAD_DATE&#xA;</xsl:text>
            <xsl:text>AND xts.HASHDIFF = </xsl:text><xsl:value-of select="upper-case($sat_name)"/><xsl:text>_HASHDIFF&#xA;</xsl:text>
            <xsl:text>AND NOT EXISTS (&#xA;</xsl:text>
            <xsl:text>  SELECT 1&#xA;</xsl:text>
            <xsl:text>  FROM {{ ref('</xsl:text><xsl:value-of select="$vxts_name"/><xsl:text>') }} x&#xA;</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:text>  WHERE x.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK = xts.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="link_name" select="@link"/>
                    <xsl:text>  WHERE x.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK = xts.</xsl:text> <xsl:value-of select="$link_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  AND xts.SATELLITE_NAME = '</xsl:text><xsl:value-of select="$sat_name"/><xsl:text>'&#xA;</xsl:text>
            <xsl:text>  AND x.LOAD_DATE &gt; xts.LOAD_DATE&#xA;</xsl:text>
            <xsl:text>  AND x.HASHDIFF = xts.HASHDIFF&#xA;</xsl:text>
            <xsl:text>)&#xA;</xsl:text>
       </xsl:result-document>

        <!-- Views _last auf die Satellites mit den zuletzt gesehenen Daten -->
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/vmas/',$vsat_name,'_last.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- </xsl:text><xsl:value-of select="$sat_name"/><xsl:text>: View on latest seen data&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>SELECT </xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:text>hub.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_KEY&#xA;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="../nat_key">
                        <xsl:if test="position() &gt; 1">     , </xsl:if>
                        <xsl:text>link.</xsl:text><xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/><xsl:text>_PK&#xA;</xsl:text>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>     , sat.</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:value-of select="$hub_key_prefix"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$link_key_prefix"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>_PK&#xA;</xsl:text>
            <xsl:for-each select="child_dependent_keys/field">
                <xsl:text>     , sat.</xsl:text><xsl:value-of select="@name"/><xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <!-- wenn bei Satellites auf einen Hub bei den Payload-Feldern des Satellite
                 der KEY des zugehörigen Hubs enthalten ist, wird er nicht übernommen -->
            <xsl:for-each select="payload/field[@name != concat($hub_key_prefix, '_KEY')]">
                <xsl:text>     , sat.</xsl:text><xsl:value-of select="@name"/><xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>     , sat.EFFECTIVE_FROM&#xA;</xsl:text>
            <xsl:text>     , sat.LOAD_DATE&#xA;</xsl:text>
            <xsl:text>     , sat.RECORD_SOURCE&#xA;</xsl:text>
            <xsl:text>     , xts.LOAD_DATE as LAST_SEEN&#xA;</xsl:text>
            <xsl:text>FROM {{ ref('</xsl:text><xsl:value-of select="$sat_name"/><xsl:text>') }} sat&#xA;</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:text>JOIN {{ ref('</xsl:text><xsl:value-of select="$hub_name"/><xsl:text>') }} hub</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>JOIN {{ ref('</xsl:text><xsl:value-of select="$link_name"/><xsl:text>') }} link</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xA;</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:text>ON hub.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK = sat.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="link_name" select="@link"/>
                    <xsl:text>ON link.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK = sat.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>JOIN {{ ref('</xsl:text><xsl:value-of select="$vxts_name"/><xsl:text>') }} xts&#xA;</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:text>ON xts.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK = sat.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="link_name" select="@link"/>
                    <xsl:text>ON xts.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK = sat.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>AND xts.SATELLITE_NAME = '</xsl:text><xsl:value-of select="$sat_name"/><xsl:text>'&#xA;</xsl:text>
            <xsl:text>AND xts.LOAD_DATE >= sat.LOAD_DATE&#xA;</xsl:text>
            <xsl:text>AND xts.HASHDIFF = </xsl:text><xsl:value-of select="upper-case($sat_name)"/><xsl:text>_HASHDIFF&#xA;</xsl:text>
            <xsl:text>AND NOT EXISTS (&#xA;</xsl:text>
            <xsl:text>  SELECT 1&#xA;</xsl:text>
            <xsl:text>  FROM {{ ref('</xsl:text><xsl:value-of select="$vxts_name"/><xsl:text>') }} x&#xA;</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:text>  WHERE x.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK = xts.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="link_name" select="@link"/>
                    <xsl:text>  WHERE x.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK = xts.</xsl:text> <xsl:value-of select="$link_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  AND xts.SATELLITE_NAME = '</xsl:text><xsl:value-of select="$sat_name"/><xsl:text>'&#xA;</xsl:text>
            <xsl:text>  AND x.LOAD_DATE &gt; xts.LOAD_DATE&#xA;</xsl:text>
            <xsl:text>  AND x.HASHDIFF = xts.HASHDIFF&#xA;</xsl:text>
            <xsl:text>)&#xA;</xsl:text>
            <xsl:text>WHERE NOT EXISTS (&#xA;</xsl:text>
            <xsl:text>  SELECT 1&#xA;</xsl:text>
            <xsl:text>  FROM {{ ref('</xsl:text><xsl:value-of select="$sat_name"/><xsl:text>') }} x&#xA;</xsl:text>
            <xsl:choose>
                <xsl:when test="local-name(..) = 'hub'">
                    <xsl:text>  WHERE x.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK = sat.</xsl:text><xsl:value-of select="$hub_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>  WHERE x.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK = sat.</xsl:text><xsl:value-of select="$link_key_prefix"/><xsl:text>_PK</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  AND x.LOAD_DATE &gt; sat.LOAD_DATE&#xA;</xsl:text>
            <xsl:text>)&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genVMasPropertiesYml">
        <xsl:if test="/raw_vault/db_sources/db_source/table/stage/(hub|link)/ma_sat">
            <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s04_raw_vault/vmas/properties.yml')}" method="text" omit-xml-declaration="yes">
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>version: 2&#xA;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>models:&#xA;</xsl:text>

                <xsl:for-each select="db_source/table/stage/(hub|link)/ma_sat">
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
                    <xsl:text>  - name: v</xsl:text><xsl:value-of select="$sat_name"/><xsl:text>_last&#xA;</xsl:text>
                    <xsl:text>    description: View on latest data from </xsl:text><xsl:value-of select="$sat_name"/><xsl:text>&#xA;</xsl:text>
                    <xsl:text>  - name: v</xsl:text><xsl:value-of select="$sat_name"/><xsl:text>_seen&#xA;</xsl:text>
                    <xsl:text>    description: View on all seen data from </xsl:text><xsl:value-of select="$sat_name"/><xsl:text>&#xA;</xsl:text>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
