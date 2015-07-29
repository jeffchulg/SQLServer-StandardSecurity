/*requires Schema.Security.sql*/
/*requires Table.Contacts.sql*/
/*requires Table.ApplicationParams.sql*/



PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'PROCEDURE [security].[ManageContacts]'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[ManageContacts]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [security].[ManageContacts] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   SELECT ''Not implemented'' ' +
            'END')
            
    IF @@ERROR = 0
        PRINT '   PROCEDURE created.'
    ELSE
    BEGIN
        PRINT '   Error while trying to create procedure'
        RETURN
    END        
END
GO

ALTER PROCEDURE [security].[ManageContacts] (
    @SQLLogin       VARCHAR(256),
    @ContactName    VARCHAR(MAX),
    @JobTitle       VARCHAR(64) = 'N/A',
    @isActive       BIT = 1,
    @Department     VARCHAR(64) = 'N/A',
    @UseSQLAuth     BIT = 0,
    @DropLogin      BIT = 0,
    @Debug			BIT = 0
)
AS 
/*
    Example Usage : exec [security].[ManageContacts] @ServerName = 'MyServer1' , @Debug = 1 , @Description = 'Test Server',@AppEnvironment = 'TEST', @PrimaryBU = 'MyCorp/IT/DB'
        Checks : 
            select * from [security].[Contacts] where ServerName = 'MyServer1'
            select * from [security].[SQLDatabases] where ServerName = 'MyServer1'
*/  
BEGIN 
    SET NOCOUNT ON;
    
    declare @tsql NVARCHAR(MAX);
    declare @cnt  TINYINT ;
    DECLARE @authmode VARCHAR(64) ;

    if(@DropLogin = 1) 
    BEGIN 
        if(@Debug = 1) 
        BEGIN 
            PRINT 'TODO Trying to drop login ' + QUOTENAME(@SQLLogin) 
        END     
        RETURN
    END 
    
    if(@UseSQLAuth = 0) 
    BEGIN 
        select 
            @authmode = ISNULL(ParamValue,ISNULL(DefaultValue,'SQLSRVR')) 
        from 
            security.ApplicationParams
        where 
            ParamName = 'SQLServerAuthModeStr';
    END
    ELSE 
    BEGIN 
        select 
            @authmode = ISNULL(ParamValue,ISNULL(DefaultValue,'WINDOWS')) 
        from 
            security.ApplicationParams
        where 
            ParamName = 'WindowsAuthModeStr';
    END 
    
    select @cnt = count(*) from [security].[Contacts] where SQLLogin = @SQLLogin
    
    if(@cnt = 0) 
    BEGIN 
        if(@Debug = 1) 
        BEGIN 
            PRINT 'No documented SQL login "' + @SQLLogin + '".'
        END 
        
        insert into [security].[Contacts] (
            SqlLogin,Name,job,isActive,Department,authmode
        )
        values (
            @SQLLogin,@ContactName,@JobTitle,@isActive,@Department,@authmode
        )
    END 
    ELSE 
    BEGIN 
        if(@Debug = 1) 
        BEGIN 
            PRINT 'A contact with name "' + @SQLLogin + '" is documented. Updating informations (if necessary)'
        END 
        
        DECLARE @UpdateValues TABLE (ColumnName Varchar(128), ColumnType Varchar(128), GivenValue varchar(MAX), ShouldBeWithValue BIT ) ;
        
        insert into @UpdateValues (ColumnName , ColumnType , GivenValue , ShouldBeWithValue  )
            select 
                'Name','VARCHAR',@ContactName,1
            UNION ALL 
            select 
                'job','VARCHAR',@JobTitle,1
            UNION ALL 
            select 
                'isActive','BIT',CONVERT(VARCHAR,@isActive),1
            UNION ALL 
            select 
                'Department','VARCHAR',@Department,1
            UNION ALL 
            select 
                'authmode','VARCHAR',@authmode,1
        ;
        
        
        DECLARE getUpdateValues CURSOR FOR  
            select * from @UpdateValues; 
        
        DECLARE @CurColName     VARCHAR(128) ;
        DECLARE @CurColType     VARCHAR(128);
        DECLARE @varcharVal     VARCHAR(MAX);
        DECLARE @CurSBWV        BIT; -- current should be with value 
        DECLARE @datetimeVal    DATETIME;        
        DECLARE @bitVal         BIT;        
        
        
        OPEN getUpdateValues  ;
        
        FETCH NEXT from getUpdateValues
            INTO @CurColName , @CurColType , @varcharVal, @CurSBWV ;
        
        
        WHILE (@@FETCH_STATUS = 0) 
        BEGIN 
        
            if(@CurSBWV = 1 and @varcharVal is not null and @varcharVal <> 'N/A') 
            BEGIN 
                SET @tsql = 'update [security].[Contacts] SET ' + QUOTENAME(@CurColName) + ' = @ColumnValue WHERE SQLLogin = @SQLLogin' ;
                
                if(@CurColType = 'VARCHAR') 
                BEGIN 
                    exec sp_executesql @tsql , N'@ColumnValue VARCHAR(MAX), @SQLLogin VARCHAR(1024)', @varcharVal, @SQLLogin
                END 
                ELSE IF (@CurColType = 'DATETIME') 
                BEGIN 
                    SET @datetimeVal = convert(DATETIME, @varcharVal, 21)
                    exec sp_executesql @tsql , N'@ColumnValue DATETIME, @SQLLogin VARCHAR(1024)' , @datetimeVal , @SQLLogin
                END 
                ELSE IF (@CurColType = 'BIT') 
                BEGIN 
                    SET @bitVal = convert(bit, @varcharVal)
                    exec sp_executesql @tsql , N'@ColumnValue BIT, @SQLLogin VARCHAR(1024)' , @bitVal , @SQLLogin
                END 
                ELSE 
                BEGIN 
                    SET @varcharVal = 'Column type ' + @CurColType + 'not handled by procedure !'
                    raiserror (@varcharVal,10,1)
                END 
                if(@Debug = 1) 
                BEGIN 
                    PRINT '  > Column ' + @CurColName + ' updated.'
                END  
            END 
            else if (@CurSBWV = 1 and @varcharVal is null) 
            BEGIN 
                if(@Debug = 1) 
                BEGIN 
                    PRINT '  > No changes made to column ' + @CurColName
                END             
            END 
            ELSE 
            BEGIN 
                raiserror ('Case where there is the need to reset a column is not handled by procedure !',10,1)
            END 
            
            FETCH NEXT from getUpdateValues
                INTO @CurColName , @CurColType , @varcharVal, @CurSBWV ;
        END 
        
        CLOSE getUpdateValues;
        DEALLOCATE getUpdateValues ;

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
