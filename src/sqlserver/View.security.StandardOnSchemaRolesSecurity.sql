/*requires Schema.Security.sql*/
/*requires Table.security.StandardRoleMembers.sql*/
/*requires Table.security.StandardRolesPermissions.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'View [security].[StandardOnSchemaRolesSecurity] Creation'

IF (EXISTS( select 1 from sys.all_objects where OBJECT_ID = OBJECT_ID('[security].[StandardOnSchemaRolesSecurity]') and type_desc = 'USER_TABLE'))
BEGIN 
	EXEC sp_rename N'[security].[StandardOnSchemaRolesSecurity]','StandardOnSchemaRolesSecurity_bak';
	IF @@ERROR <> 0
		RETURN;
	ELSE 
		PRINT '    Table [security].[StandardOnSchemaRolesSecurity] renamed to StandardOnSchemaRolesSecurity_bak';
END 
GO

IF @@ERROR <> 0
	RETURN;


DECLARE @SQL VARCHAR(MAX);
IF  NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]'))
BEGIN
    SET @SQL =  'CREATE view [security].[StandardOnSchemaRolesSecurity]
				 WITH SCHEMABINDING
                AS					
                select ''Not implemented'' as Col1'
    EXEC (@SQL)
	PRINT '    View [security].[StandardOnSchemaRolesSecurity] created.'
END

SET @SQL = 'ALTER view [security].[StandardOnSchemaRolesSecurity]
			    WITH SCHEMABINDING
                AS
					select 
						MemberName as RoleName,
						RoleName as PrivName,
						''DATABASE_SCHEMA'' as PermissionClass,
						PermissionLevel,
						isActive,
						1 as isRoleMembership
					from 
						security.StandardRoleMembers
					where 
						RoleScope = ''SCHEMA'' and RoleMemberScope = ''SCHEMA''
					union all (
						select 
							RoleName,
							PermissionName,
							ObjectClass,
							PermissionLevel,
							isActive,
							0 as isRoleMembership 
						from 
							security.StandardRolesPermissions
						where 
							RoleScope = ''SCHEMA''
                        AND ObjectClass in (''DATABASE'',''DATABASE_SCHEMA'')
					)';
EXEC (@SQL)
PRINT '    View altered.'
GO

/*
IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]') AND name = N'PK_StandardOnSchemaRolesSecurity')
BEGIN
    CREATE UNIQUE CLUSTERED INDEX [PK_StandardOnSchemaRolesSecurity]
        ON [security].[StandardOnSchemaRolesSecurity] (
                [RoleName] ASC,
				[PrivName] ASC,
				[PermissionClass] ASC				
        )        
    ON [PRIMARY]
	
	PRINT '    Clustered Index [PK_StandardOnSchemaRolesSecurity] created.'
END
GO*/

DECLARE @retval int   
DECLARE @tsql nvarchar(500);
DECLARE @ParmDefinition nvarchar(500);
SET @ParmDefinition = N'@retvalOUT int OUTPUT';

SELECT @tsql = N'SELECT @retvalOUT = count(*) FROM (
	select RoleName,PrivName,PermissionClass,PermissionLevel,isActive,isRoleMembership from [security].[StandardOnSchemaRolesSecurity_bak]
	except
	select RoleName,PrivName,PermissionClass,PermissionLevel,isActive,isRoleMembership from [security].[StandardOnSchemaRolesSecurity]';



SET @ParmDefinition = N'@retvalOUT int OUTPUT';
IF(	OBJECT_ID('[security].[StandardOnSchemaRolesSecurity_bak]') IS NOT NULL)
BEGIN 
	
	EXEC sp_executesql @tsql, @ParmDefinition, @retvalOUT=@retval OUTPUT;

	if(@retVal > 0)
	BEGIN 
		exec sp_executesql N'DROP VIEW [security].[StandardOnSchemaRolesSecurity]';
		EXEC sp_rename N'[security].[StandardOnSchemaRolesSecurity_bak]','StandardOnSchemaRolesSecurity';
		RAISERROR('Problem while trying to upgrade',12,1);
	END
	ELSE 
	BEGIN 
		exec sp_executesql N'DROP TABLE [security].[StandardOnSchemaRolesSecurity_bak]';
	END 
END 

GO 
GO 

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 