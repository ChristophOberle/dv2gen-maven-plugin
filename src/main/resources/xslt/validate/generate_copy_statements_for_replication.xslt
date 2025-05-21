<?xml version="1.0" encoding="UTF-8"?>
<!-- Example, how to generate SQL-Statements from the GenRawVault control file -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/raw_vault">

        <xsl:for-each select="db_sources/db_source/table">
            <xsl:variable name="db_source_name" select="../@name"/>
            <xsl:message>select * into DWH_Transfer.<xsl:value-of select="../@name"/>.<xsl:value-of select="@name"/> from <xsl:value-of select="../@database"/>.<xsl:value-of select="../@schema"/>.<xsl:value-of select="@name"/>;</xsl:message>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
