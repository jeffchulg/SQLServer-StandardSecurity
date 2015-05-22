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