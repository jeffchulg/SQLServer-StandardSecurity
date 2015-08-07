/*requires Schema.Security.sql*/
/*requires Table.security.SQLMappings.sql*/
/*requires Procedure.security.CreateTempTables4Generation.sql*/
/*requires Procedure.security.SaveSecurityGenerationResult.sql*/
/*requires Function.security.getLogin2DbUserMappingStatement.sql*/
/*requires Procedure.security.SecurityGenHelper_AppendCheck.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[getLogin2DbUserMappingsScript] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getLogin2DbUserMappingsScript]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [security].[getLogin2DbUserMappingsScript] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Procedure [security].[getLogin2DbUserMappingsScript] created.'
END
GO

ALTER Procedure [security].[getLogin2DbUserMappingsScript] (    
    @ServerName  		    varchar(512),    
    @LoginName  		    varchar(512)    = NULL,    
    @DbName  		        varchar(128)     = NULL ,    
	@AsOf 				    DATETIME 		= NULL ,
	@OutputType 		    VARCHAR(20) 	= 'TABLE' ,
    @OutputDatabaseName     NVARCHAR(128) 	= NULL ,
    @OutputSchemaName 	    NVARCHAR(256) 	= NULL ,
    @OutputTableName 	    NVARCHAR(256) 	= NULL ,	
    @NoDependencyCheckGen   BIT             = 0,   
    @CanDropTempTables      BIT             = 1,
	@Debug		 		    BIT		  	 	= 0    
)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This Procedure generates the statements for all the mappings between a login 
    and a database user on a given server 
 
  ARGUMENTS :
    @ServerName             name of the server on which the SQL Server instance we want to modify is running.
    @LoginName              name of the login we need to take care of
    @DbName                 name of the database in which we need to map this login
    @AsOf                   to see a previous generated script result
    @OutputType             the output type you want : TABLE or SCRIPT at the moment
    @OutputDatabaseName     name of the database where we'll keep track of the generated script 
    @OutputSchemaName       name of the database schema in which we'll keep track of the generated script 
    @OutputTableName        name of the table in which we'll actually keep track of the generated script 
    @NoDependencyCheckGen   if set to 1, no check for server name and database name are generated
    @CanDropTempTables      if set to 1, the temporary tables required for this procedure to succeed can be dropped by the tool.
                            It will create them if they don't exist
    @Debug                  If set to 1, then we are in debug mode
 
  REQUIREMENTS:
 
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
  Historique des revisions
 
    Date        Name	        	Description
    ==========  =================	===========================================================
    24/12/2014  Jefferson Elias		Creation
    ----------------------------------------------------------------------------------
    07/08/2015  Jefferson Elias     Removed version number
    ----------------------------------------------------------------------------------	
 ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    
    DECLARE @execTime			datetime;
    DECLARE @tsql               varchar(max);   
    DECLARE	@CurLogin 	  	    varchar(64)
    DECLARE	@CurDbName	  	    varchar(64)
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
    
    SET @CurLogin    = @LoginName
    SET @CurDbName   = @DbName

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
        DECLARE @CurOpName VARCHAR(512)
        DECLARE @CurOpOrder BIGINT
        
		BEGIN TRY
		BEGIN TRANSACTION           
                
            if(@NoDependencyCheckGen = 0)
            BEGIN     
                EXEC [security].[SecurityGenHelper_AppendCheck] @CheckName = 'SERVER_NAME', @ServerName = @ServerName
            END     
            
            if(@NoDependencyCheckGen = 0)
            BEGIN     
                EXEC [security].[SecurityGenHelper_AppendCheck] @CheckName = 'DATABASE_NAME', @ServerName = @ServerName, @DbName = @DbName
            END     
            
            if(@CurLogin is null or @CurDbName is null) 
			BEGIN
                if @CurDbName is null and @CurLogin is null 
                BEGIN 
                    if @Debug = 1 
                    BEGIN
                        PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Every mappings for server detected'
                    END                 
                    DECLARE getMappings CURSOR LOCAL FOR 
                        select 
                            SqlLogin, DbName 
                        from 
                            security.sqlmappings 
                        where 
                            QUOTENAME(ServerName) = QUOTENAME(@ServerName)
                END
                ELSE IF @CurDbName is not null and @CurLogin is null         
                BEGIN 
                    if @Debug = 1 
                    BEGIN
                        PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - All mappings for database ' + @DbName + ' detected'
                    END                
                    DECLARE getMappings CURSOR LOCAL FOR 
                        select 
                            SqlLogin, DbName 
                        from 
                            security.sqlmappings 
                        where 
                            QUOTENAME(ServerName) = QUOTENAME(@ServerName)
                        and QUOTENAME(DbName)     = QUOTENAME(@CurDbName)
                END 
                else if @CurDbName is null and @CurLogin is not null 
                BEGIN 
                    if @Debug = 1 
                    BEGIN
                        PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - All mappings for login ' + @CurLogin + ' detected'
                    END
                    DECLARE getMappings CURSOR LOCAL FOR 
                        select 
                            SqlLogin, DbName 
                        from 
                            security.sqlmappings 
                        where 
                            QUOTENAME(ServerName) = QUOTENAME(@ServerName)
                        and QUOTENAME(SQLLogin)     = QUOTENAME(@CurLogin)
                END 

                open getMappings
				FETCH NEXT
				FROM getMappings INTO @CurLogin, @CurDbName

                WHILE @@FETCH_STATUS = 0
				BEGIN						
					EXEC [security].[getLogin2DbUserMappingsScript] 
						@ServerName 		    = @ServerName,
						@DbName 		        = @DbName,
						@LoginName 		        = @CurLogin,
						@OutputType 		    = @OutputType,
						@OutputDatabaseName     = null,--@OutputDatabaseName,
						@OutputSchemaName 	    = null,--@OutputSchemaName,
						@OutputTableName 	    = null,--@OutputTableName,
                        @NoDependencyCheckGen   = 1,
                        @CanDropTempTables      = 0,
						@Debug 				    = @Debug
					-- carry on ...
					FETCH NEXT
					FROM getMappings INTO @CurLogin, @CurDbName
				END
				CLOSE getMappings
				DEALLOCATE getMappings			
            END
            ELSE  -- a dbname and login are given
            BEGIN                        
                DECLARE @DbUserName     VARCHAR(64)
                DECLARE @DefaultSchema  VARCHAR(64)                
                DECLARE @isDefaultDb    BIT
                
                select 
                    @DbUserName     = DbUserName,
                    @DefaultSchema  = DefaultSchema,
                    @isDefaultDb    = isDefaultDb
                from 
                    [security].[SQLMappings]        
                where 
                    [ServerName] = @ServerName
                and [DbName]     = @DbName 
                and [SQLLogin]   = @CurLogin                
    
                if @isDefaultDb is null 
                BEGIN
					DECLARE @ErrMsg VARCHAR(512) = 'The provided role assignement ' + QUOTENAME(@CurDbName) + ' > ' + QUOTENAME(@CurLogin) + ' does not exist.'
                    RAISERROR(@ErrMsg,16,0)
                END 
                                
                SET @StringToExecute = 'PRINT ''. Commands to map login "' + QUOTENAME(@CurLogin) + ' to user ' + QUOTENAME(@DbUserName) + '" on ' + @DbName + '"''' + @LineFeed +
                                       [security].[getLogin2DbUserMappingStatement](
                                            @CurLogin,
                                            @CurDbName,
                                            @DbUserName,
                                            @DefaultSchema,
                                            1, -- no header
                                            1, -- no dependency check 
                                            0,
                                            0, -- TODO remove it once the grant connect to database is in DatabasePermission
                                            @Debug
                                        ) 
                SET @CurOpName = 'CHECK_AND_DO_LOGIN_2_DBUSER_MAPPING'
                
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                DECLARE @FullObjectName VARCHAR(MAX) = QUOTENAME(@CurLogin) + ' to ' + QUOTENAME(@DbUserName) + ' on ' + QUOTENAME(@CurDbName)
                
                EXEC [security].[SecurityGenHelper_AppendCheck] 
                    @CheckName   = 'STATEMENT_APPEND', 
                    @ServerName  = @ServerName, 
                    @DbName      = @DbName,
                    @ObjectName  = @FullObjectName,
                    @CurOpName   = @CurOpName,
                    @CurOpOrder  = @CurOpOrder,
                    @Statements  = @StringToExecute
                                                           
                SET @CurOpName  = null
                SET @CurOpOrder = null
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
				@Debug		 		    = @Debug
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
			
			if CURSOR_STATUS('local','getMappings') >= 0 
			begin
				close getMappings
				deallocate getMappings 
			end

            IF @@TRANCOUNT > 0
                ROLLBACK
		END CATCH
	END
END
GO            


PRINT '    Procedure [security].[getLogin2DbUserMappingsScript] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 