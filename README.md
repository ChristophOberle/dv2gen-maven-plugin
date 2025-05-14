# dv2gen-maven-plugin
A maven plugin to generate a DataVault 2.0 data warehouse from an XML configuration

## Motivation
A Data Vault 2.0 data warehouse consists of many database artifacts which have to be defined in a consistent way.
In addition the scripts to run the data warehouse have to be automated.

One way to achieve these goals is to use dbt as a database tool and AutomateDV to describe the artifacts.

dbt Core is an open-source tool that enables data practitioners to transform data.

AutomateDV is a dbt package that generates & executes the ETL you need to build a Data Vault 2.0 Data Warehouse.

But even with this toolset there is a lot of redundancy in the definition of the artifacts.

With dv2gen-maven-plugin you describe the data warehouse in an XML configuration file and use the plugin to generate
all needed artifacts to define and run your data warehouse.

## Dependencies
dv2gen-maven-plugin uses Saxon to generate the data warehouse scripts.

The generated data warehouse scripts use
* Postgres
* dbt
* AutomateDV

## Features
The plugin uses the XML configuration and generates definitions for  
* DB scripts to load the data from csv files
* hubs
* links
* satellites
* multi-active satellites (macro ma_sat from AutomateDV)
* extended tracking satellites (macro xts from AutomateDV)
* views on links and satellites
* and more

## Changes
Version 1.0.1:
* includes batch scripts to import CSV files, load data into PSA tables and load data from PSA tables to the RawVault and BusinessVault
* includes sql_scripts to create db schemas and roles and users in the postgres db
* includes a dbt_project.yml file to define the dbt project
* includes the packages.yml file with the AutomateDV package for dbt
