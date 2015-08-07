/*requires Schema.Security.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[CreateTempTables4Generation] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[CreateTempTables4Generation]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[CreateTempTables4Generation] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[CreateTempTables4Generation] created.'
END
GO

ALTER PROCEDURE [security].[CreateTempTables4Generation] (
    @CanDropTempTables      BIT     = 1,
	@Debug		 		    BIT		= 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
		This procedure creates temporary tables 
            ##SecurityGenerationResults 
            ##SecurityScriptResultsCommandsOrder
        
		mandatory for the standard security script generation.
  
   ARGUMENTS :
        @CanDropTempTables      If set to 1, this procedure can drop temp tables when they exists
        @Debug                  If set to 1, then we are in debug mode

  
   REQUIREMENTS:
  
	EXAMPLE USAGE :
		
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

	DECLARE @LineFeed 			VARCHAR(10)
    if @CanDropTempTables = 1 and OBJECT_ID('tempdb..##SecurityGenerationResults') IS NOT NULL 
    BEGIN 
        DROP TABLE ##SecurityGenerationResults;
    
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + '-- DEBUG - Table ##SecurityGenerationResults dropped'
        END                 
    END 
    
    if @CanDropTempTables = 1 and OBJECT_ID('tempdb..##SecurityScriptResultsCommandsOrder') IS NOT NULL 
    BEGIN 
        DROP TABLE ##SecurityScriptResultsCommandsOrder;
    
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + '-- DEBUG - Table ##SecurityScriptResultsCommandsOrder dropped'
        END                 
    END 

    IF OBJECT_ID('tempdb..##SecurityGenerationResults') is null 
    BEGIN 
        CREATE TABLE ##SecurityGenerationResults (
            ID 				INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
            ServerName		VARCHAR(256) NOT NULL,
            DbName			VARCHAR(64)  NULL,
            ObjectName      VARCHAR(512)  NULL, 
            OperationType 	VARCHAR(64) NOT NULL,
            OperationOrder	BIGINT,
            QueryText 		VARCHAR(MAX) NOT NULL
        )
        
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + '-- DEBUG - Table ##SecurityGenerationResults created'
        END             
    END
    
    if OBJECT_ID('tempdb..##SecurityScriptResultsCommandsOrder') IS NULL 
    BEGIN 
        CREATE TABLE ##SecurityScriptResultsCommandsOrder (
            OperationType	VARCHAR(256) NOT NULL,
            OperationOrder	BIGINT
        )
        
        insert ##SecurityScriptResultsCommandsOrder
            select 'CHECK_EXPECTED_SERVERNAME', 1
            union all
            select 'CHECK_DATABASE_EXISTS', 10
            union all
            select 'CHECK_AND_CREATE_SQL_LOGINS', 50
            union all
            select 'CHECK_AND_CREATE_DB_SCHEMA', 60
            union all
            select 'CHECK_AND_CREATE_DB_USER', 70
            union all
            select 'CHECK_AND_DO_LOGIN_2_DBUSER_MAPPING', 80
            union all
            select 'CHECK_AND_CREATE_DB_ROLE', 90
            union all
            select 'CHECK_AND_ASSIGN_DBROLE_MEMBERSHIP', 100
            union all
            select 'CHECK_AND_ASSIGN_OBJECT_PERMISSION', 101
            
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + '-- DEBUG - Table ##SecurityScriptResultsCommandsOrder created'
        END                        
    END    
END
GO

PRINT '    Procedure [security].[CreateTempTables4Generation] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 	