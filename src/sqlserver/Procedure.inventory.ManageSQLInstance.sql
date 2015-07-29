/*requires Schema.Inventory.sql*/
/*requires Table.inventory.SQLInstances.sql*/
/*requires Table.inventory.SQLDatabases.sql*/



PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'PROCEDURE [inventory].[ManageSQLInstance]'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[inventory].[ManageSQLInstance]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [inventory].[ManageSQLInstance] ( ' +
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

ALTER PROCEDURE [inventory].[ManageSQLInstance] (
    @ServerName         VARCHAR(256),
    @Description        VARCHAR(MAX) = NULL,
    @AppEnvironment     VARCHAR(16)  = NULL,
    @ServerCollation    VARCHAR(128) = NULL,
    @PrimaryBU          VARCHAR(256) = NULL,
    @ServerCreationDate DATETIME     = NULL,
    @SQLVersion         VARCHAR(256) = NULL,
    @SQLEdition         VARCHAR(256) = NULL,
    @Debug              BIT = 0
)
AS 
/*
    Example Usage : exec [inventory].[ManageSQLInstance] @ServerName = 'MyServer1' , @Debug = 1 , @Description = 'Test Server',@AppEnvironment = 'TEST', @PrimaryBU = 'MyCorp/IT/DB'
        Checks : 
            select * from [inventory].[SQLInstances] where ServerName = 'MyServer1'
            select * from [inventory].[SQLDatabases] where ServerName = 'MyServer1'
*/  
BEGIN 
    SET NOCOUNT ON;
    
    declare @tsql NVARCHAR(MAX);
    declare @cnt  TINYINT ;
    
    -- sanitize input 
    SELECT  
        @ServerName = upper(@ServerName),
        @AppEnvironment = upper(@AppEnvironment)
    ;
    
    select @cnt = count(*) from [inventory].[SQLInstances] where ServerName = @ServerName
    
    if(@cnt = 0) 
    BEGIN 
        if(@Debug = 1) 
        BEGIN 
            PRINT 'No documented server "' + @ServerName + '".'
        END 
        
        insert into [inventory].[SQLInstances] (
            ServerName,Description,AppEnvironment,ServerCollation,PrimaryBU,ServerCreationDate,SQLVersion,SQLEdition
        )
        values (
            @ServerName,@Description,@AppEnvironment,@ServerCollation,@PrimaryBU,@ServerCreationDate,@SQLVersion,@SQLEdition
        )
    END 
    ELSE 
    BEGIN 
        if(@Debug = 1) 
        BEGIN 
            PRINT 'A server with name "' + @ServerName + '" is documented. Updating informations'
        END 
        
        DECLARE @UpdateValues TABLE (ColumnName Varchar(128), ColumnType Varchar(128), GivenValue varchar(MAX), ShouldBeWithValue BIT ) ;
        
        insert into @UpdateValues (ColumnName , ColumnType , GivenValue , ShouldBeWithValue  )
            select 
                'Description','VARCHAR',@Description,1
            UNION ALL 
            select 
                'AppEnvironment','VARCHAR',@AppEnvironment,1
            UNION ALL 
            select 
                'ServerCollation','VARCHAR',@ServerCollation,1
            UNION ALL 
            select 
                'PrimaryBU','VARCHAR',@PrimaryBU,1
            UNION ALL 
            select 
                'ServerCreationDate','DATETIME',convert(varchar(256), @ServerCreationDate, 21),1
            UNION ALL 
            select 
                'SQLVersion','VARCHAR',@SQLVersion,1
            UNION ALL 
            select 
                'SQLEdition','VARCHAR',@SQLEdition,1
        ;
        
        
        DECLARE getUpdateValues CURSOR FOR  
            select * from @UpdateValues; 
        
        DECLARE @CurColName     VARCHAR(128) ;
        DECLARE @CurColType     VARCHAR(128);
        DECLARE @varcharVal     VARCHAR(MAX);
        DECLARE @CurSBWV        BIT; -- current should be with value 
        DECLARE @datetimeVal    DATETIME;        
        
        
        OPEN getUpdateValues  ;
        
        FETCH NEXT from getUpdateValues
            INTO @CurColName , @CurColType , @varcharVal, @CurSBWV ;
        
        
        WHILE (@@FETCH_STATUS = 0) 
        BEGIN 
        
            if(@CurSBWV = 1 and @varcharVal is not null) 
            BEGIN 
                SET @tsql = 'update [inventory].[SQLInstances] SET ' + QUOTENAME(@CurColName) + ' = @ColumnValue WHERE ServerName = @ServerName' ;
                
                if(@CurColType = 'VARCHAR') 
                BEGIN 
                    exec sp_executesql @tsql , N'@ColumnValue VARCHAR(MAX), @ServerName VARCHAR(1024)', @varcharVal, @ServerName
                END 
                ELSE IF (@CurColType = 'DATETIME') 
                BEGIN 
                    SET @datetimeVal = convert(DATETIME, @varcharVal, 21)
                    exec sp_executesql @tsql , N'@ColumnValue DATETIME, @ServerName VARCHAR(1024)' , @datetimeVal , @ServerName
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
    
    -- declaring system databases list
    if(@Debug = 1) 
    BEGIN 
        PRINT 'Now managing system databases creation "' + @ServerName + '".'
    END     
    
    MERGE [inventory].[SQLDatabases] t
    using ( 
        SELECT @ServerName as ServerName, 'master' as DbName UNION ALL 
        SELECT @ServerName ,'msdb' UNION ALL 
        SELECT @ServerName ,'tempdb' UNION ALL
        SELECT @ServerName ,('model')
    ) i
    on 
        t.ServerName = i.ServerName
    and t.DbName     = i.DbName
    WHEN NOT MATCHED BY TARGET THEN 
        insert (ServerName,DbName, isUserDatabase,Reason, Comments)
        values (i.ServerName,i.DbName , 0, 'SQL Server system database', 'Added automatically by [inventory].[ManageSQLInstance] procedure')
    ;
    
    
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
