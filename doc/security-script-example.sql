-- Jan 11 2015  6:35PM-- DEBUG - Table ##SecurityGenerationResults dropped
-- Jan 11 2015  6:35PM-- DEBUG - Table ##SecurityScriptResultsCommandsOrder dropped
-- Jan 11 2015  6:35PM-- DEBUG - Table ##SecurityGenerationResults created
-- Jan 11 2015  6:35PM-- DEBUG - Table ##SecurityScriptResultsCommandsOrder created
-- Jan 11 2015  6:35PM - DEBUG -     > Login creation statements
-- Jan 11 2015  6:35PM - DEBUG - Every logins generation detected.
-- Jan 11 2015  6:35PM - DEBUG - Taking care of login Enduser1 (Application End User 1)
-- Jan 11 2015  6:35PM - DEBUG - Taking care of login MyDomain\Jeff.Elias (Jefferson Elias)
-- Jan 11 2015  6:35PM - DEBUG - Taking care of login MyDomain\JohnDoe (John Doe)
-- Jan 11 2015  6:35PM - DEBUG - Full server generation mode detected.
--------------------------------------------------------------------------------------------------------------
-- Jan 11 2015  6:35PM - DEBUG - Server Name : MyServer1
-- Jan 11 2015  6:35PM - DEBUG - Database set to ApplicationDatabase1
 
-- Jan 11 2015  6:35PM - DEBUG -     > Schema creation statements
-- Jan 11 2015  6:35PM - DEBUG - Every Schema generation detected.
-- Jan 11 2015  6:35PM - DEBUG -     > Database user creation statements
-- Jan 11 2015  6:35PM - DEBUG - Every users in database generation detected.
-- Jan 11 2015  6:35PM - DEBUG - ServerName MyServer1
-- Jan 11 2015  6:35PM - DEBUG - DbName     ApplicationDatabase1
-- Jan 11 2015  6:35PM - DEBUG - Taking care of user Enduser1
-- Jan 11 2015  6:35PM - DEBUG - ServerName MyServer1
-- Jan 11 2015  6:35PM - DEBUG - DbName     ApplicationDatabase1
-- Jan 11 2015  6:35PM - DEBUG - Taking care of user MyDomain\JohnDoe
-- Jan 11 2015  6:35PM - DEBUG -     > Login to database user creation statements
-- Jan 11 2015  6:35PM - DEBUG - All mappings for database ApplicationDatabase1 detected
-- Jan 11 2015  6:35PM - DEBUG -     > Database Roles creation and assignment statements
-- Jan 11 2015  6:35PM - DEBUG - Every Role generation detected.
-- Jan 11 2015  6:35PM - DEBUG - Every Role membership generation detected.
-- Jan 11 2015  6:35PM - DEBUG -     > Object-level permission assignment statements
-- Jan 11 2015  6:35PM - DEBUG - Every permission assignment detected.
-- Jan 11 2015  6:35PM - DEBUG - Taking care of permissions for [ApplicationResponsibles] in database [ApplicationDatabase1]
-- Jan 11 2015  6:35PM - DEBUG - Taking care of permissions for [ApplicationSchema1_data_modifier] in database [ApplicationDatabase1]
-- Jan 11 2015  6:35PM - DEBUG - Taking care of permissions for [ApplicationSchema1_data_reader] in database [ApplicationDatabase1]
-- Jan 11 2015  6:35PM - DEBUG - Taking care of permissions for [ApplicationSchema1_prog_executors] in database [ApplicationDatabase1]
-- Jan 11 2015  6:35PM - DEBUG - Taking care of permissions for [ApplicationSchema1_struct_modifier] in database [ApplicationDatabase1]
-- Jan 11 2015  6:35PM - DEBUG - Taking care of permissions for [ApplicationSchema1_struct_viewer] in database [ApplicationDatabase1]
-- Jan 11 2015  6:35PM - DEBUG - Taking care of permissions for [ApplicationSchema2_data_modifier] in database [ApplicationDatabase1]
-- Jan 11 2015  6:35PM - DEBUG - Taking care of permissions for [ApplicationSchema2_data_reader] in database [ApplicationDatabase1]
-- Jan 11 2015  6:35PM - DEBUG - Taking care of permissions for [ApplicationSchema2_prog_executors] in database [ApplicationDatabase1]
-- Jan 11 2015  6:35PM - DEBUG - Taking care of permissions for [ApplicationSchema2_struct_modifier] in database [ApplicationDatabase1]
-- Jan 11 2015  6:35PM - DEBUG - Taking care of permissions for [ApplicationSchema2_struct_viewer] in database [ApplicationDatabase1]
-- Jan 11 2015  6:35PM - INFO - Generation successful
--------------------------------------------------------------------------------------------------------------
-- Nothing to display
--------------------------------------------------------------------------------------------------------------
-- Jan 11 2015  6:35PM - DEBUG - Server Name : MyServer1
-- Jan 11 2015  6:35PM - DEBUG - Database set to master
 
-- Jan 11 2015  6:35PM - DEBUG -     > Schema creation statements
-- Jan 11 2015  6:35PM - DEBUG - Every Schema generation detected.
-- Jan 11 2015  6:35PM - DEBUG -     > Database user creation statements
-- Jan 11 2015  6:35PM - DEBUG - Every users in database generation detected.
-- Jan 11 2015  6:35PM - DEBUG - ServerName MyServer1
-- Jan 11 2015  6:35PM - DEBUG - DbName     master
-- Jan 11 2015  6:35PM - DEBUG - Taking care of user MyDomain\Jeff.Elias
-- Jan 11 2015  6:35PM - DEBUG -     > Login to database user creation statements
-- Jan 11 2015  6:35PM - DEBUG - All mappings for database master detected
-- Jan 11 2015  6:35PM - DEBUG -     > Database Roles creation and assignment statements
-- Jan 11 2015  6:35PM - DEBUG - Every Role generation detected.
-- Jan 11 2015  6:35PM - DEBUG - Every Role membership generation detected.
-- Jan 11 2015  6:35PM - DEBUG -     > Object-level permission assignment statements
-- Jan 11 2015  6:35PM - DEBUG - Every permission assignment detected.
-- Jan 11 2015  6:35PM - INFO - Generation successful
--------------------------------------------------------------------------------------------------------------
-- Nothing to display
-- Jan 11 2015  6:35PM - DEBUG - Creating table (if not exists) where we must save results
-- Jan 11 2015  6:35PM - DEBUG - Filling in with results 
IF (@@SERVERNAME <> 'MyServer1')
BEGIN
    RAISERROR('Expected @@ServerName : "MyServer1"', 16, 0)
END
IF NOT EXISTS( SELECT 1 FROM sys.databases where Name =  'ApplicationDatabase1')
BEGIN
    RAISERROR('The Database named : "ApplicationDatabase1" doesn''t exist on server !', 16, 0)
END
IF NOT EXISTS( SELECT 1 FROM sys.databases where Name =  'master')
BEGIN
    RAISERROR('The Database named : "master" doesn''t exist on server !', 16, 0)
END
PRINT '. Commands for "Application End User 1" from department "External/DevCorp/DevProduct"'
DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('Enduser1')
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE  QUOTENAME(name) = @loginToPlayWith)
BEGIN
    -- create it !
    EXEC ('USE [master]; CREATE LOGIN [Enduser1] WITH PASSWORD=N''123456a.'' , DEFAULT_DATABASE=[ApplicationDatabase1]')
END
GO

DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('Enduser1')
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
    ALTER LOGIN [Enduser1] ENABLE
END

-- If necessary, give the login the permission to connect the database engine
if not exists (select 1 from master.sys.server_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @loginToPlayWith and permission_name = 'CONNECT SQL' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT SQL TO [Enduser1]' );
END

-- If necessary, set the default database for this login
if ISNULL(@loginDefaultDb,'<null>') <> QUOTENAME('ApplicationDatabase1')
BEGIN
    exec sp_defaultdb @loginame = 'Enduser1' , @DefDb = 'ApplicationDatabase1'
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
    ALTER LOGIN [Enduser1] WITH CHECK_EXPIRATION=OFF
END
if @loginHasPwdExpireChecked <> 0
BEGIN
    ALTER LOGIN [Enduser1] WITH CHECK_POLICY=OFF
END

GO
PRINT '. Commands for "Jefferson Elias" from department "MyCorp/IT Service/DBA Team"'
DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('MyDomain\Jeff.Elias')
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE  QUOTENAME(name) = @loginToPlayWith)
BEGIN
    -- create it !
    EXEC ('USE [master]; CREATE LOGIN [MyDomain\Jeff.Elias] FROM WINDOWS  , DEFAULT_DATABASE=[master]')
END
GO

DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('MyDomain\Jeff.Elias')
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
    ALTER LOGIN [MyDomain\Jeff.Elias] ENABLE
END

-- If necessary, give the login the permission to connect the database engine
if not exists (select 1 from master.sys.server_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @loginToPlayWith and permission_name = 'CONNECT SQL' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT SQL TO [MyDomain\Jeff.Elias]' );
END

-- If necessary, set the default database for this login
if ISNULL(@loginDefaultDb,'<null>') <> QUOTENAME('master')
BEGIN
    exec sp_defaultdb @loginame = 'MyDomain\Jeff.Elias' , @DefDb = 'master'
END

GO
PRINT '. Commands for "John Doe" from department "MyCorp/IT Service/Application Support Team"'
DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('MyDomain\JohnDoe')
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE  QUOTENAME(name) = @loginToPlayWith)
BEGIN
    -- create it !
    EXEC ('USE [master]; CREATE LOGIN [MyDomain\JohnDoe] FROM WINDOWS  , DEFAULT_DATABASE=[ApplicationDatabase1]')
END
GO

DECLARE @loginToPlayWith VARCHAR(64)
SET @loginToPlayWith = QUOTENAME('MyDomain\JohnDoe')
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
    ALTER LOGIN [MyDomain\JohnDoe] ENABLE
END

-- If necessary, give the login the permission to connect the database engine
if not exists (select 1 from master.sys.server_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @loginToPlayWith and permission_name = 'CONNECT SQL' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT SQL TO [MyDomain\JohnDoe]' );
END

-- If necessary, set the default database for this login
if ISNULL(@loginDefaultDb,'<null>') <> QUOTENAME('ApplicationDatabase1')
BEGIN
    exec sp_defaultdb @loginame = 'MyDomain\JohnDoe' , @DefDb = 'ApplicationDatabase1'
END

GO
PRINT '. Commands for Schema "ApplicationSchema1" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for Schema "ApplicationSchema2" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for Schema "dbo" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('dbo')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for Database User "Enduser1" in database "ApplicationDatabase1"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[Enduser1]'
SET @CurDbName     = '[ApplicationDatabase1]'
SET @CurLoginName  = '[Enduser1]'
SET @CurSchemaName = '[ApplicationSchema1]'
Use [ApplicationDatabase1]
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
PRINT '. Commands for Database User "MyDomain\JohnDoe" in database "ApplicationDatabase1"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[MyDomain\JohnDoe]'
SET @CurDbName     = '[ApplicationDatabase1]'
SET @CurLoginName  = '[MyDomain\JohnDoe]'
SET @CurSchemaName = '[ApplicationSchema1]'
Use [ApplicationDatabase1]
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
PRINT '. Commands for Database User "MyDomain\Jeff.Elias" in database "master"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[MyDomain\Jeff.Elias]'
SET @CurDbName     = '[master]'
SET @CurLoginName  = '[MyDomain\Jeff.Elias]'
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
PRINT '. Commands to map login "[Enduser1] to user [Enduser1]" on ApplicationDatabase1"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[Enduser1]'
SET @CurDbName     = '[ApplicationDatabase1]'
SET @CurLoginName  = '[Enduser1]'
SET @CurSchemaName = '[ApplicationSchema1]'
Use [ApplicationDatabase1]
if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )
BEGIN
    EXEC('ALTER USER '+'[Enduser1]'+ 'WITH LOGIN = ' + '[Enduser1]' )
END

-- If necessary, give the database user the permission to connect the database 
if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = 'CONNECT' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [ApplicationDatabase1] ; GRANT CONNECT TO [Enduser1]' );
END
GO
PRINT '. Commands to map login "[MyDomain\JohnDoe] to user [MyDomain\JohnDoe]" on ApplicationDatabase1"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[MyDomain\JohnDoe]'
SET @CurDbName     = '[ApplicationDatabase1]'
SET @CurLoginName  = '[MyDomain\JohnDoe]'
SET @CurSchemaName = '[ApplicationSchema1]'
Use [ApplicationDatabase1]
if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )
BEGIN
    EXEC('ALTER USER '+'[MyDomain\JohnDoe]'+ 'WITH LOGIN = ' + '[MyDomain\JohnDoe]' )
END

-- If necessary, give the database user the permission to connect the database 
if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = 'CONNECT' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [ApplicationDatabase1] ; GRANT CONNECT TO [MyDomain\JohnDoe]' );
END
GO
PRINT '. Commands to map login "[MyDomain\Jeff.Elias] to user [MyDomain\Jeff.Elias]" on master"'
DECLARE @CurDbUser     VARCHAR(64)
DECLARE @CurDbName     VARCHAR(64)
DECLARE @CurLoginName  VARCHAR(64)
DECLARE @CurSchemaName VARCHAR(64)
SET @CurDbUser     = '[MyDomain\Jeff.Elias]'
SET @CurDbName     = '[master]'
SET @CurLoginName  = '[MyDomain\Jeff.Elias]'
SET @CurSchemaName = '[dbo]'
Use [master]
if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )
BEGIN
    EXEC('ALTER USER '+'[MyDomain\Jeff.Elias]'+ 'WITH LOGIN = ' + '[MyDomain\Jeff.Elias]' )
END

-- If necessary, give the database user the permission to connect the database 
if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = 'CONNECT' and state_desc = 'GRANT')
BEGIN
    EXEC ('USE [master] ; GRANT CONNECT TO [MyDomain\Jeff.Elias]' );
END
GO
PRINT '. Commands for role "ApplicationEndUsers" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationEndUsers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
    EXEC ('CREATE ROLE [ApplicationEndUsers] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationEndUsers] TO [dbo]')
END

GO
PRINT '. Commands for role "ApplicationResponsibles" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationResponsibles')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
    EXEC ('CREATE ROLE [ApplicationResponsibles] AUTHORIZATION [dbo]')
END
ELSE IF @RoleOwner <> '[dbo]'
BEGIN
    EXEC ('ALTER AUTHORIZATION on ROLE::[ApplicationResponsibles] TO [dbo]')
END

GO
PRINT '. Commands for role "ApplicationSchema1_data_modifier" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_data_modifier')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema1_data_reader" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_data_reader')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema1_endusers" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_endusers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema1_full_access" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_full_access')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema1_managers" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_managers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema1_prog_executors" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_prog_executors')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema1_responsible" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_responsible')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema1_struct_modifier" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_struct_modifier')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema1_struct_viewer" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema1_struct_viewer')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema2_data_modifier" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_data_modifier')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema2_data_reader" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_data_reader')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema2_endusers" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_endusers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema2_full_access" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_full_access')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema2_managers" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_managers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema2_prog_executors" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_prog_executors')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema2_responsible" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_responsible')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema2_struct_modifier" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_struct_modifier')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role "ApplicationSchema2_struct_viewer" in database "ApplicationDatabase1"'
DECLARE @dynamicDeclaration VARCHAR(64)
SET @dynamicDeclaration = QUOTENAME('ApplicationSchema2_struct_viewer')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema1_endusers] > [ApplicationSchema1_data_modifier]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_data_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema1_endusers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema1_responsible] > [ApplicationSchema1_data_modifier]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_data_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema1_responsible')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema1_endusers] > [ApplicationSchema1_data_reader]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_data_reader')
SET @MemberName = QUOTENAME('ApplicationSchema1_endusers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema1_responsible] > [ApplicationSchema1_data_reader]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_data_reader')
SET @MemberName = QUOTENAME('ApplicationSchema1_responsible')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationEndusers] > [ApplicationSchema1_endusers]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_endusers')
SET @MemberName = QUOTENAME('ApplicationEndusers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_endusers', @MemberName = 'ApplicationEndusers'
    -- TODO : check return code to ensure role member is really added
END

GO
PRINT '. Commands for role assignment "[ApplicationSchema1_full_access] > [ApplicationSchema1_endusers]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_endusers')
SET @MemberName = QUOTENAME('ApplicationSchema1_full_access')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema1_full_access] > [ApplicationSchema1_managers]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_managers')
SET @MemberName = QUOTENAME('ApplicationSchema1_full_access')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema1_responsible] > [ApplicationSchema1_managers]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_managers')
SET @MemberName = QUOTENAME('ApplicationSchema1_responsible')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema1_endusers] > [ApplicationSchema1_prog_executors]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_prog_executors')
SET @MemberName = QUOTENAME('ApplicationSchema1_endusers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationResponsibles] > [ApplicationSchema1_responsible]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_responsible')
SET @MemberName = QUOTENAME('ApplicationResponsibles')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema1_responsible', @MemberName = 'ApplicationResponsibles'
    -- TODO : check return code to ensure role member is really added
END

GO
PRINT '. Commands for role assignment "[ApplicationSchema1_managers] > [ApplicationSchema1_struct_modifier]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_struct_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema1_managers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema1_managers] > [ApplicationSchema1_struct_viewer]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema1_struct_viewer')
SET @MemberName = QUOTENAME('ApplicationSchema1_managers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema2_endusers] > [ApplicationSchema2_data_modifier]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_data_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema2_endusers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema2_responsible] > [ApplicationSchema2_data_modifier]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_data_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema2_responsible')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema2_endusers] > [ApplicationSchema2_data_reader]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_data_reader')
SET @MemberName = QUOTENAME('ApplicationSchema2_endusers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema2_responsible] > [ApplicationSchema2_data_reader]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_data_reader')
SET @MemberName = QUOTENAME('ApplicationSchema2_responsible')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationEndusers] > [ApplicationSchema2_endusers]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_endusers')
SET @MemberName = QUOTENAME('ApplicationEndusers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_endusers', @MemberName = 'ApplicationEndusers'
    -- TODO : check return code to ensure role member is really added
END

GO
PRINT '. Commands for role assignment "[ApplicationSchema2_full_access] > [ApplicationSchema2_endusers]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_endusers')
SET @MemberName = QUOTENAME('ApplicationSchema2_full_access')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema2_full_access] > [ApplicationSchema2_managers]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_managers')
SET @MemberName = QUOTENAME('ApplicationSchema2_full_access')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema2_responsible] > [ApplicationSchema2_managers]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_managers')
SET @MemberName = QUOTENAME('ApplicationSchema2_responsible')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema2_endusers] > [ApplicationSchema2_prog_executors]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_prog_executors')
SET @MemberName = QUOTENAME('ApplicationSchema2_endusers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationResponsibles] > [ApplicationSchema2_responsible]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_responsible')
SET @MemberName = QUOTENAME('ApplicationResponsibles')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

if not exists ( 
    select 1 
    from sys.database_role_members 
    where QUOTENAME(USER_NAME(member_principal_id)) = @MemberName
    and QUOTENAME(USER_NAME(role_principal_id ))  = @RoleName
)
BEGIN
    EXECUTE sp_addrolemember @rolename = 'ApplicationSchema2_responsible', @MemberName = 'ApplicationResponsibles'
    -- TODO : check return code to ensure role member is really added
END

GO
PRINT '. Commands for role assignment "[ApplicationSchema2_managers] > [ApplicationSchema2_struct_modifier]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_struct_modifier')
SET @MemberName = QUOTENAME('ApplicationSchema2_managers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for role assignment "[ApplicationSchema2_managers] > [ApplicationSchema2_struct_viewer]" on ApplicationDatabase1"'
DECLARE @RoleName   VARCHAR(64)
DECLARE @MemberName VARCHAR(64)
SET @RoleName   = QUOTENAME('ApplicationSchema2_struct_viewer')
SET @MemberName = QUOTENAME('ApplicationSchema2_managers')
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on object "[dbo].[SchemaChangeLog] to [ApplicationResponsibles]" on ApplicationDatabase1"'
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
DECLARE @ObjectName      VARCHAR(64)
DECLARE @SubObjectName   VARCHAR(64)
SET @Grantee         = '[ApplicationResponsibles]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'SELECT'
SET @SchemaName      = '[dbo]'
SET @ObjectName      = '[SchemaChangeLog]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'OBJECT_OR_COLUMN'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(OBJECT_SCHEMA_NAME(major_id))	= @SchemaName
and QUOTENAME(OBJECT_NAME(major_id))	        = @ObjectName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT SELECT ON OBJECT::[dbo].[SchemaChangeLog] to [ApplicationResponsibles]  AS [dbo]'
END

GO
PRINT '. Commands for permission assignment on object "[dbo].[SchemaChangeLog] to [ApplicationResponsibles]" on ApplicationDatabase1"'
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
DECLARE @ObjectName      VARCHAR(64)
DECLARE @SubObjectName   VARCHAR(64)
SET @Grantee         = '[ApplicationResponsibles]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'INSERT'
SET @SchemaName      = '[dbo]'
SET @ObjectName      = '[SchemaChangeLog]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'OBJECT_OR_COLUMN'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(OBJECT_SCHEMA_NAME(major_id))	= @SchemaName
and QUOTENAME(OBJECT_NAME(major_id))	        = @ObjectName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is null OR @CurPermLevel <> 'GRANT')
BEGIN
    EXEC sp_executesql N'GRANT INSERT ON OBJECT::[dbo].[SchemaChangeLog] to [ApplicationResponsibles]  AS [dbo]'
END

GO
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_data_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'DELETE'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_data_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_data_modifier]'
SET @PermissionLevel = 'REVOKE'
SET @PermissionName  = 'EXECUTE'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is not null)
BEGIN
    EXEC sp_executesql N'REVOKE EXECUTE ON SCHEMA::[ApplicationSchema1] FROM [ApplicationSchema1_data_modifier] AS [dbo]'
END

GO
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_data_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'INSERT'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_data_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'UPDATE'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_data_reader'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_data_reader]'
SET @PermissionLevel = 'REVOKE'
SET @PermissionName  = 'EXECUTE'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is not null)
BEGIN
    EXEC sp_executesql N'REVOKE EXECUTE ON SCHEMA::[ApplicationSchema1] FROM [ApplicationSchema1_data_reader] AS [dbo]'
END

GO
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_data_reader'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_data_reader]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'SELECT'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_prog_executors'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_prog_executors]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'EXECUTE'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'ALTER'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE FUNCTION'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE PROCEDURE'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE SYNONYM'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE TABLE'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE TYPE'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE VIEW'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'REFERENCES'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema1'' for database principal ''ApplicationSchema1_struct_viewer'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema1_struct_viewer]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'VIEW DEFINITION'
SET @SchemaName      = '[ApplicationSchema1]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_data_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'DELETE'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_data_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_data_modifier]'
SET @PermissionLevel = 'REVOKE'
SET @PermissionName  = 'EXECUTE'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is not null)
BEGIN
    EXEC sp_executesql N'REVOKE EXECUTE ON SCHEMA::[ApplicationSchema2] FROM [ApplicationSchema2_data_modifier] AS [dbo]'
END

GO
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_data_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'INSERT'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_data_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_data_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'UPDATE'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_data_reader'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_data_reader]'
SET @PermissionLevel = 'REVOKE'
SET @PermissionName  = 'EXECUTE'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

DECLARE @CurPermLevel VARCHAR(10)
select @CurPermLevel = state_desc
from
sys.database_permissions
where
    class_desc                                 = 'SCHEMA'
and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee
and QUOTENAME(SCHEMA_NAME(major_id))			= @SchemaName
and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)
if (@CurPermLevel is not null)
BEGIN
    EXEC sp_executesql N'REVOKE EXECUTE ON SCHEMA::[ApplicationSchema2] FROM [ApplicationSchema2_data_reader] AS [dbo]'
END

GO
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_data_reader'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_data_reader]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'SELECT'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_prog_executors'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_prog_executors]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'EXECUTE'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'ALTER'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE FUNCTION'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE PROCEDURE'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE SYNONYM'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE TABLE'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE TYPE'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationDatabase1'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'CREATE VIEW'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_struct_modifier'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_struct_modifier]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'REFERENCES'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
PRINT '. Commands for permission assignment on database schema ''ApplicationSchema2'' for database principal ''ApplicationSchema2_struct_viewer'' on database ''ApplicationDatabase1'''
DECLARE @Grantee         VARCHAR(256)
DECLARE @PermissionLevel VARCHAR(10)
DECLARE @PermissionName  VARCHAR(256)
DECLARE @SchemaName      VARCHAR(64)
SET @Grantee         = '[ApplicationSchema2_struct_viewer]'
SET @PermissionLevel = 'GRANT'
SET @PermissionName  = 'VIEW DEFINITION'
SET @SchemaName      = '[ApplicationSchema2]'
DECLARE @DbName      VARCHAR(64) = '[ApplicationDatabase1]'
USE [ApplicationDatabase1]

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
