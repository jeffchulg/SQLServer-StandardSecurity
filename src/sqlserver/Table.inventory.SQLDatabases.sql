/*requires Schema.inventory.sql*/

/**
  ==================================================================================
    DESCRIPTION
        Creation of the [inventory].[SQLDatabases] table.
        
        
    ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================
    ----------------------------------------------------------------------------------
  ==================================================================================
  Notes :
 
        Exemples :
        -------
 
  ==================================================================================
  Revision history
 
    Date        Name                Description
    ==========  ================    ================================================
    13/03/2015  Jefferson Elias     Version 0.1.0
    ----------------------------------------------------------------------------------    
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [inventory].[SQLDatabases] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inventory].[SQLDatabases]') AND type in (N'U'))
BEGIN
    CREATE TABLE [inventory].[SQLDatabases] (
        ServerName      VARCHAR(256) NOT NULL,
        DbName          VARCHAR(64)  NOT NULL,
        isUserDatabase  BIT          NOT NULL,
        Reason          VARCHAR(MAX) NULL,
        DbCreationDate  DATETIME     NULL,
        DbOwner         VARCHAR(128) NOT NULL default 'sa',
        DbCollation     VARCHAR(128) NULL,
        RecoveryModel   VARCHAR(16)  NULL,
        CompatLevel     TINYINT NULL,       
        CreationDate    DATETIME NOT NULL,
        LastModified    DATETIME NOT NULL,
        Comments        VARCHAR(MAX) NULL
    )
    ON [PRIMARY];
    
    IF @@ERROR = 0
        PRINT '   Table created.'
    ELSE
    BEGIN
        PRINT '   Error while trying to create table.'
        RETURN
    END
END

IF (OBJECTPROPERTY( OBJECT_ID( '[inventory].[SQLDatabases]' ), 'TableHasPrimaryKey' ) <> 1)
BEGIN
    ALTER TABLE [inventory].[SQLDatabases]
        ADD  CONSTRAINT [PK_SQLDatabases ]
            PRIMARY KEY (
                [ServerName],
                [DbName]
            )
    IF @@ERROR = 0
        PRINT '   Primary Key [PK_SQLDatabases] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[inventory].[DF_SQLDatabases_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [inventory].[SQLDatabases]
        ADD CONSTRAINT [DF_SQLDatabases_CreationDate]
            DEFAULT (Getdate()) FOR [CreationDate]
        
    PRINT '    Constraint [DF_SQLDatabases_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[inventory].[DF_SQLDatabases_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [inventory].[SQLDatabases]
        ADD CONSTRAINT [DF_SQLDatabases_LastModified] DEFAULT (Getdate()) FOR [LastModified]
    
    PRINT '    Constraint [DF_SQLDatabases_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[inventory].[DF_SQLDatabases_ServerName]') AND type = 'D')
BEGIN
    ALTER TABLE [inventory].[SQLDatabases]
        ADD CONSTRAINT [DF_SQLDatabases_ServerName] DEFAULT (@@SERVERNAME) FOR [ServerName]
    
    PRINT '    Constraint [DF_SQLDatabases_ServerName] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_SQLDatabases_RecoveryModel]') AND parent_object_id = OBJECT_ID(N'[security].[SQLDatabases]'))
BEGIN
    ALTER TABLE [security].[SQLDatabases]
        WITH CHECK ADD CONSTRAINT [CK_SQLDatabases_RecoveryModel]
            CHECK (([RecoveryModel] in ('SIMPLE','BULK_LOGGED','FULL')))
    PRINT '     Constraint [CK_SQLDatabases_RecoveryModel] created.'
END
GO


DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[inventory].[TRG_I_SQLDatabases]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [inventory].[TRG_I_SQLDatabases] ' + CHAR(13) +
               '  ON inventory.SQLDatabases ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
    
    PRINT '    Trigger [inventory].[TRG_I_SQLDatabases] created.'
END

SET @SQL =  'ALTER TRIGGER [inventory].[TRG_I_SQLDatabases]' + CHAR(13) +
            '    ON inventory.SQLDatabases' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [inventory].SQLDatabases ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            -- '         , CASE WHEN (i.DbName in (''master'',''msdb'',''tempdb'') AND (i.Reason is null)) 
            '    FROM [inventory].SQLDatabases o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName]  = i.[ServerName]' +CHAR(13) +
            '           and o.DbName        = i.DbName' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [inventory].[TRG_I_SQLDatabases] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[inventory].[TRG_U_SQLDatabases]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [inventory].[TRG_U_SQLDatabases] ' + CHAR(13) +
               '  ON inventory.SQLDatabases ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
    PRINT '    Trigger [inventory].[TRG_U_SQLDatabases] created.'
END

SET @SQL =  'ALTER TRIGGER [inventory].[TRG_U_SQLDatabases]' + CHAR(13) +
            '    ON inventory.SQLDatabases' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [inventory].SQLDatabases ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [inventory].SQLDatabases o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName]  = i.[ServerName]' +CHAR(13) +
            '           and o.DbName        = i.DbName' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [inventory].[TRG_U_SQLDatabases] altered.'
PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 
