/*requires Schema.Security.sql*/
/*requires Table.DatabaseRoles.sql*/
/*requires Table.DatabasePermissions.sql*/
/*requires Table.StandardExclusion.sql*/
/*requires Table.security.StandardRoles.sql*/
/*requires Table.ApplicationParams.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setStandardPermissions] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setStandardPermissions]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setStandardPermissions] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName        varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
    PRINT '    Procedure created.'
END
GO


ALTER PROCEDURE [security].[setStandardPermissions] (
    @ServerName  varchar(512)	= @@SERVERNAME,
    @DbName      varchar(128)  	= NULL,
	@SchemaName  varchar(64)   	= NULL,
    @Debug       BIT          	= 0
)
AS
BEGIN 
    --SET NOCOUNT ON;
    DECLARE @tsql               varchar(max);
	DECLARE @tsql_declaration   nvarchar(max);    
	DECLARE @LineFeed           VARCHAR(6) ;
	
	DECLARE @tmpCnt             BIGINT;
    
    SET @LineFeed = CHAR(13) + CHAR(10) ;
    SET @tsql = '';
    SET @tsql_declaration = '';
    SET @tmpCnt = 0;	
	
	if(EXISTS (
		select 1 from security.StandardExclusion
		where 
			isActive = 1 
		and (
				(ObjectType = 'DATABASE' and ObjectName = isnull(@DbName,'<null_db>'))
			or 	(ObjectType = 'SERVER' and ObjectName = @ServerName)
			or 	(ObjectType = 'DATABASE_SCHEMA' and ObjectName = isnull(@SchemaName,'<null_schema>')))
		)
	)
	BEGIN
		PRINT 'Warning : one or more exclusion rules have been defined for this set of parameters :';
		PRINT '          ServerName => ' + @ServerName ;
		PRINT '          DbName     => ' + @DbName;
		PRINT '          SchemaName => ' + @SchemaName;	
		RETURN;
	END 
	
	DECLARE @RoleSep      VARCHAR(64)
    
    select @RoleSep = ParamValue
    from [security].[ApplicationParams]
    where ParamName = 'Separator4OnSchemaStandardRole' ;

	with prep
	AS (
	select 
		srp.RoleScope,
		case 
			when sr.NeedsPrefix = 1 AND srp.RoleScope = 'SCHEMA' THEN
				CASE 
					WHEN LEN(@SchemaName) > 0 THEN @SchemaName + @RoleSep + srp.RoleName 
					ELSE NULL 
				END 
			WHEN sr.NeedsPrefix = 1 AND srp.RoleScope = 'DATABASE' THEN 
				CASE 
					WHEN LEN(@DbName) > 0 THEN @DbName + @RoleSep + srp.RoleName 
					ELSE NULL 
				END
			WHEN sr.NeedsPrefix = 1 AND srp.RoleScope not in ('SCHEMA','DATABASE') THEN NULL 
			ELSE  srp.RoleName 
		END as RoleName,
		srp.ObjectClass,
		srp.ObjectType,
		srp.PermissionLevel,
		srp.PermissionName,
		CASE 
			WHEN srp.DbName IS NULL AND srp.RoleScope in ('SCHEMA','DATABASE') THEN @DbName
			ELSE srp.DbName
		END as DbName,
		srp.SchemaName,
		CASE WHEN srp.ObjectName = '$(SCHEMA_NAME)' THEN @SchemaName WHEN srp.ObjectName = '$(DATABASE)' THEN @DbName ELSE srp.ObjectName END as ObjectName, 
		srp.SubObjectName, 
		srp.isWithGrantOption,
		srp.isDefinedByMSSQL,
		case when srp.isDefinedByMSSQL = 1 and srp.Reason is null THEN 'Defined by Microsoft' ELSE srp.Reason END as Reason,
		srp.isActive	
	from [security].[StandardRolesPermissions] srp
	inner join [security].[StandardRoles] sr
	on srp.RoleScope = sr.RoleScope
	and srp.RoleName = sr.RoleName

	)
	MERGE [security].[DatabasePermissions] t
	USING (
		select 
			@ServerName as ServerName,
			DbName,
			RoleName,
			0 as isUser,
			ObjectClass,
			ObjectType,
			PermissionLevel,
			PermissionName,
			SchemaName,
			ObjectName,
			SubObjectName,
			isWithGrantOption,
			case when Reason is null THEN 'Defined by standard' ELSE Reason END as Reason,
			isActive	
		from prep
		where 
			RoleName is not null
		and LEN(ObjectName) > 0
	) i
	ON 
		t.ServerName = i.ServerName 
	and isnull(t.DbName,'<null>') = isnull(i.DbName,'<null>')
	and t.Grantee = i.RoleName
	and t.ObjectClass = i.ObjectClass
	and isnull(t.ObjectType,'<null>') = isnull(i.ObjectType,'<null>')
	and t.PermissionName = i.PermissionName
	and isnull(t.SchemaName,'<null>') = isnull(i.SchemaName,'<null>')
	and t.ObjectName = i.ObjectName
	and isnull(t.SubObjectName,'<null>') = isnull(i.SubObjectName,'<null>')
	WHEN NOT MATCHED THEN 
		insert (
			ServerName,DbName,Grantee,isUser,ObjectClass,ObjectType,PermissionLevel,PermissionName,SchemaName,ObjectName,SubObjectName,isWithGrantOption,Reason,isActive
		)
		values (
			i.ServerName,i.DbName,i.RoleName,i.isUser,i.ObjectClass,i.ObjectType,i.PermissionLevel,i.PermissionName,i.SchemaName,i.ObjectName,i.SubObjectName,i.isWithGrantOption,i.Reason,i.isActive
		)
	;
	
END
GO


IF @@ERROR = 0
    PRINT '   PROCEDURE altered.'
ELSE
BEGIN
    PRINT '   Error while trying to alter procedure'
    RETURN
END   

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''   