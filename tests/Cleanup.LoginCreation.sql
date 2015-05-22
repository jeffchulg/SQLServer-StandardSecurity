/*requires main.sql*/
/*requires TempTable.TestResults.sql*/
/*requires TempTable.TestContacts.sql*/
/*requires Tests.Start.sql*/
/*requires Tests.ContactCreation.sql*/
/*requires Tests.LoginCreation.sql*/
/*requires Tests.SQLMappingsCreation.sql*/
/*requires Tests.GenerateStandardRoles.sql*/
/*requires Tests.PermissionAssignments.sql*/
/*requires Tests.SecurityScriptGeneration.sql*/
/*requires Tests.End.sql*/
/*requires cleanups.sql */
/*requires Cleanup.SQLMappingsCreation.sql*/


SET @TestID = @TestID + 1 ;
SET @TestName = 'SQL Logins Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[SQLLogins] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = '';

if(${NoCleanups} = 1)
BEGIN
    SET @TestResult = 'SKIPPED'
END


DECLARE getTestContacts CURSOR LOCAL FOR 
    SELECT SQLLogin
    FROM #testContacts ;
    
OPEN getTestContacts ;

FETCH Next From getTestContacts into @SQLLogin ;

SET @TmpIntVal = 0

WHILE @@FETCH_STATUS = 0 and ${NoCleanups} = 0
BEGIN 
    PRINT '    . Removing SQL Login ' + QUOTENAME(@SQLLogin) + ' from list for ' + @@SERVERNAME + ' SQL instance';
    /*
    SET @TestID = @TestID + 1 ;
    SET @TestName = 'Deletion of unused SQL Login ' + QUOTENAME(@SQLLogin) ;
    SET @TestDescription = 'deletes a record from the [security].[SQLLogins] table';
    SET @TestResult = 'SUCCESS';
    SET @ErrorMessage = NULL ;
*/
    BEGIN TRY 
        if( not exists (
                select 1 
                from [security].[SQLMappings] 
                where ServerName = @@SERVERNAME 
                and SQLLogin = @SQLLogin
            )
        )
        BEGIN 
            BEGIN TRAN 
            DELETE FROM [security].[SQLLogins] WHERE ServerName = @@SERVERNAME and SqlLogin = @SQLLogin ;            
            COMMIT;
            SET @TmpIntVal = @TmpIntVal + 1;
        END ;
    END TRY 
    BEGIN CATCH         
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK ;
        END
        --SET @ErrorCount = @ErrorCount + 1
        SET @TestResult = 'FAILURE';
        if(LEN(@ErrorMessage) > 0)
            SET @ErrorMessage = @ErrorMessage + @LineFeed
         
        SET @ErrorMessage = @ErrorMessage + 'Deletion of unused SQL Login ' + QUOTENAME(@SQLLogin)  + ' : ' + ERROR_MESSAGE() ;
        
        PRINT '        > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    END CATCH    
    
    FETCH Next From getTestContacts into @SQLLogin ;
END ;

CLOSE getTestContacts ;
DEALLOCATE getTestContacts;

if( ${NoCleanups} = 0 and @TmpIntVal <> ${expectedSQLLoginsTotalCount})
BEGIN 
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = @ErrorMessage + 'Unable to delete all expected SQL Logins' ;
    
    if(LEN(@ErrorMessage) > 0)
        SET @ErrorMessage = @ErrorMessage + @LineFeed
    
    PRINT '        > ERROR Unable to delete all SQL Logins';        
END 

if(@TestResult = 'FAILURE')
    SET @ErrorCount = @ErrorCount + 1

BEGIN TRAN    
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;