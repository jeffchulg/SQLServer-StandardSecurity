/*requires Schema.Security.sql*/
/*requires Table.security.DatabaseRoles.sql*/
/*requires View.security.Logins.sql*/
/*requires Function.security.getDbRoleCreationStatement.sql*/
/*requires Procedure.security.CreateTempTables4Generation.sql*/
/*requires Procedure.security.SaveSecurityGenerationResult.sql*/
/*requires Procedure.security.SecurityGenHelper_AppendCheck.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[getDbRolesCreationScript] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getDbRolesCreationScript]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [security].[getDbRolesCreationScript] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Procedure [security].[getDbRolesCreationScript] created.'
END
GO

ALTER Procedure [security].[getDbRolesCreationScript] (    
    @ServerName  		    varchar(512),    
    @DbName  		        varchar(128),    
    @RoleName               varchar(64)     = NULL,	
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
    This Procedure generates the statements for all the database roles according to 
    given parameters
 
  ARGUMENTS :
    @ServerName             name of the server on which the SQL Server instance we want to modify is running.
    @DbName                 name of the database in which we have some job to do 
    @RoleName               name of the role we need to take care of
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
    DECLARE	@CurRole   	  	    varchar(64)
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
    
    SET @CurRole = @RoleName

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

            if(@CurRole is null) 
			BEGIN	
           		if @Debug = 1 
				BEGIN
					PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Every Role generation detected.'
				END
                
                DECLARE getRoles CURSOR LOCAL FOR
                    select
                        [RoleName]
                    from 
                        [security].[DatabaseRoles]        
                    where 
                        [ServerName] = @ServerName
                    and [DbName]     = @DbName
                
                open getRoles
				FETCH NEXT
				FROM getRoles INTO @CurRole

                WHILE @@FETCH_STATUS = 0
				BEGIN						
					EXEC [security].[getDbRolesCreationScript] 
						@ServerName 		    = @ServerName,
						@DbName 		        = @DbName,
						@RoleName  		        = @CurRole,
						@OutputType 		    = @OutputType,
						@OutputDatabaseName     = null,--@OutputDatabaseName,
						@OutputSchemaName 	    = null,--@OutputSchemaName,
						@OutputTableName 	    = null,--@OutputTableName,
                        @NoDependencyCheckGen   = 1,
                        @CanDropTempTables      = 0,
						@Debug 				    = @Debug
					-- carry on ...
					FETCH NEXT
					FROM getRoles INTO @CurRole
				END
				CLOSE getRoles
				DEALLOCATE getRoles			
            END
            ELSE  -- a role name is given
            BEGIN                        
                DECLARE @isStandard BIT
                DECLARE @isActive   BIT
                
                select 
                    @isActive   = isActive,
                    @isStandard = isStandard
                from 
                    [security].[DatabaseRoles]        
                where 
                    [ServerName] = @ServerName
                and [DbName]     = @DbName 
                and [RoleName]   = @CurRole
    
                if @isActive is null 
                BEGIN
					DECLARE @ErrMsg VARCHAR(512) = 'The provided role ' + QUOTENAME(@CurRole) + ' does not exist.'
                    RAISERROR(@ErrMsg,16,0)
                END 
                                
                
                SET @StringToExecute = 'PRINT ''. Commands for role "' + @CurRole + '" in database "' + @DbName + '"''' + @LineFeed +
                                       [security].[getDbRoleCreationStatement](
                                            @DbName,
                                            @CurRole,
                                            @isStandard,
                                            @isActive,                                            
                                            1, -- no header
                                            1, -- no db check 
                                            @Debug
                                        ) 
                SET @CurOpName = 'CHECK_AND_CREATE_DB_ROLE'
                
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName
                
                EXEC [security].[SecurityGenHelper_AppendCheck] 
                    @CheckName   = 'STATEMENT_APPEND', 
                    @ServerName  = @ServerName, 
                    @DbName      = @DbName,
                    @ObjectName  = @CurRole,
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
			
			if CURSOR_STATUS('local','getRoles') >= 0 
			begin
				close getRoles
				deallocate getRoles 
			end

            IF @@TRANCOUNT > 0
                ROLLBACK
		END CATCH
	END
END
GO            


PRINT '    Procedure [security].[getDbRolesCreationScript] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 