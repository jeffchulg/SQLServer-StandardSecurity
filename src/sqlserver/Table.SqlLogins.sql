/*requires Schema.Security.sql*/
/*requires Table.Contacts.sql*/

/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[SQLLogins] table.
		
		This table will contain default informations (database + schema) for a login 
		on a given sql server instance.

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
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[SQLlogins] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[SQLlogins]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[SQLlogins] (
        [ServerName]      [VARCHAR](256) NOT NULL,
        [SqlLogin]        [VARCHAR](256) NOT NULL,
		[isActive]	      BIT		NOT NULL,
        [PermissionLevel] [varchar](6) DEFAULT 'GRANT' not null,
        [CreationDate]    datetime NOT NULL,
        [lastmodified]    datetime NOT NULL
    )
    ON [PRIMARY]
	PRINT '   Table [SQLlogins] created.'
END
GO

/**
    Adding a column to a given table 
 */
DECLARE @ColumnName     VARCHAR(128)    = QUOTENAME('PermissionLevel')
DECLARE @ColumnDef      NVARCHAR(MAX)   = '[varchar](6) DEFAULT ''GRANT'' not null'
DECLARE @FullTableName  NVARCHAR(MAX)   = N'[security].[SQLlogins]'
DECLARE @tsql           NVARCHAR(max)

IF NOT EXISTS( 
    SELECT 1 
    FROM  sys.columns 
    WHERE QUOTENAME(Name) = @ColumnName and Object_ID = Object_ID(@FullTableName)
)
BEGIN
    SET @tsql = N'ALTER TABLE ' + @FullTableName + ' ADD ' + @ColumnName +' ' + @ColumnDef
    execute sp_executesql @tsql
    
    PRINT '    Column ' + @ColumnName + ' from ' + @FullTableName + ' table added.'
END


IF (OBJECTPROPERTY( OBJECT_ID( '[security].[SQLlogins]' ), 'TableHasPrimaryKey' ) <> 1)
BEGIN
    ALTER TABLE [security].[SQLlogins]
        ADD  CONSTRAINT [PK_SQLlogins ]
            PRIMARY KEY (
                [ServerName],[SqlLogin]
            )
	PRINT '   Primary Key [PK_SQLlogins] created.'
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[security].[FK_SQLlogins_Contacts]') AND parent_object_id = OBJECT_ID(N'[security].[SQLlogins]'))
BEGIN
    ALTER TABLE [security].[SQLlogins]
        ADD  CONSTRAINT [FK_SQLlogins_Contacts]
            FOREIGN KEY (
                [SqlLogin]
            )
        REFERENCES [security].[Contacts] ([SqlLogin])
	PRINT '   Foreign Key [FK_SQLlogins_Contacts] created.'
END
GO


IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_SQLLogins_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[SQLlogins]
        ADD CONSTRAINT [DF_SQLLogins_isActive] DEFAULT (1) FOR [isActive]
	PRINT '   Constraint [DF_SQLLogins_isActive] created.'
END

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_SQLLogins_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[SQLlogins]
        ADD CONSTRAINT [DF_SQLLogins_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	PRINT '   Constraint [DF_SQLLogins_CreationDate] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_SQLLogins_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[SQLlogins]
        ADD CONSTRAINT [DF_SQLLogins_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	PRINT '   Constraint [DF_SQLLogins_LastModified] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_SQLLogins_PermissionLevel]') AND parent_object_id = OBJECT_ID(N'[security].[SQLLogins]'))
BEGIN
    ALTER TABLE [security].[SQLLogins]
        WITH CHECK ADD CONSTRAINT [CK_SQLLogins_PermissionLevel]
            CHECK (([PermissionLevel] in ('GRANT','REVOKE','DENY')))
	PRINT '     Constraint [CK_SQLLogins_PermissionLevel] created.'
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_SQLLogins]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_SQLLogins] ' + CHAR(13) +
               '  ON security.SQLLogins ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '   Trigger [TRG_I_SQLLogins] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_SQLLogins]' + CHAR(13) +
            '    ON security.SQLLogins' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].SQLLogins ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].SQLLogins o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName] = i.[ServerName]' +CHAR(13) +
            '           and o.[SQLLogin] = i.[SQLLogin]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '   Trigger [TRG_I_SQLLogins] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_SQLLogins]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_SQLLogins] ' + CHAR(13) +
               '  ON security.SQLLogins ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '   Trigger [TRG_U_SQLLogins] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_SQLLogins]' + CHAR(13) +
            '    ON security.SQLLogins' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].SQLLogins ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].SQLLogins o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName] = i.[ServerName]' +CHAR(13) +
            '           and o.[SQLLogin] = i.[SQLLogin]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '   Trigger [TRG_U_SQLLogins] altered.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 