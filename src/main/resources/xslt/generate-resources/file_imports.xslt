<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault/db_sources/db_source">

        <xsl:for-each select="table/import">
            <xsl:call-template name="genCreate"/>
            <xsl:call-template name="genBulkInsert"/>
            <xsl:call-template name="genDrop"/>
            <xsl:call-template name="genSelectForCsv"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="genCreate">
        <xsl:variable name="db_source" select="../../@name"/>
        <xsl:variable name="table_name" select="../@name"/>
        <xsl:variable name="csv_name" select="@csv_name"/>
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/sql_scripts/DataVault_import/', ../../file_import/@script_dir, '/Create_', $table_name,'.sql')}" method="text" omit-xml-declaration="yes">

            <xsl:text>&#xA;</xsl:text>
            <xsl:text>CREATE TABLE "$(DATABASE)"."$(DBSCHEMA)"."</xsl:text>
            <xsl:value-of select="$table_name"/>
            <xsl:text>" (</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:for-each select="/raw_vault/db_sources/db_source[@name = $db_source]/table[@name = $table_name]/fields/field">
                <xsl:text>    </xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="@type"/>
                <xsl:text>,</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>

            <xsl:text>    CONSTRAINT PK_$(DBSCHEMA)_</xsl:text>
            <xsl:value-of select="$table_name"/>
            <xsl:text> PRIMARY KEY (</xsl:text>
            <!-- Normalfall: der unique_key ist im file-Element angegeben -->
            <xsl:for-each select="/raw_vault/db_sources/db_source[@name = $db_source]/table[@name = $table_name]/unique_key/field">
                <xsl:if test="position() &gt; 1">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:value-of select="@name"/>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
            <xsl:text>&#xA;</xsl:text>

            <xsl:text>);</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>

            <xsl:text>GRANT ALL PRIVILEGES ON TABLE "$(DATABASE)"."$(DBSCHEMA)"."</xsl:text>
            <xsl:value-of select="$table_name"/>
            <xsl:text>" TO dwh_admins</xsl:text>
            <xsl:text>;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genBulkInsert">
        <xsl:variable name="db_source" select="../../@name"/>
        <xsl:variable name="table_name" select="../@name"/>
        <xsl:variable name="csv_name" select="@csv_name"/>
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/sql_scripts/DataVault_import/', ../../file_import/@script_dir, '/Bulk_insert_', $table_name,'.sql')}" method="text" omit-xml-declaration="yes">

            <xsl:text>&#xA;</xsl:text>

            <xml:text>COPY </xml:text>
            <xml:text>"$(DATABASE)"."$(DBSCHEMA)"."</xml:text>
            <xsl:value-of select="$table_name"/>
            <xsl:text>"</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>FROM $(FILENAME)</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>WITH</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>(</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>FORMAT csv</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:if test="../../file_import/@header = 'yes'">
                <xsl:text>, HEADER</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:if>
            <xsl:text>, ENCODING utf8</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <!-- Todo: wie wird bei pg der Rowterminator definiert?
            <xsl:text>  , ROWTERMINATOR = '0x0a'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            -->
            <xsl:text>, DELIMITER ';'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>, QUOTE '"'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>, ESCAPE '\'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>)</xsl:text>
            <xsl:text>;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genDrop">
        <xsl:variable name="db_source" select="../../@name"/>
        <xsl:variable name="table_name" select="../@name"/>
        <xsl:variable name="csv_name" select="@csv_name"/>
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/sql_scripts/DataVault_import/', ../../file_import/@script_dir, '/Drop_', $table_name,'.sql')}" method="text" omit-xml-declaration="yes">

            <xsl:text>&#xA;</xsl:text>
            <xsl:text>DROP TABLE IF EXISTS "$(DATABASE)"."$(DBSCHEMA)"."</xsl:text>
            <xsl:value-of select="$table_name"/>
            <xsl:text>"</xsl:text>
            <xsl:text> CASCADE</xsl:text>
            <xsl:text>;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genSelectForCsv">
        <xsl:variable name="db_source" select="../../@name"/>
        <xsl:variable name="table_name" select="../@name"/>
        <xsl:variable name="csv_name" select="@csv_name"/>
        <!-- this script generates code for SQL-Server! -->
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/DataVault/sql_scripts/OpSys_export/', ../../file_import/@script_dir, '/', ../@name,'.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <!-- Header-Zeile schreiben -->
            <xsl:for-each select="/raw_vault/db_sources/db_source[@name = $db_source]/table[@name = $table_name]/fields/field">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <xsl:text>select </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>     + </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>'"C</xsl:text>
                <xsl:value-of select="position()"/>
                <xsl:text>"'</xsl:text>
                <xsl:if test="position() &lt; last()">
                    <xsl:text> + ';'</xsl:text>
                </xsl:if>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>union all</xsl:text>
            <xsl:text>&#xA;</xsl:text>

            <!-- Daten schreiben -->
            <xsl:for-each select="/raw_vault/db_sources/db_source[@name = $db_source]/table[@name = $table_name]/fields/field">
                <xsl:variable name="field_name">
                    <xsl:choose>
                        <xsl:when test="@export_name"><xsl:value-of select="@export_name"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="@name"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <xsl:text>select </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>     + </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>case when </xsl:text>
                <xsl:value-of select="$field_name"/>
                <xsl:text> is null then '' else </xsl:text>
                <xsl:choose>
                    <xsl:when test="@type = 'integer' or @type = 'smallint'">
                        <!-- Datentyp integer oder smallint -->
                        <xsl:text>'"' + replace(cast(</xsl:text>
                        <xsl:value-of select="$field_name"/>
                        <xsl:text> as varchar), '"', '""') + '"'</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(@type,'numeric') or starts-with(@type, 'decimal')">
                        <!-- Datentyp numeric oder decimal -->
                        <xsl:text>'"' + replace(cast(</xsl:text>
                        <xsl:value-of select="$field_name"/>
                        <xsl:text> as varchar), '"', '""') + '"'</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'timestamp(3)'">
                        <!-- Datentyp timestamp(3) -->
                        <xsl:text>'"' + convert(varchar, </xsl:text>
                        <xsl:value-of select="$field_name"/>
                        <xsl:text>, 126) + '"'</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'timestamp(0)'">
                        <!-- Datentyp timestamp(0) -->
                        <xsl:text>'"' + convert(varchar, </xsl:text>
                        <xsl:value-of select="$field_name"/>
                        <xsl:text>, 120) + '"'</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'boolean'">
                        <!-- Datentyp boolean -->
                        <xsl:text>'"' + cast(</xsl:text>
                        <xsl:value-of select="$field_name"/>
                        <xsl:text> as varchar) + '"'</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'bigint'">
                        <!-- Datentyp bigint -->
                        <xsl:text>'"' + cast(</xsl:text>
                        <xsl:value-of select="$field_name"/>
                        <xsl:text> as varchar) + '"'</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'text'">
                        <!-- Datentyp text -->
                        <xsl:text>'"' + trim(cast(</xsl:text>
                        <xsl:value-of select="$field_name"/>
                        <xsl:text> as varchar)) + '"'</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Datentyp char oder varchar -->
                        <xsl:text>'"' + replace(replace(trim(cast(</xsl:text>
                        <xsl:value-of select="$field_name"/>
                        <xsl:text> as </xsl:text>
                        <xsl:value-of select="@type"/>
                        <xsl:text>)), '\', '\\'), '"', '\"') + '"'</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> end</xsl:text>
                <xsl:if test="position() &lt; last()">
                    <xsl:text> + ';'</xsl:text>
                </xsl:if>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>from $(DATABASE).$(DBSCHEMA).</xsl:text>
            <xsl:value-of select="$table_name"/>
            <xsl:text>;</xsl:text>
            <xsl:text>&#xA;</xsl:text>

        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
