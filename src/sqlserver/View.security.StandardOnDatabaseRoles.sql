/*requires Schema.Security.sql*/
/*requires Table.security.StandardRoles.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'View [security].[logins] Creation'

IF (EXISTS( select 1 from sys.all_objects where OBJECT_ID = OBJECT_ID('[security].[StandardOnDatabaseRoles]') and type_desc = 'USER_TABLE'))
BEGIN 
	EXEC sp_rename N'[security].[StandardOnDatabaseRoles]','StandardOnDatabaseRoles_bak';
	IF @@ERROR <> 0
		RETURN;
	ELSE 
		PRINT '    Table [security].[StandardOnDatabaseRoles] renamed to StandardOnDatabaseRoles_bak';
END 
GO

IF @@ERROR <> 0
	RETURN;


DECLARE @SQL VARCHAR(MAX);
IF  NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[security].[StandardOnDatabaseRoles]'))
BEGIN
    SET @SQL =  'CREATE view [security].[StandardOnDatabaseRoles]
                AS
                select ''Not implemented'' as Col1'
    EXEC (@SQL)
	PRINT '    View [security].[StandardOnDatabaseRoles] created.'
END

SET @SQL = 'ALTER view [security].[StandardOnDatabaseRoles]
                AS
                 select
                    RoleName,
					Description,
					isActive,
					[CreationDate],
					[lastmodified]
                from [security].[StandardRoles] sr
				where sr.RoleScope = ''DATABASE'''
EXEC (@SQL)
PRINT '    View altered.'
GO



IF(	OBJECT_ID('[security].[StandardOnDatabaseRoles_bak]') IS NOT NULL AND EXISTS (
	select RoleName,Description,isActive from [security].[StandardOnDatabaseRoles_bak]
	except
	select RoleName,Description,isActive from [security].[StandardOnDatabaseRoles]
))
BEGIN 
	exec sp_executesql N'DROP VIEW [security].[StandardOnDatabaseRoles]';
	EXEC sp_rename N'[security].[StandardOnDatabaseRoles_bak]','StandardOnDatabaseRoles';
	RAISERROR('Problem while trying to upgrade',12,1);
END 
ELSE 
BEGIN 
	exec sp_executesql N'DROP TABLE [security].[StandardOnDatabaseRoles_bak]';
END 

GO 

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 