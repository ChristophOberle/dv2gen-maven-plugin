<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="baseDir" select="/.."/>
    <xsl:template match="/raw_vault">
        <xsl:call-template name="genCreateSchemasSqlTemplate"/>
        <xsl:call-template name="genCreateRolesAndUsersSqlTemplate"/>
    </xsl:template>

    <xsl:template name="genCreateSchemasSqlTemplate">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/templates/DataVault/sql_scripts/DatabaseGrants/CreateSchemas.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:text>-- Script to initialize (or reset) the database</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- all SCHEMAs, TABLEs and other objects are dropped</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- and SCHEMAs are created</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>DROP SCHEMA IF EXISTS "DATAVAULT_PSA" CASCADE;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>CREATE SCHEMA "DATAVAULT_PSA";</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>DROP SCHEMA IF EXISTS "DATAVAULT" CASCADE;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>CREATE SCHEMA "DATAVAULT";</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:for-each select="db_sources/db_source">
                <xsl:text>DROP SCHEMA IF EXISTS "</xsl:text><xsl:value-of select="@schema"/><xsl:text>" CASCADE;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>CREATE SCHEMA "</xsl:text><xsl:value-of select="@schema"/><xsl:text>";</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>-- -- Schemas for MARTs etc. have to be added manually</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- DROP SCHEMA IF EXISTS "DATAVAULT_CONTROLLING" CASCADE;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- CREATE SCHEMA "DATAVAULT_CONTROLLING";</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="genCreateRolesAndUsersSqlTemplate">
        <xsl:result-document href="{concat('file://', $baseDir, '/target/classes/templates/DataVault/sql_scripts/DatabaseGrants/CreateRolesAndUsers.sql')}" method="text" omit-xml-declaration="yes">
            <xsl:for-each select="db_sources/db_source">
                <xsl:text>CREATE ROLE </xsl:text><xsl:value-of select="@name"/><xsl:text>_users;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>GRANT USAGE ON SCHEMA "</xsl:text><xsl:value-of select="@schema"/><xsl:text>" TO </xsl:text><xsl:value-of select="@name"/><xsl:text>_users;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>GRANT SELECT ON ALL TABLES IN SCHEMA "</xsl:text><xsl:value-of select="@schema"/><xsl:text>" TO </xsl:text><xsl:value-of select="@name"/><xsl:text>_users;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>CREATE ROLE dwh_admins;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>CREATE ROLE dwh_users;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>GRANT USAGE ON SCHEMA "DATAVAULT_PSA" TO dwh_admins;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA "DATAVAULT_PSA" TO dwh_admins;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA "DATAVAULT" TO dwh_admins;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>GRANT USAGE ON SCHEMA "DATAVAULT" TO dwh_admins;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>GRANT USAGE ON SCHEMA "DATAVAULT" TO dwh_users;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>GRANT SELECT ON ALL TABLES IN SCHEMA "DATAVAULT" TO dwh_users;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>--CREATE ROLE controlling_admins;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>--CREATE ROLE controlling_admins;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>--CREATE ROLE controlling_users;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- -- Grants for MARTs etc. have to be added manually</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- GRANT USAGE ON SCHEMA "DATAVAULT_CONTROLLING" TO controlling_users;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA "DATAVAULT_CONTROLLING" TO controlling_admins;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- GRANT SELECT ON ALL TABLES IN SCHEMA "DATAVAULT_CONTROLLING" TO controlling_users;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- GRANT dwh_users TO controlling_admins WITH INHERIT TRUE;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- -- Grants for users have to be added manually</xsl:text>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>-- GRANT source_users, dwh_admins, controlling_admins TO some_user WITH INHERIT TRUE;</xsl:text>
            <xsl:text>&#xA;</xsl:text>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
