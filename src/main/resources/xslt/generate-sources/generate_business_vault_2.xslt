<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!--xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"-->
    <xsl:output indent="yes"/>

    <xsl:param name="baseDir" select="/.."/>

    <xsl:template match="/">
        <xsl:apply-templates select="business_vault"/>
    </xsl:template>

    <xsl:template match="business_vault">
        <!--xsl:result-document href="'target/classes/DataVault/generated-sources/xml/BusinessVault_2.xml'" method="xml"-->
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
            <xsl:text>&#xA;</xsl:text>
        <!--/xsl:result-document-->
    </xsl:template>

    <xsl:template match="pit_tables">
        <xsl:variable name="as_of_dates" select="@as_of_dates"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="document(concat('file://', $baseDir, '/target/classes/DataVault/generated-sources/xml/RawVault.xml'))/raw_vault/(hubs/hub|links/link)[stages/stage/sat|stages/stage/ma_sat]">
                <!-- erzeuge pit_table für die Hubs und Links
                     mit allen sat und mas, die an dem Hub oder Link hängen
                -->
                <xsl:if test="not(preceding-sibling::link[@name = current()/@name])">
                    <xsl:variable name="ref_name" select="@name"/>
                    <pit_table>
                        <xsl:attribute name="ref_name" select="$ref_name"/>
                        <xsl:attribute name="ref_pk">
                            <xsl:choose>
                                <xsl:when test="local-name() = 'hub'">
                                    <xsl:value-of select="/raw_vault/nat_keys/nat_key[@id = current()/nat_key/@idref]/@name"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@prefix"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>_PK</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="as_of_date" select="$as_of_dates"/>
                        <xsl:for-each select="stages/stage[sat|ma_sat]">
                            <xsl:copy>
                                <xsl:apply-templates select="@name"/>
                                <xsl:for-each select="sat|ma_sat">
                                    <xsl:copy>
                                        <xsl:apply-templates select="@name"/>
                                    </xsl:copy>
                                </xsl:for-each>
                            </xsl:copy>
                        </xsl:for-each>
                    </pit_table>
                </xsl:if>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <!--Identity template, kopiert alles unverändert -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
