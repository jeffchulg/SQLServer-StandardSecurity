/*requires Table.TestResults.sql*/
/*requires Table.TestContacts.sql*/
/*requires Tests.Start.sql*/
/*requires Tests.ContactCreation.sql*/
/*requires Tests.LoginCreation.sql*/
/*requires Tests.SQLMappingsCreation.sql*/
/*requires Tests.GenerateStandardRoles.sql*/

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
            '    ''$(CustomRoleName1)'',' + @LineFeed +
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
    SET @ErrorCount = @ErrorCount + 1;
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
            '    ''$(CustomRoleName2)'',' + @LineFeed +
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
    SET @ErrorCount = @ErrorCount + 1;
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
            '    ''$(CustomRoleName1)'',' + @LineFeed +
            '    ''$(LocalSQLLogin1)'',' + @LineFeed +            
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
    SET @ErrorCount = @ErrorCount + 1;
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
            '    ''$(CustomRoleName1)'',' + @LineFeed +
            '    ''$(LocalSQLLogin4)'',' + @LineFeed +            
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
    
    SET @ErrorCount = @ErrorCount + 1;
    SET @TestResult = 'WARN';
    SET @ErrorMessage = 'MISSING CHECK - Trial to add [$(LocalSQLLogin4)] (a SQL Login mapped to database user [$(LocalSQLLogin4)]) as member of a DATABASE Role ($(CustomRoleName1)) succeeded. It should never work as this database user should have not been created (the mapping is done with another username)!'  ;
    PRINT '    > WARNING -' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    
END TRY
BEGIN CATCH        
    IF @@TRANCOUNT > 0
    BEGIN 
        ROLLBACK ;
    END 
END CATCH

BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
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
            '    ''$(CustomRoleName1)'',' + @LineFeed +
            '    ''$(LocalSQLLogin3)'',' + @LineFeed +            
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
    SET @ErrorCount = @ErrorCount + 1;
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
            '    ''$(CurrentDB_Schema1)' + @TmpStringVal + 'endusers'',' + @LineFeed +
            '    ''$(CustomRoleName1)'',' + @LineFeed +            
            '    1,' + @LineFeed +
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
    SET @ErrorCount = @ErrorCount + 1;
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

SET @TestID = @TestID + 1 ;
SET @TestName = 'Expected failed creation by INSERT statement into [security].[DatabaseRoleMembers] table (MemberIsRole = 0 ; PermissionLevel = GRANT ; active = 1)';
SET @TestDescription = 'Tries to insert a record into the [security].[DatabaseRoleMembers] table with a member which is a Role and MemberIsRole parameter set inappropriately.' ;
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
            '    ''$(CurrentDB_Schema1)' + @TmpStringVal + 'endusers'',' + @LineFeed +
            '    ''$(CustomRoleName1)'',' + @LineFeed +            
            '    1,' + @LineFeed +
            '    ''GRANT'',' + @LineFeed +
            '    0,' + @LineFeed +
            '    ''For validation test called "' + @TestName + '"''' + @LineFeed +
            ')' ;

BEGIN TRY
    BEGIN TRANSACTION
    PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';
    execute sp_executesql @tsql ;
	SET @ErrorCount = @ErrorCount + 1;
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = 'Able to add a member which is a database role as a database user' ;
    PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')
    IF @@TRANCOUNT > 0
    BEGIN 
        ROLLBACK ;
    END     
END TRY
BEGIN CATCH    
	IF @@TRANCOUNT > 0
    BEGIN 
        COMMIT ;
    END     
END CATCH

BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
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
        SET @ErrorCount = @ErrorCount + 1;
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