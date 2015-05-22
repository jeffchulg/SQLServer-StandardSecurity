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
/*requires Cleanup.LoginCreation.sql*/

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