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
        <!--xsl:result-document href="'target/classes/DataVault/generated-sources/xml/BusinessVault.xml'" method="xml"-->
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:text>&#xA;    </xsl:text>
                <xsl:comment>DO NOT CHANGE THIS FILE! It is generated by gen_business_vault.xslt</xsl:comment>
                <xsl:text>&#xA;    </xsl:text>
                <xsl:comment>Diese Datei ist generiert!</xsl:comment>
                <xsl:text>&#xA;    </xsl:text>
                <xsl:for-each select="document(concat('file://', $baseDir, '/src/main/xml/RawVault.xml'))/raw_vault">
                    <xsl:apply-templates select="system"/>
                </xsl:for-each>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
            <xsl:text>&#xA;</xsl:text>
        <!--/xsl:result-document-->
    </xsl:template>

    <!--Identity template, kopiert alles unverändert -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
