set :SolutionName "Security Manager" 
set :TestingSchema "dbo"
set :DomainName   "CHULg"
set :DomainUser1  "SAI_Db"
set :DomainUser2  "c168350"
set :LocalSQLLogin1 "ApplicationSQLUser1"
set :LocalSQLLogin2 "ApplicationSQLUser2"
set :LocalSQLLogin3 "ApplicationSQLUser3"
set :DbUserForSQLLogin2 "DbUser2"
set :CurrentDB_Schema1 "ApplicationSchema1"
set :CurrentDB_Schema2 "ApplicationSchema2"
set :OtherDBs_Schema "dbo"
set :expectedContactsTotalCount 5
set :expectedSQLLoginsCountAfterSQLMappingsCreation 4
set :expectedSQLMappingsTotalCount 6
set :expectedDatabaseSchemasCountAfterSQLMappingsCreation 3
set :CustomRoleName1 "CustomRole"
set :CustomRoleName2 "InactiveCustomRole"
-- NoCleanups : 0 or 1
set :NoCleanups 1
set :expectedSQLLoginsTotalCount 5
set :GeneratedScriptBackupTable "GeneratedSecurityScripts"
/*

Find and replace : 

${SolutionName} "Security Manager" 
${DomainName}   "CHULg"
${DomainUser1}  "SAI_Db"
${DomainUser2}  "c168350"
${LocalSQLLogin1}    ApplicationSQLUser1
${LocalSQLLogin2}    ApplicationSQLUser2
${LocalSQLLogin3}    ApplicationSQLUser3
${DbUserForSQLLogin2} "DbUser2"
${CurrentDB_Schema1} "ApplicationSchema1"
${CurrentDB_Schema2} "ApplicationSchema2"
${OtherDBs_Schema} "dbo"
${expectedContactsTotalCount} 5
${expectedSQLLoginsCountAfterSQLMappingsCreation} 5
${expectedSQLLoginsTotalCount} 5
${expectedSQLMappingsTotalCount} 6
${expectedDatabaseSchemasCountAfterSQLMappingsCreation} 4
${CustomRoleName1} "CustomRole"
${CustomRoleName2} "InactiveCustomRole"
${NoCleanups} 1
${GeneratedScriptBackupTable} GeneratedSecurityScripts

*/

SET NOCOUNT ON;

DECLARE @TestID             BIGINT ;
DECLARE @TestName           VARCHAR(1024);
DECLARE @TestDescription    NVARCHAR(MAX);
DECLARE @TestResult         VARCHAR(16);
DECLARE @ErrorMessage       NVARCHAR(MAX);
DECLARE @tsql               NVARCHAR(MAX);
DECLARE @tsql2              NVARCHAR(MAX);
DECLARE @LineFeed           VARCHAR(10) ;
DECLARE @ErrorCount         BIGINT ;
DECLARE @ProcedureName      VARCHAR(128) ;
DECLARE @CreationWasOK      BIT ;

DECLARE @TestReturnValInt   BIGINT ;
DECLARE @TmpIntVal          BIGINT ;
DECLARE @TmpStringVal       VARCHAR(MAX);

SET @LineFeed = CHAR(13) + CHAR(10);
SET @ErrorCount = 0;

PRINT 'Starting testing for solution ${SolutionName}';
PRINT '' ;

-- =========================================================================================================

PRINT ''

if(${NoCleanups} = 0) 
BEGIN 
    PRINT 'Now cleaning up'
    
    if(OBJECT_ID('[security].[${GeneratedScriptBackupTable}]') is not null)
    BEGIN
        execute sp_executesql N'DROP TABLE [security].[${GeneratedScriptBackupTable}]';
    END 

END 
ELSE
BEGIN 
    PRINT 'Skipping cleanup (check script parameters)'
END 
 
PRINT ''

DECLARE @SQLLogin VARCHAR(512) ;

SET @TestID = @TestID + 1 ;
SET @TestName = 'SQLMappings Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[SQLMappings] table';
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
    PRINT '    . Removing SQL Mappings for SQL Login ' + QUOTENAME(@SQLLogin) + ' from list for ' + @@SERVERNAME + ' SQL instance';

/*    
    SET @TestID = @TestID + 1 ;
    SET @TestName = 'Deletion of unused SQL Mappings ' + QUOTENAME(@SQLLogin) ;
    SET @TestDescription = 'deletes a record from the [security].[SQLMappings] table';
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
            BEGIN TRAN ;
            DELETE FROM [security].[SQLMappings] WHERE ServerName = @@SERVERNAME and SqlLogin = @SQLLogin ;            
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
         
        SET @ErrorMessage = @ErrorMessage + 'Deletion of unused SQL Mappings ' + QUOTENAME(@SQLLogin)  + ' : ' + ERROR_MESSAGE() ;
        
        PRINT '        > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    END CATCH     
    
    FETCH Next From getTestContacts into @SQLLogin ;
END ;

CLOSE getTestContacts ;
DEALLOCATE getTestContacts;

if( ${NoCleanups} = 0 and @TmpIntVal <> ${expectedSQLMappingsTotalCount})
BEGIN 
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = @ErrorMessage + 'Unable to delete all expected SQL Mappings' ;
    
    if(LEN(@ErrorMessage) > 0)
        SET @ErrorMessage = @ErrorMessage + @LineFeed
    
    PRINT '        > ERROR Unable to delete all SQL Mappings';        
END 

if(@TestResult = 'FAILURE')
    SET @ErrorCount = @ErrorCount + 1

BEGIN TRAN ;
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;



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



SET @TestID = @TestID + 1 ;
SET @TestName = 'SQLMappings Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[SQLMappings] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = '';

if(${NoCleanups} = 1)
BEGIN
    SET @TestResult = 'SKIPPED'
END




if(@TestResult = 'FAILURE')
    SET @ErrorCount = @ErrorCount + 1

INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );





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