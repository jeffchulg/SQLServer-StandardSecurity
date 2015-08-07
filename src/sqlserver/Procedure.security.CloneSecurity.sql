/*requires Schema.Security.sql*/
/*requires Table.security.DatabaseRoles.sql*/
/*requires Table.security.DatabaseSchemas.sql*/
/*requires Table.security.SQLMappings.sql*/
/*requires Table.security.DatabasePermissions.sql*/
/*requires Table.security.DatabaseRoleMembers.sql*/
/*requires Table.security.SQLLogins.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[CloneSecurity] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[CloneSecurity]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[CloneSecurity] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[CloneSecurity] created.'
END
GO

ALTER PROCEDURE [security].[CloneSecurity] (
    @ServerName  		varchar(512) = @@ServerName,
	@DbName		 		varchar(128)  = NULL,
	@TargetServerName	varchar(512) = @@ServerName,
	@TargetDbName		varchar(128)  = NULL,
	@ExactCopy	 		BIT		  	 = 0,
	@Debug		 		BIT		  	 = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
		This function is a helper for one to quickly copy the security model set
		for a database in a server. If no database is set, the whole server is used.
		This can lead to problematic situations as there can be databases that exists
		on the source server and doesn't on the target server.
		So, be aware of what you are doing !
  
   ARGUMENTS :
     @ServerName    name of the server from which the we want to copy the security
					By default, it's the current server
	
	 @DbName		name of the database to consider on that server.
					A NULL value (which is the default value) means that this procedure
					has to take care of every databases existing on that server.
  
	 @TargetServerName
					name of the server for which we want to set the same configuration
  
	 @TargetDbName	name of the server for which we want to set the same configuration
					A NULL value means that we will use @DbName value.
  
	 @ExactCopy		specifies if we need to scratch configuration for @TargetServer
  
   REQUIREMENTS:
  
	EXAMPLE USAGE :
		
		[security].[CloneSecurity]
			@ServerName  		= 'SI-S-SERV204',
			@DbName		 		= 'Pharmalogic',
			@TargetServerName	= 'SI-S-SERV183',
			@TargetDbName		= NULL,
			@ExactCopy	 		= 1,
			@Debug		 		= 0		
   ==================================================================================
   BUGS:
  
     BUGID       Fixed   Description
     ==========  =====   ==========================================================
     ----------------------------------------------------------------------------------
   ==================================================================================
   NOTES:
   AUTHORS:
        .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
        .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
        .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
  
   COMPANY: CHU Liege
   ==================================================================================
   Revision History
  
    Date        Nom         Description
    ==========  =====       ==========================================================
	24/12/2014  JEL         Version 0.0.1
    ----------------------------------------------------------------------------------
	07/08/2015 	JEL			Removed version number
    ----------------------------------------------------------------------------------	 
  ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    DECLARE @tsql             	varchar(max);

	DECLARE	@CurDbName		  	varchar(64)
	DECLARE @TgtDbName			varchar(64)
	
	/*
		Checking parameters
	*/
	
	if(@ServerName is null)
	BEGIN
		RAISERROR('No value set for @ServerName !',10,1)
	END		
	if(@TargetServerName is null)
	BEGIN
		RAISERROR('No value set for @TargetServerName !',10,1)
	END		
	
	SET @TgtDbName = @TargetDbName
	SET @CurDbName = @DbName		
	
	BEGIN TRY
	BEGIN TRANSACTION
	
		if(@CurDbName is null) 
		BEGIN

			if @ExactCopy = 1
			BEGIN
				if @Debug = 1
				BEGIN
					RAISERROR('Exact copy mode not yet implemented',10,1)
					--PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Deleting every information about target database'
					-- TODO: Mark all logins as to be dropped
				END	
			END		
		
			-- needs to loop on all dbs defined in SQLMappings
			-- no parameterized cursor in MSSQL ... viva Oracle!
			DECLARE getServerDatabases CURSOR LOCAL FOR
				select distinct
					DbName
				from security.SQLMappings
				where 
					[ServerName] = @ServerName 
				order by 1			
			open getServerDatabases
			FETCH NEXT
			FROM getServerDatabases INTO @CurDbName
			
			WHILE @@FETCH_STATUS = 0
			BEGIN						
				EXEC [security].[CloneSecurity] @ServerName = @ServerName, @DbName = @CurDbName,@TargetServerName = @TargetServerName,@TargetDbName = @TgtDbName, @ExactCopy = @ExactCopy, @Debug = @Debug
				-- carry on ...
				FETCH NEXT
				FROM getServerDatabases INTO @CurDbName
			END
			CLOSE getServerDatabases
			DEALLOCATE getServerDatabases				
		
		END
		ELSE
		BEGIN
			
			if @Debug = 1
			BEGIN
				PRINT '--------------------------------------------------------------------------------------------------------------'
				PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Source server Name : ' + @ServerName				
				PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Target server Name : ' + @TargetServerName				
			END	
			-- setting source database name
			if @Debug = 1
			BEGIN
				PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Source server database set to ' + @CurDbName				
			END		
			
			-- setting target database name
			if(@TargetDbName is null)
			BEGIN
				SET @TgtDbName = @CurDbName
				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Target server database set to ' + @TgtDbName				
				END						
			END
			ELSE
			BEGIN
				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Target server database name :' + @TgtDbName				
				END									
			END
			
			-- Checking we won't be in a problematic situation...
			if(@ServerName = @TargetServerName and @TgtDbName = @CurDbName)
			BEGIN
				PRINT CONVERT(VARCHAR,GETDATE()) + ' - WARN - Skipping execution for this settings : same server name, same database name.'				
			END
			ELSE 
			BEGIN
			
				if @ExactCopy = 1
				BEGIN
					if @Debug = 1
					BEGIN
						RAISERROR('Exact copy mode not yet implemented',10,1)
						--PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Deleting every information about target database'
						-- TODO: Procedure to mark as to be dropped everything about @TgtDbName on @TargetServer
					END	
				END			
				
				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding logins information'
				END									
				
				merge security.SQLlogins l
					using (					
						select 
							@TargetServerName as ServerName, 
							SqlLogin,
							isActive 
						from security.SQLlogins 
						where ServerName = @ServerName
					) i
					on
						l.ServerName = i.ServerName
					and l.sqlLogin   = i.SqlLogin			
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							SqlLogin,
							isActive
						)
						values (
							i.ServerName,
							i.SqlLogin,
							i.isActive
						)
					;			
				
				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding database schemas information'
				END		
				
				merge security.DatabaseSchemas d
				using (					
						select 
							@TargetServerName as ServerName, 
							@TgtDbName        as DbName,
							SchemaName,
							Description,						
							isActive 
						from security.DatabaseSchemas
						where ServerName = @ServerName
						  and DbName     = @CurDbName
					) i
					on
						d.ServerName = i.ServerName
					and d.DbName     = i.DbName			
					and d.SchemaName = i.SchemaName
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							DbName,
							SchemaName,
							Description,
							isActive
						)
						values (
							i.ServerName,
							i.DbName,
							i.SchemaName,
							i.Description,
							i.isActive
						)
					;		

				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding SQL Mappings information'
				END		
						
				merge security.SQLMappings d
				using (					
						select 
							@TargetServerName as ServerName, 
							SQLLogin,
							@TgtDbName        as DbName,
							DbUserName,
							DefaultSchema,
							isDefaultDb,	
							isLocked
						from security.SQLMappings
						where ServerName = @ServerName
						  and DbName     = @CurDbName
					) i
					on
						d.ServerName = i.ServerName
					and d.DbName     = i.DbName			
					and d.SQLLogin   = i.SQLLogin
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							SQLLogin,
							DbName,
							DbUserName,
							DefaultSchema,
							isDefaultDb,
							isLocked
						)
						values (
							i.ServerName,
							i.SQLLogin,
							i.DbName,
							i.DbUserName,
							i.DefaultSchema,
							i.isDefaultDb,
							i.isLocked
						)
					;		
				

				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding Database Roles and role members information'
				END			
				
				merge security.DatabaseRoles d
				using (					
						select 
							@TargetServerName as ServerName, 
							@TgtDbName        as DbName,
							RoleName,
							isStandard,
							Reason,	
							isActive
						from security.DatabaseRoles
						where ServerName = @ServerName
						  and DbName     = @CurDbName
					) i
					on
						d.ServerName = i.ServerName
					and d.DbName     = i.DbName			
					and d.RoleName   = i.RoleName
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							DbName,
							RoleName,
							isStandard,
							Reason,
							isActive
						)
						values (
							i.ServerName,
							i.DbName,
							i.RoleName,
							i.isStandard,
							i.Reason,
							i.isActive
						)
					;			

				merge security.DatabaseRoleMembers d
				using (					
						select 
							@TargetServerName as ServerName, 
							@TgtDbName        as DbName,
							RoleName,
							MemberName,
							MemberIsRole,
							Reason,	
							isActive
						from security.DatabaseRoleMembers
						where ServerName = @ServerName
						  and DbName     = @CurDbName
					) i
					on
						d.ServerName = i.ServerName
					and d.DbName     = i.DbName			
					and d.RoleName   = i.RoleName
					and d.MemberName = i.MemberName
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							DbName,
							RoleName,
							MemberName,
							MemberIsRole,
							Reason,
							isActive
						)
						values (
							i.ServerName,
							i.DbName,
							i.RoleName,
							i.MemberName,
							i.MemberIsRole,
							i.Reason,
							i.isActive
						)
					;					
				
				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding object permissions information'
				END					
				
				merge security.DatabasePermissions d
				using (					
						select 
							@TargetServerName as ServerName, 
							@TgtDbName        as DbName,
							Grantee,
							isUser,
							ObjectClass,
							ObjectType,	
							PermissionLevel,	
							PermissionName,	
							SchemaName,	
							ObjectName,	
							SubObjectName,	
							isWithGrantOption,	
							Reason,	
							isActive
						from security.DatabasePermissions
						where ServerName = @ServerName
						  and DbName     = @CurDbName
					) i
					on
						d.ServerName  					= i.ServerName
					and d.DbName      					= i.DbName			
					and d.Grantee     					= i.Grantee
					and d.ObjectClass 					= i.ObjectClass
					and ISNULL(d.ObjectType,'null')		= ISNULL(i.ObjectType,'null')
					and d.PermissionName  				= i.PermissionName
					and ISNULL(d.SchemaName,'null') 	= ISNULL(i.SchemaName,'null')
					and d.ObjectName  	    			= i.ObjectName
					and ISNULL(d.SubObjectName,'null')	= ISNULL(i.SubObjectName,'null')
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							DbName,
							Grantee,
							isUser,
							ObjectClass,
							ObjectType,
							PermissionLevel,
							PermissionName,
							SchemaName,
							ObjectName,
							SubObjectName,
							isWithGrantOption,
							Reason,
							isActive
						)
						values (
							i.ServerName,
							i.DbName,
							i.Grantee,
							i.isUser,
							i.ObjectClass,
							i.ObjectType,
							i.PermissionLevel,
							i.PermissionName,
							i.SchemaName,
							i.ObjectName,
							i.SubObjectName,
							i.isWithGrantOption,
							i.Reason,
							i.isActive
						)
					;					
			END
			if @Debug = 1 
			BEGIN
				PRINT '--------------------------------------------------------------------------------------------------------------'
			END
		END
	COMMIT
	
	END TRY
	
	BEGIN CATCH
		SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
		
		if CURSOR_STATUS('local','getServerDatabases') >= 0 
		begin
			close getServerDatabases
			deallocate getServerDatabases 
		end
		
		ROLLBACK
	END CATCH
END
GO

PRINT '    Procedure [security].[CloneSecurity] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 	