/*requires Schema.Security.sql*/



PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[SaveSecurityGenerationResult] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[SaveSecurityGenerationResult]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[SaveSecurityGenerationResult] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[SaveSecurityGenerationResult] created.'
END
GO

ALTER PROCEDURE [security].[SaveSecurityGenerationResult] (
    @OutputDatabaseName     NVARCHAR(128),
    @OutputSchemaName 	    NVARCHAR(256) ,
    @OutputTableName 	    NVARCHAR(256) ,
	@VersionNumber			VARCHAR(128),
	@Debug		 		    BIT		= 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
		This procedure saves the content of ##SecurityGenerationResults table
		to the table provided in parameters.
		If this table doesn't exist, it will create it.
		If this table exists, it will check that it is suitable for insertion and then
		perform the inserts.
  
   ARGUMENTS :

  
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
     19/12/2014  JEL         Version 0.0.1
     ----------------------------------------------------------------------------------
  ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    DECLARE @versionNb        	varchar(16) = '0.0.1';
    DECLARE @tsql             	varchar(max);

	DECLARE @LineFeed 			VARCHAR(10)
    DECLARE @StringToExecute    VARCHAR(MAX)
    
	/* Sanitize our inputs */
	SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10)	
	
	if @VersionNumber is null 
	BEGIN
		-- we'll get the global version number 
		select 
			@VersionNumber = ParamValue
		from [security].[ApplicationParams]
		where ParamName = 'Version'
		
		if @Debug = 1
		BEGIN 
			PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Generator version number set to ' + @VersionNumber
		END 
	END
	
	BEGIN TRY 

		IF OBJECT_ID('tempdb..##SecurityGenerationResults') is not null 
		    AND @OutputDatabaseName IS NOT NULL
			AND @OutputSchemaName IS NOT NULL
			AND @OutputTableName IS NOT NULL
			AND EXISTS ( SELECT *
						 FROM   sys.databases
						 WHERE  QUOTENAME([name]) = @OutputDatabaseName) 
		BEGIN
			if @Debug = 1 
			BEGIN
				PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Creating table (if not exists) where we must save results'
			END            
			SET @StringToExecute = 'USE '
				+ @OutputDatabaseName
				+ '; IF EXISTS(SELECT * FROM '
				+ @OutputDatabaseName
				+ '.INFORMATION_SCHEMA.SCHEMATA WHERE QUOTENAME(SCHEMA_NAME) = QUOTENAME('''
				+ @OutputSchemaName
				+ ''')) AND NOT EXISTS (SELECT * FROM '
				+ @OutputDatabaseName
				+ '.INFORMATION_SCHEMA.TABLES WHERE QUOTENAME(TABLE_SCHEMA) = QUOTENAME('''
				+ @OutputSchemaName + ''') AND QUOTENAME(TABLE_NAME) = QUOTENAME('''
				+ @OutputTableName + ''')) CREATE TABLE '
				+ @OutputSchemaName + '.'
				+ @OutputTableName
				+ ' (
				GenerationDate 	    DATETIME NOT NULL, 				
				ServerName 			VARCHAR(256) NOT NULL,
				DbName     			VARCHAR(64)  NULL,
				ObjectName          VARCHAR(512)  NULL,
				GeneratorVersion 	VARCHAR(16) NOT NULL,
				OperationOrder		BIGINT  NOT NULL,
				OperationType		VARCHAR(64) not null,
				QueryText			VARCHAR(MAX) NOT NULL,
				cc_ServerDb			AS [ServerName] + ISNULL('':'' + [DbName],'''') + ISNULL(''-'' + [ObjectName] + ''-'',''''), -- need for null values of DbName...
				CONSTRAINT [PK_' + CAST(NEWID() AS CHAR(36)) + '] PRIMARY KEY CLUSTERED (GenerationDate ASC, cc_ServerDb ASC ,OperationOrder ASC));'               
			
			EXEC(@StringToExecute);
							
			if @Debug = 1 
			BEGIN
				PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Filling in with results '                    
			END                                 
			
			SET @StringToExecute = N'IF EXISTS(SELECT * FROM '
				+ @OutputDatabaseName
				+ '.INFORMATION_SCHEMA.SCHEMATA WHERE (SCHEMA_NAME) = '''
				+ @OutputSchemaName + ''') ' + @LineFeed 
				+ '    INSERT '
				+ @OutputDatabaseName + '.'
				+ @OutputSchemaName + '.'
				+ @OutputTableName
				+ ' (' + @LineFeed 
				+ '        GenerationDate, ServerName, DbName, ObjectName,GeneratorVersion, OperationOrder, OperationType, QueryText' + @LineFeed 
				+ ')' + @LineFeed 
				+ '    SELECT ' + + @LineFeed 
				+ '        CAST (''' + CONVERT(VARCHAR,GETDATE(),121) + ''' AS DATETIME)' + @LineFeed 
				+ '        ,ServerName' + @LineFeed 
				+ '        ,DbName' + @LineFeed 
				+ '        ,ObjectName' + @LineFeed 
				+ '        ,''' + @VersionNumber+''''  + @LineFeed 
				+ '        ,OperationOrder' + @LineFeed 
				+ '        ,OperationType' + @LineFeed 
				+ '        ,QueryText' + @LineFeed 
				+ '    FROM ##SecurityGenerationResults ' + @LineFeed
				+ '    ORDER BY ServerName, OperationOrder,DbName';
			EXEC(@StringToExecute);
		END
/* TODO
		ELSE IF (SUBSTRING(@OutputTableName, 2, 2) = '##')
		BEGIN
			SET @StringToExecute = N' IF (OBJECT_ID(''tempdb..'
				+ @OutputTableName
				+ ''') IS NOT NULL) DROP TABLE ' + @OutputTableName + ';'
				+ 'CREATE TABLE '
				+ @OutputTableName
		END
*/	
		ELSE IF (SUBSTRING(@OutputTableName, 2, 1) = '#')
		BEGIN
			RAISERROR('Due to the nature of Dymamic SQL, only global (i.e. double pound (##)) temp tables are supported for @OutputTableName', 16, 0)
		END
	
	END TRY
	
	BEGIN CATCH
		declare @ErrorMessage nvarchar(max), @ErrorSeverity int, @ErrorState int;
		select @ErrorMessage = ERROR_MESSAGE() + ' Line ' + cast(ERROR_LINE() as nvarchar(5)), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
	    raiserror (@ErrorMessage, @ErrorSeverity, @ErrorState);
		
	END CATCH
END
GO

PRINT '    Procedure [security].[SaveSecurityGenerationResult] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 	