/*requires cleanups.sql*/
/*requires Cleanup.DatabaseRoleMembers.sql*/

SET @TestID = @TestID + 1 ;
SET @TestName = 'DatabaseRoles Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[DatabaseRoles] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = '';

if($(NoCleanups) = 1)
BEGIN
    SET @TestResult = 'SKIPPED'
END




if(@TestResult = 'FAILURE')
    SET @ErrorCount = @ErrorCount + 1

INSERT into $(TestingSchema).testResults values (@TestID , '$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );