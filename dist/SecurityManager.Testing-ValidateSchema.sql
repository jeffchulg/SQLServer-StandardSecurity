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

PRINT 'Creating temporary table in which tests results will be stored';

IF(OBJECT_ID('$(TestingSchema).testResults') is not null)
	DROP TABLE $(TestingSchema).testResults

CREATE TABLE $(TestingSchema).testResults (
    TestID          BIGINT          NOT NULL ,
	Feature         VARCHAR(1024)   NOT NULL,
    TestName        VARCHAR(1024)   NOT NULL ,
    TestDescription NVARCHAR(MAX),
    TestResult      VARCHAR(16)     NOT NULL,
    ErrorMessage    NVARCHAR(MAX)
);


:setvar Feature "ValidateSchema"

SET @TestID = 1 ;
SET @TestName = 'ValidateSchema-DbName fields';
SET @TestDescription = 'Ensure DbName fields are at least VARCHAR(128)';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';

DECLARE WrongTypeObjects CURSOR LOCAL FOR 
	select 
		OBJECT_SCHEMA_NAME(object_id) as SchemaName, 
		OBJECT_NAME(object_id)        as ObjectName,   
		(select name from sys.types t where t.system_type_id = ac.system_type_id) as ObjectType,
		max_length  
	from sys.all_columns ac
	where OBJECT_SCHEMA_NAME(object_id) in ('security','inventory')
	and  name = 'DbName' 
	and (
			ac.system_type_id <> (
				select system_type_id from sys.types t where t.name = 'varchar' 
			)
		or  ac.max_length < 128 
	) ;
DECLARE @SchemaName SYSNAME;
DECLARE @ObjectName SYSNAME;
DECLARE @ObjectType SYSNAME;
DECLARE @max_length BIGINT;

OPEN WrongTypeObjects;
FETCH NEXT FROM WrongTypeObjects INTO @SchemaName,@ObjectName,@ObjectType,@max_length;

WHILE @@FETCH_STATUS = 0
BEGIN 

	SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = ISNULL(@ErrorMessage ,'')+ 'Table ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName) + ' not OK ' + '[TYPE=' + @ObjectType + ' | LENGTH=' + CONVERT(VARCHAR,@max_length) + ']' + @LineFeed;

	FETCH NEXT FROM WrongTypeObjects INTO @SchemaName,@ObjectName,@ObjectType,@max_length;
END ;

if(LEN(@ErrorMessage) > 0)
BEGIN 
	PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')		;	
END
      
BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

-- ---------------------------------------------------------------------------------------------------------




PRINT ''
PRINT ''
PRINT ''
PRINT ''
PRINT ''

DECLARE @ResultsInErrorCnt BIGINT ;
SELECT @ResultsInErrorCnt = count(*) FROM $(TestingSchema).testResults WHERE Feature = '$(Feature)' and TestResult = 'FAILURE'

if(@ResultsInErrorCnt > 0)
BEGIN
	DECLARE @textMsg VARCHAR(2048);
	SET @textMsg = CONVERT(VARCHAR,@ResultsInErrorCnt) + ' errors found for the $(Feature) feature' ;
	RAISERROR(@textMsg,12,1);
END 
GO
