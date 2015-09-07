/*requires Schema.Security.sql*/
/*requires Table.security.Contacts.sql*/
/*requires Table.security.ApplicationParams.sql*/
/*requires Procedure.security.UpdateTableWithValues.sql*/



PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'PROCEDURE [security].[ManageContacts]'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[ManageContacts]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [security].[ManageContacts] ( ' +
            ' @ServerName    VARCHAR(512), ' +
            ' @DbName    VARCHAR(50) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   SELECT ''Not implemented'' ' +
            'END') ;

    IF @@ERROR = 0
        PRINT '   PROCEDURE created.';
    ELSE
    BEGIN
        PRINT '   Error while trying to create procedure';
        RETURN;
    END;
END;
GO

ALTER PROCEDURE [security].[ManageContacts] (
    @SQLLogin       VARCHAR(256),
    @ContactName    VARCHAR(MAX),
    @JobTitle       VARCHAR(64)     = 'N/A',
    @isActive       BIT             = 1,
    @Department     VARCHAR(64)     = 'N/A',
    @UseSQLAuth     BIT             = 0,
    @DropOperation  BIT             = 0,
    @Debug			BIT             = 0
)
AS
/*
    This procedure manages the [Contacts] table.

    Example Usage : exec [security].[ManageContacts] @ServerName = 'MyServer1' , @Debug = 1 , @Description = 'Test Server',@AppEnvironment = 'TEST', @PrimaryBU = 'MyCorp/IT/DB'
        Checks :
            SELECT * FROM [security].[Contacts] WHERE ServerName = 'MyServer1'
            SELECT * FROM [security].[SQLDatabases] WHERE ServerName = 'MyServer1'
*/
BEGIN
    SET NOCOUNT ON;

    DECLARE @tsql       NVARCHAR(MAX);
    DECLARE @cnt        TINYINT ;
    DECLARE @tmpStr     VARCHAR(4000);
    DECLARE @tmpStr2    VARCHAR(4000);
    DECLARE @authmode   VARCHAR(64) ;

    --
    -- Drop Operation Required ?
    --
    IF(@DropOperation = 1)
    BEGIN
        IF(@Debug = 1)
        BEGIN
            PRINT 'Contact Deletion Mode';
            PRINT 'TODO Trying to drop login ' + QUOTENAME(@SQLLogin);
        END;
        RAISERROR('Drop Contact not implemented yet',12,1);
        RETURN;
    END;

    --
    -- Getting back Authentication mode String.
    -- 
    
    IF(@UseSQLAuth = 0)
    BEGIN
        SET @tmpStr  = 'SQLServerAuthModeStr' ;
        SET @tmpStr2 = 'SQLSRVR' ;
    END
    ELSE
    BEGIN
        SET @tmpStr  = 'WindowsAuthModeStr' ;
        SET @tmpStr2 = 'WINDOWS' ;
    END;

    SELECT
        @authmode = ISNULL(ParamValue,ISNULL(DefaultValue,@tmpStr2))
    FROM
        security.ApplicationParams
    WHERE
        ParamName = @tmpStr 
    ;
    
    --
    -- Does a Contact with that SQL Login exist ?
    -- Note : 
    --      It's possible for a contact to use multiple SQL Logins for different purposes.
    --
    
    SELECT 
        @cnt = count(*) 
    FROM 
        [security].[Contacts] 
    WHERE 
        SQLLogin = @SQLLogin
    ;

    IF(@cnt = 0)
    BEGIN
        IF(@Debug = 1)
        BEGIN
            PRINT 'There is no documented Contact with SQL Login ' + QUOTENAME(@SQLLogin) + '.';
            PRINT 'New Contact Definition';
        END;

        insert into [security].[Contacts] (
            SqlLogin,Name,job,isActive,Department,authmode
        )
        values (
            @SQLLogin,@ContactName,@JobTitle,@isActive,@Department,@authmode
        );    
    END
    ELSE
    BEGIN
        IF(@Debug = 1)
        BEGIN
            PRINT 'A contact with SQL Login ' + QUOTENAME(@SQLLogin) + ' is documented.' ;
            PRINT 'Contact Update Mode';
        END;
        
        IF(OBJECT_ID('tempdb..##ContactsUpdateValues') IS NOT NULL)
        BEGIN 
            exec sp_executesql N'DROP TABLE ##ContactsUpdateValues;' ;
        END ;

        CREATE TABLE ##ContactsUpdateValues (
            ColumnName          VARCHAR(128), 
            ColumnType          VARCHAR(128), 
            GivenValue          VARCHAR(MAX), 
            ShouldBeWithValue   BIT ,
            IsPartOfWhereClause BIT DEFAULT 0,
            status              BIT DEFAULT 0,
            
            CONSTRAINT [ContactsUpdateValues_pk] PRIMARY KEY (ColumnName)
        ) ;

        insert into ##ContactsUpdateValues (ColumnName , ColumnType , GivenValue , ShouldBeWithValue, IsPartOfWhereClause  )
            SELECT
                'Name','VARCHAR',@ContactName,1,0
            UNION ALL
            SELECT
                'job','VARCHAR',@JobTitle,1,0
            UNION ALL
            SELECT
                'isActive','BIT',CONVERT(VARCHAR,@isActive),1,0
            UNION ALL
            SELECT
                'Department','VARCHAR',@Department,1,0
            UNION ALL
            SELECT
                'authmode','VARCHAR',@authmode,1,0
            UNION ALL
            SELECT
                'SQLLogin','VARCHAR',@SQLLogin,1,1
        ;

        BEGIN TRY 
            SELECT @tmpStr = DB_NAME() ;
            exec [security].[UpdateTableWithValues]
                        @DbName         = @tmpStr, 
                        @SchemaName     = 'security', 
                        @TableName      = 'Contacts', 
                        @ValueTmpTbl    = '##ContactsUpdateValues' ,
                        @Debug          = @Debug
            ;
        END TRY
        BEGIN CATCH 
              DECLARE @ErrorNumber VARCHAR(MAX)  
              DECLARE @ErrorState VARCHAR(MAX)  
              DECLARE @ErrorSeverity VARCHAR(MAX)  
              DECLARE @ErrorLine VARCHAR(MAX)  
              DECLARE @ErrorProc VARCHAR(MAX)  
              DECLARE @ErrorMesg VARCHAR(MAX)  
              DECLARE @vUserName VARCHAR(MAX)  
              DECLARE @vHostName VARCHAR(MAX) 

              SELECT  @ErrorNumber = ERROR_NUMBER()  
                   ,@ErrorState = ERROR_STATE()  
                   ,@ErrorSeverity = ERROR_SEVERITY()  
                   ,@ErrorLine = ERROR_LINE()  
                   ,@ErrorProc = ERROR_PROCEDURE()  
                   ,@ErrorMesg = ERROR_MESSAGE()  
                   ,@vUserName = SUSER_SNAME()  
                   ,@vHostName = Host_NAME()  
        END CATCH ;
        
        IF(OBJECT_ID('tempdb..##ContactsUpdateValues') IS NOT NULL)
        BEGIN 
            DROP TABLE ##ContactsUpdateValues;
        END ;

    END

END;
GO

IF @@ERROR = 0
    PRINT '   PROCEDURE altered.'
ELSE
BEGIN
    PRINT '   Error while trying to alter procedure'
    RETURN
END




PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''
