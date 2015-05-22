/*requires Tests.Start.sql*/

SET @TestID = 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[Contacts] table (authmode SQL Server - active)';
SET @TestDescription = 'inserts a record into the [security].[Contacts] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

set @tsql = 'insert into [security].[Contacts]'  + @LineFeed +
            '    (SqlLogin,Name,job,isActive,Department,authmode)' + @LineFeed +
            'values (' + @LineFeed +
            '    ''${LocalSQLLogin1}'',' + @LineFeed +
            '    ''John Doe'',' + @LineFeed +
            '    ''Application Manager'',' + @LineFeed +
            '    1,' + @LineFeed + 
            '    ''MyCorp/IT Service/Application Support Team'',' + @LineFeed +
            '    ''SQLSRVR''' + @LineFeed + 
            ')' ;

            
BEGIN TRY
    BEGIN TRANSACTION 
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;    
    COMMIT TRANSACTION
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
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
INSERT INTO #testContacts(SQLLogin) values ('${LocalSQLLogin1}');
COMMIT;

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[Contacts] table (authmode Windows - active)';
SET @TestDescription = 'inserts a record into the [security].[Contacts] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[Contacts]'  + @LineFeed +
            '    (SqlLogin,Name,job,isActive,Department,authmode)' + @LineFeed +
            'values (' + @LineFeed +
            '    ''${DomainName}\${DomainUser1}'',' + @LineFeed +
            '    ''${DomainUser1}'',' + @LineFeed +
            '    ''Test Manager'',' + @LineFeed +
            '    1,' + @LineFeed + 
            '    ''MyCorp/IT Service/Validation Team'',' + @LineFeed +
            '    ''Windows''' + @LineFeed + 
            ')' ;

       
BEGIN TRY
    BEGIN TRANSACTION      
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;    
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
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
INSERT INTO #testContacts(SQLLogin) values ('${DomainName}\${DomainUser1}');
COMMIT;
-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[Contacts] table (authmode Windows - active)';
SET @TestDescription = 'inserts a record into the [security].[Contacts] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[Contacts]'  + @LineFeed +
            '    (SqlLogin,Name,job,isActive,Department,authmode)' + @LineFeed +
            'values (' + @LineFeed +
            '    ''${DomainName}\${DomainUser2}'',' + @LineFeed +
            '    ''${DomainUser2}'',' + @LineFeed +
            '    ''DBA'',' + @LineFeed +
            '    1,' + @LineFeed + 
            '    ''MyCorp/IT Service/DBA'',' + @LineFeed +
            '    ''Windows''' + @LineFeed + 
            ')' ;

       
BEGIN TRY
    BEGIN TRANSACTION      
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;    
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
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
INSERT INTO #testContacts(SQLLogin) values ('${DomainName}\${DomainUser2}');
COMMIT;

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[Contacts] table (authmode SQL Server - inactive)';
SET @TestDescription = 'inserts a record into the [security].[Contacts] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[Contacts]'  + @LineFeed +
            '    (SqlLogin,Name,job,isActive,Department,authmode)' + @LineFeed +
            'values (' + @LineFeed +
            '    ''${LocalSQLLogin2}'',' + @LineFeed +
            '    ''Jane Doe'',' + @LineFeed +
            '    ''Application EndUser'',' + @LineFeed +
            '    0,' + @LineFeed + 
            '    ''External/DevCorp/DevProduct'',' + @LineFeed +
            '    ''SQLSRVR''' + @LineFeed + 
            ')' ;
       
BEGIN TRY
    BEGIN TRANSACTION      
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;    
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
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
INSERT INTO #testContacts(SQLLogin) values ('${LocalSQLLogin2}');
COMMIT;

-- ---------------------------------------------------------------------------------------------------------


SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[Contacts] table (authmode SQL Server - inactive)';
SET @TestDescription = 'inserts a record into the [security].[Contacts] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[Contacts]'  + @LineFeed +
            '    (SqlLogin,Name,job,isActive,Department,authmode)' + @LineFeed +
            'values (' + @LineFeed +
            '    ''${LocalSQLLogin3}'',' + @LineFeed +
            '    ''John Smith'',' + @LineFeed +
            '    ''Application EndUser'',' + @LineFeed +
            '    0,' + @LineFeed + 
            '    ''External/DevCorp/DevProduct'',' + @LineFeed +
            '    ''SQLSRVR''' + @LineFeed + 
            ')' ;

BEGIN TRY
    BEGIN TRANSACTION             
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;
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
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
INSERT INTO #testContacts(SQLLogin) values ('${LocalSQLLogin3}');
COMMIT;
-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Check the number of contacts is OK';
SET @TestDescription = 'Joins #testContacts and [security].[Contacts] and checks the number of contacts defined in both tables';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

set @tsql = 'SELECT @cnt = COUNT(*)'  + @LineFeed +            
            'FROM (' + @LineFeed +
            '    SELECT SQLLogin FROM #testContacts t' + @LineFeed +
            'INTERSECT' + @LineFeed +
            '    SELECT SQLLogin FROM [security].[Contacts] c' + @LineFeed +
            ') A' + @LineFeed             
            ;

       
BEGIN TRY
    BEGIN TRANSACTION      
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql, N'@cnt BIGINT OUTPUT', @cnt = @TestReturnValInt OUTPUT ;    
    
    if(@TestReturnValInt <> ${expectedContactsTotalCount}) 
    BEGIN 
        SET @ErrorMessage = 'Unexpected number of contacts : ' + CONVERT(VARCHAR,@TestReturnValInt) + '. Expected : ${expectedContactsTotalCount}';
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
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;
-- ---------------------------------------------------------------------------------------------------------