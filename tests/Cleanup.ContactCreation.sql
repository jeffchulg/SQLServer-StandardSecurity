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
/*requires Cleanup.SQLMappingsCreation.sql */
/*requires Cleanup.LoginCreation.sql */
/*requires Cleanup.DatabaseSchemas.sql */


SET @TestID = @TestID + 1 ;
SET @TestName = 'Contacts Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[Contacts] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = '';

if(${NoCleanups} = 1)
BEGIN
    SET @TestResult = 'SKIPPED'
END
ELSE
BEGIN
    PRINT 'Removing unused contacts' 
END



DECLARE getTestContacts CURSOR LOCAL FOR 
    SELECT SQLLogin
    FROM #testContacts ;
    
OPEN getTestContacts ;

FETCH Next From getTestContacts into @SQLLogin ;

WHILE @@FETCH_STATUS = 0 and ${NoCleanups} = 0
BEGIN 
    PRINT '    . Removing contact ' + QUOTENAME(@SQLLogin) ;
    /*
    SET @TestID = @TestID + 1 ;
    SET @TestName = 'Deletion of unused contact ' + QUOTENAME(@SQLLogin) ;
    SET @TestDescription = 'deletes a record from the [security].[Contacts] table';
    SET @TestResult = 'SUCCESS';
    SET @ErrorMessage = NULL ;
*/
    BEGIN TRY 
        if( not exists (
                select 1 
                from [security].[SQLLogins] 
                where SQLLogin = @SQLLogin
            )
        )
        BEGIN 
            BEGIN TRAN;
            DELETE FROM [security].[Contacts] WHERE SqlLogin = @SQLLogin ;            
            COMMIT;
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
         
        SET @ErrorMessage = @ErrorMessage + 'Deletion of unused contact ' + QUOTENAME(@SQLLogin)  + ' : ' + ERROR_MESSAGE() ;
        
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


if(${NoCleanups} = 0 and OBJECT_ID('tempdb..#testContacts') is not null)
BEGIN
    execute sp_executesql N'DROP TABLE #testContacts';
END 

-- ---------------------------------------------------------------------------------------------------------