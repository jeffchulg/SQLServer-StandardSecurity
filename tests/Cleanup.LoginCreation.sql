/*requires main.sql*/
/*requires Tests.LoginCreation.sql*/
/*requires cleanups.sql */

DECLARE getTestContacts CURSOR LOCAL FOR 
    SELECT SQLLogin
    FROM #testContacts ;
    
OPEN getTestContacts ;

FETCH Next From getTestContacts into @SQLLogin ;

WHILE @@FETCH_STATUS = 0
BEGIN 
    PRINT '    . Removing SQL Login ' + QUOTENAME(@SQLLogin) + ' from list for ' + @@SERVERNAME + ' SQL instance';
    
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
            DELETE FROM [security].[SQLLogins] WHERE ServerName = @@SERVERNAME and SqlLogin = @SQLLogin ;            
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