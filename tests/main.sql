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