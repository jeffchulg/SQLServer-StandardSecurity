/*requires Schema.Security.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[UpdateTableWithValues] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[UpdateTableWithValues]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [security].[UpdateTableWithValues] ( ' +
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


ALTER PROCEDURE [security].[UpdateTableWithValues] (
    @DbName         VARCHAR(128) = DB_NAME,
    @SchemaName     VARCHAR(128) = 'dbo',
    @TableName      VARCHAR(128),
    @ValueTmpTbl    VARCHAR(256),
    @Debug          BIT = 0
)
AS
/*
  ===================================================================================
    DESCRIPTION:

    ARGUMENTS :

    REQUIREMENTS:

    EXAMPLE USAGE :


   ==================================================================================
    NOTES:
    AUTHORS:
        .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
        .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
        .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)

    COMPANY: CHU Liege
  ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    
    DECLARE @cnt                BIGINT;
    DECLARE @tsql               NVARCHAR(MAX);
    DECLARE @tmpStr             VARCHAR(MAX);
    DECLARE @DestinationTable   VARCHAR(1024);
    DECLARE @LineFeed           VARCHAR(2);

    SET @LineFeed = CHAR(13) + CHAR(10);
    SET @DestinationTable = '';
    
    IF(@Debug = 1)
    BEGIN     
        PRINT 'Build destination table complete name and Validate the destination table exists';
    END ;
    
    if(LEN(@DbName) > 0)
    BEGIN 
        SET @DestinationTable = QUOTENAME(@DbName) + '.' ;
    END ;
    
    if(LEN(@SchemaName) > 0)
    BEGIN         
        SET @DestinationTable = @DestinationTable + QUOTENAME(@SchemaName) + '.' ;
    END 
    ELSE 
    BEGIN 
        -- (default schema)
        IF(LEN(@DestinationTable) > 0) -- the database has beeen specified.
        BEGIN 
            SET @DestinationTable = @DestinationTable + '.';
        END ;
    END;    
    
    if(LEN(@TableName) > 0)
    BEGIN         
        SET @DestinationTable = @DestinationTable + QUOTENAME(@TableName);
    END 
    ELSE 
    BEGIN 
        SET @tmpStr = 'One or more provided parameters about the destination table is/are NULL or empty.';
        RAISERROR(@tmpStr, 12,1);
        RETURN;
    END;

    if(@Debug = 1) 
    BEGIN 
        PRINT 'Generated Destination Table : ' + isnull(@DestinationTable,'N/A');
    END ;
    
    IF(OBJECT_ID(@DestinationTable) IS NULL)
    BEGIN 
        SET @tmpStr = 'Table called ' + @DestinationTable + ' not found.';
        RAISERROR(@tmpStr, 12,1);
        RETURN;
    END ;
    
    if(@Debug = 1)
    BEGIN 
        PRINT 'Validate table @ValueTmpTbl' ;
    END 
    
    -- Object exists ?
    IF(OBJECT_ID('tempdb..' + @ValueTmpTbl) IS NULL)
    BEGIN
        SET @tmpStr = 'No temporary table called ' + QUOTENAME(@ValueTmpTbl) + ' exists in tempdb.';
        RAISERROR(@tmpStr, 12,1);
        RETURN;
    END;
    
    if(@Debug = 1)
    BEGIN 
        PRINT 'The temporary table exists.' ;
    END;     
        
        -- Mandatory columns exists ?
    select @cnt = sum(1)
    from 
        tempdb.sys.columns
    where 
        object_id = OBJECT_ID('tempdb..' + @ValueTmpTbl)
    and name in ('ColumnName','ColumnType','GivenValue','ShouldBeWithValue','IsPartOfWhereClause','status');
    
    if(@cnt is null or @cnt <> 6) 
    BEGIN 
        SET @tmpStr = 'Provided temporary table called ' + QUOTENAME(@ValueTmpTbl) + ' exists in tempdb but contains ' + CONVERT(VARCHAR,@cnt) + '/6 expected columns.' + @LineFeed + 
                      'Expected columns : ColumnName,ColumnType,GivenValue,ShouldBeWithValue,IsPartOfWhereClause,status';
        
        RAISERROR(@tmpStr, 12,1);
        RETURN;
    END ;
    
    if(@Debug = 1)
    BEGIN 
        PRINT 'The temporary table has the mandatory columns.' ;
    END;     
    
    if(@Debug = 1)
    BEGIN 
        PRINT 'Building the WHERE clause.' ;
    END; 
        
    DECLARE @WhereClause    VARCHAR(MAX);
    DECLARE @CurColName     VARCHAR(128) ;
    DECLARE @CurColType     VARCHAR(128);
    DECLARE @varcharVal     VARCHAR(MAX);
    DECLARE @CurSBWV        BIT; -- current should be with value
    
    SET @WhereClause = '    1 = 1';
    DECLARE @LoopExitRequired BIT ;
    
    SET @LoopExitRequired = 0;
    
    WHILE (@LoopExitRequired = 0) 
    BEGIN
        SET @tsql = 'SELECT TOP 1 @CurColName = ColumnName, @CurColType = ColumnType, @varcharVal = GivenValue, @CurSBWV = ShouldBeWithValue FROM ' + QUOTENAME(@ValueTmpTbl) + ' where [status] = 0 and IsPartOfWhereClause = 1';
        SET @CurColName = NULL;
        SET @CurColType = NULL;
        SET @varcharVal = NULL;
        SET @CurSBWV    = NULL; 
        exec sp_executesql 
            @tsql , 
            N'@CurColName VARCHAR(128) OUTPUT,@CurColType VARCHAR(128) OUTPUT,@varcharVal VARCHAR(MAX) OUTPUT, @CurSBWV BIT OUTPUT',
            @CurColName = @CurColName OUTPUT, 
            @CurColType = @CurColType OUTPUT, 
            @varcharVal = @varcharVal OUTPUT, 
            @CurSBWV    = @CurSBWV    OUTPUT;
        
        if(@CurColName is null)
        BEGIN 
            SET @LoopExitRequired = 1;
        END
        ELSE 
        BEGIN 
            
            SET @WhereClause = @WhereClause + @LineFeed + 
                               'AND ' + QUOTENAME(@CurColName) + ' = ' ;
            IF(@CurColType <> 'VARCHAR')
            BEGIN 
                SET @WhereClause = @WhereClause + 
                                   'CONVERT(' + @CurColType + ','''+ @varcharVal + ''')' ;
            END 
            ELSE
            BEGIN 
                SET @WhereClause = @WhereClause + '''' + @varcharVal + '''' ;
            END 
            
            SET @tsql = 'UPDATE ' + @ValueTmpTbl + ' SET [status] = 1 WHERE ColumnName = @ColName' ;
            exec sp_executesql @tsql , N'@ColName VARCHAR(128)', @ColName = @CurColName ;
        END ;
    END ;
    
    IF (@Debug = 1) 
    BEGIN   
        PRINT '/*' + @LineFeed + 
              '  WHERE clause: ' + @LineFeed + 
              @WhereClause  + @LineFeed  + '*/';
    END 
    
    --
    -- Now we can run the code to update the table
    -- 
       
    DECLARE @datetimeVal    DATETIME;
    DECLARE @bitVal         BIT;

    SET @tsql = 'SELECT TOP 1 @CurColName = ColumnName, @CurColType = ColumnType, @varcharVal = GivenValue, @CurSBWV = ShouldBeWithValue FROM ' + @ValueTmpTbl + ' where [status] = 0 and IsPartOfWhereClause = 0';    
    
    SET @LoopExitRequired = 0;
    WHILE ( @LoopExitRequired = 0 )
    BEGIN
        SET @tsql = 'SELECT TOP 1 @CurColName = ColumnName, @CurColType = ColumnType, @varcharVal = GivenValue, @CurSBWV = ShouldBeWithValue FROM ' + @ValueTmpTbl + ' where [status] = 0 and IsPartOfWhereClause = 0';    
        
        SET @CurColName = NULL;
        SET @CurColType = NULL;
        SET @varcharVal = NULL;
        SET @CurSBWV    = NULL; 
        
        exec sp_executesql 
            @tsql , 
            N'@CurColName VARCHAR(128) OUTPUT,@CurColType VARCHAR(128) OUTPUT,@varcharVal VARCHAR(MAX) OUTPUT, @CurSBWV BIT OUTPUT',
            @CurColName = @CurColName OUTPUT, 
            @CurColType = @CurColType OUTPUT, 
            @varcharVal = @varcharVal OUTPUT, 
            @CurSBWV    = @CurSBWV    OUTPUT;
            
            
        if(@CurColName is null)
        BEGIN 
            SET @LoopExitRequired = 1;
        END
        ELSE 
        BEGIN 
            if(@Debug = 1) 
            BEGIN 
                PRINT '  . Column Name   : ' + @CurColName ; 
                PRINT '  . Column Type   : ' + @CurColType ; 
                PRINT '  . Column Value  : ' + isnull(@varcharVal,'N/A') ; 
                PRINT '  . Column should : ' + CONVERT(VARCHAR,@CurSBWV) ; 
            END ;
            
            IF(@CurSBWV = 1 and @varcharVal is not null and @varcharVal <> 'N/A')
            BEGIN
                SET @tsql = 'update ' + @DestinationTable + ' SET ' + QUOTENAME(@CurColName) + ' = @ColumnValue ' + 'WHERE ' + @WhereClause ;

                IF(@CurColType = 'VARCHAR')
                BEGIN
                    exec sp_executesql @tsql , N'@ColumnValue VARCHAR(MAX)', @varcharVal;
                END
                ELSE IF (@CurColType = 'DATETIME')
                BEGIN
                    SET @datetimeVal = convert(DATETIME, @varcharVal, 21)
                    exec sp_executesql @tsql , N'@ColumnValue DATETIME' , @datetimeVal 
                END
                ELSE IF (@CurColType = 'BIT')
                BEGIN
                    SET @bitVal = convert(bit, @varcharVal)
                    exec sp_executesql @tsql , N'@ColumnValue BIT' , @bitVal 
                END
                ELSE
                BEGIN
                    SET @varcharVal = 'Column type ' + @CurColType + 'not handled by procedure !'
                    raiserror (@varcharVal,10,1)
                END
                IF(@Debug = 1)
                BEGIN
                    PRINT '  > Column ' + @CurColName + ' updated.'
                END
            END
            else IF (@CurSBWV = 1 and (@varcharVal is null or @varcharVal = 'N/A'))
            BEGIN
                IF(@Debug = 1)
                BEGIN
                    PRINT '  > No changes made to column ' + @CurColName
                END
            END
            ELSE
            BEGIN
                raiserror ('Case WHERE there is the need to reset a column is not handled by procedure !',10,1)
            END
            
            SET @tsql = 'UPDATE ' + @ValueTmpTbl + ' SET [status] = 1 WHERE ColumnName = @ColName' ;
            exec sp_executesql @tsql , N'@ColName VARCHAR(128)', @ColName = @CurColName ;
        END;
    END

END
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
GO