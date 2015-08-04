/*requires Schema.Security.sql*/
/*requires Table.security.DatabaseRoles.sql*/
/*requires Table.security.DatabasePermissions.sql*/
/*requires Table.security.StandardExclusion.sql*/
/*requires Table.security.StandardRoles.sql*/
/*requires Table.security.ApplicationParams.sql*/
/*requires Procedure.security.setStandardPermissions.sql*/
/*requires Procedure.security.setStandardRoleMembers.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setStandardRoles] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setStandardRoles]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setStandardRoles] ( ' +
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


ALTER PROCEDURE [security].[setStandardRoles] (
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
		@ServerName as ServerName,
		@DbName     as DbName,
		case
			when NeedsPrefix = 1 AND RoleScope = 'SCHEMA' THEN
				CASE
					WHEN LEN(@SchemaName) > 0 THEN @SchemaName + @RoleSep + RoleName
					ELSE NULL
				END
			WHEN NeedsPrefix = 1 AND RoleScope = 'DATABASE' THEN
				CASE
					WHEN LEN(@DbName) > 0 THEN @DbName + @RoleSep + RoleName
					ELSE NULL
				END
			WHEN NeedsPrefix = 1 AND RoleScope not in ('SCHEMA','DATABASE') THEN NULL
			ELSE  RoleName
		END as RoleName,
		1 as isStandard,
		case
			when isDefinedByMSSQL = 1 and [Description] is null THEN 'Defined by Microsoft'
			WHEN isDefinedByMSSQL = 0 and [Description] is null THEN 'Defined by Standard'
			ELSE [Description]
		END as Reason,
		isActive
	from [security].[StandardRoles] srp
	where 
		RoleName is not null 
	and RoleScope in ('DATABASE','SCHEMA')
	)
	MERGE [security].[DatabaseRoles] t
	USING prep as i
	ON
		t.ServerName = i.ServerName
	and isnull(t.DbName,'<null>') = isnull(i.DbName,'<null>')
	and t.RoleName = i.RoleName
	WHEN NOT MATCHED THEN
		insert (
			ServerName,DbName,RoleName,isStandard,Reason,isActive
		)
		values (
			i.ServerName,i.DbName,i.RoleName,i.isStandard,i.Reason,i.isActive
		)
	;

	-- setting up permissions
	exec security.setStandardPermissions @ServerName = @ServerName, @DbName = @DbName , @SchemaName = @SchemaName, @Debug = @Debug;
	
	-- setting up role memberships
	exec security.setStandardRoleMembers @ServerName = @ServerName, @DbName = @DbName , @SchemaName = @SchemaName, @Debug = @Debug;
	
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