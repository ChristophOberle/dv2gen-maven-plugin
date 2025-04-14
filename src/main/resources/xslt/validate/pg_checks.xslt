<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- pg_checks.xslt checks, whether PostgreSQL specific limits are violated
         -->
    <xsl:template match="/raw_vault">
        <xsl:call-template name="test_sats_not_more_than_50_payload_fields"/>
    </xsl:template>

    <xsl:template name="test_sats_not_more_than_50_payload_fields">
        <!-- the environment variable FUNC_MAX_ARGS defines the maximum nr. of arguments a function can have
             it is used during compilation of the PostgreSQL server. Currently FUNC_MAX_ARGS is 100.
             In dbt there is a concat function for the HASHDIFFs which uses n_payload_filed + (n_payload_field - 1) args
             -->
        <xsl:for-each select="dv_tables/sat/payload">
            <xsl:if test="count(field) &gt; 50 ">
                <xsl:message>PostgreSQL limit violated: <xsl:value-of select="../@name"/> has <xsl:value-of select="count(field)"/> payload fields, which is more than the maximum allowed 50 payload fields</xsl:message>
                <xsl:text>failed</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
