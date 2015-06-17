/*requires ..\main.sql*/


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