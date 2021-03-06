-- Jun 22 2015 10:18AM-- DEBUG - Table ##SecurityGenerationResults created
-- Jun 22 2015 10:18AM-- DEBUG - Table ##SecurityScriptResultsCommandsOrder created
-- Jun 22 2015 10:18AM - DEBUG -     > Login creation statements
-- Jun 22 2015 10:18AM - DEBUG - Every logins generation detected.
-- Jun 22 2015 10:18AM - DEBUG - Taking care of login ApplicationSQLUser1 (John Doe)
-- Jun 22 2015 10:18AM - DEBUG - Taking care of login ApplicationSQLUser2 (Jane Doe)
-- Jun 22 2015 10:18AM - DEBUG - Taking care of login ApplicationSQLUser3 (John Smith)
-- Jun 22 2015 10:18AM - DEBUG - Taking care of login ApplicationSQLUser4 (Lazy Worker)
-- Jun 22 2015 10:18AM - DEBUG - Taking care of login CHULg\c168350 (c168350)
-- Jun 22 2015 10:18AM - DEBUG - Taking care of login CHULg\SAI_Db (SAI_Db)
-- Jun 22 2015 10:18AM - DEBUG - Full server generation mode detected.
--------------------------------------------------------------------------------------------------------------
-- Jun 22 2015 10:18AM - DEBUG - Server Name : SI-S-SERV236
-- Jun 22 2015 10:18AM - DEBUG - Database set to JEL_SecurityManager_TestingFeature
 
-- Jun 22 2015 10:18AM - DEBUG -     > Schema creation statements
-- Jun 22 2015 10:18AM - DEBUG - Every Schema generation detected.
-- Jun 22 2015 10:18AM - DEBUG -     > Database user creation statements
-- Jun 22 2015 10:18AM - DEBUG - Every users in database generation detected.
-- Jun 22 2015 10:18AM - DEBUG - ServerName SI-S-SERV236
-- Jun 22 2015 10:18AM - DEBUG - DbName     JEL_SecurityManager_TestingFeature
-- Jun 22 2015 10:18AM - DEBUG - Taking care of user ApplicationSQLUser1
-- Jun 22 2015 10:18AM - DEBUG - ServerName SI-S-SERV236
-- Jun 22 2015 10:18AM - DEBUG - DbName     JEL_SecurityManager_TestingFeature
-- Jun 22 2015 10:18AM - DEBUG - Taking care of user ApplicationSQLUser3
-- Jun 22 2015 10:18AM - DEBUG - ServerName SI-S-SERV236
-- Jun 22 2015 10:18AM - DEBUG - DbName     JEL_SecurityManager_TestingFeature
-- Jun 22 2015 10:18AM - DEBUG - Taking care of user CHULg\c168350
-- Jun 22 2015 10:18AM - DEBUG - ServerName SI-S-SERV236
-- Jun 22 2015 10:18AM - DEBUG - DbName     JEL_SecurityManager_TestingFeature
-- Jun 22 2015 10:18AM - DEBUG - Taking care of user DbUser2
-- Jun 22 2015 10:18AM - DEBUG - ServerName SI-S-SERV236
-- Jun 22 2015 10:18AM - DEBUG - DbName     JEL_SecurityManager_TestingFeature
-- Jun 22 2015 10:18AM - DEBUG - Taking care of user DbUser4
-- Jun 22 2015 10:18AM - DEBUG -     > Login to database user creation statements
-- Jun 22 2015 10:18AM - DEBUG - All mappings for database JEL_SecurityManager_TestingFeature detected
-- Jun 22 2015 10:18AM - DEBUG -     > Database Roles creation and assignment statements
-- Jun 22 2015 10:18AM - DEBUG - Every Role generation detected.
-- Jun 22 2015 10:18AM - DEBUG - Every Role membership generation detected.
-- Jun 22 2015 10:18AM - DEBUG -     > Object-level permission assignment statements
-- Jun 22 2015 10:18AM - DEBUG - Every permission assignment detected.
-- Jun 22 2015 10:18AM - DEBUG - Taking care of permissions for [ApplicationSchema1_data_modifier] in database [JEL_SecurityManager_TestingFeature]
-- Jun 22 2015 10:18AM - DEBUG - Taking care of permissions for [ApplicationSchema1_data_reader] in database [JEL_SecurityManager_TestingFeature]
-- Jun 22 2015 10:18AM - DEBUG - Taking care of permissions for [ApplicationSchema1_prog_executors] in database [JEL_SecurityManager_TestingFeature]
-- Jun 22 2015 10:18AM - DEBUG - Taking care of permissions for [ApplicationSchema1_struct_modifier] in database [JEL_SecurityManager_TestingFeature]
-- Jun 22 2015 10:18AM - DEBUG - Taking care of permissions for [ApplicationSchema1_struct_viewer] in database [JEL_SecurityManager_TestingFeature]
-- Jun 22 2015 10:18AM - DEBUG - Taking care of permissions for [ApplicationSchema2_data_modifier] in database [JEL_SecurityManager_TestingFeature]
-- Jun 22 2015 10:18AM - DEBUG - Taking care of permissions for [ApplicationSchema2_data_reader] in database [JEL_SecurityManager_TestingFeature]
-- Jun 22 2015 10:18AM - DEBUG - Taking care of permissions for [ApplicationSchema2_prog_executors] in database [JEL_SecurityManager_TestingFeature]
-- Jun 22 2015 10:18AM - DEBUG - Taking care of permissions for [ApplicationSchema2_struct_modifier] in database [JEL_SecurityManager_TestingFeature]
-- Jun 22 2015 10:18AM - DEBUG - Taking care of permissions for [ApplicationSchema2_struct_viewer] in database [JEL_SecurityManager_TestingFeature]
-- Jun 22 2015 10:18AM - INFO - Generation successful
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- Jun 22 2015 10:18AM - DEBUG - Server Name : SI-S-SERV236
-- Jun 22 2015 10:18AM - DEBUG - Database set to master
 
-- Jun 22 2015 10:18AM - DEBUG -     > Schema creation statements
-- Jun 22 2015 10:18AM - DEBUG - Every Schema generation detected.
-- Jun 22 2015 10:18AM - DEBUG -     > Database user creation statements
-- Jun 22 2015 10:18AM - DEBUG - Every users in database generation detected.
-- Jun 22 2015 10:18AM - DEBUG - ServerName SI-S-SERV236
-- Jun 22 2015 10:18AM - DEBUG - DbName     master
-- Jun 22 2015 10:18AM - DEBUG - Taking care of user CHULg\c168350
-- Jun 22 2015 10:18AM - DEBUG - ServerName SI-S-SERV236
-- Jun 22 2015 10:18AM - DEBUG - DbName     master
-- Jun 22 2015 10:18AM - DEBUG - Taking care of user CHULg\SAI_Db
-- Jun 22 2015 10:18AM - DEBUG -     > Login to database user creation statements
-- Jun 22 2015 10:18AM - DEBUG - All mappings for database master detected
-- Jun 22 2015 10:18AM - DEBUG -     > Database Roles creation and assignment statements
-- Jun 22 2015 10:18AM - DEBUG - Every Role generation detected.
-- Jun 22 2015 10:18AM - DEBUG - Every Role membership generation detected.
-- Jun 22 2015 10:18AM - DEBUG -     > Object-level permission assignment statements
-- Jun 22 2015 10:18AM - DEBUG - Every permission assignment detected.
-- Jun 22 2015 10:18AM - INFO - Generation successful
--------------------------------------------------------------------------------------------------------------
-- Jun 22 2015 10:18AM - DEBUG - Creating table (if not exists) where we must save results
-- Jun 22 2015 10:18AM - DEBUG - Filling in with results 
IF (@@SERVERNAME <> 'SI-S-SERV236')
BEGIN
    RAISERROR('Expected @@ServerName : "SI-S-SERV236"', 16, 0)
END
IF NOT EXISTS( SELECT 1 FROM sys.databases where Name =  'JEL_SecurityManager_TestingFeature')
BEGIN
    RAISERROR('The Database named : "JEL_SecurityManager_TestingFeature" doesn''t exist on server !', 16, 0)
END
IF NOT EXISTS( SELECT 1 FROM sys.databases where Name =  'master')
BEGIN
    RAISERROR('The Database named : "master" doesn''t exist on server !', 16, 0)
END
PRINT '. Commands for "John Doe" from department "MyCorp/IT Service/Application Support Team"'
DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('ApplicationSQLUser1')
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE  QUOTENAME(name) = @loginToPlayWith)
BEGIN
    -- create it !
    EXEC ('USE [master]; CREATE LOGIN [ApplicationSQLUser1] WITH PASSWORD=N''123456a.'' , DEFAULT_DATABASE=[JEL_SecurityManager_TestingFeature]')
END
GO

DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('ApplicationSQLUser1')
-- getting some infos to carry on
DECLARE @loginIsDisabled BIT
DECLARE @loginDefaultDb  SYSNAME
select
    @loginIsDisabled   = is_disabled ,
    @loginDefaultDb    = QUOTENAME(default_database_name)
from
    master.sys.server_principals
where QUOTENAME(name) = @loginToPlayWith

-- ENABLE|DISABLE login
if @loginIsDisabled = 1
BEGIN
    ALTER LOGIN [ApplicationSQLUser1] ENABLE
END

-- If necessary, give the login the permission to connect the database engine
if not exists (select 1 from master.sys.server_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @loginToPlayWith and permission_name = 'CONNECT SQL' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT SQL TO [ApplicationSQLUser1]' );
END

-- If necessary, set the default database for this login
if ISNULL(@loginDefaultDb,'<null>') <> QUOTENAME('JEL_SecurityManager_TestingFeature')
BEGIN
    exec sp_defaultdb @loginame = 'ApplicationSQLUser1' , @DefDb = 'JEL_SecurityManager_TestingFeature'
END
-- Password policy settings
-- ------------------------
DECLARE @loginHasPwdPolicyChecked BIT
DECLARE @loginHasPwdExpireChecked BIT
select
    @loginHasPwdPolicyChecked = is_policy_checked,
    @loginHasPwdExpireChecked = is_expiration_checked
from master.sys.sql_logins
where QUOTENAME(name) = @loginToPlayWith

-- by default : no password policy is defined
if @loginHasPwdPolicyChecked <> 0
BEGIN
    ALTER LOGIN [ApplicationSQLUser1] WITH CHECK_EXPIRATION=OFF
END
if @loginHasPwdExpireChecked <> 0
BEGIN
    ALTER LOGIN [ApplicationSQLUser1] WITH CHECK_POLICY=OFF
END

GO

PRINT '. Commands for "Jane Doe" from department "External/DevCorp/DevProduct"'
DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('ApplicationSQLUser2')
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE  QUOTENAME(name) = @loginToPlayWith)
BEGIN
    -- create it !
    EXEC ('USE [master]; CREATE LOGIN [ApplicationSQLUser2] WITH PASSWORD=N''123456a.'' , DEFAULT_DATABASE=[JEL_SecurityManager_TestingFeature]')
END
GO

DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('ApplicationSQLUser2')
-- getting some infos to carry on
DECLARE @loginIsDisabled BIT
DECLARE @loginDefaultDb  SYSNAME
select
    @loginIsDisabled   = is_disabled ,
    @loginDefaultDb    = QUOTENAME(default_database_name)
from
    master.sys.server_principals
where QUOTENAME(name) = @loginToPlayWith

-- ENABLE|DISABLE login
if @loginIsDisabled = 0
BEGIN
    ALTER LOGIN [ApplicationSQLUser2] DISABLE
END

-- If necessary, give the login the permission to connect the database engine
if not exists (select 1 from master.sys.server_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @loginToPlayWith and permission_name = 'CONNECT SQL' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT SQL TO [ApplicationSQLUser2]' );
END

-- If necessary, set the default database for this login
if ISNULL(@loginDefaultDb,'<null>') <> QUOTENAME('JEL_SecurityManager_TestingFeature')
BEGIN
    exec sp_defaultdb @loginame = 'ApplicationSQLUser2' , @DefDb = 'JEL_SecurityManager_TestingFeature'
END
-- Password policy settings
-- ------------------------
DECLARE @loginHasPwdPolicyChecked BIT
DECLARE @loginHasPwdExpireChecked BIT
select
    @loginHasPwdPolicyChecked = is_policy_checked,
    @loginHasPwdExpireChecked = is_expiration_checked
from master.sys.sql_logins
where QUOTENAME(name) = @loginToPlayWith

-- by default : no password policy is defined
if @loginHasPwdPolicyChecked <> 0
BEGIN
    ALTER LOGIN [ApplicationSQLUser2] WITH CHECK_EXPIRATION=OFF
END
if @loginHasPwdExpireChecked <> 0
BEGIN
    ALTER LOGIN [ApplicationSQLUser2] WITH CHECK_POLICY=OFF
END

GO

PRINT '. Commands for "John Smith" from department "External/DevCorp/DevProduct"'
DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('ApplicationSQLUser3')
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE  QUOTENAME(name) = @loginToPlayWith)
BEGIN
    -- create it !
    EXEC ('USE [master]; CREATE LOGIN [ApplicationSQLUser3] WITH PASSWORD=N''123456a.'' , DEFAULT_DATABASE=[JEL_SecurityManager_TestingFeature]')
END
GO

DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('ApplicationSQLUser3')
-- getting some infos to carry on
DECLARE @loginIsDisabled BIT
DECLARE @loginDefaultDb  SYSNAME
select
    @loginIsDisabled   = is_disabled ,
    @loginDefaultDb    = QUOTENAME(default_database_name)
from
    master.sys.server_principals
where QUOTENAME(name) = @loginToPlayWith

-- ENABLE|DISABLE login
if @loginIsDisabled = 0
BEGIN
    ALTER LOGIN [ApplicationSQLUser3] DISABLE
END

-- If necessary, give the login the permission to connect the database engine
if not exists (select 1 from master.sys.server_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @loginToPlayWith and permission_name = 'CONNECT SQL' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT SQL TO [ApplicationSQLUser3]' );
END

-- If necessary, set the default database for this login
if ISNULL(@loginDefaultDb,'<null>') <> QUOTENAME('JEL_SecurityManager_TestingFeature')
BEGIN
    exec sp_defaultdb @loginame = 'ApplicationSQLUser3' , @DefDb = 'JEL_SecurityManager_TestingFeature'
END
-- Password policy settings
-- ------------------------
DECLARE @loginHasPwdPolicyChecked BIT
DECLARE @loginHasPwdExpireChecked BIT
select
    @loginHasPwdPolicyChecked = is_policy_checked,
    @loginHasPwdExpireChecked = is_expiration_checked
from master.sys.sql_logins
where QUOTENAME(name) = @loginToPlayWith

-- by default : no password policy is defined
if @loginHasPwdPolicyChecked <> 0
BEGIN
    ALTER LOGIN [ApplicationSQLUser3] WITH CHECK_EXPIRATION=OFF
END
if @loginHasPwdExpireChecked <> 0
BEGIN
    ALTER LOGIN [ApplicationSQLUser3] WITH CHECK_POLICY=OFF
END

GO

PRINT '. Commands for "Lazy Worker" from department "External/DevCorp/DevProduct"'
DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('ApplicationSQLUser4')
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE  QUOTENAME(name) = @loginToPlayWith)
BEGIN
    -- create it !
    EXEC ('USE [master]; CREATE LOGIN [ApplicationSQLUser4] WITH PASSWORD=N''123456a.'' , DEFAULT_DATABASE=[JEL_SecurityManager_TestingFeature]')
END
GO

DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('ApplicationSQLUser4')
-- getting some infos to carry on
DECLARE @loginIsDisabled BIT
DECLARE @loginDefaultDb  SYSNAME
select
    @loginIsDisabled   = is_disabled ,
    @loginDefaultDb    = QUOTENAME(default_database_name)
from
    master.sys.server_principals
where QUOTENAME(name) = @loginToPlayWith

-- ENABLE|DISABLE login
if @loginIsDisabled = 0
BEGIN
    ALTER LOGIN [ApplicationSQLUser4] DISABLE
END

-- If necessary, give the login the permission to connect the database engine
if not exists (select 1 from master.sys.server_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @loginToPlayWith and permission_name = 'CONNECT SQL' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT SQL TO [ApplicationSQLUser4]' );
END

-- If necessary, set the default database for this login
if ISNULL(@loginDefaultDb,'<null>') <> QUOTENAME('JEL_SecurityManager_TestingFeature')
BEGIN
    exec sp_defaultdb @loginame = 'ApplicationSQLUser4' , @DefDb = 'JEL_SecurityManager_TestingFeature'
END
-- Password policy settings
-- ------------------------
DECLARE @loginHasPwdPolicyChecked BIT
DECLARE @loginHasPwdExpireChecked BIT
select
    @loginHasPwdPolicyChecked = is_policy_checked,
    @loginHasPwdExpireChecked = is_expiration_checked
from master.sys.sql_logins
where QUOTENAME(name) = @loginToPlayWith

-- by default : no password policy is defined
if @loginHasPwdPolicyChecked <> 0
BEGIN
    ALTER LOGIN [ApplicationSQLUser4] WITH CHECK_EXPIRATION=OFF
END
if @loginHasPwdExpireChecked <> 0
BEGIN
    ALTER LOGIN [ApplicationSQLUser4] WITH CHECK_POLICY=OFF
END

GO

PRINT '. Commands for "c168350" from department "MyCorp/IT Service/DBA"'
DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('CHULg\c168350')
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE  QUOTENAME(name) = @loginToPlayWith)
BEGIN
    -- create it !
    EXEC ('USE [master]; CREATE LOGIN [CHULg\c168350] FROM WINDOWS  , DEFAULT_DATABASE=[JEL_SecurityManager_TestingFeature]')
END
GO

DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('CHULg\c168350')
-- getting some infos to carry on
DECLARE @loginIsDisabled BIT
DECLARE @loginDefaultDb  SYSNAME
select
    @loginIsDisabled   = is_disabled ,
    @loginDefaultDb    = QUOTENAME(default_database_name)
from
    master.sys.server_principals
where QUOTENAME(name) = @loginToPlayWith

-- ENABLE|DISABLE login
if @loginIsDisabled = 1
BEGIN
    ALTER LOGIN [CHULg\c168350] ENABLE
END

-- If necessary, give the login the permission to connect the database engine
if not exists (select 1 from master.sys.server_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @loginToPlayWith and permission_name = 'CONNECT SQL' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT SQL TO [CHULg\c168350]' );
END

-- If necessary, set the default database for this login
if ISNULL(@loginDefaultDb,'<null>') <> QUOTENAME('JEL_SecurityManager_TestingFeature')
BEGIN
    exec sp_defaultdb @loginame = 'CHULg\c168350' , @DefDb = 'JEL_SecurityManager_TestingFeature'
END

GO

PRINT '. Commands for "SAI_Db" from department "MyCorp/IT Service/Validation Team"'
DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('CHULg\SAI_Db')
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE  QUOTENAME(name) = @loginToPlayWith)
BEGIN
    -- create it !
    EXEC ('USE [master]; CREATE LOGIN [CHULg\SAI_Db] FROM WINDOWS  , DEFAULT_DATABASE=[master]')
END
GO

DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('CHULg\SAI_Db')
-- getting some infos to carry on
DECLARE @loginIsDisabled BIT
DECLARE @loginDefaultDb  SYSNAME
select
    @loginIsDisabled   = is_disabled ,
    @loginDefaultDb    = QUOTENAME(default_database_name)
from
    master.sys.server_principals
where QUOTENAME(name) = @loginToPlayWith

-- ENABLE|DISABLE login
if @loginIsDisabled = 1
BEGIN
    ALTER LOGIN [CHULg\SAI_Db] ENABLE
END

-- If necessary, give the login the permission to connect the database engine
if not exists (select 1 from master.sys.server_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @loginToPlayWith and permission_name = 'CONNECT SQL' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT SQL TO [CHULg\SAI_Db]' );
END

-- If necessary, set the default database for this login
if ISNULL(@loginDefaultDb,'<null>') <> QUOTENAME('master')
BEGIN
    exec sp_defaultdb @loginame = 'CHULg\SAI_Db' , @DefDb = 'master'
END

GO

PRINT '. Commands for Schema "ApplicationSchema1" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @SchemaOwner VARCHAR(64)

SELECT @SchemaOwner = QUOTENAME(SCHEMA_OWNER)
FROM
    INFORMATION_SCHEMA.SCHEMATA
WHERE
    QUOTENAME(CATALOG_NAME) = @DbName
AND QUOTENAME(SCHEMA_NAME)  = @dynamicDeclaration
IF (@SchemaOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE SCHEMA [ApplicationSchema1] AUTHORIZATION [dbo]')
END
ELSE IF @SchemaOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on SCHEMA::[ApplicationSchema1] TO [dbo]')
END

GO

PRINT '. Commands for Schema "ApplicationSchema2" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @SchemaOwner VARCHAR(64)

SELECT @SchemaOwner = QUOTENAME(SCHEMA_OWNER)
FROM
    INFORMATION_SCHEMA.SCHEMATA
WHERE
    QUOTENAME(CATALOG_NAME) = @DbName
AND QUOTENAME(SCHEMA_NAME)  = @dynamicDeclaration
IF (@SchemaOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE SCHEMA [ApplicationSchema2] AUTHORIZATION [dbo]')
END
ELSE IF @SchemaOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on SCHEMA::[ApplicationSchema2] TO [dbo]')
END

GO

PRINT '. Commands for Schema "dbo" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('dbo')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @SchemaOwner VARCHAR(64)

SELECT @SchemaOwner = QUOTENAME(SCHEMA_OWNER)
FROM
    INFORMATION_SCHEMA.SCHEMATA
WHERE
    QUOTENAME(CATALOG_NAME) = @DbName
AND QUOTENAME(SCHEMA_NAME)  = @dynamicDeclaration
IF (@SchemaOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE SCHEMA [dbo] AUTHORIZATION [dbo]')
END
ELSE IF @SchemaOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on SCHEMA::[dbo] TO [dbo]')
END

GO

PRINT '. Commands for Schema "dbo" in database "master"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('dbo')
DECLARE @DbName      VARCHAR(64) = '[master]'
USE [master]

DECLARE @SchemaOwner VARCHAR(64)

SELECT @SchemaOwner = QUOTENAME(SCHEMA_OWNER)
FROM
    INFORMATION_SCHEMA.SCHEMATA
WHERE
    QUOTENAME(CATALOG_NAME) = @DbName
AND QUOTENAME(SCHEMA_NAME)  = @dynamicDeclaration
IF (@SchemaOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE SCHEMA [dbo] AUTHORIZATION [dbo]')
END
ELSE IF @SchemaOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on SCHEMA::[dbo] TO [dbo]')
END

GO

PRINT '. Commands for Database User "ApplicationSQLUser1" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[ApplicationSQLUser1]'
SET @CurDbName     = '[JEL_SecurityManager_TestingFeature]'
SET @CurLoginName  = '[ApplicationSQLUser1]'
SET @CurSchemaName = '[ApplicationSchema1]'
Use [JEL_SecurityManager_TestingFeature]
DECLARE @gotName       VARCHAR(64)
DECLARE @defaultSchema VARCHAR(64)
select @gotName = name, @defaultSchema = default_schema_name from sys.database_principals WHERE QUOTENAME(NAME) = @CurDbUser and Type in ('S','U')
IF @gotName is null
BEGIN
    EXEC ('create user ' + @CurDbUser + ' FOR LOGIN ' + @CurLoginName )
END
if isnull(@defaultSchema,'<NULL>') <> isnull(@CurSchemaName,'<NULL>')
BEGIN
    EXEC ('alter user ' + @CurDbUser + ' WITH DEFAULT_SCHEMA = ' + @CurSchemaName )
END
GO

PRINT '. Commands for Database User "ApplicationSQLUser3" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[ApplicationSQLUser3]'
SET @CurDbName     = '[JEL_SecurityManager_TestingFeature]'
SET @CurLoginName  = '[ApplicationSQLUser3]'
SET @CurSchemaName = '[ApplicationSchema1]'
Use [JEL_SecurityManager_TestingFeature]
DECLARE @gotName       VARCHAR(64)
DECLARE @defaultSchema VARCHAR(64)
select @gotName = name, @defaultSchema = default_schema_name from sys.database_principals WHERE QUOTENAME(NAME) = @CurDbUser and Type in ('S','U')
IF @gotName is null
BEGIN
    EXEC ('create user ' + @CurDbUser + ' FOR LOGIN ' + @CurLoginName )
END
if isnull(@defaultSchema,'<NULL>') <> isnull(@CurSchemaName,'<NULL>')
BEGIN
    EXEC ('alter user ' + @CurDbUser + ' WITH DEFAULT_SCHEMA = ' + @CurSchemaName )
END
GO

PRINT '. Commands for Database User "CHULg\c168350" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[CHULg\c168350]'
SET @CurDbName     = '[JEL_SecurityManager_TestingFeature]'
SET @CurLoginName  = '[CHULg\c168350]'
SET @CurSchemaName = '[dbo]'
Use [JEL_SecurityManager_TestingFeature]
DECLARE @gotName       VARCHAR(64)
DECLARE @defaultSchema VARCHAR(64)
select @gotName = name, @defaultSchema = default_schema_name from sys.database_principals WHERE QUOTENAME(NAME) = @CurDbUser and Type in ('S','U')
IF @gotName is null
BEGIN
    EXEC ('create user ' + @CurDbUser + ' FOR LOGIN ' + @CurLoginName )
END
if isnull(@defaultSchema,'<NULL>') <> isnull(@CurSchemaName,'<NULL>')
BEGIN
    EXEC ('alter user ' + @CurDbUser + ' WITH DEFAULT_SCHEMA = ' + @CurSchemaName )
END
GO

PRINT '. Commands for Database User "DbUser2" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[DbUser2]'
SET @CurDbName     = '[JEL_SecurityManager_TestingFeature]'
SET @CurLoginName  = '[ApplicationSQLUser2]'
SET @CurSchemaName = '[ApplicationSchema2]'
Use [JEL_SecurityManager_TestingFeature]
DECLARE @gotName       VARCHAR(64)
DECLARE @defaultSchema VARCHAR(64)
select @gotName = name, @defaultSchema = default_schema_name from sys.database_principals WHERE QUOTENAME(NAME) = @CurDbUser and Type in ('S','U')
IF @gotName is null
BEGIN
    EXEC ('create user ' + @CurDbUser + ' FOR LOGIN ' + @CurLoginName )
END
if isnull(@defaultSchema,'<NULL>') <> isnull(@CurSchemaName,'<NULL>')
BEGIN
    EXEC ('alter user ' + @CurDbUser + ' WITH DEFAULT_SCHEMA = ' + @CurSchemaName )
END
GO

PRINT '. Commands for Database User "DbUser4" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[DbUser4]'
SET @CurDbName     = '[JEL_SecurityManager_TestingFeature]'
SET @CurLoginName  = '[ApplicationSQLUser4]'
SET @CurSchemaName = '[ApplicationSchema2]'
Use [JEL_SecurityManager_TestingFeature]
DECLARE @gotName       VARCHAR(64)
DECLARE @defaultSchema VARCHAR(64)
select @gotName = name, @defaultSchema = default_schema_name from sys.database_principals WHERE QUOTENAME(NAME) = @CurDbUser and Type in ('S','U')
IF @gotName is null
BEGIN
    EXEC ('create user ' + @CurDbUser + ' FOR LOGIN ' + @CurLoginName )
END
if isnull(@defaultSchema,'<NULL>') <> isnull(@CurSchemaName,'<NULL>')
BEGIN
    EXEC ('alter user ' + @CurDbUser + ' WITH DEFAULT_SCHEMA = ' + @CurSchemaName )
END
GO

PRINT '. Commands for Database User "CHULg\c168350" in database "master"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[CHULg\c168350]'
SET @CurDbName     = '[master]'
SET @CurLoginName  = '[CHULg\c168350]'
SET @CurSchemaName = '[dbo]'
Use [master]
DECLARE @gotName       VARCHAR(64)
DECLARE @defaultSchema VARCHAR(64)
select @gotName = name, @defaultSchema = default_schema_name from sys.database_principals WHERE QUOTENAME(NAME) = @CurDbUser and Type in ('S','U')
IF @gotName is null
BEGIN
    EXEC ('create user ' + @CurDbUser + ' FOR LOGIN ' + @CurLoginName )
END
if isnull(@defaultSchema,'<NULL>') <> isnull(@CurSchemaName,'<NULL>')
BEGIN
    EXEC ('alter user ' + @CurDbUser + ' WITH DEFAULT_SCHEMA = ' + @CurSchemaName )
END
GO

PRINT '. Commands for Database User "CHULg\SAI_Db" in database "master"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[CHULg\SAI_Db]'
SET @CurDbName     = '[master]'
SET @CurLoginName  = '[CHULg\SAI_Db]'
SET @CurSchemaName = '[dbo]'
Use [master]
DECLARE @gotName       VARCHAR(64)
DECLARE @defaultSchema VARCHAR(64)
select @gotName = name, @defaultSchema = default_schema_name from sys.database_principals WHERE QUOTENAME(NAME) = @CurDbUser and Type in ('S','U')
IF @gotName is null
BEGIN
    EXEC ('create user ' + @CurDbUser + ' FOR LOGIN ' + @CurLoginName )
END
if isnull(@defaultSchema,'<NULL>') <> isnull(@CurSchemaName,'<NULL>')
BEGIN
    EXEC ('alter user ' + @CurDbUser + ' WITH DEFAULT_SCHEMA = ' + @CurSchemaName )
END
GO

PRINT '. Commands to map login "[ApplicationSQLUser1] to user [ApplicationSQLUser1]" on JEL_SecurityManager_TestingFeature"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[ApplicationSQLUser1]'
SET @CurDbName     = '[JEL_SecurityManager_TestingFeature]'
SET @CurLoginName  = '[ApplicationSQLUser1]'
SET @CurSchemaName = '[ApplicationSchema1]'
Use [JEL_SecurityManager_TestingFeature]
if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )
BEGIN
    EXEC('ALTER USER '+'[ApplicationSQLUser1]'+ 'WITH LOGIN = ' + '[ApplicationSQLUser1]' )
END

-- If necessary, give the database user the permission to connect the database 
if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = 'CONNECT' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [JEL_SecurityManager_TestingFeature] ; GRANT CONNECT TO [ApplicationSQLUser1]' );
END
GO

PRINT '. Commands to map login "[ApplicationSQLUser2] to user [DbUser2]" on JEL_SecurityManager_TestingFeature"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[DbUser2]'
SET @CurDbName     = '[JEL_SecurityManager_TestingFeature]'
SET @CurLoginName  = '[ApplicationSQLUser2]'
SET @CurSchemaName = '[ApplicationSchema2]'
Use [JEL_SecurityManager_TestingFeature]
if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )
BEGIN
    EXEC('ALTER USER '+'[DbUser2]'+ 'WITH LOGIN = ' + '[ApplicationSQLUser2]' )
END

-- If necessary, give the database user the permission to connect the database 
if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = 'CONNECT' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [JEL_SecurityManager_TestingFeature] ; GRANT CONNECT TO [DbUser2]' );
END
GO

PRINT '. Commands to map login "[ApplicationSQLUser3] to user [ApplicationSQLUser3]" on JEL_SecurityManager_TestingFeature"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[ApplicationSQLUser3]'
SET @CurDbName     = '[JEL_SecurityManager_TestingFeature]'
SET @CurLoginName  = '[ApplicationSQLUser3]'
SET @CurSchemaName = '[ApplicationSchema1]'
Use [JEL_SecurityManager_TestingFeature]
if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )
BEGIN
    EXEC('ALTER USER '+'[ApplicationSQLUser3]'+ 'WITH LOGIN = ' + '[ApplicationSQLUser3]' )
END

-- If necessary, give the database user the permission to connect the database 
if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = 'CONNECT' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [JEL_SecurityManager_TestingFeature] ; GRANT CONNECT TO [ApplicationSQLUser3]' );
END
GO

PRINT '. Commands to map login "[ApplicationSQLUser4] to user [DbUser4]" on JEL_SecurityManager_TestingFeature"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[DbUser4]'
SET @CurDbName     = '[JEL_SecurityManager_TestingFeature]'
SET @CurLoginName  = '[ApplicationSQLUser4]'
SET @CurSchemaName = '[ApplicationSchema2]'
Use [JEL_SecurityManager_TestingFeature]
if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )
BEGIN
    EXEC('ALTER USER '+'[DbUser4]'+ 'WITH LOGIN = ' + '[ApplicationSQLUser4]' )
END

-- If necessary, give the database user the permission to connect the database 
if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = 'CONNECT' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [JEL_SecurityManager_TestingFeature] ; GRANT CONNECT TO [DbUser4]' );
END
GO

PRINT '. Commands to map login "[CHULg\c168350] to user [CHULg\c168350]" on JEL_SecurityManager_TestingFeature"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[CHULg\c168350]'
SET @CurDbName     = '[JEL_SecurityManager_TestingFeature]'
SET @CurLoginName  = '[CHULg\c168350]'
SET @CurSchemaName = '[dbo]'
Use [JEL_SecurityManager_TestingFeature]
if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )
BEGIN
    EXEC('ALTER USER '+'[CHULg\c168350]'+ 'WITH LOGIN = ' + '[CHULg\c168350]' )
END

-- If necessary, give the database user the permission to connect the database 
if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = 'CONNECT' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [JEL_SecurityManager_TestingFeature] ; GRANT CONNECT TO [CHULg\c168350]' );
END
GO

PRINT '. Commands to map login "[CHULg\c168350] to user [CHULg\c168350]" on master"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[CHULg\c168350]'
SET @CurDbName     = '[master]'
SET @CurLoginName  = '[CHULg\c168350]'
SET @CurSchemaName = '[dbo]'
Use [master]
if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )
BEGIN
    EXEC('ALTER USER '+'[CHULg\c168350]'+ 'WITH LOGIN = ' + '[CHULg\c168350]' )
END

-- If necessary, give the database user the permission to connect the database 
if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = 'CONNECT' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT TO [CHULg\c168350]' );
END
GO

PRINT '. Commands to map login "[CHULg\SAI_Db] to user [CHULg\SAI_Db]" on master"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[CHULg\SAI_Db]'
SET @CurDbName     = '[master]'
SET @CurLoginName  = '[CHULg\SAI_Db]'
SET @CurSchemaName = '[dbo]'
Use [master]
if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )
BEGIN
    EXEC('ALTER USER '+'[CHULg\SAI_Db]'+ 'WITH LOGIN = ' + '[CHULg\SAI_Db]' )
END

-- If necessary, give the database user the permission to connect the database 
if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = 'CONNECT' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT TO [CHULg\SAI_Db]' );
END
GO

PRINT '. Commands for role "ApplicationSchema1_data_modifier" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_data_modifier')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema1_data_modifier] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema1_data_modifier] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema1_data_reader" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_data_reader')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema1_data_reader] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema1_data_reader] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema1_endusers" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_endusers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema1_endusers] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema1_endusers] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema1_full_access" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_full_access')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema1_full_access] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema1_full_access] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema1_managers" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_managers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema1_managers] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema1_managers] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema1_prog_executors" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_prog_executors')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema1_prog_executors] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema1_prog_executors] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema1_responsible" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_responsible')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema1_responsible] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema1_responsible] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema1_struct_modifier" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_struct_modifier')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema1_struct_modifier] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema1_struct_modifier] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema1_struct_viewer" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_struct_viewer')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema1_struct_viewer] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema1_struct_viewer] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema2_data_modifier" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_data_modifier')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema2_data_modifier] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema2_data_modifier] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema2_data_reader" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_data_reader')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema2_data_reader] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema2_data_reader] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema2_endusers" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_endusers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema2_endusers] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema2_endusers] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema2_full_access" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_full_access')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema2_full_access] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema2_full_access] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema2_managers" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_managers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema2_managers] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema2_managers] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema2_prog_executors" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_prog_executors')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema2_prog_executors] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema2_prog_executors] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema2_responsible" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_responsible')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema2_responsible] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema2_responsible] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema2_struct_modifier" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_struct_modifier')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema2_struct_modifier] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema2_struct_modifier] TO [dbo]')
END

GO

PRINT '. Commands for role "ApplicationSchema2_struct_viewer" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_struct_viewer')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [ApplicationSchema2_struct_viewer] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationSchema2_struct_viewer] TO [dbo]')
END

GO

PRINT '. Commands for role "CustomRole" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('CustomRole')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [CustomRole] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[CustomRole] TO [dbo]')
END

GO

PRINT '. Commands for role "InactiveCustomRole" in database "JEL_SecurityManager_TestingFeature"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('InactiveCustomRole')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @RoleOwner VARCHAR(64)

SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id))
FROM
    sys.database_principals
WHERE
    QUOTENAME(name) = @dynamicDeclaration
AND type = 'R'
IF (@RoleOwner is null ) -- then the schema does not exist 
BEGIN
    -- create it !
    EXEC ('CREATE ROLE [InactiveCustomRole] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[InactiveCustomRole] TO [dbo]')
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema1_endusers] > [ApplicationSchema1_data_modifier]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_data_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema1_endusers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_data_modifier', @MemberName = 'ApplicationSchema1_endusers'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema1_responsible] > [ApplicationSchema1_data_modifier]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_data_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema1_responsible')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_data_modifier', @MemberName = 'ApplicationSchema1_responsible'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema1_endusers] > [ApplicationSchema1_data_reader]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_data_reader')
SET @MemberName = QUOTENAME('ApplicationSchema1_endusers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_data_reader', @MemberName = 'ApplicationSchema1_endusers'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema1_responsible] > [ApplicationSchema1_data_reader]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_data_reader')
SET @MemberName = QUOTENAME('ApplicationSchema1_responsible')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_data_reader', @MemberName = 'ApplicationSchema1_responsible'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema1_full_access] > [ApplicationSchema1_endusers]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_endusers')
SET @MemberName = QUOTENAME('ApplicationSchema1_full_access')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_endusers', @MemberName = 'ApplicationSchema1_full_access'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[CustomRole] > [ApplicationSchema1_endusers]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_endusers')
SET @MemberName = QUOTENAME('CustomRole')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_endusers', @MemberName = 'CustomRole'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema1_full_access] > [ApplicationSchema1_managers]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_managers')
SET @MemberName = QUOTENAME('ApplicationSchema1_full_access')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_managers', @MemberName = 'ApplicationSchema1_full_access'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema1_responsible] > [ApplicationSchema1_managers]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_managers')
SET @MemberName = QUOTENAME('ApplicationSchema1_responsible')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_managers', @MemberName = 'ApplicationSchema1_responsible'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema1_endusers] > [ApplicationSchema1_prog_executors]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_prog_executors')
SET @MemberName = QUOTENAME('ApplicationSchema1_endusers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_prog_executors', @MemberName = 'ApplicationSchema1_endusers'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema1_managers] > [ApplicationSchema1_struct_modifier]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_struct_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema1_managers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_struct_modifier', @MemberName = 'ApplicationSchema1_managers'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema1_managers] > [ApplicationSchema1_struct_viewer]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_struct_viewer')
SET @MemberName = QUOTENAME('ApplicationSchema1_managers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_struct_viewer', @MemberName = 'ApplicationSchema1_managers'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema2_endusers] > [ApplicationSchema2_data_modifier]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_data_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema2_endusers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_data_modifier', @MemberName = 'ApplicationSchema2_endusers'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema2_responsible] > [ApplicationSchema2_data_modifier]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_data_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema2_responsible')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_data_modifier', @MemberName = 'ApplicationSchema2_responsible'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema2_endusers] > [ApplicationSchema2_data_reader]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_data_reader')
SET @MemberName = QUOTENAME('ApplicationSchema2_endusers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_data_reader', @MemberName = 'ApplicationSchema2_endusers'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema2_responsible] > [ApplicationSchema2_data_reader]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_data_reader')
SET @MemberName = QUOTENAME('ApplicationSchema2_responsible')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_data_reader', @MemberName = 'ApplicationSchema2_responsible'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema2_full_access] > [ApplicationSchema2_endusers]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_endusers')
SET @MemberName = QUOTENAME('ApplicationSchema2_full_access')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_endusers', @MemberName = 'ApplicationSchema2_full_access'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema2_full_access] > [ApplicationSchema2_managers]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_managers')
SET @MemberName = QUOTENAME('ApplicationSchema2_full_access')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_managers', @MemberName = 'ApplicationSchema2_full_access'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema2_responsible] > [ApplicationSchema2_managers]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_managers')
SET @MemberName = QUOTENAME('ApplicationSchema2_responsible')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_managers', @MemberName = 'ApplicationSchema2_responsible'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema2_endusers] > [ApplicationSchema2_prog_executors]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_prog_executors')
SET @MemberName = QUOTENAME('ApplicationSchema2_endusers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_prog_executors', @MemberName = 'ApplicationSchema2_endusers'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema2_managers] > [ApplicationSchema2_struct_modifier]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_struct_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema2_managers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_struct_modifier', @MemberName = 'ApplicationSchema2_managers'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSchema2_managers] > [ApplicationSchema2_struct_viewer]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_struct_viewer')
SET @MemberName = QUOTENAME('ApplicationSchema2_managers')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_struct_viewer', @MemberName = 'ApplicationSchema2_managers'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSQLUser1] > [CustomRole]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('CustomRole')
SET @MemberName = QUOTENAME('ApplicationSQLUser1')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'CustomRole', @MemberName = 'ApplicationSQLUser1'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for role assignment "[ApplicationSQLUser3] > [CustomRole]" on JEL_SecurityManager_TestingFeature"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('CustomRole')
SET @MemberName = QUOTENAME('ApplicationSQLUser3')
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'CustomRole', @MemberName = 'ApplicationSQLUser3'
    -- TODO : check return code to ensure role member is really added
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_data_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'DELETE'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT DELETE ON SCHEMA::[ApplicationSchema1] to [ApplicationSchema1_data_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_data_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'INSERT'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT INSERT ON SCHEMA::[ApplicationSchema1] to [ApplicationSchema1_data_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_data_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'UPDATE'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT UPDATE ON SCHEMA::[ApplicationSchema1] to [ApplicationSchema1_data_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_data_reader'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_data_reader]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'SELECT'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT SELECT ON SCHEMA::[ApplicationSchema1] to [ApplicationSchema1_data_reader]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_prog_executors'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_prog_executors]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'EXECUTE'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT EXECUTE ON SCHEMA::[ApplicationSchema1] to [ApplicationSchema1_prog_executors]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'ALTER'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT ALTER ON SCHEMA::[ApplicationSchema1] to [ApplicationSchema1_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE FUNCTION'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE FUNCTION to [ApplicationSchema1_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE PROCEDURE'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE PROCEDURE to [ApplicationSchema1_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE SYNONYM'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE SYNONYM to [ApplicationSchema1_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE TABLE'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE TABLE to [ApplicationSchema1_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE TYPE'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE TYPE to [ApplicationSchema1_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE VIEW'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE VIEW to [ApplicationSchema1_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'REFERENCES'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT REFERENCES ON SCHEMA::[ApplicationSchema1] to [ApplicationSchema1_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_struct_viewer'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_struct_viewer]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'VIEW DEFINITION'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT VIEW DEFINITION ON SCHEMA::[ApplicationSchema1] to [ApplicationSchema1_struct_viewer]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_data_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'DELETE'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT DELETE ON SCHEMA::[ApplicationSchema2] to [ApplicationSchema2_data_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_data_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'INSERT'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT INSERT ON SCHEMA::[ApplicationSchema2] to [ApplicationSchema2_data_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_data_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'UPDATE'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT UPDATE ON SCHEMA::[ApplicationSchema2] to [ApplicationSchema2_data_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_data_reader'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_data_reader]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'SELECT'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT SELECT ON SCHEMA::[ApplicationSchema2] to [ApplicationSchema2_data_reader]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_prog_executors'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_prog_executors]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'EXECUTE'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT EXECUTE ON SCHEMA::[ApplicationSchema2] to [ApplicationSchema2_prog_executors]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'ALTER'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT ALTER ON SCHEMA::[ApplicationSchema2] to [ApplicationSchema2_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE FUNCTION'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE FUNCTION to [ApplicationSchema2_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE PROCEDURE'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE PROCEDURE to [ApplicationSchema2_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE SYNONYM'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE SYNONYM to [ApplicationSchema2_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE TABLE'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE TABLE to [ApplicationSchema2_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE TYPE'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE TYPE to [ApplicationSchema2_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''JEL_SecurityManager_TestingFeature'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE VIEW'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'DATABASE'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT CREATE VIEW to [ApplicationSchema2_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'REFERENCES'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT REFERENCES ON SCHEMA::[ApplicationSchema2] to [ApplicationSchema2_struct_modifier]  AS [dbo]'
END

GO

PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_struct_viewer'' on database ''JEL_SecurityManager_TestingFeature'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_struct_viewer]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'VIEW DEFINITION'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[JEL_SecurityManager_TestingFeature]'
USE [JEL_SecurityManager_TestingFeature]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT VIEW DEFINITION ON SCHEMA::[ApplicationSchema2] to [ApplicationSchema2_struct_viewer]  AS [dbo]'
END

GO

