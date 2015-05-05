set :SolutionName "Security Manager" 
set :DomainName   "CHULg"
set :DomainUser1  "SAI_Db"
set :DomainUser2  "c168350"

/*

Find and replace : 

${SolutionName} "Security Manager" 
${DomainName}   "CHULg"
${DomainUser1}  "SAI_Db"
${DomainUser2}  "c168350"

*/

SET NOCOUNT ON;

DECLARE @TestID             BIGINT ;
DECLARE @TestName           VARCHAR(1024);
DECLARE @TestDescription    NVARCHAR(MAX);
DECLARE @TestResult         VARCHAR(16);
DECLARE @ErrorMessage       NVARCHAR(MAX);
DECLARE @tsql               NVARCHAR(MAX);
DECLARE @LineFeed           VARCHAR(10) ;
DECLARE @ErrorCount         BIGINT ;

SET @LineFeed = CHAR(13) + CHAR(10);
SET @ErrorCount = 0;

PRINT 'Starting testing for solution ${SolutionName}';
PRINT '' ;

PRINT 'Creating temporary table in which tests results will be stored';

CREATE TABLE #testResults (
    TestID          BIGINT          NOT NULL ,
    TestName        VARCHAR(1024)   NOT NULL ,
    TestDescription NVARCHAR(MAX),
    TestResult      VARCHAR(16)     NOT NULL,
    ErrorMessage    NVARCHAR(MAX)
);


PRINT 'Creating temporary table in which created Contacts will be stored' ;

CREATE TABLE #testContacts (
    SQLLogin VARCHAR(512) NOT NULL 
) ;




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
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) ;
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
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) ;
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
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) ;
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



PRINT '    > Now testing SQL Login definition for server'

SET @TestID = @TestID + 1 ;
SET @TestName = 'Creation by INSERT statement into [security].[SQLLogins] table (active = 1)';
SET @TestDescription = 'inserts a record into the [security].[SQLLogins] table';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


set @tsql = 'insert into [security].[SQLLogins]'  + @LineFeed +
            '    (ServerName,SqlLogin,isActive)' + @LineFeed +
            'values (' + @LineFeed +
            '    @@SERVERNAME,' + @LineFeed +
            '    ''ApplicationSQLUser1'',' + @LineFeed +
            '    1,' + @LineFeed 
            ')' ;

BEGIN TRANSACTION             
BEGIN TRY
	PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) ;
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
    DECLARE @CreationWasOK BIT
    SET @CreationWasOK = 0 ;   
    
    BEGIN TRANSACTION             
    BEGIN TRY
        PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) ;
        
        SET @tsql = 'execute [security].[setServerAccess] @ServerName = @@SERVERNAME , @ContactLogin = ''${DomainName}\${DomainUser1}'' , @isActive = 1 ;' ;
        execute sp_executesql @tsql ;
        
        SET @CreationWasOK = 1 ;
        
        -- call it twice to check the edition mode is OK
        SET @tsql = 'execute [security].[setServerAccess] @ServerName = @@SERVERNAME , @ContactLogin = ''${DomainName}\${DomainUser1}'' , @isActive = 0;' ;
        execute sp_executesql @tsql ;
    END TRY 
    BEGIN CATCH
        SET @ErrorCount = @ErrorCount + 1;
        SET @TestResult = 'FAILURE';
        SET @ErrorMessage = ERROR_MESSAGE() ;
        PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ') + ' | @CreationWasOK = ' + CONVERT(VARCHAR,@CreationWasOK);
    END CATCH 
    COMMIT TRANSACTION;
END 

INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );

-- ---------------------------------------------------------------------------------------------------------






-- =========================================================================================================

PRINT ''
PRINT 'Now cleaning up'
PRINT ''

DECLARE @SQLLogin VARCHAR(512) ;



DECLARE getTestContacts CURSOR LOCAL FOR 
    SELECT SQLLogin
    FROM #testContacts ;
    
OPEN getTestContacts ;

FETCH Next From getTestContacts into @SQLLogin ;

WHILE @@FETCH_STATUS = 0
BEGIN 
    PRINT '    . Removing SQL Login ' + QUOTENAME(@SQLLogin) ;
    
    SET @TestID = @TestID + 1 ;
    SET @TestName = 'Deletion of unused SQL Login ' + QUOTENAME(@SQLLogin) ;
    SET @TestDescription = 'deletes a record from the [security].[SQLLogins] table';
    SET @TestResult = 'SUCCESS';
    SET @ErrorMessage = NULL ;

    BEGIN TRY 
        if( not exists (
                select 1 
                from [security].[SQLMappings] 
                where ServerName = @@SERVERNAME 
                and SQLLogin = @SQLLogin
            )
        )
        BEGIN 
            DELETE FROM [security].[SQLLogin] WHERE ServerName = @@SERVERNAME and SqlLogin = @SQLLogin ;            
        END ;
    END TRY 
    BEGIN CATCH         
        SET @ErrorCount = @ErrorCount + 1
        SET @TestResult = 'FAILURE';
        SET @ErrorMessage = ERROR_MESSAGE() ;
        PRINT '        > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    END CATCH 
    
    INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
    
    
    FETCH Next From getTestContacts into @SQLLogin ;
END ;

CLOSE getTestContacts ;
DEALLOCATE getTestContacts;




PRINT 'Removing unused contacts' 

DECLARE getTestContacts CURSOR LOCAL FOR 
    SELECT SQLLogin
    FROM #testContacts ;
    
OPEN getTestContacts ;

FETCH Next From getTestContacts into @SQLLogin ;

WHILE @@FETCH_STATUS = 0
BEGIN 
    PRINT '    . Removing contact ' + QUOTENAME(@SQLLogin) ;
    
    SET @TestID = @TestID + 1 ;
    SET @TestName = 'Deletion of unused contact ' + QUOTENAME(@SQLLogin) ;
    SET @TestDescription = 'deletes a record from the [security].[Contacts] table';
    SET @TestResult = 'SUCCESS';
    SET @ErrorMessage = NULL ;

    BEGIN TRY 
        if( not exists (
                select 1 
                from [security].[SQLLogins] 
                where SQLLogin = @SQLLogin
            )
        )
        BEGIN 
            DELETE FROM [security].[Contacts] WHERE SqlLogin = @SQLLogin ;            
        END ;
    END TRY 
    BEGIN CATCH         
        SET @ErrorCount = @ErrorCount + 1
        SET @TestResult = 'FAILURE';
        SET @ErrorMessage = ERROR_MESSAGE() ;
        PRINT '        > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    END CATCH 
    
    INSERT into #testResults values (@TestID , @TestName , @TestDescription, @TestResult , @ErrorMessage );
    
    
    FETCH Next From getTestContacts into @SQLLogin ;
END ;

CLOSE getTestContacts ;
DEALLOCATE getTestContacts;



if(OBJECT_ID('tempdb..#testContacts') is not null)
BEGIN
    execute sp_executesql N'DROP TABLE #testContacts';
END 

-- ---------------------------------------------------------------------------------------------------------




-- =========================================================================================================

PRINT ''
PRINT ''
PRINT '-------------------------------------------------------'

DECLARE @TestCount BIGINT ;

SELECT @TestCount = count(*) 
from #TestResults 

if @ErrorCount = 0
BEGIN 
    PRINT 'All tests (' + @TestCount + ' / ' + @TestCount + ') ended successfully';
END 
ELSE 
BEGIN 
    PRINT CONVERT(VARCHAR,@ErrorCount) + ' / ' + @TestCount + ' tests were unsuccessful';
    PRINT 'Please, review code to ensure everything is OK and maybe check the tests...';
END 


PRINT '-------------------------------------------------------'
PRINT ''
PRINT ''

if(OBJECT_ID('tempdb..#testResults') is not null)
BEGIN
    execute sp_executesql N'DROP TABLE #testResults';
END 