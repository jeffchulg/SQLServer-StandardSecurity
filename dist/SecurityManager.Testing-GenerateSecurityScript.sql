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


:setvar Feature "SecurityScriptGeneration"

SET @TestID = @TestID + 1 ;
SET @ProcedureName = 'getSecurityScript';
SET @TestName = 'Generate the standard security script and save result to a given table (' + @ProcedureName + ' procedure)';
SET @TestDescription = 'checks that ' + @ProcedureName + ' procedure exists and call it';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

IF( NOT EXISTS (
        select 1
        from sys.all_objects
        where
            SCHEMA_NAME(Schema_ID) COLLATE French_CI_AI = 'security' COLLATE French_CI_AI
        and name COLLATE French_CI_AI = @ProcedureName COLLATE French_CI_AI
    )
)
BEGIN
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'No procedure with name [security].[' + @ProcedureName + '] exists in ' + DB_NAME() ;
END
ELSE
BEGIN   
    BEGIN TRY
        BEGIN TRANSACTION
        PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
        
        if (OBJECT_ID('[security].[$(GeneratedScriptBackupTable)]') IS NOT NULL)
        BEGIN 
            execute sp_executesql N'TRUNCATE TABLE [security].[$(GeneratedScriptBackupTable)]';
        END 
        
        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName   = NULL , @OutputType = ''SCRIPT'', @OutputSchemaName = ''security'' , @OutputTableName = ''$(GeneratedScriptBackupTable)'', @Debug = 1;' ;
        execute sp_executesql @tsql ;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @ErrorCount = @ErrorCount + 1
        SET @TestResult = 'FAILURE';
        SET @ErrorMessage = 'Line ' + CONVERT(VARCHAR,ERROR_LINE()) + ' => ' + ERROR_MESSAGE()  ;
        PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ') + ' | @CreationWasOK = ' + CONVERT(VARCHAR,@CreationWasOK) ;
        IF @@TRANCOUNT > 0
        BEGIN 
            ROLLBACK ;
        END 
    END CATCH

END

BEGIN TRAN
INSERT into ${TestingSchema}.testResults values (@TestID , '$(Feature)',@TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

-- ---------------------------------------------------------------------------------------------------------