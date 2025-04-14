<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault/db_sources">
        <xsl:for-each select="db_source/table/stage">
            <xsl:call-template name="genPsaStage"/>
            <xsl:call-template name="genRawStage"/>
            <xsl:call-template name="genStage"/>
        </xsl:for-each>
        <xsl:call-template name="genPsaPropertiesYml"/>
        <xsl:call-template name="genRawPropertiesYml"/>
        <xsl:call-template name="genStgPropertiesYml"/>
    </xsl:template>

    <xsl:template name="genPsaStage">

        <!-- @psa_name defaults to @name -->
        <xsl:variable name="psa_name">
            <xsl:choose>
                <xsl:when test="@psa_name"><xsl:value-of select="@psa_name"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="not(@psa) or @psa != 'false'">
            <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s01_psa_stage/', ../../@models_dir, '/psa_',$psa_name,'.sql')}" method="text" omit-xml-declaration="yes">

                <xsl:text>&#xA;</xsl:text>
                <xsl:text>{{</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    config(</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>        full_refresh = false,</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>        materialized='incremental',</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>        unique_key=['LOAD_DATE', </xsl:text>
                <xsl:for-each select="../unique_key/field">
                    <xsl:if test="position() &gt; 1">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>'</xsl:text>
                </xsl:for-each>
                <xsl:text>],</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>        indexes=[</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>        {'columns': ['LOAD_DATE'</xsl:text>
                <xsl:for-each select="../unique_key/field">
                    <xsl:text>, </xsl:text>
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>'</xsl:text>
                </xsl:for-each>
                <xsl:text>], 'unique': True}</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>        ]</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    )</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>}}</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>&#xA;</xsl:text>

                <xsl:text>SELECT '{{ var('load_date') }}' AS LOAD_DATE</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:for-each select="../fields/field">
                    <xsl:text>     , </xsl:text>
                    <xsl:if test="@source_field">
                        <xsl:choose>
                            <xsl:when test="@source_field_pg">
                                <xsl:value-of select="@source_field_pg"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@source_field"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> AS </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="@name"/>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:for-each>

                <xsl:text>FROM {{ source('</xsl:text>
                <xsl:value-of select="../../@name"/>
                <xsl:text>', '</xsl:text>
                <xsl:value-of select="../@name"/>
                <xsl:text>') }}</xsl:text>
                <xsl:text>&#xA;</xsl:text>

                <xsl:if test="filter/@clause">
                    <xsl:text>WHERE </xsl:text>
                    <xsl:choose>
                        <xsl:when test="filter/@clause_pg">
                            <xsl:value-of select="filter/@clause_pg"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="filter/@clause"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:if>

                <xsl:text>&#xA;</xsl:text>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>

    <xsl:template name="genRawStage">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s02_raw_stage/', ../../@models_dir, '/raw_', @name,'.sql')}" method="text" omit-xml-declaration="yes">

            <!-- @psa_name defaults to @name -->
            <xsl:variable name="psa_name">
                <xsl:choose>
                    <xsl:when test="@psa_name"><xsl:value-of select="@psa_name"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- the constant load data EFFECTIVE_FROM and LOAD_DATE have been moved from staging.sql</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- to this file, because otherwise the generated code is not executable</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- die konstanten Ladedaten EFFECTIVE_FROM und LOAD_DATE wurden aus dem staging.sql</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- hierher verschoben, da der generierte Code sonst nicht ausführbar ist</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:choose>
                <xsl:when test="not(@psa) or @psa != 'false'">
                    <xsl:text>SELECT to_timestamp(concat(LOAD_DATE, ' 0'), 'YYYY-MM-DD TZH') as LOAD_DATE</xsl:text>
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:text>     , to_timestamp(concat(LOAD_DATE, ' 0'), 'YYYY-MM-DD TZH') as EFFECTIVE_FROM</xsl:text>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>SELECT to_timestamp('{{ var('load_date') }} 0', 'YYYY-MM-DD TZH') AS LOAD_DATE</xsl:text>
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:text>     , to_timestamp('{{ var('load_date') }} 0', 'YYYY-MM-DD TZH') AS EFFECTIVE_FROM</xsl:text>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="hub/nat_key[@definition]">
                <xsl:text>     , </xsl:text>
                <xsl:choose>
                    <xsl:when test="@definition_pg">
                        <xsl:value-of select="@definition_pg"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@definition"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> as </xsl:text>
                <xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/>
                <xsl:text>_KEY</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:for-each select="../fields/field">
                <xsl:text>     , </xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:choose>
                <xsl:when test="not(@psa) or @psa != 'false'">
                    <xsl:text>FROM {{ ref('psa_</xsl:text>
                    <xsl:value-of select="$psa_name"/>
                    <xsl:text>') }}</xsl:text>
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:text>WHERE LOAD_DATE = '{{ var('load_date') }}' </xsl:text>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>FROM {{ source('</xsl:text>
                    <xsl:value-of select="../../@name"/>
                    <xsl:text>', '</xsl:text>
                    <xsl:value-of select="../@name"/>
                    <xsl:text>') }}</xsl:text>
                    <xsl:text>&#xA;</xsl:text>

                    <xsl:if test="filter/@clause">
                        <xsl:text>WHERE </xsl:text>
                        <xsl:choose>
                            <xsl:when test="filter/@clause_pg">
                                <xsl:value-of select="filter/@clause_pg"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="filter/@clause"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>

                    <xsl:text>&#xA;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genStage">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s03_stage/stg_', @name,'.sql')}" method="text" omit-xml-declaration="yes">

            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- Attention: in the staging.sql datasets no tabs must be used, they have to be replaced with blanks!</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- Achtung: in den staging.sql-Dateien dürfen keine Tabs verwendet werden, sie müssen durch Leerzeichen ersetzt werden!</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{%- set yaml_metadata -%}</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>source_model: "raw_</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>"</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>derived_columns:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  RECORD_SOURCE: "!</xsl:text>
            <xsl:value-of select="../../@record_source_prefix"/>
            <xsl:text>_</xsl:text>
            <xsl:value-of select="@record_source_suffix"/>
            <xsl:text>"</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  LAST_SEEN: "LOAD_DATE"</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:if test="(hub|link)/(ma_sat|sat)[payload/@existenceFlag = 'yes']">
                <xsl:text>  EXISTENCE_FLAG: "!true"</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:if>
            <!-- die KEYs aller nat_keys mit source_field werden hier als derived column definiert
                 die KEYs der nat_keys mit definition sind bereits in der raw stage definiert worden
                 -->
            <xsl:for-each select="hub/nat_key[@source_field]">
                <xsl:text>  </xsl:text>
                <xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/>
                <xsl:text>_KEY: "</xsl:text>
                <xsl:value-of select="@source_field"/>
                <xsl:text>"</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <!-- für jeden Satelliten, der aus dieser Stage erstellt wird, wird eine derived_column
                 <sat_name> mit dem konstanten Wert <sat_name> für das XTS-Macro erstellt
                 -->
            <xsl:for-each select="(hub|link)/sat">
                <xsl:variable name="stage_name" select="../../@name"/>
                <xsl:variable name="hub_name" select="concat('hub_', ..[local-name() = 'hub']/nat_key/@idref)"/>
                <xsl:variable name="link_name" select="concat('link_', string-join(../nat_key/@idref, '_'))"/>
                <xsl:variable name="hub_key_prefix" select="/raw_vault/nat_keys/nat_key[@id = current()/..[local-name() = 'hub']/nat_key/@idref]/@name"/>
                <xsl:variable name="link_key_prefix" select="/raw_vault/links/link[@name = $link_name]/@prefix"/>
                <xsl:variable name="sat_name">
                    <xsl:choose>
                        <xsl:when test="local-name(..) = 'hub'">
                            <xsl:value-of select="concat('sat_', $stage_name, '_', $hub_name)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('sat_', $stage_name, '_', $link_name)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="@sat_suffix">
                        <xsl:value-of select="concat('_', @sat_suffix)"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:text>  </xsl:text>
                <xsl:value-of select="upper-case($sat_name)"/>
                <xsl:text>_NAME: "!</xsl:text>
                <xsl:value-of select="$sat_name"/>
                <xsl:text>"</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:for-each select="(hub|link)/ma_sat">
                <xsl:variable name="stage_name" select="../../@name"/>
                <xsl:variable name="hub_name" select="concat('hub_', ..[local-name() = 'hub']/nat_key/@idref)"/>
                <xsl:variable name="link_name" select="concat('link_', string-join(../nat_key/@idref, '_'))"/>
                <xsl:variable name="hub_key_prefix" select="/raw_vault/nat_keys/nat_key[@id = current()/..[local-name() = 'hub']/nat_key/@idref]/@name"/>
                <xsl:variable name="link_key_prefix" select="/raw_vault/links/link[@name = $link_name]/@prefix"/>
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
                <xsl:text>  </xsl:text>
                <xsl:value-of select="upper-case($sat_name)"/>
                <xsl:text>_NAME: "!</xsl:text>
                <xsl:value-of select="$sat_name"/>
                <xsl:text>"</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>hashed_columns:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <!-- die PKs aller nat_keys werden hier als hashed column definiert
                 -->
            <xsl:for-each select="hub/nat_key">
                <xsl:text>  </xsl:text>
                <xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/>
                <xsl:text>_PK: "</xsl:text>
                <xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/>
                <xsl:text>_KEY"</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <!-- die PKs aller Links, die aus diesem stg_file gefüllt werden,
                 werden hier als hashed column definiert
                 -->
            <xsl:variable name="stage_name" select="@name"/>

            <xsl:for-each select="/raw_vault/links/link[stages/stage/@name = $stage_name]">
                <xsl:if test="not(preceding-sibling::link[@name = current()/@name])">
                    <xsl:text>  </xsl:text>
                    <xsl:value-of select="@prefix"/>
                    <xsl:text>_PK:</xsl:text>
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:for-each select="nat_keys/nat_key">
                        <xsl:text>    - '</xsl:text>
                        <xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/@idref]/@name"/>
                        <xsl:text>_KEY'</xsl:text>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:for-each>
                </xsl:if>
            </xsl:for-each>
            <!-- die HASHDIFFs aller Satelliten, die aus diesem stg_file gefüllt werden,
                 werden hier als hashed column definiert
                 -->
            <xsl:for-each select="(hub|link)/sat">
                <xsl:variable name="stage_name" select="../../@name"/>
                <xsl:variable name="hub_name" select="concat('hub_', ..[local-name() = 'hub']/nat_key/@idref)"/>
                <xsl:variable name="link_name" select="concat('link_', string-join(../nat_key/@idref, '_'))"/>
                <xsl:variable name="hub_key_prefix" select="/raw_vault/nat_keys/nat_key[@id = current()/..[local-name() = 'hub']/nat_key/@idref]/@name"/>
                <xsl:variable name="link_key_prefix" select="/raw_vault/links/link[@name = $link_name]/@prefix"/>
                <xsl:variable name="sat_name">
                    <xsl:choose>
                        <xsl:when test="local-name(..) = 'hub'">
                            <xsl:value-of select="concat('sat_', $stage_name, '_', $hub_name)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('sat_', $stage_name, '_', $link_name)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="@sat_suffix">
                        <xsl:value-of select="concat('_', @sat_suffix)"/>
                    </xsl:if>
                </xsl:variable>
                <!-- der Satellit wird als hashed_column definiert
                     -->
                <xsl:text>  </xsl:text>
                <xsl:value-of select="upper-case($sat_name)"/>
                <xsl:text>_HASHDIFF:</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    is_hashdiff: true</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    columns:</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:if test="payload[@existenceFlag = 'yes']">
                    <xsl:text>    - '</xsl:text>
                    <xsl:value-of select="'EXISTENCE_FLAG'"/>
                    <xsl:text>'</xsl:text>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:if>
                <xsl:for-each select="payload/field">
                    <xsl:text>    - '</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>'</xsl:text>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:for-each>
            </xsl:for-each>
            <!-- aus dem Stage-Name wird der LS_HASHDIFF erzeugt -->
            <xsl:text>  </xsl:text>
            <xsl:text>LS_</xsl:text>
            <xsl:value-of select="fn:upper-case(@name)"/>
            <xsl:text>_HASHDIFF:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    is_hashdiff: true</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    columns:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    - 'LAST_SEEN'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <!-- die HASHDIFFs aller Satelliten, die aus diesem stg_file gefüllt werden,
                 werden hier als hashed column definiert
                 -->
            <xsl:for-each select="(hub|link)/ma_sat">
                <xsl:variable name="stage_name" select="../../@name"/>
                <xsl:variable name="hub_name" select="concat('hub_', ..[local-name() = 'hub']/nat_key/@idref)"/>
                <xsl:variable name="link_name" select="concat('link_', string-join(../nat_key/@idref, '_'))"/>
                <xsl:variable name="hub_key_prefix" select="/raw_vault/nat_keys/nat_key[@id = current()/..[local-name() = 'hub']/nat_key/@idref]/@name"/>
                <xsl:variable name="link_key_prefix" select="/raw_vault/links/link[@name = $link_name]/@prefix"/>
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
                <!-- der Satellit wird als hashed_column definiert
                     -->
                <xsl:text>  </xsl:text>
                <xsl:value-of select="upper-case($sat_name)"/>
                <xsl:text>_HASHDIFF:</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    is_hashdiff: true</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    columns:</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:for-each select="child_dependent_keys/field">
                    <xsl:text>    - '</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>'</xsl:text>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:for-each>
                <xsl:for-each select="payload/field">
                    <xsl:text>    - '</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>'</xsl:text>
                    <xsl:text>&#xA;</xsl:text>
                </xsl:for-each>
            </xsl:for-each>
            <xsl:text>  {%- endset -%}</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{% set metadata_dict = fromyaml(yaml_metadata) %}</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{% set source_model = metadata_dict['source_model'] %}</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{% set derived_columns = metadata_dict['derived_columns'] %}</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{% set hashed_columns = metadata_dict['hashed_columns'] %}</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- in staging.sql no WITH can be used, because the generated SQL statement </xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- can not be executed</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- the constant values for EFFECTIVE_FROM and LOAD_DATE have been moved to raw_*</xsl:text>
            <xsl:text>&#xA;</xsl:text>
             <xsl:text>-- bei Verwendung von dbt_sqlserver darf im staging.sql kein WITH verwendet werden, da </xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- das generierte SQL-Statement vom SQL-Server nicht ausgeführt wird</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- deshalb habe ich die Erzeugung der konstanten Werte für EFFECTIVE_FROM und LOAD_DATE nach raw_* verschoben</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- und komme hier mit einem einfachen SELECT aus</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- WITH staging AS (</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>{{ automate_dv.stage(include_source_columns=true,</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>                  source_model=source_model,</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>                  derived_columns=derived_columns,</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>                  hashed_columns=hashed_columns,</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>                  ranked_columns=none) }}</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- )</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- </xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- SELECT *,</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>--        CONVERT(DATE, '{{ var('load_date') }}', 23) AS EFFECTIVE_FROM,</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>--        CONVERT(DATE, '{{ var('load_date') }}', 23) AS LOAD_DATE</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- FROM staging</xsl:text>
            <xsl:text>&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genPsaPropertiesYml">

        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s01_psa_stage/properties.yml')}" method="text" omit-xml-declaration="yes">

            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: 2</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>models:</xsl:text>
            <xsl:text>&#xA;</xsl:text>

            <xsl:for-each select="db_source/table/stage">
                <xsl:if test="not(@psa) or @psa != 'false'">

                    <!-- @psa_name defaults to @name -->
                    <xsl:variable name="psa_name">
                        <xsl:choose>
                            <xsl:when test="@psa_name"><xsl:value-of select="@psa_name"/></xsl:when>
                            <xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:text>  - name: psa_</xsl:text>
                    <xsl:value-of select="$psa_name"/>
                    <xsl:text>&#xA;</xsl:text>
                    <xsl:text>    description: </xsl:text>
                    <xsl:value-of select="@psa_description"/>
                    <xsl:text>&#xA;</xsl:text>

                </xsl:if>

            </xsl:for-each>

        </xsl:result-document>

    </xsl:template>

    <xsl:template name="genRawPropertiesYml">

        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s02_raw_stage/properties.yml')}" method="text" omit-xml-declaration="yes">

            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: 2</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>models:</xsl:text>
            <xsl:text>&#xA;</xsl:text>

            <xsl:for-each select="db_source/table/stage">

                <xsl:text>  - name: raw_</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    description: </xsl:text>
                <xsl:value-of select="@raw_description"/>
                <xsl:text>&#xA;</xsl:text>

            </xsl:for-each>

        </xsl:result-document>

    </xsl:template>

    <xsl:template name="genStgPropertiesYml">

        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/models/s03_stage/properties.yml')}" method="text" omit-xml-declaration="yes">

            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: 2</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>models:</xsl:text>
            <xsl:text>&#xA;</xsl:text>

            <xsl:for-each select="db_source/table/stage">

                <xsl:text>  - name: stg_</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>    description: </xsl:text>
                <xsl:value-of select="@stg_description"/>
                <xsl:text>&#xA;</xsl:text>

            </xsl:for-each>

        </xsl:result-document>

    </xsl:template>

</xsl:stylesheet>
