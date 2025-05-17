<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault">
        <xsl:call-template name="genDbtProjectYmlTemplate"/>
        <xsl:call-template name="genProfilesYmlTemplate"/>
        <xsl:call-template name="genPgPassTemplate"/>
        <xsl:call-template name="genGetCredentialsPs1Template"/>
    </xsl:template>

    <xsl:template name="genDbtProjectYmlTemplate">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/templates/DataVault/dbt_project.yml')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>name: </xsl:text>
            <xsl:value-of select="system/@name"/>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>profile: </xsl:text>
            <xsl:value-of select="system/@name"/>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>version: '5.3.0'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>require-dbt-version: ['>=1.0.0', '&lt;2.0.0']</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>config-version: 2</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>vars:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  # disable ghost records</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  # ghost records are disabled, because the postgres implementation of ghost records in AutomateDV obviously generates wrong HASH_KEYs</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  enable_ghost_records: false</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>analysis-paths:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  - analysis</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>clean-targets:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  - target</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>seed-paths:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  - seeds</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>macro-paths:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  - macros</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>model-paths:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  - models</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>test-paths:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  - tests</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>target-path: target</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>models:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  +on_schema_change: "fail"</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  </xsl:text><xsl:value-of select="system/@name"/><xsl:text>:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    s01_psa_stage:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      +schema: PSA</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        - 'psa'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      materialized: incremental</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      +grants:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          select: ['dwh_admins']</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:for-each select="db_sources/db_source[not(table/stage/@psa) or table/stage/@psa = 'true']">
                <xsl:text>      </xsl:text><xsl:value-of select="@name"/><xsl:text>:</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>        tags:</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>          - 'psa_</xsl:text><xsl:value-of select="@name"/><xsl:text>'</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>    s02_raw_stage:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        - 'raw'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      materialized: view</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      +grants:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          select: ['dwh_admins']</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:for-each select="db_sources/db_source">
                <xsl:text>      </xsl:text><xsl:value-of select="@name"/><xsl:text>:</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>        tags:</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>          - 'raw_</xsl:text><xsl:value-of select="@name"/><xsl:text>'</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>    s03_stage:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        - 'stage'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      enabled: true</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      materialized: table</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      +grants:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          select: ['dwh_admins']</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    s04_raw_vault:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        - 'raw_vault'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      materialized: incremental</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      +grants:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          select: ['dwh_admins', 'dwh_users']</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      hub:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          - 'raw_vault_hub'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      link:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          - 'raw_vault_link'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      sat:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          - 'raw_vault_sat'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      mas:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          - 'raw_vault_mas'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      xts:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          - 'raw_vault_xts'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      vlink:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          - 'raw_vault_vlink'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        materialized: view</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      vsat:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          - 'raw_vault_vsat'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        materialized: view</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      vmas:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          - 'raw_vault_vmas'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        materialized: view</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      vxts:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          - 'raw_vault_vxts'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        materialized: view</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #s05_bv_raw_stage:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #  tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #    - 'bv_raw'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #  materialized: view</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #  +grants:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #      select: ['dwh_admins']</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #s06_bv_stage:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #  tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #    - 'bv_stage'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #  enabled: true</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #  materialized: table</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #  +grants:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #      select: ['dwh_admins']</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    s07_business_vault:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        - 'business_vault'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      materialized: incremental</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      +grants:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          select: ['dwh_admins', 'dwh_users']</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      as_of_date:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          - 'as_of_date'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        materialized: table</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>      pit:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>          - 'pit'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        materialized: pit_incremental</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>        +grants:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>            select: ['dwh_admins', 'dwh_users']</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    # an example for a model directory of a data mart</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #s08_mart_controlling:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #  +schema: CONTROLLING</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #  tags:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #    - 'marts'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #    - 'mart_controlling'</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #  materialized: table</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #  +grants:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>    #      select: ['controlling_admins', 'controlling_users']</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genProfilesYmlTemplate">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/templates/home/.dbt/profiles.yml')}" method="text" omit-xml-declaration="yes">
            <xsl:text>&#xA;</xsl:text>
            <xsl:value-of select="system/@name"/><xsl:text>:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  target: dev</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>  outputs:</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:for-each select="system/target">
                <xsl:text>    </xsl:text><xsl:value-of select="@name"/><xsl:text>:</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      type: postgres</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      host: </xsl:text><xsl:value-of select="@server"/>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      port: </xsl:text><xsl:value-of select="@port"/>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      database: </xsl:text><xsl:value-of select="@database"/>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      schema: </xsl:text><xsl:value-of select="@schema"/>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      user: ***user***</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      password: ***password***</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      threads: 1</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      keepalives_idle: 0 # default 0, indicating the system default. See below</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      connect_timeout: 10 # default 10 seconds</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>      retries: 1  # default 1 retry on error/timeout when opening connections</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genPgPassTemplate">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/templates/home/.pgpass')}" method="text" omit-xml-declaration="yes">
            <xsl:text>#Host:Port:Database:User:Passwort</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:for-each select="system/target">
                <xsl:text># </xsl:text><xsl:value-of select="../@name"/><xsl:text> target </xsl:text><xsl:value-of select="@name"/>
                <xsl:text>&#xA;</xsl:text>
                <xsl:value-of select="@server"/>
                <xsl:text>:</xsl:text>
                <xsl:value-of select="@port"/>
                <xsl:text>:</xsl:text>
                <xsl:value-of select="@database"/>
                <xsl:text>:</xsl:text>
                <xsl:text>***user***:***password***</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genGetCredentialsPs1Template">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/templates/home/get_credentials.ps1')}" method="text" omit-xml-declaration="yes">
            <xsl:text># Postgres</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>$PGUSER = "***user***"</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text># $PGPASSWORD is not set</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text># It is specified in file .pgpass in the user's home directory for the combination of server, port, database and user
            </xsl:text>
            <xsl:text>&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
