/*requires Schema.Security.sql*/
/*requires Table.DatabaseRoles.sql*/
/*requires Table.DatabaseSchemas.sql*/
/*requires Table.SQLMappings.sql*/
/*requires Table.DatabasePermissions.sql*/
/*requires Procedure.CreateTempTables4Generation.sql*/
/*requires Procedure.SaveSecurityGenerationResult.sql*/
/*requires Table.DatabaseRoleMembers.sql*/
/*requires Table.SQLLogins.sql*/
/*requires Procedure.getDbSchemasCreationScript.sql*/
/*requires Procedure.getLoginsCreationScript.sql*/
/*requires Procedure.getDbUsersCreationScript.sql*/
/*requires Procedure.getDbRolesCreationScript.sql*/
/*requires Procedure.getDbRolesAssignmentScript.sql*/
/*requires Procedure.getLogin2DbUserMappingsScript.sql*/
/*requires Procedure.SecurityGenHelper_AppendCheck.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[getSecurityScript] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getSecurityScript]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[getSecurityScript] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[getSecurityScript] created.'
END
GO

ALTER PROCEDURE [security].[getSecurityScript] (
    @ServerName  		    varchar(512) 	= @@ServerName,
	@DbName		 		    varchar(64)  	= NULL,
	@AsOf 				    DATETIME 		= NULL ,
	@OutputType 		    VARCHAR(20) 	= 'TABLE' ,
    @OutputDatabaseName     NVARCHAR(128) 	= NULL ,
    @OutputSchemaName 	    NVARCHAR(256) 	= NULL ,
    @OutputTableName 	    NVARCHAR(256) 	= NULL ,	
    @NoServerNameCheckGen   BIT             = 0,
    @NoLoginGen             BIT             = 0,
    @CanDropTempTables      BIT             = 1,
    @DisplayResult          BIT             = 1,
	@Debug		 		    BIT		  	 	= 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
		This procedure will generate a script which will be applicable on the
        specified server. It will create all the statements for the application
        of security standard on that server.
  
   ARGUMENTS :
    @ServerName             name of the server from which the we want to copy the security
                            By default, it's the current server

    @DbName		            name of the database to consider on that server.
                            A NULL value (which is the default value) means that this procedure
                            has to take care of every databases existing on that server.
    @UserName               name of the database user we need to take care of
    @AsOf                   to see a previous generated script result
    @OutputType             the output type you want : TABLE or SCRIPT at the moment
    @OutputDatabaseName     name of the database where we'll keep track of the generated script 
    @OutputSchemaName       name of the database schema in which we'll keep track of the generated script 
    @OutputTableName        name of the table in which we'll actually keep track of the generated script 
    @NoServerNameCheckGen   if set to 1, no check for server name is generated
    @NoLoginGen             if set to 1, no generation for login creation statements is launched
    @CanDropTempTables      if set to 1, the temporary tables required for this procedure to succeed can be dropped by the tool.
                            It will create them if they don't exist
    @DisplayResult          If set to 1, then we'll display the results on standard output
    @Debug                  If set to 1, then we are in debug mode
  
   REQUIREMENTS:
  
	EXAMPLE USAGE :
		exec [security].[getSecurityScript] 
    @ServerName  		= 'SI-S-SERV308',
	@DbName		 		= NULL, --'DBA',
	@AsOf 				= NULL ,
	@OutputType 		= 'TABLE' ,
    @OutputDatabaseName = 'TESTING_ONLY_TESTING' ,
    @OutputSchemaName 	= 'dbo' ,
    @OutputTableName 	= 'tst_getSecurityScript' ,	
	@Debug		 		= 1
	
DROP TABLE ##getSecurityScriptResults

DECLARE @asOf DATETIME
select @asOf = CAST( '2014-12-19 07:22:15.073' AS DATETIME)
exec [security].[getSecurityScript] 
    @ServerName  		= 'SI-S-SERV308',
	@DbName		 		= NULL, --'DBA',
	@AsOf 				= @asOf,
	@OutputType 		= 'TABLE' ,
    @OutputDatabaseName = 'TESTING_ONLY_TESTING' ,
    @OutputSchemaName 	= 'dbo' ,
    @OutputTableName 	= 'tst_getSecurityScript' ,	
	@Debug		 		= 1	
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

    SET NOCOUNT ON;
	
    DECLARE @versionNb        	varchar(16) = '0.0.1';
    DECLARE @tsql             	varchar(max);
	DECLARE @execTime			datetime;
	DECLARE	@CurDbName		  	varchar(64)
	DECLARE @LineFeed 			VARCHAR(10)
    DECLARE @StringToExecute    VARCHAR(MAX)
    
	/* Sanitize our inputs */
	SELECT 
		@OutputDatabaseName = QUOTENAME(@OutputDatabaseName),
		@LineFeed 			= CHAR(13) + CHAR(10),
		@execTime = GETDATE()
	
    /**
     * Checking parameters
     */
    if(@ServerName is null)
    BEGIN
        RAISERROR('No value set for @ServerName !',10,1)
    END		
    
    SET @CurDbName = @DbName		
    
    exec security.CreateTempTables4Generation 
            @CanDropTempTables, 
            @Debug = @Debug 
    
	
	IF @OutputType = 'SCHEMA'
	BEGIN
		SELECT FieldList = 'GenerationDate DATETIME NOT NULL | ServerName VARCHAR(256) NOT NULL | DbName VARCHAR(64) NULL | ObjectName VARCHAR(512)  NULL | GeneratorVersion VARCHAR(16) NOT NULL | OperationOrder BIGINT  NOT NULL | OperationType VARCHAR(64) not null | QueryText	VARCHAR(MAX) NOT NULL'
	END
	ELSE IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL
    -- This mode is OK, just a TODO (make it with *named* fields)
	BEGIN
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Asof Mode detected'
        END       
		-- They want to look into the past.

        SET @StringToExecute = N' IF EXISTS(SELECT * FROM '
            + @OutputDatabaseName
            + '.INFORMATION_SCHEMA.SCHEMATA WHERE (SCHEMA_NAME) = '''
            + @OutputSchemaName + ''')' + @LineFeed 
            + '    SELECT GenerationDate, ServerName,DbName,ObjectName,GeneratorVersion,OperationOrder,OperationType,QueryText' + @LineFeed 
            + '    FROM '
            + @OutputDatabaseName + '.'
            + @OutputSchemaName + '.'
            + @OutputTableName + @LineFeed
            + '    WHERE GenerationDate = /*DATEADD(mi, -15, */CONVERT(DATETIME,''' + CONVERT(NVARCHAR(100),@AsOf,121) + ''',121)'
            + '    ORDER BY OperationOrder;'
        ;
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Query : ' + @LineFeed + @StringToExecute
        END  
        EXEC(@StringToExecute);
	END /* IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL */

	ELSE -- Security command generation
	BEGIN
        DECLARE @CurOpOrder BIGINT
        DECLARE @CurOpName  VARCHAR(256)	
		BEGIN TRY
		BEGIN TRANSACTION           
            
            SET @CurOpName = 'CHECK_EXPECTED_SERVERNAME'
            
            if(@NoServerNameCheckGen = 0)
            BEGIN     
                EXEC [security].[SecurityGenHelper_AppendCheck] @CheckName = 'SERVER_NAME', @ServerName = @ServerName
            END            
            
            if @NoLoginGen = 0 
            BEGIN 
                if @Debug = 1
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Login creation statements'                
                END                 

                EXEC [security].[getLoginsCreationScript]
                        @ServerName             = @ServerName, 
                        @NoDependencyCheckGen   = 1,
                        @CanDropTempTables      = 0,
                        @Debug                  = @Debug 
            END 
            
			if(@CurDbName is null) 
			BEGIN	
           		if @Debug = 1 
				BEGIN
					PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Full server generation mode detected.'
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
					EXEC [security].[getSecurityScript] 
						@ServerName 		    = @ServerName,
						@DbName 			    = @CurDbName,
						@OutputType 		    = @OutputType,
						@OutputDatabaseName     = null,--@OutputDatabaseName,
						@OutputSchemaName 	    = null,--@OutputSchemaName,
						@OutputTableName 	    = null,--@OutputTableName,
                        @NoServerNameCheckGen   = 1,
                        @NoLoginGen             = 1,     
                        @CanDropTempTables      = 0,
                        @DisplayResult          = 0,
						@Debug 				    = @Debug
					-- carry on ...
					FETCH NEXT
					FROM getServerDatabases INTO @CurDbName
				END
				CLOSE getServerDatabases
				DEALLOCATE getServerDatabases				
            
			END
			ELSE -- a database name is given
			BEGIN
                                
				if @Debug = 1
				BEGIN
					PRINT '--------------------------------------------------------------------------------------------------------------'
					PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Server Name : ' + @ServerName				
					PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Database set to ' + @CurDbName				
                    PRINT ''
				END	 
                               
                EXEC [security].[SecurityGenHelper_AppendCheck] @CheckName = 'DATABASE_NAME', @ServerName = @ServerName, @DbName = @CurDbName
                
                if @Debug = 1
				BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Schema creation statements'
                END 
                
                EXEC [security].[getDbSchemasCreationScript] 
                    @ServerName  		    = @ServerName,    
                    @DbName  		        = @CurDbName,    
                    @SchemaName             = NULL,	
                    @AsOf 				    = NULL ,
                    @OutputType 		    = @OutputType,
                    @OutputDatabaseName     = NULL ,
                    @OutputSchemaName 	    = NULL ,
                    @OutputTableName 	    = NULL ,	
                    @NoDependencyCheckGen   = 1,
                    @CanDropTempTables      = 0,
                    @Debug		 		    = @Debug
                    
                    
                if @Debug = 1
				BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Database user creation statements'
                END 
                
                EXEC [security].[getDbUsersCreationScript] 
                    @ServerName  		    = @ServerName,    
                    @DbName  		        = @CurDbName,    
                    @UserName               = NULL,	
                    @AsOf 				    = NULL ,
                    @OutputType 		    = @OutputType,
                    @OutputDatabaseName     = NULL ,
                    @OutputSchemaName 	    = NULL ,
                    @OutputTableName 	    = NULL ,	
                    @NoDependencyCheckGen   = 1,
                    @CanDropTempTables      = 0,
                    @Debug		 		    = @Debug
                    
                if @Debug = 1
				BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Login to database user creation statements'
                END  
                EXEC [security].[getLogin2DbUserMappingsScript] 
                    @ServerName  		    = @ServerName,    
                    @DbName  		        = @CurDbName,    
                    @LoginName              = NULL,	
                    @AsOf 				    = NULL ,
                    @OutputType 		    = @OutputType,
                    @OutputDatabaseName     = NULL ,
                    @OutputSchemaName 	    = NULL ,
                    @OutputTableName 	    = NULL ,	
                    @NoDependencyCheckGen   = 1,
                    @CanDropTempTables      = 0,
                    @Debug		 		    = @Debug
  
                if @Debug = 1
				BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Database Roles creation and assignment statements'
                END   
                EXEC [security].[getDbRolesCreationScript] 
                    @ServerName  		    = @ServerName,    
                    @DbName  		        = @CurDbName,    
                    @RoleName               = NULL,	
                    @AsOf 				    = NULL ,
                    @OutputType 		    = @OutputType,
                    @OutputDatabaseName     = NULL ,
                    @OutputSchemaName 	    = NULL ,
                    @OutputTableName 	    = NULL ,	
                    @NoDependencyCheckGen   = 1,
                    @CanDropTempTables      = 0,
                    @Debug		 		    = @Debug                
                
                EXEC [security].[getDbRolesAssignmentScript] 
                    @ServerName  		    = @ServerName,    
                    @DbName  		        = @CurDbName,    
                    @RoleName               = NULL,	
                    @MemberName             = NULL,	
                    @AsOf 				    = NULL ,
                    @OutputType 		    = @OutputType,
                    @OutputDatabaseName     = NULL ,
                    @OutputSchemaName 	    = NULL ,
                    @OutputTableName 	    = NULL ,	
                    @NoDependencyCheckGen   = 1,
                    @CanDropTempTables      = 0,
                    @Debug		 		    = @Debug
                
                if @Debug = 1
				BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Object-level permission assignment statements'
                END 
                
                
                EXEC [security].[getObjectPermissionAssignmentScript] 
                    @ServerName  		    = @ServerName,    
                    @DbName  		        = @CurDbName,    
                    @Grantee                = NULL,	
                    @isUser                 = NULL,	
                    @AsOf 				    = NULL ,
                    @OutputType 		    = @OutputType,
                    @OutputDatabaseName     = NULL ,
                    @OutputSchemaName 	    = NULL ,
                    @OutputTableName 	    = NULL ,	
                    @NoDependencyCheckGen   = 1,
                    @CanDropTempTables      = 0,
                    @Debug		 		    = @Debug
                
                PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - INFO - Generation successful'
                
				if @Debug = 1 
				BEGIN
					PRINT '--------------------------------------------------------------------------------------------------------------'
				END
			END
			
            
            /*
                Now we have the table ##SecurityGenerationResults 
                with all we got from generation.
                
			    @OutputTableName lets us export the results to a permanent table 
				
                This way to process is highly inspired from Brent Ozar's 
            */
			--SELECT * from ##SecurityGenerationResults
            exec [security].[SaveSecurityGenerationResult] 
				@OutputDatabaseName     = @OutputDatabaseName,
				@OutputSchemaName 	    = @OutputSchemaName ,
				@OutputTableName 	    = @OutputTableName ,
				@VersionNumber		 	= @versionNb,
				@Debug		 		    = @Debug
            
			if @DisplayResult = 0 
			BEGIN 
				set @DisplayResult = @DisplayResult
			END 
            ELSE if @DisplayResult = 1 and @OutputType = 'TABLE'
            BEGIN 
                SELECT * 
                from ##SecurityGenerationResults
                order by [ServerName], [OperationOrder],[DbName]
            END 
            ELSE if @OutputType = 'SCRIPT' 
            BEGIN
                DECLARE Cursor4ResultScript CURSOR LOCAL FOR
					SELECT QueryText
					from ##SecurityGenerationResults
					order by [ServerName], [OperationOrder],[DbName]
                
                DECLARE @toDisplay VARCHAR(MAX) 
                open Cursor4ResultScript; 
                FETCH NEXT
				FROM Cursor4ResultScript INTO @toDisplay
                
                WHILE @@FETCH_STATUS = 0
				BEGIN						
					PRINT @toDisplay 
					-- carry on ...
                    FETCH NEXT
                    FROM Cursor4ResultScript INTO @toDisplay
				END
				CLOSE Cursor4ResultScript
				DEALLOCATE Cursor4ResultScript				
            
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
            if CURSOR_STATUS('local','Cursor4ResultScript') >= 0 
			begin
				close Cursor4ResultScript
				deallocate Cursor4ResultScript 
			end			
/*            
            if OBJECT_ID('tempdb..##SecurityGenerationResults') IS NOT NULL 
            BEGIN 
                exec sp_executesql N'DROP TABLE tempdb..##SecurityGenerationResults';             
            END 
            
            if OBJECT_ID('tempdb..##SecurityScriptResultsCommandsOrder') IS NOT NULL 
            BEGIN 
                exec sp_executesql N'DROP TABLE tempdb..##SecurityScriptResultsCommandsOrder';
            END             
*/            
            IF @@TRANCOUNT > 0
                ROLLBACK
		END CATCH
	END
END
GO

PRINT '    Procedure [security].[getSecurityScript] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 	