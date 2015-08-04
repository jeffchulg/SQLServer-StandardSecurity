/*requires Schema.Security.sql*/
/*requires Table.security.DatabasePermissions.sql*/
/*requires Function.security.getOnDbSchemaPermissionAssignmentStatement.sql*/
/*requires Function.security.getOnUserObjectPermissionAssignmentStatement.sql*/
/*requires Procedure.security.CreateTempTables4Generation.sql*/
/*requires Procedure.security.SaveSecurityGenerationResult.sql*/
/*requires Procedure.security.SecurityGenHelper_AppendCheck.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[getObjectPermissionAssignmentScript] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getObjectPermissionAssignmentScript]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [security].[getObjectPermissionAssignmentScript] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Procedure [security].[getObjectPermissionAssignmentScript] created.'
END
GO

ALTER Procedure [security].[getObjectPermissionAssignmentScript] (    
    @ServerName  		    varchar(512),    
    @DbName  		        varchar(64),    
    @Grantee                varchar(64)     = NULL,
    @isUser                 BIT             = NULL,
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
    This Procedure generates the statements for all the permission assignments that
    need to be considered according to given parameters
 
  ARGUMENTS :
    @ServerName             name of the server on which the SQL Server instance we want to modify is running.
    @DbName                 name of the database in which we have some job to do 
    @Grantee                name of the database user or role which will be granted some permissions
    @isUser                 if set to 1, the grantee is a database user 
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
 ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    
    DECLARE @versionNb          varchar(16) = '0.0.1';
    DECLARE @execTime			datetime;
    DECLARE @tsql               varchar(max);   
    DECLARE	@CurGrantee   	  	varchar(64)
    DECLARE	@CurGranteeIsUser	BIT
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
    
    SET @CurGrantee         = @Grantee
    SET @CurGranteeIsUser   = @isUser

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
            SET @CurOpName = 'CHECK_EXPECTED_SERVERNAME'
                
            if(@NoDependencyCheckGen = 0 and not exists (select 1 from ##SecurityGenerationResults where ServerName = @ServerName and OperationType = @CurOpName))
            BEGIN     
                
                if @Debug = 1
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Adding Server name check'
                END                    
                
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                insert ##SecurityGenerationResults (
                    ServerName,		
                    DbName,			
                    OperationType, 	
                    OperationOrder,
                    QueryText 		
                )
                values (
                    @ServerName,		
                    null,
                    @CurOpName,
                    @CurOpOrder,
                    'IF (@@SERVERNAME <> ''' + (@ServerName) + '''' +  @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    RAISERROR(''Expected @@ServerName : "' + @ServerName + '"'', 16, 0)'  + @LineFeed +
                    'END' 
                )
                SET @CurOpName  = null
                SET @CurOpOrder = null
            END
            
            SET @CurOpName = 'CHECK_DATABASE_EXISTS'
            if(@NoDependencyCheckGen = 0 and not exists (select 1 from ##SecurityGenerationResults where ServerName = @ServerName and DbName = @DbName and OperationType = @CurOpName))
            BEGIN     
                if @Debug = 1
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Adding database existence check'
                END                 
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                insert ##SecurityGenerationResults (
                    ServerName,		
                    DbName,			
                    OperationType, 	
                    OperationOrder,
                    QueryText 		
                )
                values (
                    @ServerName,		
                    @DbName,
                    @CurOpName,
                    @CurOpOrder,
                    'IF NOT EXISTS( SELECT 1 FROM sys.databases where Name =  ''' + (@DbName) + ''')' +  @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    RAISERROR(''The Database named : "' + @DbName + '" doesn''t exist on server !'', 16, 0)'  + @LineFeed +
                    'END' 
                )
                SET @CurOpName  = null
                SET @CurOpOrder = null                    
            END
			if(@CurGrantee is null) 
			BEGIN	
           		if @Debug = 1 
				BEGIN
					PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Every permission assignment detected.'
				END
                
                
                DECLARE getGrantees CURSOR LOCAL FOR
                    select distinct
                        [Grantee], 
                        [isUser]
                    from 
                        [security].[DatabasePermissions]        
                    where 
                        [ServerName] = @ServerName
                    and [DbName]     = @DbName

                open getGrantees
				FETCH NEXT
				FROM getGrantees INTO @CurGrantee, @CurGranteeIsUser

                WHILE @@FETCH_STATUS = 0
				BEGIN						
					EXEC [security].[getObjectPermissionAssignmentScript] 
						@ServerName 		    = @ServerName,
						@DbName 		        = @DbName,
						@Grantee  		        = @CurGrantee,
                        @isUser                 = @CurGranteeIsUser,
						@OutputType 		    = @OutputType,
						@OutputDatabaseName     = null,--@OutputDatabaseName,
						@OutputSchemaName 	    = null,--@OutputSchemaName,
						@OutputTableName 	    = null,--@OutputTableName,
                        @NoDependencyCheckGen   = 1,
                        @CanDropTempTables      = 0,
						@Debug 				    = @Debug
					-- carry on ...
					FETCH NEXT
					FROM getGrantees INTO @CurGrantee, @CurGranteeIsUser
				END
				CLOSE getGrantees
				DEALLOCATE getGrantees			
            END
            ELSE  -- a grantee name is given
            BEGIN      
                
                if @Debug = 1
                BEGIN 
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of permissions for ' + QUOTENAME(@Grantee) + ' in database ' + QUOTENAME(@DbName)
                END
                
                DECLARE @ObjectClass        VARCHAR(128)
                DECLARE @ObjectType         VARCHAR(128)
                DECLARE @PermissionLevel    VARCHAR(10)
                DECLARE @PermissionName     VARCHAR(128)
                DECLARE @SchemaName         VARCHAR(64)
                DECLARE @ObjectName         VARCHAR(128)
                DECLARE @SubObjectName      VARCHAR(128)                
                DECLARE @isWithGrantOption  BIT
                DECLARE @isActive           BIT
                
                DECLARE GetGranteePermissions CURSOR LOCAL FOR 
                    select 
                        ObjectClass,
                        ObjectType,
                        PermissionLevel,
                        PermissionName,
                        SchemaName,
                        ObjectName,
                        SubObjectName,
                        isWithGrantOption,
                        isActive
                    from 
                        [security].[DatabasePermissions]        
                    where 
                        [ServerName] = @ServerName
                    and [DbName]     = @DbName 
                    and [Grantee]    = @CurGrantee
                    and [isUser]     = @CurGranteeIsUser
    
                OPEN GetGranteePermissions
                FETCH NEXT 
                FROM GetGranteePermissions INTO @ObjectClass,@ObjectType,@PermissionLevel,@PermissionName,@SchemaName,@ObjectName,@SubObjectName,@isWithGrantOption,@isActive
                
                SET @CurOpName = 'CHECK_AND_ASSIGN_OBJECT_PERMISSION'
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName
                
                DECLARE @FullObjectName VARCHAR(512)
                
                while @@FETCH_STATUS = 0
                BEGIN 
                    if @ObjectClass = 'DATABASE' 
                    BEGIN 
                        SET @StringToExecute = 'PRINT ''. Commands for permission assignment on database schema ''''' + @ObjectName + ''''' for database principal ''''' + @CurGrantee + ''''' on database ''''' + @DbName  + '''''''' + @LineFeed +
                                               [security].[getOnDatabasePermissionAssignmentStatement](
                                                    @DbName,
                                                    @CurGrantee,
                                                    @CurGranteeIsUser,
                                                    @PermissionLevel,
                                                    @PermissionName,
                                                    @isWithGrantOption,
                                                    @isActive,                                            
                                                    1, -- no header
                                                    1, -- no dependency check 
                                                    @Debug
                                                )
                        SET @FullObjectName = @PermissionLevel + ' ' + @PermissionName + ' to ' + QUOTENAME(@CurGrantee)
                    END 
                    ELSE IF @ObjectClass = 'DATABASE_SCHEMA'
                    BEGIN 
                        SET @StringToExecute = 'PRINT ''. Commands for permission assignment on database schema ''''' + @ObjectName + ''''' for database principal ''''' + @CurGrantee + ''''' on database ''''' + @DbName  + '''''''' + @LineFeed +
                                               [security].[getOnDbSchemaPermissionAssignmentStatement](
                                                    @DbName,
                                                    @CurGrantee,
                                                    @CurGranteeIsUser,
                                                    @PermissionLevel,
                                                    @PermissionName,
                                                    @isWithGrantOption,
                                                    @ObjectName,
                                                    @isActive,                                            
                                                    1, -- no header
                                                    1, -- no dependency check 
                                                    @Debug
                                                )          
                        SET @FullObjectName = @PermissionLevel + ' ' + @PermissionName + ' on SCHEMA::' + QUOTENAME(@ObjectName) + ' to ' + QUOTENAME(@CurGrantee)
                    END 
                    ELSE IF @ObjectClass = 'SCHEMA_OBJECT'
                    BEGIN 
                        SET @StringToExecute = 'PRINT ''. Commands for permission assignment on object "' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName) + ' to ' + QUOTENAME(@CurGrantee) + '" on ' + @DbName + '"''' + @LineFeed +
                                               [security].[getOnUserObjectPermissionAssignmentStatement](
                                                    @DbName,
                                                    @CurGrantee,
                                                    @CurGranteeIsUser,
                                                    @PermissionLevel,
                                                    @PermissionName,
                                                    @isWithGrantOption,
                                                    @ObjectClass,
                                                    @ObjectType,
                                                    @SchemaName,
                                                    @ObjectName,
                                                    @SubObjectName,
                                                    @isActive,                                            
                                                    1, -- no header
                                                    1, -- no dependency check 
                                                    @Debug
                                                )                            
                                                
                        SET @FullObjectName = @PermissionLevel + ' ' + @PermissionName + ' on OBJECT::' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName)  + ' to ' + @CurGrantee
                        if @SubObjectName is not null 
                        BEGIN 
                            SET @FullObjectName = @FullObjectName + ':' + @SubObjectName
                        END 
                    END
                    ELSE IF @ObjectClass = 'DATABASE_ROLE'
                    BEGIN 
                        SET @StringToExecute = 'PRINT ''. Commands for permission assignment on role "' +  QUOTENAME(@ObjectName) + ' to ' + QUOTENAME(@CurGrantee) + '" on ' + @DbName + '"''' + @LineFeed +                    
                                                [security].[getOnDbRolePermissionAssignmentStatement](
                                                    @DbName,
                                                    @CurGrantee,
                                                    @CurGranteeIsUser,
                                                    @PermissionLevel,
                                                    @PermissionName,
                                                    @isWithGrantOption,
                                                    @ObjectName,
                                                    @isActive,                                            
                                                    1, -- no header
                                                    1, -- no dependency check 
                                                    @Debug
                                                )                            
                                                
                        SET @FullObjectName = @PermissionLevel + ' ' + @PermissionName + ' on ROLE::' + QUOTENAME(@ObjectName)  + ' to ' + @CurGrantee
                        if @SubObjectName is not null 
                        BEGIN 
                            SET @FullObjectName = @FullObjectName + ':' + @SubObjectName
                        END 
                    END
                    ELSE 
                        RAISERROR('Unsupported %s object class for object permission assignment generation' , 16,0,@ObjectClass)

                    
                    EXEC [security].[SecurityGenHelper_AppendCheck] 
                        @CheckName   = 'STATEMENT_APPEND', 
                        @ServerName  = @ServerName, 
                        @DbName      = @DbName,
                        @ObjectName  = @FullObjectName,
                        @CurOpName   = @CurOpName,
                        @CurOpOrder  = @CurOpOrder,
                        @Statements  = @StringToExecute                        
                    
                    -- carry on ...
                    FETCH NEXT 
                    FROM GetGranteePermissions INTO @ObjectClass,@ObjectType,@PermissionLevel,@PermissionName,@SchemaName,@ObjectName,@SubObjectName,@isWithGrantOption,@isActive
                
                END 
                
                CLOSE GetGranteePermissions
                DEALLOCATE GetGranteePermissions
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
			
			if CURSOR_STATUS('local','getGrantees') >= 0 
			begin
				close getGrantees
				deallocate getGrantees 
			end
			
			if CURSOR_STATUS('local','GetGranteePermissions') >= 0 
			begin
				close GetGranteePermissions
				deallocate GetGranteePermissions 
			end

            IF @@TRANCOUNT > 0
                ROLLBACK
		END CATCH
	END
END
GO            


PRINT '    Procedure [security].[getObjectPermissionAssignmentScript] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 