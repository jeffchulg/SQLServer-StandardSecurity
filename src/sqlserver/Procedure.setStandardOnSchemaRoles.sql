/*requires Schema.Security.sql*/
/*requires Table.DatabaseRoles.sql*/
/*requires Table.DatabasePermissions.sql*/
/*requires Table.StandardOnSchemaRoles.sql*/
/*requires Table.DatabaseSchemas.sql*/
/*requires Table.SQLMappings.sql*/
/*requires Table.StandardExclusion.sql*/
/*requires View.StandardOnSchemaRolesTreeView.sql*/
/*requires Procedure.setStandardOnSchemaRolePermissions.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setStandardOnSchemaRoles] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setStandardOnSchemaRoles]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setStandardOnSchemaRoles] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName        varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
    PRINT '    Procedure [security].[setStandardOnSchemaRoles] created.'
END
GO

ALTER PROCEDURE [security].[setStandardOnSchemaRoles] (
    @ServerName  varchar(512) = @@SERVERNAME,
    @DbName      varchar(128)  = NULL,
    @SchemaName  varchar(64)  = NULL,
    @StdRoleName varchar(64)  = NULL,
    @Debug       BIT          = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
     This function takes care of the generation of Database Roles for "on schema" access 
     according to its parameter values.
  
   ARGUMENTS :
     @ServerName    name of the server on which the SQL Server instance we want to modify is running.
                    By default, it's the current server
    
     @DbName        name of the database to take care of.
                    A NULL value (which is the default value) means that this procedure
                    has to take care of all "on schema" roles for any database on the given server.
     
     @SchemaName    name of the schema for which execute this procedure
                    if NULL given, all schemas references in the security inventory will be taken
     
     @StdRoleName   name of the standard role for which execute this procedure
                    if NULL given, all standard roles are being taken into account

     @Debug         If set to 1, then we are in debug mode

   REQUIREMENTS:
  
    EXAMPLE USAGE :
        
        -- All standard security roles on all servers
        exec [security].[setStandardOnSchemaRoles] @ServerName = null
        
        -- All standard security roles on all servers for DBA database
        exec [security].[setStandardOnSchemaRoles] @ServerName = null, @DbName = 'DBA'
        
        -- All standard security roles on server 'SI-S-SERV308' for DBA database
        exec [security].[setStandardOnSchemaRoles] @ServerName = 'SI-S-SERV308', @DbName = 'DBA'        
        
        -- All standard security roles on local server for all database (uses variable @@SERVERNAME)
        exec [security].[setStandardOnSchemaRoles]
        
        -- All standard security roles on local server for DBA database (uses variable @@SERVERNAME)
        exec [security].[setStandardOnSchemaRoles] @DbName = 'DBA'
  
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
  ===================================================================================
*/
BEGIN

    --SET NOCOUNT ON;
    DECLARE @versionNb          varchar(16) = '0.1.1';
    DECLARE @tsql               varchar(max);
    DECLARE @CurServerName      varchar(512)
    DECLARE @CurDbName          varchar(64)
    DECLARE @CurRoleName        varchar(64) 
    DECLARE @CurDescription     varchar(2048)
    DECLARE @curIsActive        BIT
	DECLARE @TransactionOpened  BIT
    DECLARE @SchemaRoleSep      VARCHAR(64)
    
    select @SchemaRoleSep = ParamValue
    from [security].[ApplicationParams]
    where ParamName = 'Separator4OnSchemaStandardRole' ;
    
    SET @CurServerName = @ServerName
    SET @CurDbName     = @DbName
    
    BEGIN TRY
		if(@@TRANCOUNT = 0)
		BEGIN 
			BEGIN TRANSACTION;
			SET @TransactionOpened = 1;
		END 
        if(@CurServerName is null) 
        BEGIN
            -- needs to loop on all servers defined in SQLMappings
            -- no parameterized cursor in MSSQL ... viva Oracle!
            
            if @Debug = 1
            BEGIN           
                PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - No ServerName Given. Overall repository security update.'
            END
            
            DECLARE getServers CURSOR LOCAL FOR
                select distinct
                    ServerName
                from    
                    security.SQLMappings        
                order by 1
                
            open getServers
            FETCH NEXT
            FROM getServers INTO @CurServerName
            
            WHILE @@FETCH_STATUS = 0
            BEGIN               
                EXEC [security].[setStandardOnSchemaRoles] @ServerName = @CurServerName, @DbName = @CurDbName,@Debug = @Debug
                -- carry on ...
                FETCH NEXT
                FROM getServers INTO @CurServerName
            END
            CLOSE getServers
            DEALLOCATE getServers
        END
        else if(@CurServerName is not null and @CurDbName is null) 
        BEGIN
            -- needs to loop on all dbs defined in SQLMappings
            -- no parameterized cursor in MSSQL ... viva Oracle!
            DECLARE getServerDatabases CURSOR LOCAL FOR
                select distinct
                    DbName
                from security.SQLMappings
                where 
                    [ServerName] = @CurServerName 
                and [DbName] not in (
                    select 
                        ObjectName 
                    from 
                        security.StandardExclusion
                    where 
                        ObjectType = 'DATABASE'
                    and isActive = 1            
                )
                order by 1          
            open getServerDatabases
            FETCH NEXT
            FROM getServerDatabases INTO @CurDbName
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC [security].[setStandardOnSchemaRoles] @ServerName = @CurServerName, @DbName = @CurDbName,@Debug = @Debug
                -- carry on ...
                FETCH NEXT
                FROM getServerDatabases INTO @CurDbName
            END
            CLOSE getServerDatabases
            DEALLOCATE getServerDatabases   
        END 
        else
        BEGIN           
            if @Debug = 1
            BEGIN
                PRINT '--------------------------------------------------------------------------------------------------------------'
                PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of server ' + @CurServerName             
                PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of Database ' + @CurDbName               
            END     
            
            -- Get the list of standard roles to create/update
            
            -- no parameterized cursor in MSSQL ... viva Oracle!
            
            DECLARE getSchemasRoles CURSOR LOCAL FOR
                select s.SchemaName, r.[Level],r.RoleName, r.isActive, r.Description
                from 
                    security.DatabaseSchemas as S 
                cross join
                    security.StandardOnSchemaRolesTreeView as r 
                where 
                    s.ServerName = @CurServerName
                and s.DbName     = @CurDbName
                and s.SchemaName not in (
                        select 
                            ObjectName 
                        from 
                            security.StandardExclusion
                        where 
                            ObjectType = 'DATABASE_SCHEMA'
                        and isActive = 1    
                    )
                order by s.SchemaName,r.[Level]           
            
            Declare @CurSchemaName VARCHAR(64)
            DECLARE @CurRoleSuffix VARCHAR(64);
            DECLARE @RoleTreeLevel BIGINT;
            open getSchemasRoles
            FETCH NEXT
            FROM getSchemasRoles INTO @CurSchemaName,@RoleTreeLevel,@CurRoleSuffix,@curIsActive,@CurDescription
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
            
                if( (@SchemaName is not null and @CurSchemaName <> @SchemaName) 
                    or (
                    @StdRoleName is not null and @CurRoleSuffix <> @StdRoleName))
                BEGIN
                    PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Not taking care of Schema "' + ISNULL(@CurRoleName,'<N/A>') + '" | Standard Role "' + ISNULL(@CurRoleSuffix,'<N/A>') + '"'
                    FETCH NEXT
                        FROM getSchemasRoles INTO @CurSchemaName,@RoleTreeLevel,@CurRoleSuffix,@curIsActive,@CurDescription
                    CONTINUE
                END
            
                SET @CurRoleName = @CurSchemaName + @SchemaRoleSep + @CurRoleSuffix 
            
                if @Debug = 1
                BEGIN
                    PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of Standard Role ' + @CurRoleName
                END

                merge security.DatabaseRoles r
                using (
                    select 
                        @CurServerName  as ServerName,
                        @CurDbName      as DbName,
                        @CurRoleName    as RoleName,
                        @curIsActive    as isActive,
                        @curDescription as Description 
                ) i
                on
                    r.ServerName = i.ServerName
                and r.DbName     = i.DbName
                and r.RoleName   = i.RoleName
                WHEN MATCHED THEN
                    update set
                        isActive = i.isActive
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
                        1,
                        i.Description,
                        i.isActive
                    )
                /*
                WHEN NOT MATCHED BY SOURCE THEN
                    -- TODO make a procedure to undo the missing standard privilege
                */
                ;
                
                -- now the role is created, we can add its permissions
                EXEC [security].[setStandardOnSchemaRolePermissions] 
                    @ServerName  = @CurServerName,
                    @DbName      = @CurDbName,
                    @SchemaName  = @CurSchemaName,
                    @StdRoleName = @CurRoleSuffix,
                    @Debug       = @Debug
                
                -- carry on ...
                FETCH NEXT
                    FROM getSchemasRoles INTO @CurSchemaName,@RoleTreeLevel,@CurRoleSuffix,@curIsActive,@CurDescription
            END
            CLOSE getSchemasRoles
            DEALLOCATE getSchemasRoles              
            if(@Debug = 1) 
            BEGIN
                PRINT '--------------------------------------------------------------------------------------------------------------'
            END
        end
		if(@TransactionOpened = 1)
		BEGIN 
			COMMIT
		END 
	END TRY
    BEGIN CATCH
        SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
        
        if CURSOR_STATUS('local','getServers') >= 0 
        begin
            close getServers
            deallocate getServers 
        end     
        if CURSOR_STATUS('local','getServerDatabases') >= 0 
        begin
            close getServerDatabases
            deallocate getServerDatabases 
        end
        if CURSOR_STATUS('local','getSchemasRoles') >= 0 
        begin
            close getSchemasRoles
            deallocate getSchemasRoles 
        end
		IF @@TRANCOUNT > 0 and @TransactionOpened = 1
        BEGIN 
            ROLLBACK ;
        END
	END CATCH
END
GO


PRINT '    Procedure [security].[setStandardOnSchemaRoles] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''    