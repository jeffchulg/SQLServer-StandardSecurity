/*requires Schema.Security.sql*/
/*requires Table.security.StandardRoles.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'View [security].[logins] Creation'

IF (EXISTS( select 1 from sys.all_objects where OBJECT_ID = OBJECT_ID('[security].[StandardOnSchemaRoles]') and type_desc = 'USER_TABLE'))
BEGIN 
	EXEC sp_rename N'[security].[StandardOnSchemaRoles]','StandardOnSchemaRoles_bak';
	IF @@ERROR <> 0
		RETURN;
	ELSE 
		PRINT '    Table [security].[StandardOnSchemaRoles] renamed to StandardOnSchemaRoles_bak';
END 
GO

IF @@ERROR <> 0
	RETURN;


DECLARE @SQL VARCHAR(MAX);
IF  NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRoles]'))
BEGIN
    SET @SQL =  'CREATE view [security].[StandardOnSchemaRoles]
                AS
                select ''Not implemented'' as Col1'
    EXEC (@SQL)
	PRINT '    View [security].[StandardOnSchemaRoles] created.'
END

SET @SQL = 'ALTER view [security].[StandardOnSchemaRoles]
                AS
                 select
                    RoleName,
					Description,
					isActive,
					[CreationDate],
					[lastmodified]
                from [security].[StandardRoles] sr
				where sr.RoleScope = ''SCHEMA'''
EXEC (@SQL)
PRINT '    View altered.'
GO

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRoles]') AND name = N'PK_StandardOnSchemaRoles')
BEGIN
    CREATE UNIQUE CLUSTERED INDEX [PK_StandardOnSchemaRoles]
        ON [security].[StandardOnSchemaRoles] (
                [RoleName] ASC
        )        
    ON [PRIMARY]
	
	PRINT '    Clustered Index [PK_StandardOnSchemaRoles] created.'
END
GO

IF(	OBJECT_ID('[security].[StandardOnSchemaRoles_bak]') IS NOT NULL AND EXISTS (
	select RoleName,Description,isActive from [security].[StandardOnSchemaRoles_bak]
	except
	select RoleName,Description,isActive from [security].[StandardOnSchemaRoles]
))
BEGIN 
	exec sp_executesql N'DROP VIEW [security].[StandardOnSchemaRoles]';
	EXEC sp_rename N'[security].[StandardOnSchemaRoles_bak]','StandardOnSchemaRoles';
	RAISERROR('Problem while trying to upgrade',12,1);
END 
ELSE 
BEGIN 
	exec sp_executesql N'DROP TABLE [security].[StandardOnSchemaRoles_bak]';
END 

GO 

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 