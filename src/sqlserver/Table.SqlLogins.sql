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
    16/04/2014  Jefferson Elias     Creation
    --------------------------------------------------------------------------------
    23/04/2014  Jefferson Elias     VERSION 1.0.0
    --------------------------------------------------------------------------------
	25/04/2014	Jefferson Elias		Added BEGIN END at each IF
									Removed columns defaultDatabase and DefaultSchema
									As there is the table SQLMappings for this
									Added isActive column.
									VERSION 1.0.1
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
		[isActive]	  BIT		NOT NULL,
        [CreationDate]    datetime NOT NULL,
        [lastmodified]    datetime NOT NULL
    )
    ON [PRIMARY]
	PRINT '   Table [SQLlogins] created.'
END
GO

IF EXISTS( SELECT * from sys.columns where OBJECT_SCHEMA_NAME(object_id) = 'security' and OBJECT_NAME(object_id) = 'SQLLogins' and name = 'defaultdatabase')
BEGIN
	ALTER TABLE [security].[SQLLogins] drop column [DefaultDatabase]
	if @@ERROR = 0	
		PRINT '   Table altered : column DefaultDatabase dropped.'
END
GO

IF EXISTS( SELECT * from sys.columns where OBJECT_SCHEMA_NAME(object_id) = 'security' and OBJECT_NAME(object_id) = 'SQLLogins' and name = 'defaultschema')
BEGIN
	ALTER TABLE [security].[SQLLogins] drop column [defaultschema]
	if @@ERROR = 0	
		PRINT '   Table altered : column defaultschema dropped.'
END
GO

IF NOT EXISTS( SELECT * from sys.columns where OBJECT_SCHEMA_NAME(object_id) = 'security' and OBJECT_NAME(object_id) = 'SQLLogins' and name = 'isActive')
BEGIN
	ALTER TABLE [security].[SQLLogins] add [isActive] BIT
	if @@ERROR = 0	
		PRINT '   Table altered : column isActive added.'
	ELSE
		return
END
GO

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