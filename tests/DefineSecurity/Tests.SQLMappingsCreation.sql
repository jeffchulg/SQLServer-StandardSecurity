/*requires Table.TestResults.sql*/
/*requires Table.TestContacts.sql*/
/*requires Tests.Start.sql*/
/*requires Tests.ContactCreation.sql*/
/*requires Tests.LoginCreation.sql*/

PRINT ''
PRINT 'Now testing SQL Mappings definition for server'
PRINT ''


SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[SQLMappings] table (DbUserName = SQLLogin)';
SET @TestDescription = 'inserts a record into the [security].[SQLMappings] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[SQLMappings]'  + @LineFeed +
            '    (ServerName,SqlLogin,DbName,DbUserName,DefaultSchema,isDefaultDb)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    ''$(LocalSQLLogin1)'',' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +            
            '    ''$(LocalSQLLogin1)'',' + @LineFeed +
            '    ''$(CurrentDB_Schema1)'',' + @LineFeed +
            '    1' + @LineFeed +
            ')' ;


BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;
    
    SET @tsql = 'update $(TestingSchema).testContacts set DbUserName = @DbUserName where SQLLogin = @SQLLogin'
    execute sp_executesql @tsql , N'@DbUserName VARCHAR(512),@ServerName VARCHAR(512) , @SQLLogin VARCHAR(256)' , @DbUserName = '$(LocalSQLLogin1)', @ServerName = @@SERVERNAME, @SQLLogin = '$(LocalSQLLogin1)';    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'Line ' + CONVERT(VARCHAR,ERROR_LINE()) + ' => ' + ERROR_MESSAGE()  ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK ;
    END
END CATCH

BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

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
            '    ''$(LocalSQLLogin2)'',' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +            
            '    ''$(DbUserForSQLLogin2)'',' + @LineFeed +
            '    ''$(CurrentDB_Schema2)'',' + @LineFeed +
            '    1' + @LineFeed +
            '),(' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    ''$(LocalSQLLogin4)'',' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +            
            '    ''$(DbUserForSQLLogin4)'',' + @LineFeed +
            '    ''$(CurrentDB_Schema2)'',' + @LineFeed +
            '    1' + @LineFeed +
            ')' ;


BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;
    
    SET @tsql = 'update $(TestingSchema).testContacts set DbUserName = @DbUserName where SQLLogin = @SQLLogin'
    execute sp_executesql @tsql , N'@DbUserName VARCHAR(512),@ServerName VARCHAR(512) , @SQLLogin VARCHAR(256)' , @DbUserName = '$(DbUserForSQLLogin2)', @ServerName = @@SERVERNAME, @SQLLogin = '$(LocalSQLLogin2)';    
    execute sp_executesql @tsql , N'@DbUserName VARCHAR(512),@ServerName VARCHAR(512) , @SQLLogin VARCHAR(256)' , @DbUserName = '$(DbUserForSQLLogin4)', @ServerName = @@SERVERNAME, @SQLLogin = '$(LocalSQLLogin4)';    
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'Line ' + CONVERT(VARCHAR,ERROR_LINE()) + ' => ' + ERROR_MESSAGE()  ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK ;
    END
END CATCH

BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

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
    SET @TestReturnValInt = 0;

    BEGIN TRY
        BEGIN TRANSACTION
        PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';

        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = ''master'', @ContactLogin = ''$(DomainName)\$(DomainUser1)'' , @DefaultSchema=''$(OtherDBs_Schema)'',@isDefaultDb = 1 ;' ;
        execute sp_executesql @tsql ;
        
        SET @tsql = 'update $(TestingSchema).testContacts set DbUserName = @DbUserName where SQLLogin = @SQLLogin'
        execute sp_executesql @tsql , N'@DbUserName VARCHAR(512),@ServerName VARCHAR(512) , @SQLLogin VARCHAR(256)' , @DbUserName = '$(DomainName)\$(DomainUser1)', @ServerName = @@SERVERNAME, @SQLLogin = '$(DomainName)\$(DomainUser1)';    
        
        SET @TestReturnValInt = @TestReturnValInt + 1;
        SET @CreationWasOK = 1 ;

        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = ''master'', @ContactLogin = ''$(DomainName)\$(DomainUser2)'' , @DefaultSchema=''$(OtherDBs_Schema)'',@isDefaultDb = 1 , @withServerAccessCreation = 1;' ;
        execute sp_executesql @tsql ;

        SET @tsql = 'update $(TestingSchema).testContacts set DbUserName = @DbUserName where SQLLogin = @SQLLogin'
        execute sp_executesql @tsql , N'@DbUserName VARCHAR(512),@ServerName VARCHAR(512) , @SQLLogin VARCHAR(256)' , @DbUserName = '$(DomainName)\$(DomainUser2)', @ServerName = @@SERVERNAME, @SQLLogin = '$(DomainName)\$(DomainUser2)';    
        
        SET @TestReturnValInt = @TestReturnValInt + 1;

        SET @tsql = 'DECLARE @DbName VARCHAR(256) ; SET @DbName = DB_NAME() ; execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = @DbName, @ContactLogin = ''$(DomainName)\$(DomainUser2)'' , @DefaultSchema=''$(OtherDBs_Schema)'',@isDefaultDb = 1 ;' ;
        execute sp_executesql @tsql ;

        SET @TestReturnValInt = @TestReturnValInt + 1;

        SET @tsql = 'DECLARE @DbName VARCHAR(256) ; SET @DbName = DB_NAME() ; execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = @DbName, @ContactLogin = ''$(LocalSQLLogin3)'' , @DefaultSchema=''$(CurrentDB_Schema1)'',@isDefaultDb = 1 , @withServerAccessCreation = 1;' ;
        execute sp_executesql @tsql ;

        SET @tsql = 'update $(TestingSchema).testContacts set DbUserName = @DbUserName where SQLLogin = @SQLLogin'
        execute sp_executesql @tsql , N'@DbUserName VARCHAR(512),@ServerName VARCHAR(512) , @SQLLogin VARCHAR(256)' , @DbUserName = '$(LocalSQLLogin3)', @ServerName = @@SERVERNAME, @SQLLogin = '$(LocalSQLLogin3)';    
        
        SET @TestReturnValInt = @TestReturnValInt + 1;

        -- call it twice to check the edition mode is OK
        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = ''master'', @ContactLogin = ''$(DomainName)\$(DomainUser1)'' , @DefaultSchema=''$(OtherDBs_Schema)'',@isDefaultDb = 1 ;' ;
        execute sp_executesql @tsql ;

        SET @TestReturnValInt = @TestReturnValInt + 1;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @ErrorCount = @ErrorCount + 1
        SET @TestResult = 'FAILURE';
        SET @ErrorMessage = 'Line ' + CONVERT(VARCHAR,ERROR_LINE()) + ' => ' + ERROR_MESSAGE()  ;
        PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ') + ' | @CreationWasOK = ' + CONVERT(VARCHAR,@CreationWasOK) + '| @ProcedureExecCnt = ' + CONVERT(VARCHAR,@TestReturnValInt);
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK ;
        END

    END CATCH
END

BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Check the number of SQL Logins is OK';
SET @TestDescription = 'Checks that table [security].[SQLLogins] contains the expected number of items';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'SELECT @cnt = COUNT(*)'  + @LineFeed +
            'FROM' + @LineFeed +
            '    [security].[SQLLogins]' + @LineFeed +
            'WHERE ServerName = @@SERVERNAME' + @LineFeed
            ;

BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql, N'@cnt BIGINT OUTPUT', @cnt = @TestReturnValInt OUTPUT ;

    if(@TestReturnValInt <> $(expectedSQLLoginsCountAfterSQLMappingsCreation))
    BEGIN
        SET @ErrorMessage = 'Unexpected number of SQL Logins : ' + CONVERT(VARCHAR,@TestReturnValInt) + '. Expected : $(expectedSQLLoginsCountAfterSQLMappingsCreation)';
        RAISERROR(@ErrorMessage,12,1);
    END
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'Line ' + CONVERT(VARCHAR,ERROR_LINE()) + ' => ' + ERROR_MESSAGE()  ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK ;
    END
END CATCH

BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;
-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Check the number of SQL Mappings is OK';
SET @TestDescription = 'Checks that table [security].[SQLMappings] contains the expected number of items';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'SELECT @cnt = COUNT(*)'  + @LineFeed +
            'FROM' + @LineFeed +
            '    [security].[SQLMappings]' + @LineFeed +
            'WHERE ServerName = @@SERVERNAME' + @LineFeed
            ;

BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql, N'@cnt BIGINT OUTPUT', @cnt = @TestReturnValInt OUTPUT ;

    if(@TestReturnValInt <> $(expectedSQLMappingsTotalCount))
    BEGIN
        SET @ErrorMessage = 'Unexpected number of SQL Mappings : ' + CONVERT(VARCHAR,@TestReturnValInt) + '. Expected : $(expectedSQLMappingsTotalCount)';
        RAISERROR(@ErrorMessage,12,1);
    END
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'Line ' + CONVERT(VARCHAR,ERROR_LINE()) + ' => ' + ERROR_MESSAGE()  ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK ;
    END
END CATCH

BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;
-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Check the number of schemas is OK';
SET @TestDescription = 'Checks that table [security].[DatabaseSchemas] contains the expected number of items';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'SELECT @cnt = COUNT(*)'  + @LineFeed +
            'FROM' + @LineFeed +
            '    [security].[DatabaseSchemas]' + @LineFeed +
            'WHERE ServerName = @@SERVERNAME' + @LineFeed
            ;

BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql, N'@cnt BIGINT OUTPUT', @cnt = @TestReturnValInt OUTPUT ;

    if(@TestReturnValInt <> $(expectedDatabaseSchemasCountAfterSQLMappingsCreation))
    BEGIN
        SET @ErrorMessage = 'Unexpected number of Database Schemas : ' + CONVERT(VARCHAR,@TestReturnValInt) + '. Expected : $(expectedDatabaseSchemasCountAfterSQLMappingsCreation)';
        RAISERROR(@ErrorMessage,12,1);
    END
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'Line ' + CONVERT(VARCHAR,ERROR_LINE()) + ' => ' + ERROR_MESSAGE()  ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK ;
    END
END CATCH

BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Check All Contacts are defined by these tests';
SET @TestDescription = 'Checks that table [security].[DatabaseSchemas] contains the expected number of items';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'SELECT @cnt = COUNT(*)'  + @LineFeed +
            'FROM' + @LineFeed +
            '    $(TestingSchema).testContacts' + @LineFeed +
            'WHERE DbuserName is null' + @LineFeed
            ;

BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql, N'@cnt BIGINT OUTPUT', @cnt = @TestReturnValInt OUTPUT ;

    if(@TestReturnValInt <> 0)
    BEGIN
        SET @ErrorMessage = CONVERT(VARCHAR,@TestReturnValInt) + ' mappings are not well defined by these tests.';
        RAISERROR(@ErrorMessage,12,1);
    END
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'Line ' + CONVERT(VARCHAR,ERROR_LINE()) + ' => ' + ERROR_MESSAGE()  ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK ;
    END
END CATCH

BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

-- ---------------------------------------------------------------------------------------------------------