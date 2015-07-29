/*requires Schema.Security.sql*/
/*requires Schema.Inventory.sql*/
/*requires Table.inventory.SQLDatabases.sql*/


/**
  ==================================================================================
    DESCRIPTION
        Creation of the table [security].[DatabaseSchemas]
        This table lists all the schemas that are referenced into tables :
            - SQLLogins
            - SchemaPermissions
            - OnObjectPrivs (which will become ObjectPermissions)

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
    24/12/2014  Jefferson Elias     Version 0.1.0
    --------------------------------------------------------------------------------
    13/03/2015  Jefferson Elias     Added support for auto-creation of records in
                                    inventory.SQLDatabases table.
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[DatabaseSchemas] Creation'

IF  NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[security].[DatabaseSchemas]'))
BEGIN
    CREATE TABLE [security].[DatabaseSchemas](
        [ServerName]    [varchar](256) NOT NULL,
        [DbName]        [varchar](128) NOT NULL,
        [SchemaName]    [varchar](64) NOT NULL,
        [Description]   [varchar](2048),
        [isActive]      [bit] NOT NULL,
        [CreationDate]  [datetime] NOT NULL,
        [lastmodified]  [datetime] NOT NULL
    ) ON [PRIMARY]

    PRINT '    Table [security].[DatabaseSchemas] created.'

END


IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseSchemas_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseSchemas]
        ADD CONSTRAINT [DF_DatabaseSchemas_CreationDate]
            DEFAULT (Getdate()) FOR [CreationDate]

    PRINT '    Constraint [DF_DatabaseSchemas_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseSchemas_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseSchemas]
        ADD CONSTRAINT [DF_DatabaseSchemas_LastModified] DEFAULT (Getdate()) FOR [LastModified]

    PRINT '    Constraint [DF_DatabaseSchemas_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseSchemas_ServerName]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseSchemas]
        ADD CONSTRAINT [DF_DatabaseSchemas_ServerName] DEFAULT (@@SERVERNAME) FOR [ServerName]

    PRINT '    Constraint [DF_DatabaseSchemas_ServerName] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseSchemas_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseSchemas]
        ADD CONSTRAINT [DF_DatabaseSchemas_isActive] DEFAULT (0) FOR [isActive]

    PRINT '    Constraint [DF_DatabaseSchemas_isActive] created.'
END
GO


IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[DatabaseSchemas]') AND name = N'PK_DatabaseSchemas')
BEGIN
    ALTER TABLE [security].[DatabaseSchemas]
        ADD CONSTRAINT [PK_DatabaseSchemas]
            PRIMARY KEY CLUSTERED (
                [ServerName],
                [DbName],
                [SchemaName]
            )
        WITH (
            PAD_INDEX               = OFF,
            STATISTICS_NORECOMPUTE  = OFF,
            SORT_IN_TEMPDB          = OFF,
            IGNORE_DUP_KEY          = OFF,
            ONLINE                  = OFF,
            ALLOW_ROW_LOCKS         = ON,
            ALLOW_PAGE_LOCKS        = ON
        )
    ON [PRIMARY]

    PRINT '    Primary Key [PK_DatabaseSchemas] created.'
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_DatabaseSchemas]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_DatabaseSchemas] ' + CHAR(13) +
               '  ON security.DatabaseSchemas ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;

    PRINT '    Trigger [security].[TRG_I_DatabaseSchemas] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_DatabaseSchemas]' + CHAR(13) +
            '    ON security.DatabaseSchemas' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].DatabaseSchemas ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].DatabaseSchemas o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName]  = i.[ServerName]' +CHAR(13) +
            '           and o.DbName        = i.DbName' +CHAR(13) +
            '           and o.[SchemaName]  = i.[SchemaName]' +CHAR(13) +
            '' + CHAR(13) +
            '   DECLARE forEachRowCursor' + CHAR(13) +
            '   CURSOR LOCAL FOR' + CHAR(13) +
            '       select distinct ' + CHAR(13) +
            '           ServerName,' + CHAR(13) +
            '           DbName' + CHAR(13) +
            '       from inserted' + CHAR(13) +
            '' + CHAR(13) +
            '/**' + CHAR(13) +
            ' * As SQL Server doesn''t have a FOR EACH ROWS trigger, ' + CHAR(13) +
            ' * and as we don''t merge on this table PRIMARY KEY, ' + CHAR(13) +
            ' * it is mandatory to use a cursor to loop on each rows!' + CHAR(13) +
            ' */' + CHAR(13) +
            '   DECLARE @currentServer  [VARCHAR](256)' + CHAR(13) +
            '   DECLARE @currentDbName  [VARCHAR](64)' + CHAR(13) +
            '   OPEN forEachRowCursor;' + CHAR(13) +
            '   FETCH next from forEachRowCursor ' + CHAR(13) +
            '       into @currentServer,@currentDbName' + CHAR(13) +
                '' + CHAR(13) +
            '   WHILE @@FETCH_STATUS = 0' + CHAR(13) +
            '   BEGIN' + CHAR(13) +
                        '' + CHAR(13) +
            '        merge [inventory].[SQLDatabases] s' + CHAR(13) +
            '        using ( ' + CHAR(13) +
            '           select ' + CHAR(13) +
            '               @currentServer  as ServerName,' + CHAR(13) +
            '               @currentDbName  as DbName,' + CHAR(13) +
            '               CASE WHEN upper(@currentDbName) in (''MASTER'',''MSDB'',''TEMPDB'',''MODEL'') THEN ''0''' + CHAR(13) +
            '                    ELSE ''1''' + CHAR(13) +
            '               END as isUserDatabase' + CHAR(13) +
            '        ) i' + CHAR(13) +
            '        on  s.[ServerName]  = i.[ServerName]' + CHAR(13) +
            '        and s.DbName        = i.DbName' + CHAR(13) +
            '/*' + CHAR(13) +
            '        WHEN MATCHED then' + CHAR(13) +
            '            update set' + CHAR(13) +
            '                isActive = 1' + CHAR(13) +
            '*/' + CHAR(13) +
            '        WHEN NOT MATCHED BY TARGET THEN' + CHAR(13) +
            '           insert (' + CHAR(13) +
            '               ServerName,' + CHAR(13) +
            '               DbName,' + CHAR(13) +
            '               isUserDatabase,' + CHAR(13) +
            '               creationDate,' + CHAR(13) +
            '               lastmodified,' + CHAR(13) +
            '               comments' + CHAR(13) +
            '            )' + CHAR(13) +
            '            values (' + CHAR(13) +
            '                i.ServerName,' + CHAR(13) +
            '                i.DbName,' + CHAR(13) +
            '                i.isUserDatabase,' + CHAR(13) +
            '                GETDATE(),' + CHAR(13) +
            '                GETDATE(),' + CHAR(13) +
            '                ''Created automatically from security.DatabaseSchemas table''' + CHAR(13) +
            '            )' + CHAR(13) +
            '        ;' + CHAR(13) +
            '        FETCH next from forEachRowCursor ' + CHAR(13) +
            '        into @currentServer,@currentDbName' + CHAR(13) +
            '   END;' + CHAR(13) +
            '   CLOSE forEachRowCursor;' + CHAR(13) +
            '   DEALLOCATE forEachRowCursor;' + CHAR(13) +
            'END' ;

EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_DatabaseSchemas] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_DatabaseSchemas]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_DatabaseSchemas] ' + CHAR(13) +
               '  ON security.DatabaseSchemas ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
    PRINT '    Trigger [security].[TRG_U_DatabaseSchemas] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_DatabaseSchemas]' + CHAR(13) +
            '    ON security.DatabaseSchemas' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].DatabaseSchemas ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].DatabaseSchemas o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName]  = i.[ServerName]' +CHAR(13) +
            '           and o.DbName        = i.DbName' +CHAR(13) +
            '           and o.[SchemaName]  = i.[SchemaName]' +CHAR(13) + CHAR(13) +
            '' + CHAR(13) +
            '   DECLARE forEachRowCursor' + CHAR(13) +
            '   CURSOR LOCAL FOR' + CHAR(13) +
            '       select distinct ' + CHAR(13) +
            '           ServerName,' + CHAR(13) +
            '           DbName' + CHAR(13) +
            '       from inserted' + CHAR(13) +
            '' + CHAR(13) +
            '/**' + CHAR(13) +
            ' * As SQL Server doesn''t have a FOR EACH ROWS trigger, ' + CHAR(13) +
            ' * and as we don''t merge on this table PRIMARY KEY, ' + CHAR(13) +
            ' * it is mandatory to use a cursor to loop on each rows!' + CHAR(13) +
            ' */' + CHAR(13) +
            '   DECLARE @currentServer  [VARCHAR](256)' + CHAR(13) +
            '   DECLARE @currentDbName  [VARCHAR](64)' + CHAR(13) +
            '   OPEN forEachRowCursor;' + CHAR(13) +
            '   FETCH next from forEachRowCursor ' + CHAR(13) +
            '       into @currentServer,@currentDbName' + CHAR(13) +
                '' + CHAR(13) +
            '   WHILE @@FETCH_STATUS = 0' + CHAR(13) +
            '   BEGIN' + CHAR(13) +
                        '' + CHAR(13) +
            '        merge [inventory].[SQLDatabases] s' + CHAR(13) +
            '        using ( ' + CHAR(13) +
            '           select ' + CHAR(13) +
            '               @currentServer  as ServerName,' + CHAR(13) +
            '               @currentDbName  as DbName,' + CHAR(13) +
            '               CASE WHEN upper(@currentDbName) in (''MASTER'',''MSDB'',''TEMPDB'',''MODEL'') THEN ''0''' + CHAR(13) +
            '                    ELSE ''1''' + CHAR(13) +
            '               END as isUserDatabase' + CHAR(13) +
            '        ) i' + CHAR(13) +
            '        on  s.[ServerName]  = i.[ServerName]' + CHAR(13) +
            '        and s.DbName        = i.DbName' + CHAR(13) +
            '/*' + CHAR(13) +
            '        WHEN MATCHED then' + CHAR(13) +
            '            update set' + CHAR(13) +
            '                isActive = 1' + CHAR(13) +
            '*/' + CHAR(13) +
            '        WHEN NOT MATCHED BY TARGET THEN' + CHAR(13) +
            '           insert (' + CHAR(13) +
            '               ServerName,' + CHAR(13) +
            '               DbName,' + CHAR(13) +
            '               isUserDatabase,' + CHAR(13) +
            '               creationDate,' + CHAR(13) +
            '               lastmodified,' + CHAR(13) +
            '               comments' + CHAR(13) +
            '            )' + CHAR(13) +
            '            values (' + CHAR(13) +
            '                i.ServerName,' + CHAR(13) +
            '                i.DbName,' + CHAR(13) +
            '                i.isUserDatabase,' + CHAR(13) +
            '                GETDATE(),' + CHAR(13) +
            '                GETDATE(),' + CHAR(13) +
            '                ''Created automatically from security.DatabaseSchemas table''' + CHAR(13) +
            '            )' + CHAR(13) +
            '        ;' + CHAR(13) +
            '        FETCH next from forEachRowCursor ' + CHAR(13) +
            '        into @currentServer,@currentDbName' + CHAR(13) +
            '   END;' + CHAR(13) +
            '   CLOSE forEachRowCursor;' + CHAR(13) +
            '   DEALLOCATE forEachRowCursor;' + CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_DatabaseSchemas] altered.'
PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''