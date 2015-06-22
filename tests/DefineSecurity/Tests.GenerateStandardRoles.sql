/*requires Table.TestResults.sql*/
/*requires Table.TestContacts.sql*/
/*requires Tests.Start.sql*/
/*requires Tests.ContactCreation.sql*/
/*requires Tests.LoginCreation.sql*/
/*requires Tests.SQLMappingsCreation.sql*/


SET @TestID = @TestID + 1 ;
SET @ProcedureName = 'setStandardOnSchemaRoles';
SET @TestName = 'Generate standard "On Schema" roles through ' + @ProcedureName + ' procedure';
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

        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME ;' ;
        execute sp_executesql @tsql ;

        SET @CreationWasOK = 1 ;

        -- call it twice to check the edition mode is OK        
        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME ;' ;
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
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Check the number of generated roles is the one expected';
SET @TestDescription = 'Get to know how many roles have to be created and check the number of items in Database ';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


SET @tsql = 'SELECT @cnt = COUNT(*)' + @LineFeed +
            'FROM [security].[DatabaseSchemas] ' + @LineFeed +
            'WHERE SchemaName not in (' + @LineFeed +
            '    SELECT ObjectName ' + @LineFeed +
            '    FROM [security].[StandardExclusion]' + @LineFeed +
            '    WHERE ' + @LineFeed +
            '        ObjectType = ''DATABASE_SCHEMA''' + @LineFeed +
            '    AND isActive   = 1' + @LineFeed +
            ')' 
            ;           

set @tsql2 = 'SELECT @cnt = COUNT(*)' + @LineFeed +
             'FROM [security].[StandardOnSchemaRoles] ' + @LineFeed 
            ;
       
BEGIN TRY
    BEGIN TRANSACTION      
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql, N'@cnt BIGINT', @cnt = @TmpIntVal  ;        
    execute sp_executesql @tsql2, N'@cnt BIGINT', @cnt = @TestReturnValInt  ;
    
    SET @TmpIntVal = @TmpIntVal * @TestReturnValInt ;
    
    SET @tsql = 'SELECT @cnt = COUNT(*)' + @LineFeed +
                'FROM [security].[DatabaseRoles] ' + @LineFeed                 
                ;           

    execute sp_executesql @tsql, N'@cnt BIGINT', @cnt = @TestReturnValInt  ;
    
    if(@TestReturnValInt <> @TmpIntVal) 
    BEGIN 
        SET @ErrorMessage = 'Unexpected number of database roles : ' + CONVERT(VARCHAR,@TestReturnValInt) + '. Expected : ' + CONVERT(VARCHAR,@TmpIntVal);
        RAISERROR(@ErrorMessage,12,1);        
    END 
    COMMIT TRANSACTION;
END TRY 
BEGIN CATCH    
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'Line ' + CONVERT(VARCHAR,ERROR_LINE()) + ' => ' + ERROR_MESSAGE()  ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    IF @@TRANCOUNT > 0
    BEGIN 
        ROLLBACK ;
    END 
END CATCH

BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;
-- ---------------------------------------------------------------------------------------------------------
