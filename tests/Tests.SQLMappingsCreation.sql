/*requires main.sql*/
/*requires Tests.ContactCreation.sql*/
/*requires Tests.LoginCreation.sql*/

PRINT '    > Now testing SQL Mappings definition for server'


SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[SQLMappings] table (DbUserName = SQLLogin)';
SET @TestDescription = 'inserts a record into the [security].[SQLMappings] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[SQLMappings]'  + @LineFeed +
            '    (ServerName,SqlLogin,DbName,DbUserName,DefaultSchema,isDefaultDb)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +
            '    ''ApplicationSQLUser1'',' + @LineFeed +
            '    ''ApplicationSQLUser1'',' + @LineFeed +
            '    ''ApplicationSchema1'',' + @LineFeed +
            '    1' + @LineFeed +
            ')' ;

BEGIN TRANSACTION             
BEGIN TRY
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;    
END TRY 
BEGIN CATCH
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = ERROR_MESSAGE() ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
END CATCH 
COMMIT TRANSACTION;

INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[SQLMappings] table (DbUserName <> SQLLogin)';
SET @TestDescription = 'inserts a record into the [security].[SQLMappings] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[SQLMappings]'  + @LineFeed +
            '    (ServerName,SqlLogin,DbName,DbUserName,DefaultSchema,isDefaultDb)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +
            '    ''ApplicationSQLUser2'',' + @LineFeed +
            '    ''DbUser2'',' + @LineFeed +
            '    ''ApplicationSchema2'',' + @LineFeed +
            '    1' + @LineFeed +
            ')' ;

BEGIN TRANSACTION             
BEGIN TRY
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;    
END TRY 
BEGIN CATCH
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = ERROR_MESSAGE() ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
END CATCH 
COMMIT TRANSACTION;

INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @ProcedureName = 'setDatabaseAccess';
SET @TestName = 'Creation through ' + @ProcedureName + ' procedure';
SET @TestDescription = 'checks that ' + @ProcedureName + ' procedure exists and call it';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

IF( NOT EXISTS (
        select 1
        from sys.all_objects 
        where 
            SCHEMA_NAME(Schema_ID) COLLATE French_CI_AI = 'security' COLLATE French_CI_AI 
        and name COLLATE French_CI_AI = @ProcedureName COLLATE French_CI_AI 
    )
)
BEGIN 
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'No procedure with name [security].[' + @ProcedureName + '] exists in ' + DB_NAME() ;
END 
ELSE 
BEGIN 
    SET @CreationWasOK = 0 ;   
    
    BEGIN TRANSACTION             
    BEGIN TRY
        PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
        
        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = ''master'', @ContactLogin = ''${DomainName}\${DomainUser1}'' , @DefaultSchema=''dbo'',@isDefaultDb = 1 ;' ;
        execute sp_executesql @tsql ;
        
        SET @CreationWasOK = 1 ;
        
        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = ''master'', @ContactLogin = ''${DomainName}\${DomainUser2}'' , @DefaultSchema=''dbo'',@isDefaultDb = 1 ;' ;
        execute sp_executesql @tsql ;
        
        -- call it twice to check the edition mode is OK
        SET @tsql = 'execute [security].[setServerAccess] @ServerName = @@SERVERNAME , @ContactLogin = ''${DomainName}\${DomainUser1}'' , @isActive = 0;' ;
        execute sp_executesql @tsql ;
    END TRY 
    BEGIN CATCH
        SET @ErrorCount = @ErrorCount + 1;
        SET @TestResult = 'FAILURE';
        SET @ErrorMessage = ERROR_MESSAGE() ;
        PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ') + ' | @CreationWasOK = ' + CONVERT(VARCHAR,@CreationWasOK);
    END CATCH 
    COMMIT TRANSACTION;
END 

INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );

-- ---------------------------------------------------------------------------------------------------------
