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

PRINT 'Creating temporary table in which tests results will be stored';

IF(OBJECT_ID('tempdb..#testResults') is not null)
	DROP TABLE #testResults

CREATE TABLE #testResults (
    TestID          BIGINT          NOT NULL ,
    TestName        VARCHAR(1024)   NOT NULL ,
    TestDescription NVARCHAR(MAX),
    TestResult      VARCHAR(16)     NOT NULL,
    ErrorMessage    NVARCHAR(MAX)
);


PRINT 'Creating temporary table in which created Contacts will be stored' ;

IF(OBJECT_ID('tempdb..#testContacts') is not null)
	DROP TABLE #testContacts

CREATE TABLE #testContacts (
    SQLLogin VARCHAR(512) NOT NULL ,
    DbUserName VARCHAR(512) 
) ;





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


PRINT ''
PRINT 'Now testing SQL Login definition for server'
PRINT ''

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[SQLLogins] table (active = 1)';
SET @TestDescription = 'inserts a record into the [security].[SQLLogins] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[SQLLogins]'  + @LineFeed +
            '    (ServerName,SqlLogin,isActive)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    ''${LocalSQLLogin1}'',' + @LineFeed +
            '    1' + @LineFeed +
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
COMMIT;

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[SQLLogins] table (active = 0)';
SET @TestDescription = 'inserts a record into the [security].[SQLLogins] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[SQLLogins]'  + @LineFeed +
            '    (ServerName,SqlLogin,isActive)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    ''${LocalSQLLogin2}'',' + @LineFeed +
            '    0' + @LineFeed +
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
COMMIT;
-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation through setServerAccess procedure of an inactive SQL Login';
SET @TestDescription = 'checks that setServerAccess procedure exists and call it';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

IF( NOT EXISTS (
        select 1
        from sys.all_objects
        where
            SCHEMA_NAME(Schema_ID) COLLATE French_CI_AI = 'security' COLLATE French_CI_AI
        and name COLLATE French_CI_AI = 'setServerAccess' COLLATE French_CI_AI
    )
)
BEGIN
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'No procedure with name [security].[setServerAccess] exists in ' + DB_NAME() ;
END
ELSE
BEGIN
    SET @CreationWasOK = 0 ;
    
    BEGIN TRY
        BEGIN TRANSACTION
        PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';

        SET @tsql = 'execute [security].[setServerAccess] @ServerName = @@SERVERNAME , @ContactLogin = ''${DomainName}\${DomainUser1}'' , @isActive = 1 ;' ;
        execute sp_executesql @tsql ;

        SET @CreationWasOK = 1 ;

        -- call it twice to check the edition mode is OK
        SET @tsql = 'execute [security].[setServerAccess] @ServerName = @@SERVERNAME , @ContactLogin = ''${DomainName}\${DomainUser1}'' , @isActive = 0;' ;
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
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;
-- ---------------------------------------------------------------------------------------------------------




PRINT ''
PRINT 'Now testing SQL Mappings definition for server'
PRINT ''


SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[SQLMappings] table (DbUserName = SQLLogin)';
SET @TestDescription = 'inserts a record into the [security].[SQLMappings] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[SQLMappings]'  + @LineFeed +
            '    (ServerName,SqlLogin,DbName,DbUserName,DefaultSchema,isDefaultDb)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    ''${LocalSQLLogin1}'',' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +            
            '    ''${LocalSQLLogin1}'',' + @LineFeed +
            '    ''${CurrentDB_Schema1}'',' + @LineFeed +
            '    1' + @LineFeed +
            ')' ;


BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;
    
    SET @tsql = 'update #testContacts set DbUserName = @DbUserName where SQLLogin = @SQLLogin'
    execute sp_executesql @tsql , N'@DbUserName VARCHAR(512),@ServerName VARCHAR(512) , @SQLLogin VARCHAR(256)' , @DbUserName = '${LocalSQLLogin1}', @ServerName = @@SERVERNAME, @SQLLogin = '${LocalSQLLogin1}';    
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

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[SQLMappings] table (DbUserName <> SQLLogin)';
SET @TestDescription = 'inserts a record into the [security].[SQLMappings] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[SQLMappings]'  + @LineFeed +
            '    (ServerName,SqlLogin,DbName,DbUserName,DefaultSchema,isDefaultDb)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    ''${LocalSQLLogin2}'',' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +            
            '    ''${DbUserForSQLLogin2}'',' + @LineFeed +
            '    ''${CurrentDB_Schema2}'',' + @LineFeed +
            '    1' + @LineFeed +
            ')' ;


BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;
    
    SET @tsql = 'update #testContacts set DbUserName = @DbUserName where SQLLogin = @SQLLogin'
    execute sp_executesql @tsql , N'@DbUserName VARCHAR(512),@ServerName VARCHAR(512) , @SQLLogin VARCHAR(256)' , @DbUserName = '${DbUserForSQLLogin2}', @ServerName = @@SERVERNAME, @SQLLogin = '${LocalSQLLogin2}';    
    
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

SET @TestID = @TestID + 1 ;
SET @ProcedureName = 'setDatabaseAccess';
SET @TestName = 'Creation through ' + @ProcedureName + ' procedure';
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
    SET @CreationWasOK = 0 ;
    SET @TestReturnValInt = 0;

    BEGIN TRY
        BEGIN TRANSACTION
        PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';

        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = ''master'', @ContactLogin = ''${DomainName}\${DomainUser1}'' , @DefaultSchema=''${OtherDBs_Schema}'',@isDefaultDb = 1 ;' ;
        execute sp_executesql @tsql ;
        
        SET @tsql = 'update #testContacts set DbUserName = @DbUserName where SQLLogin = @SQLLogin'
        execute sp_executesql @tsql , N'@DbUserName VARCHAR(512),@ServerName VARCHAR(512) , @SQLLogin VARCHAR(256)' , @DbUserName = '${DomainName}\${DomainUser1}', @ServerName = @@SERVERNAME, @SQLLogin = '${DomainName}\${DomainUser1}';    
        
        SET @TestReturnValInt = @TestReturnValInt + 1;
        SET @CreationWasOK = 1 ;

        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = ''master'', @ContactLogin = ''${DomainName}\${DomainUser2}'' , @DefaultSchema=''${OtherDBs_Schema}'',@isDefaultDb = 1 , @withServerAccessCreation = 1;' ;
        execute sp_executesql @tsql ;

        SET @tsql = 'update #testContacts set DbUserName = @DbUserName where SQLLogin = @SQLLogin'
        execute sp_executesql @tsql , N'@DbUserName VARCHAR(512),@ServerName VARCHAR(512) , @SQLLogin VARCHAR(256)' , @DbUserName = '${DomainName}\${DomainUser2}', @ServerName = @@SERVERNAME, @SQLLogin = '${DomainName}\${DomainUser2}';    
        
        SET @TestReturnValInt = @TestReturnValInt + 1;

        SET @tsql = 'DECLARE @DbName VARCHAR(256) ; SET @DbName = DB_NAME() ; execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = @DbName, @ContactLogin = ''${DomainName}\${DomainUser2}'' , @DefaultSchema=''${OtherDBs_Schema}'',@isDefaultDb = 1 ;' ;
        execute sp_executesql @tsql ;

        SET @TestReturnValInt = @TestReturnValInt + 1;

        SET @tsql = 'DECLARE @DbName VARCHAR(256) ; SET @DbName = DB_NAME() ; execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = @DbName, @ContactLogin = ''${LocalSQLLogin3}'' , @DefaultSchema=''${CurrentDB_Schema1}'',@isDefaultDb = 1 , @withServerAccessCreation = 1;' ;
        execute sp_executesql @tsql ;

        SET @tsql = 'update #testContacts set DbUserName = @DbUserName where SQLLogin = @SQLLogin'
        execute sp_executesql @tsql , N'@DbUserName VARCHAR(512),@ServerName VARCHAR(512) , @SQLLogin VARCHAR(256)' , @DbUserName = '${LocalSQLLogin3}', @ServerName = @@SERVERNAME, @SQLLogin = '${LocalSQLLogin3}';    
        
        SET @TestReturnValInt = @TestReturnValInt + 1;

        -- call it twice to check the edition mode is OK
        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName = ''master'', @ContactLogin = ''${DomainName}\${DomainUser1}'' , @DefaultSchema=''${OtherDBs_Schema}'',@isDefaultDb = 1 ;' ;
        execute sp_executesql @tsql ;

        SET @TestReturnValInt = @TestReturnValInt + 1;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @ErrorCount = @ErrorCount + 1
        SET @TestResult = 'FAILURE';
        SET @ErrorMessage = 'Line ' + CONVERT(VARCHAR,ERROR_LINE()) + ' => ' + ERROR_MESSAGE()  ;
        PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ') + ' | @CreationWasOK = ' + CONVERT(VARCHAR,@CreationWasOK) + '| @ProcedureExecCnt = ' + CONVERT(VARCHAR,@TestReturnValInt);
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK ;
        END

    END CATCH
END

BEGIN TRAN
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Check the number of SQL Logins is OK';
SET @TestDescription = 'Checks that table [security].[SQLLogins] contains the expected number of items';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'SELECT @cnt = COUNT(*)'  + @LineFeed +
            'FROM' + @LineFeed +
            '    [security].[SQLLogins]' + @LineFeed +
            'WHERE ServerName = @@SERVERNAME' + @LineFeed
            ;

BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql, N'@cnt BIGINT OUTPUT', @cnt = @TestReturnValInt OUTPUT ;

    if(@TestReturnValInt <> ${expectedSQLLoginsCountAfterSQLMappingsCreation})
    BEGIN
        SET @ErrorMessage = 'Unexpected number of SQL Logins : ' + CONVERT(VARCHAR,@TestReturnValInt) + '. Expected : ${expectedSQLLoginsCountAfterSQLMappingsCreation}';
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

SET @TestID = @TestID + 1 ;
SET @TestName = 'Check the number of SQL Mappings is OK';
SET @TestDescription = 'Checks that table [security].[SQLMappings] contains the expected number of items';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'SELECT @cnt = COUNT(*)'  + @LineFeed +
            'FROM' + @LineFeed +
            '    [security].[SQLMappings]' + @LineFeed +
            'WHERE ServerName = @@SERVERNAME' + @LineFeed
            ;

BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql, N'@cnt BIGINT OUTPUT', @cnt = @TestReturnValInt OUTPUT ;

    if(@TestReturnValInt <> ${expectedSQLMappingsTotalCount})
    BEGIN
        SET @ErrorMessage = 'Unexpected number of SQL Mappings : ' + CONVERT(VARCHAR,@TestReturnValInt) + '. Expected : ${expectedSQLMappingsTotalCount}';
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

SET @TestID = @TestID + 1 ;
SET @TestName = 'Check the number of schemas is OK';
SET @TestDescription = 'Checks that table [security].[DatabaseSchemas] contains the expected number of items';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'SELECT @cnt = COUNT(*)'  + @LineFeed +
            'FROM' + @LineFeed +
            '    [security].[DatabaseSchemas]' + @LineFeed +
            'WHERE ServerName = @@SERVERNAME' + @LineFeed
            ;

BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql, N'@cnt BIGINT OUTPUT', @cnt = @TestReturnValInt OUTPUT ;

    if(@TestReturnValInt <> ${expectedDatabaseSchemasCountAfterSQLMappingsCreation})
    BEGIN
        SET @ErrorMessage = 'Unexpected number of SQL Mappings : ' + CONVERT(VARCHAR,@TestReturnValInt) + '. Expected : ${expectedDatabaseSchemasCountAfterSQLMappingsCreation}';
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

SET @TestID = @TestID + 1 ;
SET @TestName = 'Check All Contacts are defined by these tests';
SET @TestDescription = 'Checks that table [security].[DatabaseSchemas] contains the expected number of items';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'SELECT @cnt = COUNT(*)'  + @LineFeed +
            'FROM' + @LineFeed +
            '    #testContacts' + @LineFeed +
            'WHERE DbuserName is null' + @LineFeed
            ;

BEGIN TRY
    BEGIN TRANSACTION
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql, N'@cnt BIGINT OUTPUT', @cnt = @TestReturnValInt OUTPUT ;

    if(@TestReturnValInt <> 0)
    BEGIN
        SET @ErrorMessage = CONVERT(VARCHAR,@TestReturnValInt) + ' mappings are not well defined by these tests.';
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
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
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
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;
-- ---------------------------------------------------------------------------------------------------------






PRINT ''
PRINT 'Now testing permission assignment definition'
PRINT ''

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[DatabaseRoles] table (active = 1)';
SET @TestDescription = 'inserts a record into the [security].[DatabaseRoles] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[DatabaseRoles]'  + @LineFeed +
            '    (ServerName,DbName,RoleName,isStandard,isActive,Reason)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +
            '    ''${CustomRoleName1}'',' + @LineFeed +
            '    0,' + @LineFeed +            
            '    1,' + @LineFeed +
            '    ''For validation test called "' + @TestName + '"''' + @LineFeed +
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
COMMIT;

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[DatabaseRoles] table (active = 0)';
SET @TestDescription = 'inserts a record into the [security].[DatabaseRoles] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

set @tsql = 'insert into [security].[DatabaseRoles]'  + @LineFeed +
            '    (ServerName,DbName,RoleName,isStandard,isActive,Reason)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +
            '    ''${CustomRoleName2}'',' + @LineFeed +
            '    0,' + @LineFeed +            
            '    0,' + @LineFeed +
            '    ''For validation test called "' + @TestName + '"''' + @LineFeed +
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
COMMIT;

-- ---------------------------------------------------------------------------------------------------------


SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[DatabaseRoleMembers] table (MemberIsRole = 0 ; PermissionLevel = GRANT ; active = 1)';
SET @TestDescription = 'inserts a record into the [security].[DatabaseRoleMembers] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

set @tsql = 'insert into [security].[DatabaseRoleMembers]'  + @LineFeed +
            '    (ServerName,DbName,RoleName,MemberName,MemberIsRole,PermissionLevel,isActive,Reason)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +
            '    ''${CustomRoleName1}'',' + @LineFeed +
            '    ''${LocalSQLLogin1}'',' + @LineFeed +            
            '    0,' + @LineFeed +
            '    ''GRANT'',' + @LineFeed +
            '    1,' + @LineFeed +
            '    ''For validation test called "' + @TestName + '"''' + @LineFeed +
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
COMMIT;

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[DatabaseRoleMembers] table with non-existing Database User.';
SET @TestDescription = 'inserts a record into the [security].[DatabaseRoleMembers] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

set @tsql = 'insert into [security].[DatabaseRoleMembers]'  + @LineFeed +
            '    (ServerName,DbName,RoleName,MemberName,MemberIsRole,PermissionLevel,isActive,Reason)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +
            '    ''${CustomRoleName1}'',' + @LineFeed +
            '    ''${LocalSQLLogin2}'',' + @LineFeed +            
            '    0,' + @LineFeed +
            '    ''REVOKE'',' + @LineFeed +
            '    1,' + @LineFeed +
            '    ''For validation test called "' + @TestName + '"''' + @LineFeed +
            ')' ;          

BEGIN TRY
    BEGIN TRANSACTION
    PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;
    ROLLBACK TRANSACTION 
    
    SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'Trial to add [${LocalSQLLogin2}] (a SQL Login mapped to database user [${DbUserForSQLLogin2}]) as member of a DATABASE Role succeeded. It should never work !'  ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    
END TRY
BEGIN CATCH        
    IF @@TRANCOUNT > 0
    BEGIN 
        ROLLBACK ;
    END 
END CATCH

BEGIN TRAN
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

-- TODO use of a procedure to set appropriate database user in [security].[DatabaseRoleMembers] 
-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[DatabaseRoleMembers] table (MemberIsRole = 0 ; PermissionLevel = GRANT ; active = 0)';
SET @TestDescription = 'inserts a record into the [security].[DatabaseRoleMembers] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

set @tsql = 'insert into [security].[DatabaseRoleMembers]'  + @LineFeed +
            '    (ServerName,DbName,RoleName,MemberName,MemberIsRole,PermissionLevel,isActive,Reason)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +
            '    ''${CustomRoleName1}'',' + @LineFeed +
            '    ''${LocalSQLLogin3}'',' + @LineFeed +            
            '    0,' + @LineFeed +
            '    ''GRANT'',' + @LineFeed +
            '    0,' + @LineFeed +
            '    ''For validation test called "' + @TestName + '"''' + @LineFeed +
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
COMMIT;

-- ---------------------------------------------------------------------------------------------------------

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[DatabaseRoleMembers] table (MemberIsRole = 1 ; PermissionLevel = GRANT ; active = 1)';
SET @TestDescription = 'inserts a record into the [security].[DatabaseRoleMembers] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

SELECT @TmpStringVal = ParamValue 
from [security].ApplicationParams 
where ParamName = 'Separator4OnSchemaStandardRole'

set @tsql = 'insert into [security].[DatabaseRoleMembers]'  + @LineFeed +
            '    (ServerName,DbName,RoleName,MemberName,MemberIsRole,PermissionLevel,isActive,Reason)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    DB_NAME(),' + @LineFeed +
            '    ''${CurrentDB_Schema1}' + @TmpStringVal + 'endusers'',' + @LineFeed +
            '    ''${CustomRoleName1}'',' + @LineFeed +            
            '    0,' + @LineFeed +
            '    ''GRANT'',' + @LineFeed +
            '    0,' + @LineFeed +
            '    ''For validation test called "' + @TestName + '"''' + @LineFeed +
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
COMMIT;

-- ---------------------------------------------------------------------------------------------------------


SET @TestID = @TestID + 1 ;
SET @ProcedureName = 'ManagePermission';
SET @TestName = 'Object permission assignment using [security].[ManagePermission] procedure';
SET @TestDescription = 'check that ' + @ProcedureName + ' procedure exists and call it';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;

PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';

IF( NOT EXISTS (
        select 1
        from sys.all_objects
        where
            SCHEMA_NAME(Schema_ID) COLLATE French_CI_AI = 'security' COLLATE French_CI_AI
        and name COLLATE French_CI_AI = @ProcedureName COLLATE French_CI_AI
    )
)
BEGIN
    select @TmpStringVal = ParamValue 
    from [security].ApplicationParams where ParamName = 'Version'
    
    if(@TmpStringVal <= '0.1.1')
    BEGIN         
        SET @TestResult = 'SKIPPED';
        SET @ErrorMessage = 'No procedure with name [security].[' + @ProcedureName + '] exists in ' + DB_NAME() ;
        PRINT '    > WARNING Test ' + @TestName + ' -> Skipped : ' + @ErrorMessage ;
    END 
    ELSE 
    BEGIN 
        SET @TestResult = 'FAILURE';
        SET @ErrorMessage = 'No procedure with name [security].[' + @ProcedureName + '] exists in ' + DB_NAME() ;
        PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    END 
END
ELSE
BEGIN   
    BEGIN TRY
        BEGIN TRANSACTION
        PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';

        /*
        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME ;' ;
        execute sp_executesql @tsql ;

        SET @CreationWasOK = 1 ;

        -- call it twice to check the edition mode is OK        
        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME ;' ;
        execute sp_executesql @tsql ;
        */
        RAISERROR('Test not yet implemented',12,1);
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
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

-- ---------------------------------------------------------------------------------------------------------






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
        
        if (OBJECT_ID('[security].[${GeneratedScriptBackupTable}]') IS NOT NULL)
        BEGIN 
            execute sp_executesql N'TRUNCATE TABLE [security].[${GeneratedScriptBackupTable}]';
        END 
        
        SET @tsql = 'execute [security].[' + @ProcedureName + '] @ServerName = @@SERVERNAME , @DbName   = NULL , @OutputType = ''SCRIPT'', @OutputSchemaName = ''security'' , @OutputTableName = ''${GeneratedScriptBackupTable}'', @Debug = 1;' ;
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
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

-- ---------------------------------------------------------------------------------------------------------


















-- =========================================================================================================

PRINT ''

if(${NoCleanups} = 0) 
BEGIN 
    PRINT 'Now cleaning up'
    
    if(OBJECT_ID('[security].[${GeneratedScriptBackupTable}]') is not null)
    BEGIN
        execute sp_executesql N'DROP TABLE [security].[${GeneratedScriptBackupTable}]';
    END 

END 
ELSE
BEGIN 
    PRINT 'Skipping cleanup (check script parameters)'
END 
 
PRINT ''

DECLARE @SQLLogin VARCHAR(512) ;












SET @TestID = @TestID + 1 ;
SET @TestName = 'SQLMappings Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[SQLMappings] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = '';

if(${NoCleanups} = 1)
BEGIN
    SET @TestResult = 'SKIPPED'
END

DECLARE getTestContacts CURSOR LOCAL FOR 
    SELECT SQLLogin
    FROM #testContacts ;
    
OPEN getTestContacts ;

FETCH Next From getTestContacts into @SQLLogin ;

SET @TmpIntVal = 0

WHILE @@FETCH_STATUS = 0 and ${NoCleanups} = 0
BEGIN 
    PRINT '    . Removing SQL Mappings for SQL Login ' + QUOTENAME(@SQLLogin) + ' from list for ' + @@SERVERNAME + ' SQL instance';

/*    
    SET @TestID = @TestID + 1 ;
    SET @TestName = 'Deletion of unused SQL Mappings ' + QUOTENAME(@SQLLogin) ;
    SET @TestDescription = 'deletes a record from the [security].[SQLMappings] table';
    SET @TestResult = 'SUCCESS';
    SET @ErrorMessage = NULL ;
*/
    BEGIN TRY 
        if( not exists (
                select 1 
                from [security].[SQLMappings] 
                where ServerName = @@SERVERNAME 
                and SQLLogin = @SQLLogin
            )
        )
        BEGIN            
            BEGIN TRAN ;
            DELETE FROM [security].[SQLMappings] WHERE ServerName = @@SERVERNAME and SqlLogin = @SQLLogin ;            
            COMMIT;
            SET @TmpIntVal = @TmpIntVal + 1;
        END ;
    END TRY 
    BEGIN CATCH         
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK ;
        END
        --SET @ErrorCount = @ErrorCount + 1
        SET @TestResult = 'FAILURE';
        if(LEN(@ErrorMessage) > 0)
            SET @ErrorMessage = @ErrorMessage + @LineFeed
         
        SET @ErrorMessage = @ErrorMessage + 'Deletion of unused SQL Mappings ' + QUOTENAME(@SQLLogin)  + ' : ' + ERROR_MESSAGE() ;
        
        PRINT '        > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    END CATCH     
    
    FETCH Next From getTestContacts into @SQLLogin ;
END ;

CLOSE getTestContacts ;
DEALLOCATE getTestContacts;

if( ${NoCleanups} = 0 and @TmpIntVal <> ${expectedSQLMappingsTotalCount})
BEGIN 
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = @ErrorMessage + 'Unable to delete all expected SQL Mappings' ;
    
    if(LEN(@ErrorMessage) > 0)
        SET @ErrorMessage = @ErrorMessage + @LineFeed
    
    PRINT '        > ERROR Unable to delete all SQL Mappings';        
END 

if(@TestResult = 'FAILURE')
    SET @ErrorCount = @ErrorCount + 1

BEGIN TRAN ;
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;














SET @TestID = @TestID + 1 ;
SET @TestName = 'SQL Logins Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[SQLLogins] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = '';

if(${NoCleanups} = 1)
BEGIN
    SET @TestResult = 'SKIPPED'
END


DECLARE getTestContacts CURSOR LOCAL FOR 
    SELECT SQLLogin
    FROM #testContacts ;
    
OPEN getTestContacts ;

FETCH Next From getTestContacts into @SQLLogin ;

SET @TmpIntVal = 0

WHILE @@FETCH_STATUS = 0 and ${NoCleanups} = 0
BEGIN 
    PRINT '    . Removing SQL Login ' + QUOTENAME(@SQLLogin) + ' from list for ' + @@SERVERNAME + ' SQL instance';
    /*
    SET @TestID = @TestID + 1 ;
    SET @TestName = 'Deletion of unused SQL Login ' + QUOTENAME(@SQLLogin) ;
    SET @TestDescription = 'deletes a record from the [security].[SQLLogins] table';
    SET @TestResult = 'SUCCESS';
    SET @ErrorMessage = NULL ;
*/
    BEGIN TRY 
        if( not exists (
                select 1 
                from [security].[SQLMappings] 
                where ServerName = @@SERVERNAME 
                and SQLLogin = @SQLLogin
            )
        )
        BEGIN 
            BEGIN TRAN 
            DELETE FROM [security].[SQLLogins] WHERE ServerName = @@SERVERNAME and SqlLogin = @SQLLogin ;            
            COMMIT;
            SET @TmpIntVal = @TmpIntVal + 1;
        END ;
    END TRY 
    BEGIN CATCH         
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK ;
        END
        --SET @ErrorCount = @ErrorCount + 1
        SET @TestResult = 'FAILURE';
        if(LEN(@ErrorMessage) > 0)
            SET @ErrorMessage = @ErrorMessage + @LineFeed
         
        SET @ErrorMessage = @ErrorMessage + 'Deletion of unused SQL Login ' + QUOTENAME(@SQLLogin)  + ' : ' + ERROR_MESSAGE() ;
        
        PRINT '        > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    END CATCH    
    
    FETCH Next From getTestContacts into @SQLLogin ;
END ;

CLOSE getTestContacts ;
DEALLOCATE getTestContacts;

if( ${NoCleanups} = 0 and @TmpIntVal <> ${expectedSQLLoginsTotalCount})
BEGIN 
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = @ErrorMessage + 'Unable to delete all expected SQL Logins' ;
    
    if(LEN(@ErrorMessage) > 0)
        SET @ErrorMessage = @ErrorMessage + @LineFeed
    
    PRINT '        > ERROR Unable to delete all SQL Logins';        
END 

if(@TestResult = 'FAILURE')
    SET @ErrorCount = @ErrorCount + 1

BEGIN TRAN    
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;














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
















SET @TestID = @TestID + 1 ;
SET @TestName = 'Contacts Cleanup by T-SQL "DELETE" statement ';
SET @TestDescription = 'Removes Data from [security].[Contacts] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = '';

if(${NoCleanups} = 1)
BEGIN
    SET @TestResult = 'SKIPPED'
END
ELSE
BEGIN
    PRINT 'Removing unused contacts' 
END



DECLARE getTestContacts CURSOR LOCAL FOR 
    SELECT SQLLogin
    FROM #testContacts ;
    
OPEN getTestContacts ;

FETCH Next From getTestContacts into @SQLLogin ;

WHILE @@FETCH_STATUS = 0 and ${NoCleanups} = 0
BEGIN 
    PRINT '    . Removing contact ' + QUOTENAME(@SQLLogin) ;
    /*
    SET @TestID = @TestID + 1 ;
    SET @TestName = 'Deletion of unused contact ' + QUOTENAME(@SQLLogin) ;
    SET @TestDescription = 'deletes a record from the [security].[Contacts] table';
    SET @TestResult = 'SUCCESS';
    SET @ErrorMessage = NULL ;
*/
    BEGIN TRY 
        if( not exists (
                select 1 
                from [security].[SQLLogins] 
                where SQLLogin = @SQLLogin
            )
        )
        BEGIN 
            BEGIN TRAN;
            DELETE FROM [security].[Contacts] WHERE SqlLogin = @SQLLogin ;            
            COMMIT;
        END ;
    END TRY 
    BEGIN CATCH     
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK ;
        END
        --SET @ErrorCount = @ErrorCount + 1
        SET @TestResult = 'FAILURE';
        
        if(LEN(@ErrorMessage) > 0)
            SET @ErrorMessage = @ErrorMessage + @LineFeed
         
        SET @ErrorMessage = @ErrorMessage + 'Deletion of unused contact ' + QUOTENAME(@SQLLogin)  + ' : ' + ERROR_MESSAGE() ;
        
        PRINT '        > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    END CATCH 
    
    FETCH Next From getTestContacts into @SQLLogin ;
END ;

CLOSE getTestContacts ;
DEALLOCATE getTestContacts;


if( ${NoCleanups} = 0 and @TmpIntVal <> ${expectedSQLLoginsTotalCount})
BEGIN 
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = @ErrorMessage + 'Unable to delete all expected SQL Logins' ;
    
    if(LEN(@ErrorMessage) > 0)
        SET @ErrorMessage = @ErrorMessage + @LineFeed
    
    PRINT '        > ERROR Unable to delete all SQL Logins';        
END 

if(@TestResult = 'FAILURE')
    SET @ErrorCount = @ErrorCount + 1

BEGIN TRAN    
INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;


if(${NoCleanups} = 0 and OBJECT_ID('tempdb..#testContacts') is not null)
BEGIN
    execute sp_executesql N'DROP TABLE #testContacts';
END 

-- ---------------------------------------------------------------------------------------------------------










-- =========================================================================================================

PRINT ''
PRINT ''
PRINT '-------------------------------------------------------'

DECLARE @TestCount BIGINT ;
DECLARE @SkippedTestCount BIGINT ;
SELECT @TestCount = count(*) 
from #TestResults 

SELECT @SkippedTestCount = count(*)
FROM #TestResults
WHERE TestResult Collate French_CI_AI = 'SKIPPED' Collate French_CI_AI

if(@SkippedTestCount > 0)
BEGIN 
    PRINT CONVERT(VARCHAR,@SkippedTestCount)  + ' tests were skipped.';
END 
    
if @ErrorCount = 0 
BEGIN 
    PRINT CONVERT(VARCHAR,@TestCount - @SkippedTestCount) + ' / ' + CONVERT(VARCHAR,@TestCount) + ' tests ended successfully.';    
END 
ELSE 
BEGIN 
    PRINT CONVERT(VARCHAR,@TestCount - @SkippedTestCount - @ErrorCount) + ' / ' + CONVERT(VARCHAR,@TestCount) + ' tests ended successfully.';
    PRINT CONVERT(VARCHAR,@ErrorCount) + ' / ' + CONVERT(VARCHAR,@TestCount) + ' tests failed.';
    PRINT 'Please, review code to ensure everything is OK and maybe check the tests...';
END 


PRINT '-------------------------------------------------------'
PRINT ''
PRINT ''

if(OBJECT_ID('tempdb..#testResults') is not null)
BEGIN
    execute sp_executesql N'DROP TABLE #testResults';
END 