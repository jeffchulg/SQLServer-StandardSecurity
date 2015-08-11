/*requires Schema.Security.sql*/
/*requires Table.security.DatabaseRoles.sql*/
/*requires Table.security.DatabaseRoleMembers.sql*/
/*requires Table.security.StandardExclusion.sql*/
/*requires Table.security.StandardRoles.sql*/
/*requires Table.security.ApplicationParams.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setStandardRoleMembers] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setStandardRoleMembers]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setStandardRoleMembers] ( ' +
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


ALTER PROCEDURE [security].[setStandardRoleMembers] (
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
			srp.RoleMemberScope,
			case 
				when srm.NeedsPrefix = 1 AND srp.RoleMemberScope = 'SCHEMA' THEN
					CASE 
						WHEN LEN(@SchemaName) > 0 THEN @SchemaName + @RoleSep + srp.MemberName 
						ELSE NULL 
					END 
				WHEN srm.NeedsPrefix = 1 AND srp.RoleMemberScope = 'DATABASE' THEN 
					CASE 
						WHEN LEN(@DbName) > 0 THEN @DbName + @RoleSep + srp.MemberName 
						ELSE NULL 
					END
				WHEN srm.NeedsPrefix = 1 AND srp.RoleMemberScope not in ('SCHEMA','DATABASE') THEN NULL 
				ELSE  srp.MemberName 
			END as MemberName,	
			1 as MemberIsRole , -- Until potential changes... ALWAYS a role !
			srp.PermissionLevel,
			case when srp.isDefinedByMSSQL = 1 and srp.Reason is null THEN 'Defined by Microsoft' ELSE srp.Reason END as Reason,
			srp.isActive	
		from [security].[StandardRoleMembers] srp
		inner join 
			[security].[StandardRoles] sr
		on 
			srp.RoleScope 	= sr.RoleScope
		and srp.RoleName 	= sr.RoleName
		inner join 
			[security].[StandardRoles] srm
		on 
			srp.RoleMemberScope = srm.RoleScope
		and srp.MemberName 		= srm.RoleName
	)
	MERGE [security].[DatabaseRoleMembers] t
	USING (
		select * 
		from prep 
		where 
			RoleName is not null 
		and MemberName is not null 
		and RoleScope in ('DATABASE','SCHEMA')
		and RoleMemberScope in ('DATABASE','SCHEMA')
	)  as i
	ON 
		t.ServerName = i.ServerName 
	and isnull(t.DbName,'<null>') = isnull(i.DbName,'<null>')
	and t.RoleName = i.RoleName
	and t.MemberName = i.MemberName	
	WHEN NOT MATCHED THEN 
		insert (
			ServerName,DbName,RoleName,MemberName,MemberIsRole,PermissionLevel,Reason,isActive
		)
		values (
			i.ServerName,i.DbName,i.RoleName,i.MemberName,i.MemberIsRole,i.PermissionLevel,i.Reason,i.isActive
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