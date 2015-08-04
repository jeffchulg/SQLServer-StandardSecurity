/*requires Schema.Security.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[SecurityGenHelper_AppendCheck] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[SecurityGenHelper_AppendCheck]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [security].[SecurityGenHelper_AppendCheck] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Procedure [security].[SecurityGenHelper_AppendCheck] created.'
END
GO

ALTER Procedure [security].[SecurityGenHelper_AppendCheck] (
    @CheckName              VARCHAR(256) ,
    @ServerName             VARCHAR(256) = NULL,
    @DbName                 VARCHAR(64)  = NULL,    
    @ObjectName             VARCHAR(256) = NULL,
    @Statements             VARCHAR(MAX) = NULL,
    @CurOpName              VARCHAR(256) = NULL,
    @CurOpOrder             BIGINT       = NULL,
    @Debug                  BIT = 0    
)    
AS 
/*
DESCRIPTION:
    Generates the code necessary for a given check like ServerName check or 
    database name check.
    It can also be used to append any statement with the CheckName set to "STATEMENT_APPEND"
 
  ARGUMENTS :
    @CheckName      name of the check we want to generate
                    Values :
                        * SERVER_NAME       :   generates and appends the statements to check Servername 
                        * DATABASE_NAME     :   generates  and appends the statements to check the given database exists
                        * STATEMENT_APPEND  :   appends the given statements 
    @ServerName     Name of the server on which there is something to do
    @DbName         Name of the database in or for which there is something to do
    @ObjectName     Name of the object which has to be taken into account (for SERVER_NAME and DATABASE_NAME, it's set to NULL)
    @Statements     Used for STATEMENT_APPEND mode. In that case, it cannot be null 
    @CurOpName      Used for STATEMENT_APPEND mode. It stores the operation mode (@see Procedure.CreateTempTables4Generation.sql). 
                    In that case, it cannot be null     
    @CurOpOrder     Used for STATEMENT_APPEND mode. It stores the operation order(@see Procedure.CreateTempTables4Generation.sql). 
                    In that case, it cannot be null 
    @Debug          If set to 1, then we are in debug mode

  REQUIREMENTS:
 
    EXAMPLE USAGE :
        PRINT [security].getLogin2DbUserMappingStatement ('test_jel','TESTING_ONLY_TESTING','test_jel','dbo',1,1,0,0,1)
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
    24/12/2014  JEL         Version 0.1.0
    ----------------------------------------------------------------------------------
 ===================================================================================
*/
BEGIN
     --SET NOCOUNT ON;
    DECLARE @versionNb        varchar(16) = '0.1.0';
    DECLARE @tsql             varchar(max);       
    DECLARE @LineFeed 		  VARCHAR(10);
    DECLARE @StringToExecute  VARCHAR(MAX);
     /* Sanitize our inputs */
	SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10)
        
    IF OBJECT_ID('tempdb..##SecurityGenerationResults') is null or OBJECT_ID('tempdb..##SecurityGenerationResults') is null
    BEGIN 
        RAISERROR('No generation is running !',16,0)
    END 
    
    if @ServerName is null 
    BEGIN 
        RAISERROR('No ServerName Given !',16,0)
    END     
    
    if @CheckName = 'SERVER_NAME' 
    BEGIN         
        SET @CurOpName      = 'CHECK_EXPECTED_SERVERNAME'
        SET @DbName         = NULL 
        SET @ObjectName     = NULL 
        SET @Statements     = NULL 
        
        if not exists (select 1 from ##SecurityGenerationResults where ServerName = @ServerName and OperationType = @CurOpName)
        BEGIN     
            if @Debug = 1
            BEGIN
                PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Adding Server name check'
            END                    
            
            select @CurOpOrder = OperationOrder 
            from ##SecurityScriptResultsCommandsOrder 
            where OperationType = @CurOpName

            SET @StringToExecute =  'IF (@@SERVERNAME <> ''' + (@ServerName) + ''')' +  @LineFeed +
                                    'BEGIN' + @LineFeed +
                                    '    RAISERROR(''Expected @@ServerName : "' + @ServerName + '"'', 16, 0)'  + @LineFeed +
                                    'END' 
            SET @DbName = NULL 
        END  
    END 
    
    ELSE IF @CheckName = 'DATABASE_NAME' 
    BEGIN
        SET @CurOpName      = 'CHECK_DATABASE_EXISTS'
        SET @ObjectName     = NULL 
        SET @Statements     = NULL 
        
        if @DbName is null
        BEGIN 
            RAISERROR('DbName is null !' , 16,0)
        END 
        
        if(not exists (select 1 from ##SecurityGenerationResults where ServerName = @ServerName and DbName = @DbName and OperationType = @CurOpName))
        BEGIN   
            if @Debug = 1
            BEGIN
                PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Adding database existence check'
            END  
            
            select @CurOpOrder = OperationOrder 
            from ##SecurityScriptResultsCommandsOrder 
            where OperationType = @CurOpName

            SET @StringToExecute =  'IF NOT EXISTS( SELECT 1 FROM sys.databases where Name =  ''' + (@DbName) + ''')' +  @LineFeed +
                                    'BEGIN' + @LineFeed +
                                    '    RAISERROR(''The Database named : "' + @DbName + '" doesn''''t exist on server !'', 16, 0)'  + @LineFeed +
                                    'END' 
        END                
    END 
    
    ELSE IF @CheckName = 'STATEMENT_APPEND'
    BEGIN 
    /*
        if @DbName is null
        BEGIN 
            RAISERROR('DbName is null !' , 16,0)
        END 
    */
        if @Statements is null
        BEGIN 
            RAISERROR('Statements is null !' , 16,0)
        END         
        if @CurOpName is null
        BEGIN 
            RAISERROR('CurOpName is null !' , 16,0)
        END        
        if @CurOpOrder is null
        BEGIN 
            RAISERROR('CurOpOrder is null !' , 16,0)
        END 
        
        SET @StringToExecute = @Statements
    END     
    
    ELSE IF @CheckName is null
    BEGIN 
		RAISERROR('Check Name is null !',16,0)
    END 
    ELSE 
    BEGIN 
        RAISERROR('Unsupported check name "%s" !',16,0, @CheckName)
    END     
    
    insert ##SecurityGenerationResults (
        ServerName,		
        DbName,		
        ObjectName,
        OperationType, 	
        OperationOrder,
        QueryText 		
    )
    values (
        @ServerName,		
        @DbName,
        @ObjectName,
        @CurOpName,
        @CurOpOrder,
        @StringToExecute
    )
    
    
END
GO

IF @@ERROR = 0 
BEGIN 
    PRINT '    Function [security].[getLogin2DbUserMappingStatement] altered.'
END 
ELSE 
BEGIN 
    PRINT '   Error while trying to create Function [security].[getLogin2DbUserMappingStatement]'
	RETURN
END 
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 