/*requires TempTable.TestResults.sql */
/*requires TempTable.TestContacts.sql */

SET @TestID = 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[Contacts] table (authmode SQL Server - active)';
SET @TestDescription = 'inserts a record into the [security].[Contacts] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

set @tsql = 'insert into [security].[Contacts]'  + @LineFeed +
            '    (SqlLogin,Name,job,isActive,Department,authmode)' + @LineFeed +
            'values (' + @LineFeed +
            '    ''ApplicationSQLUser1'',' + @LineFeed +
            '    ''John Doe'',' + @LineFeed +
            '    ''Application Manager'',' + @LineFeed +
            '    1,' + @LineFeed + 
            '    ''MyCorp/IT Service/Application Support Team'',' + @LineFeed +
            '    ''SQLSRVR''' + @LineFeed + 
            ')' ;

BEGIN TRANSACTION             
BEGIN TRY
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;    
END TRY 
BEGIN CATCH
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = ERROR_MESSAGE() ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
END CATCH 
COMMIT TRANSACTION;

INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
INSERT INTO #testContacts values ('ApplicationSQLUser1');

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

BEGIN TRANSACTION             
BEGIN TRY
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;    
END TRY 
BEGIN CATCH
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = ERROR_MESSAGE() ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
END CATCH 
COMMIT TRANSACTION;

INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
INSERT INTO #testContacts values ('${DomainName}\${DomainUser1}');

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[Contacts] table (authmode SQL Server - inactive)';
SET @TestDescription = 'inserts a record into the [security].[Contacts] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[Contacts]'  + @LineFeed +
            '    (SqlLogin,Name,job,isActive,Department,authmode)' + @LineFeed +
            'values (' + @LineFeed +
            '    ''ApplicationSQLUser2'',' + @LineFeed +
            '    ''${DomainUser1}'',' + @LineFeed +
            '    ''Test Manager'',' + @LineFeed +
            '    0,' + @LineFeed + 
            '    ''External/DevCorp/DevProduct'',' + @LineFeed +
            '    ''SQLSRVR''' + @LineFeed + 
            ')' ;

BEGIN TRANSACTION             
BEGIN TRY
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;    
END TRY 
BEGIN CATCH
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = ERROR_MESSAGE() ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
END CATCH 
COMMIT TRANSACTION;

INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
INSERT INTO #testContacts values ('ApplicationSQLUser2');

-- ---------------------------------------------------------------------------------------------------------