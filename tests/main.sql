set :SolutionName "Security Manager" 
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