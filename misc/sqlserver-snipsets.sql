/**
    Rename table column 
*/

if EXISTS (
	SELECT c.name AS ColName, t.name AS TableName
	FROM sys.columns c
		JOIN sys.tables t 
			ON c.object_id = t.object_id
	WHERE t.name = 'Contacts' 
	  and c.name = 'Nom'
)
BEGIN
	EXEC sp_RENAME '[security].[Contacts].[Nom]' , 'Name', 'COLUMN'
	PRINT '    Column ''Nom'' transformed to ''Name''.'
END

/**
    Adding a column to a given table 
 */
DECLARE @ColumnName     VARCHAR(128)    = QUOTENAME('moment')
DECLARE @ColumnDef      NVARCHAR(MAX)   = 'datetime not null'
DECLARE @FullTableName  NVARCHAR(MAX)   = N'[security].[ApplicationLog]'
DECLARE @tsql           NVARCHAR(max)

IF NOT EXISTS( 
    SELECT 1 
    FROM  sys.columns 
    WHERE QUOTENAME(Name) = @ColumnName and Object_ID = Object_ID(@FullTableName) and system_type_id = 40
)
BEGIN
    SET @tsql = N'ALTER TABLE ' + @FullTableName + ' ADD ' + @ColumnName +' ' + @ColumnDef
    execute sp_executesql @tsql
    
    PRINT '    Column ' + @ColumnName + ' from ' + @FullTableName + ' table added.'
END


 
/**
    Modifying a column to a given table 
 */
DECLARE @ColumnName     VARCHAR(128)    = QUOTENAME('moment')
DECLARE @ColumnDef      NVARCHAR(MAX)   = 'datetime not null'
DECLARE @FullTableName  NVARCHAR(MAX)   = N'[security].[ApplicationLog]'
DECLARE @tsql           NVARCHAR(max)

IF EXISTS( 
    SELECT 1 
    FROM  sys.columns 
    WHERE QUOTENAME(Name) = @ColumnName and Object_ID = Object_ID(@FullTableName) and system_type_id = 40
)
BEGIN
    SET @tsql = N'ALTER TABLE ' + @FullTableName + ' ALTER COLUMN ' + @ColumnName +' ' + @ColumnDef
    execute sp_executesql @tsql
    
    PRINT '    Column ' + @ColumnName + ' from ' + @FullTableName + ' table altered.'
END

/**
    Set a column which has NULL in it to NOT NULL 
*/
IF (COLUMNPROPERTY(OBJECT_ID('[security].[SQLLogins]'),'isActive','AllowsNull') = 1)
BEGIN
	update [security].[SQLLogins] set [isActive] = 1 where [SQLLogin] in (select SQLLogin from [security].[Contacts] where isActive = 1)
	update [security].[SQLLogins] set [isActive] = 0 where [SQLLogin] not in (select SQLLogin from [security].[Contacts] where isActive = 1)
	
	alter table [security].[SQLLogins] ALTER column isActive BIT NOT NULL
	
	if @@ERROR = 0	
		PRINT '   Table altered : column isActive altered.'
	ELSE
		return	
END


/**
    Add a constraint to a given table 
*/

DECLARE @SchemaName     NVARCHAR(64)    = N'[security]'
DECLARE @FullTableName  NVARCHAR(MAX)   = @SchemaName + N'[ApplicationLog]'
DECLARE @ConstraintName NVARCHAR(64)    = N'[DF_ApplicationParams_isDepreciated]'
DECLARE @ConstraintDef  NVARCHAR(MAX)   = 'DEFAULT (0) FOR [isDepreciated]'
DECLARE @tsql           NVARCHAR(MAX) 

IF  NOT EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(@SchemaName + '.' + @ConstraintName) AND type = 'D')
BEGIN
    SET @tsql = 'ALTER TABLE ' + @FullTableName + ' ADD CONSTRAINT ' + @ConstraintName + ' ' @ConstraintDef 
    exec sp_executesql @tsql     
	PRINT '   Constraint ' + @ConstraintName + ' created.'
END
GO


/**
    Create a trigger
    Example for insert
*/

DECLARE @SchemaName     NVARCHAR(64)    = N'[security]'
DECLARE @FullTableName  NVARCHAR(MAX)   = @SchemaName + N'[ApplicationLog]'
DECLARE @TriggerName    NVARCHAR(128)   = N'[TRG_I_ApplicationParams]'
DECLARE @TriggerTxt     NVARCHAR(MAX)   =   '    UPDATE [security].ApplicationParams ' + CHAR(13) +
                                            '        SET LastModified = GETDATE()'+CHAR(13) +
                                            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
                                            '    FROM [security].ApplicationParams o ' + CHAR(13) +
                                            '        INNER JOIN inserted i' +CHAR(13) +
                                            '    on o.[ParamName] = i.[ParamName]' +CHAR(13)
                                            
DECLARE @tsql           NVARCHAR(MAX)

IF  NOT EXISTS (SELECT 1 FROM sys.triggers WHERE object_id = OBJECT_ID(@SchemaName  + '.' + @TriggerName))
BEGIN
    SET @tsql = 'CREATE TRIGGER ' + @SchemaName  + '.' + @TriggerName + CHAR(13) +
               '  ON ' + @FullTableName  + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@tsql) ;
	
	PRINT '   Trigger [TRG_I_ApplicationParams] created.'
END

SET @tsql = 'ALTER TRIGGER ' + @SchemaName  + '.' + @TriggerName + CHAR(13) +
            '  ON ' + @FullTableName  + CHAR(13) +
            '    FOR INSERT ' + CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
             @TriggerTxt +
            'END' ;
EXEC (@tsql);



