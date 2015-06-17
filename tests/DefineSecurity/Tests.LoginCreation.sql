/*requires Table.TestResults.sql*/
/*requires Table.TestContacts.sql*/
/*requires Tests.Start.sql*/
/*requires Tests.ContactCreation.sql*/

PRINT ''
PRINT 'Now testing SQL Login definition for server'
PRINT ''

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[SQLLogins] table (active = 1)';
SET @TestDescription = 'inserts a record into the [security].[SQLLogins] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[SQLLogins]'  + @LineFeed +
            '    (ServerName,SqlLogin,isActive)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    ''$(LocalSQLLogin1)'',' + @LineFeed +
            '    1' + @LineFeed +
            ')' ;

BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;
    COMMIT TRANSACTION 
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
SET @TestName = 'Creation by INSERT statement into [security].[SQLLogins] table (active = 0)';
SET @TestDescription = 'inserts a record into the [security].[SQLLogins] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[SQLLogins]'  + @LineFeed +
            '    (ServerName,SqlLogin,isActive)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    ''$(LocalSQLLogin2)'',' + @LineFeed +
            '    0' + @LineFeed +
            '),(' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    ''$(LocalSQLLogin4)'',' + @LineFeed +
            '    0' + @LineFeed +
            ')' ;


BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;
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
SET @TestName = 'Creation through setServerAccess procedure of an inactive SQL Login';
SET @TestDescription = 'checks that setServerAccess procedure exists and call it';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

IF( NOT EXISTS (
        select 1
        from sys.all_objects
        where
            SCHEMA_NAME(Schema_ID) COLLATE French_CI_AI = 'security' COLLATE French_CI_AI
        and name COLLATE French_CI_AI = 'setServerAccess' COLLATE French_CI_AI
    )
)
BEGIN
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'No procedure with name [security].[setServerAccess] exists in ' + DB_NAME() ;
END
ELSE
BEGIN
    SET @CreationWasOK = 0 ;
    
    BEGIN TRY
        BEGIN TRANSACTION
        PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';

        SET @tsql = 'execute [security].[setServerAccess] @ServerName = @@SERVERNAME , @ContactLogin = ''$(DomainName)\$(DomainUser1)'' , @isActive = 1 ;' ;
        execute sp_executesql @tsql ;

        SET @CreationWasOK = 1 ;

        -- call it twice to check the edition mode is OK
        SET @tsql = 'execute [security].[setServerAccess] @ServerName = @@SERVERNAME , @ContactLogin = ''$(DomainName)\$(DomainUser1)'' , @isActive = 0;' ;
        execute sp_executesql @tsql ;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @ErrorCount = @ErrorCount + 1
        SET @TestResult = 'FAILURE';
        SET @ErrorMessage = 'Line ' + CONVERT(VARCHAR,ERROR_LINE()) + ' => ' + ERROR_MESSAGE()  ;
        PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ') + ' | @CreationWasOK = ' + CONVERT(VARCHAR,@CreationWasOK) ;
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
