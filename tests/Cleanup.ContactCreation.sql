/*requires main.sql*/
/*requires cleanups.sql */
/*requires Cleanup.LoginCreation.sql */


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