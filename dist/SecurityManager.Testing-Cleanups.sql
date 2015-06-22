:setvar SolutionName "Security Manager" 
:setvar TestingSchema "dbo"
:setvar DomainName   "CHULg"
:setvar DomainUser1  "SAI_Db"
:setvar DomainUser2  "c168350"
:setvar LocalSQLLogin1 "ApplicationSQLUser1"
:setvar LocalSQLLogin2 "ApplicationSQLUser2"
:setvar LocalSQLLogin3 "ApplicationSQLUser3"
:setvar LocalSQLLogin4 "ApplicationSQLUser4" -- every time disabled / nothing good happens with him
:setvar DbUserForSQLLogin2 "DbUser2"
:setvar DbUserForSQLLogin4 "DbUser4"
:setvar CurrentDB_Schema1 "ApplicationSchema1"
:setvar CurrentDB_Schema2 "ApplicationSchema2"
:setvar OtherDBs_Schema "dbo"
:setvar expectedContactsTotalCount 6
:setvar expectedSQLLoginsCountAfterSQLMappingsCreation 6
:setvar expectedSQLMappingsTotalCount 7
:setvar expectedDatabaseSchemasCountAfterSQLMappingsCreation 4
:setvar CustomRoleName1 "CustomRole"
:setvar CustomRoleName2 "InactiveCustomRole"
-- NoCleanups : 0 or 1
:setvar NoCleanups 0
:setvar expectedSQLLoginsTotalCount 6
:setvar GeneratedScriptBackupTable "GeneratedSecurityScripts"
/*

Find and replace : 

$(SolutionName)
$(DomainName)  
$(DomainUser1) 
$(DomainUser2) 
$(LocalSQLLogin1)    
$(LocalSQLLogin2)    
$(LocalSQLLogin3)   
$(LocalSQLLogin4)   
$(DbUserForSQLLogin2)
$(DbUserForSQLLogin4)
$(CurrentDB_Schema1)
$(CurrentDB_Schema2)
$(OtherDBs_Schema)
$(expectedContactsTotalCount) 
$(expectedSQLLoginsCountAfterSQLMappingsCreation) 
$(expectedSQLLoginsTotalCount) 
$(expectedSQLMappingsTotalCount) 
$(expectedDatabaseSchemasCountAfterSQLMappingsCreation) 
$(CustomRoleName1)
$(CustomRoleName2)
$(NoCleanups) 
$(GeneratedScriptBackupTable) 

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

PRINT 'Starting testing for solution $(SolutionName)';
PRINT '' ;


:setvar Feature "Cleanups"

-- =========================================================================================================

PRINT ''

if($(NoCleanups) = 0) 
BEGIN 
    PRINT 'Now cleaning up'
    
    if(OBJECT_ID('[security].[$(GeneratedScriptBackupTable)]') is not null)
    BEGIN
        execute sp_executesql N'DROP TABLE [security].[$(GeneratedScriptBackupTable)]';
    END 

END 
ELSE
BEGIN 
    PRINT 'Skipping cleanup (check script parameters)'
END 
 
PRINT ''

DECLARE @SQLLogin VARCHAR(512) ;

SELECT @TestID = MAX(testID) from $(TestingSchema).testResults;

if(@TestID is NULL)
	SET @TestID = 1;

SET @TestID = @TestID + 1 ;
SET @TestName = 'DatabaseSchema Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[DatabaseSchema] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = '';

if($(NoCleanups) = 1)
BEGIN
    SET @TestResult = 'SKIPPED'
END




if(@TestResult = 'FAILURE')
    SET @ErrorCount = @ErrorCount + 1

INSERT into $(TestingSchema).testResults values (@TestID , '$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );


SET @TestID = @TestID + 1 ;
SET @TestName = 'SQLMappings Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[SQLMappings] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = '';

if($(NoCleanups) = 1)
BEGIN
    SET @TestResult = 'SKIPPED'
END

DECLARE getTestContacts CURSOR LOCAL FOR 
    SELECT SQLLogin
    FROM $(TestingSchema).testContacts ;
    
OPEN getTestContacts ;

FETCH Next From getTestContacts into @SQLLogin ;

SET @TmpIntVal = 0

WHILE @@FETCH_STATUS = 0 and $(NoCleanups) = 0
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
		BEGIN TRAN ;
		DELETE FROM [security].[SQLMappings] WHERE ServerName = @@SERVERNAME and SqlLogin = @SQLLogin ;            		
		SET @TmpIntVal = @TmpIntVal + @@ROWCOUNT;
		COMMIT;
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

if( $(NoCleanups) = 0 and @TmpIntVal <> $(expectedSQLMappingsTotalCount))
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
INSERT into $(TestingSchema).testResults values (@TestID , '$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;




SET @TestID = @TestID + 1 ;
SET @TestName = 'SQL Logins Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[SQLLogins] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = '';

if($(NoCleanups) = 1)
BEGIN
    SET @TestResult = 'SKIPPED'
END


DECLARE getTestContacts CURSOR LOCAL FOR 
    SELECT SQLLogin
    FROM $(TestingSchema).testContacts ;
    
OPEN getTestContacts ;

FETCH Next From getTestContacts into @SQLLogin ;

SET @TmpIntVal = 0

WHILE @@FETCH_STATUS = 0 and $(NoCleanups) = 0
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
			SET @TmpIntVal = @TmpIntVal + @@ROWCOUNT;
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
         
        SET @ErrorMessage = @ErrorMessage + 'Deletion of unused SQL Login ' + QUOTENAME(@SQLLogin)  + ' : ' + ERROR_MESSAGE() ;
        
        PRINT '        > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    END CATCH    
    
    FETCH Next From getTestContacts into @SQLLogin ;
END ;

CLOSE getTestContacts ;
DEALLOCATE getTestContacts;

if( $(NoCleanups) = 0 and @TmpIntVal <> $(expectedSQLLoginsTotalCount))
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
INSERT into $(TestingSchema).testResults values (@TestID , '$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;






SET @TestID = @TestID + 1 ;
SET @TestName = 'Contacts Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[Contacts] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = '';

if($(NoCleanups) = 1)
BEGIN
    SET @TestResult = 'SKIPPED'
END
ELSE
BEGIN
    PRINT 'Removing unused contacts' 
END



DECLARE getTestContacts CURSOR LOCAL FOR 
    SELECT SQLLogin
    FROM $(TestingSchema).testContacts ;
    
OPEN getTestContacts ;

FETCH Next From getTestContacts into @SQLLogin ;
SET @TmpIntVal = 0

WHILE @@FETCH_STATUS = 0 and $(NoCleanups) = 0
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
			SET @TmpIntVal = @TmpIntVal + @@ROWCOUNT;
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


if( $(NoCleanups) = 0 and @TmpIntVal <> $(expectedContactsTotalCount))
BEGIN 
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = @ErrorMessage + 'Unable to delete all expected Contacts' ;
    
    if(LEN(@ErrorMessage) > 0)
        SET @ErrorMessage = @ErrorMessage + @LineFeed
    
    PRINT '        > ERROR Unable to delete all SQL Contacts';        
END 

if(@TestResult = 'FAILURE')
    SET @ErrorCount = @ErrorCount + 1

BEGIN TRAN    
INSERT into $(TestingSchema).testResults values (@TestID , '$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;


if($(NoCleanups) = 0 and OBJECT_ID('tempdb..$(TestingSchema).testContacts') is not null)
BEGIN
    execute sp_executesql N'DROP TABLE $(TestingSchema).testContacts';
END 

-- ---------------------------------------------------------------------------------------------------------