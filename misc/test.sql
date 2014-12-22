/**
    Creation of the [security] schema
  ==================================================================================
    DESCRIPTION
		This script creates the [security] schema if it does not exist.
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
    23/04/2014  Jefferson Elias     VERSION 1.0.0
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'SCHEMA [security] CREATION'

IF  NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'security')
BEGIN	
    DECLARE @SQL VARCHAR(MAX);
    SET @SQL = 'CREATE SCHEMA [security] AUTHORIZATION [dbo]'
    EXEC (@SQL)
	PRINT '   SCHEMA [security] created.'
END
ELSE
	PRINT '   SCHEMA [security] already exists.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 
/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[Contacts] table.
		This table will contain informations about contacts such as the SQLLogin associated to this contact

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
    23/04/2014  Jefferson Elias     VERSION 1.0.0
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[Contacts] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[Contacts]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[Contacts] (
        [SqlLogin]        [VARCHAR](256) NOT NULL,
        [Name]            [VARCHAR](max) NOT NULL,
        [Job]             [VARCHAR](64) NOT NULL,
        [isActive]        [BIT] NOT NULL,
        [Department]      [VARCHAR](64) NOT NULL,
        [authmode]        [VARCHAR](64) NOT NULL,
        [CreationDate]    datetime NOT NULL,
        [lastmodified]    datetime NOT NULL
    )
    ON [PRIMARY]
	PRINT '    Table [security].[Contacts] created.'
END
GO

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

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[Contacts]') AND name = N'PK_Contacts')
    ALTER TABLE [security].[Contacts]
        ADD CONSTRAINT [PK_Contacts]
            PRIMARY KEY CLUSTERED (
                [SqlLogin] ASC
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
	
	PRINT '    Primary Key [PK_Contacts] created.'
GO


IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_Contacts_AuthMode]') AND parent_object_id = OBJECT_ID(N'[security].[Contacts]'))
    ALTER TABLE [security].[Contacts]
        WITH CHECK ADD CONSTRAINT [CK_Contacts_AuthMode]
            CHECK (([authmode]='SQLSRVR' OR [authmode]='WINDOWS'))
	PRINT '     Constraint [CK_Contacts_AuthMode] created.'
GO

IF NOT EXISTS (SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('[security].[CK_Contacts_AuthMode]') AND [name] = N'MS_Description' AND [minor_id] = 0)
    EXEC sys.Sp_addextendedproperty
      @name=N'MS_Description',
      @value=N'Vérifie que la valeur est dans (''WINDOWS'',''SQLSRVR)',
      @level0type=N'SCHEMA',
      @level0name=N'security',
      @level1type=N'TABLE',
      @level1name=N'Contacts',
      @level2type=N'CONSTRAINT',
      @level2name=N'CK_Contacts_AuthMode'	  
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_Contacts_AuthMode]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[Contacts]
        ADD CONSTRAINT [DF_Contacts_AuthMode] DEFAULT (N'WINDOWS') FOR [AuthMode]
	PRINT '    Constraint [DF_Contacts_AuthMode] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_Contacts_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[Contacts]
        ADD CONSTRAINT [DF_Contacts_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	PRINT '    Constraint [DF_Contacts_CreationDate] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_Contacts_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[Contacts]
        ADD CONSTRAINT [DF_Contacts_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	PRINT '    Constraint [DF_Contacts_LastModified] created.'
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_Contacts]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_Contacts] ' + CHAR(13) +
               '  ON security.Contacts ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '   Trigger [TRG_I_Contacts] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_Contacts]' + CHAR(13) +
            '    ON security.Contacts' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].Contacts ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].Contacts o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '    on o.[SQLLogin] = i.[SQLLogin]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '   Trigger [TRG_I_Contacts] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_Contacts]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_Contacts] ' + CHAR(13) +
               '  ON security.Contacts ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '    Trigger [TRG_U_Contacts] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_Contacts]' + CHAR(13) +
            '    ON security.Contacts' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].Contacts ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].Contacts o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '    on o.[SQLLogin] = i.[SQLLogin]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
GO


PRINT '    Trigger [TRG_U_Contacts] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 
/**
    Creation of an application log table
*/
/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[ApplicationLog] table.
		an application log table

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
    23/04/2014  Jefferson Elias     VERSION 0.1.0
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[ApplicationLog] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[ApplicationLog]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[ApplicationLog](
        [runid]         [numeric](20, 0) 				NOT NULL,
        [entryid]       [numeric](20, 0) IDENTITY(1,1) 	NOT NULL,
        [moment]        [date] 							NOT NULL,
        [program]       [varchar](256) 					NOT NULL,
        [loglevel]      [varchar](8) 					NOT NULL,
        [logmessage]    [varchar](max) 					NOT NULL
    ) ON [PRIMARY]
	
	PRINT '    Table [security].[ApplicationLog] created.'
END
GO


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 

/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[StandardOnSchemaRoles] table.
		This table will contain a list of security roles defined by our standard.

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
    23/04/2014  Jefferson Elias     VERSION 1.0.0
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[StandardOnSchemaRoles] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRoles]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[StandardOnSchemaRoles](
        [RoleName]      [varchar](64) NOT NULL,
        [isActive]      [bit] NOT NULL,
        [CreationDate]  [date] NOT NULL,
        [lastmodified]  [date] NOT NULL
    ) ON [PRIMARY]
	PRINT '    Table [security].[StandardOnSchemaRoles] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRoles_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardOnSchemaRoles]
        ADD CONSTRAINT [DF_StandardOnSchemaRoles_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	
	PRINT '    Constraint [DF_StandardOnSchemaRoles_CreationDate] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRoles_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardOnSchemaRoles]
        ADD CONSTRAINT [DF_StandardOnSchemaRoles_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	PRINT '    Constraint [DF_StandardOnSchemaRoles_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRoles]') AND name = N'PK_StandardOnSchemaRoles')
BEGIN
    ALTER TABLE [security].[StandardOnSchemaRoles]
        ADD CONSTRAINT [PK_StandardOnSchemaRoles]
            PRIMARY KEY CLUSTERED (
                [RoleName] ASC
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
	
	PRINT '    Primary key [PK_StandardOnSchemaRoles] created.'
END
GO


DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_StandardOnSchemaRoles]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_StandardOnSchemaRoles] ' + CHAR(13) +
               '  ON security.StandardOnSchemaRoles ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '    Trigger [security].[TRG_I_StandardOnSchemaRoles] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_StandardOnSchemaRoles]' + CHAR(13) +
            '    ON security.StandardOnSchemaRoles' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardOnSchemaRoles ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].StandardOnSchemaRoles o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '    on o.[RoleName] = i.[RoleName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_StandardOnSchemaRoles] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_StandardOnSchemaRoles]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_StandardOnSchemaRoles] ' + CHAR(13) +
               '  ON security.StandardOnSchemaRoles ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '    Trigger [security].[TRG_U_StandardOnSchemaRoles] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_StandardOnSchemaRoles]' + CHAR(13) +
            '    ON security.StandardOnSchemaRoles' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardOnSchemaRoles ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].StandardOnSchemaRoles o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '    on o.[RoleName] = i.[RoleName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);

PRINT '    Trigger [security].[TRG_U_StandardOnSchemaRoles] altered.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 
/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[ApplicationParams] table.
		This table will contain informations about the application parameters

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
    23/04/2014  Jefferson Elias     VERSION 1.0.0
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [ApplicationParams] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[ApplicationParams]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[ApplicationParams](
        [ParamName]     [varchar](64)   NOT NULL,
        [ParamValue]    [varchar](max)  NOT NULL,
        [DefaultValue]  [varchar](max)  NOT NULL,
        [isDepreciated] [bit]           NOT NULL,
        [Description]   [varchar](max)  NULL,
        [creationdate]  [date]          NOT NULL,
        [lastmodified]  [date]          NOT NULL,

        CONSTRAINT [PK_ApplicationParams] PRIMARY KEY CLUSTERED (
            [ParamName] ASC
        )
        WITH (
            PAD_INDEX  = OFF,
            STATISTICS_NORECOMPUTE  = OFF,
            IGNORE_DUP_KEY = OFF,
            ALLOW_ROW_LOCKS  = ON,
            ALLOW_PAGE_LOCKS  = ON
        )
        ON [PRIMARY]
    )ON [PRIMARY]
	PRINT '   Table [ApplicationParams] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_ApplicationParams_isDepreciated]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[ApplicationParams]
        ADD CONSTRAINT [DF_ApplicationParams_isDepreciated] DEFAULT (0) FOR [isDepreciated]
	PRINT '   Constraint [DF_ApplicationParams_isDepreciated] created.'
END
GO


IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_ApplicationParams_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[ApplicationParams]
        ADD CONSTRAINT [DF_ApplicationParams_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	PRINT '   Constraint [DF_ApplicationParams_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_ApplicationParams_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[ApplicationParams]
        ADD CONSTRAINT [DF_ApplicationParams_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	PRINT '   Constraint [DF_ApplicationParams_LastModified] created.'
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_ApplicationParams]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_ApplicationParams] ' + CHAR(13) +
               '  ON security.ApplicationParams ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '   Trigger [TRG_I_ApplicationParams] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_ApplicationParams]' + CHAR(13) +
            '    ON security.ApplicationParams' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].ApplicationParams ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].ApplicationParams o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '    on o.[ParamName] = i.[ParamName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);

PRINT '   Trigger [TRG_I_ApplicationParams] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_ApplicationParams]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_ApplicationParams] ' + CHAR(13) +
               '  ON security.ApplicationParams ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '   Trigger [TRG_I_ApplicationParams] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_ApplicationParams]' + CHAR(13) +
            '    ON security.ApplicationParams' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].ApplicationParams ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].ApplicationParams o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '    on o.[ParamName] = i.[ParamName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
GO

PRINT '   Trigger [TRG_I_ApplicationParams] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 

/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[OnObjectPrivs] table.
		This table will contain any privilege on a given object directly given to 
		a principal (login or role)

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
    23/04/2014  Jefferson Elias     VERSION 1.0.0
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[OnObjectPrivs] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[OnObjectPrivs]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[OnObjectPrivs] (
        [ServerName]        [VARCHAR](256) NOT NULL,
        [DbName]            [VARCHAR](64) NOT NULL,
        [Grantee]           [VARCHAR](64) NOT NULL,
        [isUser]            [BIT] NOT NULL,
        [PermissionName]    [VARCHAR](128) NOT NULL,
        [SchemaName]        [VARCHAR](64) NOT NULL,
        [ObjectName]        [VARCHAR](128) NOT NULL,
        [ObjectType]        [VARCHAR](128) NOT NULL,
        [isDeny]            BIT NOT NULL,
        [isWithGrantOption] BIT NOT NULL,
        [isActive]          BIT            NOT NULL,
        [CreationDate]      [datetime] NULL,
        [lastmodified]      [datetime] NULL
    )
    ON [PRIMARY]
	PRINT '    Table [security].[OnObjectPrivs] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[CK_OnObjectPrivs_NoDenyWithGrantOption]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[OnObjectPrivs]
        ADD  CONSTRAINT [CK_OnObjectPrivs_NoDenyWithGrantOption]
            CHECK  ((NOT ([isDeny]=(1) AND [isWithGrantOption]=(1))))
	
	PRINT '    Constraint [CK_OnObjectPrivs_NoDenyWithGrantOption] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_OnObjectPrivs_isWithGrantOption]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[OnObjectPrivs]
        ADD CONSTRAINT [DF_OnObjectPrivs_isWithGrantOption]
            DEFAULT 0 FOR [isWithGrantOption]
	
	PRINT '    Constraint [DF_OnObjectPrivs_isWithGrantOption] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_OnObjectPrivs_isDeny]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[OnObjectPrivs]
        ADD CONSTRAINT [DF_OnObjectPrivs_isDeny]
            DEFAULT 0 FOR [isDeny]
	
	PRINT '    Constraint [DF_OnObjectPrivs_isDeny] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_OnObjectPrivs_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[OnObjectPrivs]
        ADD CONSTRAINT [DF_OnObjectPrivs_CreationDate]
            DEFAULT (Getdate()) FOR [CreationDate]
	
	PRINT '    Constraint [DF_OnObjectPrivs_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_OnObjectPrivs_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[OnObjectPrivs]
        ADD CONSTRAINT [DF_OnObjectPrivs_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	PRINT '    Constraint [DF_OnObjectPrivs_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_OnObjectPrivs_ServerName]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[OnObjectPrivs]
        ADD CONSTRAINT [DF_OnObjectPrivs_ServerName] DEFAULT (@@SERVERNAME) FOR [ServerName]
	
	PRINT '    Constraint [DF_OnObjectPrivs_ServerName] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_OnObjectPrivs_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[OnObjectPrivs]
        ADD CONSTRAINT [DF_OnObjectPrivs_isActive] DEFAULT (0) FOR [isActive]
	
	PRINT '    Constraint [DF_OnObjectPrivs_isActive] created.'
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_OnObjectPrivs]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_OnObjectPrivs] ' + CHAR(13) +
               '  ON security.OnObjectPrivs ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '    Trigger [security].[TRG_I_OnObjectPrivs] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_OnObjectPrivs]' + CHAR(13) +
            '    ON security.OnObjectPrivs' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].OnObjectPrivs ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].OnObjectPrivs o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName] = i.[ServerName]' +CHAR(13) +
            '           and o.DbName = i.DbName' +CHAR(13) +
            '           and o.[grantee] = i.[grantee]' +CHAR(13) +
            '           and o.[SchemaName] = i.[SchemaName]' +CHAR(13) +
            '           and o.[objectname] = i.[objectname]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_OnObjectPrivs] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_OnObjectPrivs]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_OnObjectPrivs] ' + CHAR(13) +
               '  ON security.OnObjectPrivs ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '    Trigger [security].[TRG_U_OnObjectPrivs] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_OnObjectPrivs]' + CHAR(13) +
            '    ON security.OnObjectPrivs' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].OnObjectPrivs ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].OnObjectPrivs o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName] = i.[ServerName]' +CHAR(13) +
            '           and o.DbName = i.DbName' +CHAR(13) +
            '           and o.[grantee] = i.[grantee]' +CHAR(13) +
            '           and o.[SchemaName] = i.[SchemaName]' +CHAR(13) +
            '           and o.[objectname] = i.[objectname]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_OnObjectPrivs] altered.'
GO


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 
/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[CustomRoles] table.
		This table will define custom roles that will be create for a given database 
		on a given server

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
	25/04/2014	Jefferson Elias		Added primary key
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[CustomRoles] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[CustomRoles]') AND type in (N'U'))
BEGIN
	CREATE TABLE [security].[CustomRoles](
		[ServerName]    [varchar](256) NOT NULL,
		[DbName]        [varchar](64) NOT NULL,
		[RoleName]      [varchar](64) NOT NULL,
		[isActive]      [bit] NOT NULL,
		[CreationDate]  [date] NOT NULL,
		[lastmodified]  [date] NOT NULL
	) ON [PRIMARY]
	
	PRINT '    Table [security].[CustomRoles] created.'
END
GO



IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_CustomRoles_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[CustomRoles]
        ADD CONSTRAINT [DF_CustomRoles_CreationDate]
            DEFAULT (Getdate()) FOR [CreationDate]
		
	PRINT '    Constraint [DF_CustomRoles_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_CustomRoles_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[CustomRoles]
        ADD CONSTRAINT [DF_CustomRoles_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	PRINT '    Constraint [DF_CustomRoles_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_CustomRoles_ServerName]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[CustomRoles]
        ADD CONSTRAINT [DF_CustomRoles_ServerName] DEFAULT (@@SERVERNAME) FOR [ServerName]
	
	PRINT '    Constraint [DF_CustomRoles_ServerName] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_CustomRoles_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[CustomRoles]
        ADD CONSTRAINT [DF_CustomRoles_isActive] DEFAULT (0) FOR [isActive]
		
	PRINT '    Constraint [DF_CustomRoles_isActive] created.'
END
GO


IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[CustomRoles]') AND name = N'PK_CustomRoles')
    ALTER TABLE [security].[CustomRoles]
        ADD CONSTRAINT [PK_CustomRoles]
            PRIMARY KEY CLUSTERED (
                [ServerName],
				[DbName],
				[RoleName]
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
	
	PRINT '    Primary Key [PK_CustomRoles] created.'
GO


DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_CustomRoles]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_CustomRoles] ' + CHAR(13) +
               '  ON security.CustomRoles ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '    Trigger [security].[TRG_I_CustomRoles] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_CustomRoles]' + CHAR(13) +
            '    ON security.CustomRoles' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].CustomRoles ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].CustomRoles o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName]  = i.[ServerName]' +CHAR(13) +
            '           and o.DbName        = i.DbName' +CHAR(13) +
            '           and o.[RoleName]    = i.[RoleName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_CustomRoles] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_CustomRoles]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_CustomRoles] ' + CHAR(13) +
               '  ON security.CustomRoles ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '    Trigger [security].[TRG_U_CustomRoles] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_CustomRoles]' + CHAR(13) +
            '    ON security.CustomRoles' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].CustomRoles ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].CustomRoles o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName]  = i.[ServerName]' +CHAR(13) +
            '           and o.DbName        = i.DbName' +CHAR(13) +
            '           and o.[RoleName]    = i.[RoleName]' +CHAR(13) +

            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_CustomRoles] altered.'
GO


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 



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

IF (OBJECTPROPERTY( OBJECT_ID( '[security].[PK_SQLlogins]' ), 'TableHasPrimaryKey' ) <> 1)
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




/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[logins] view that lists active logins

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
	24/04/2014	Jefferson Elias		View creation change : adding column name to 'Not Implemented'
									VERSION 1.0.1
    --------------------------------------------------------------------------------
	25/04/2014	Jefferson Elias		Modified to take into account the SQLMappings table
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'View [security].[logins] Creation'

DECLARE @SQL VARCHAR(MAX)
IF  NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[security].[logins]'))
BEGIN
    SET @SQL =  'CREATE view [security].[logins]
                AS
                select ''Not implemented'' as Col1'
    EXEC (@SQL)
	PRINT '    View [security].[logins] created.'
END

SET @SQL = 'ALTER view [security].[logins]
                AS
                 select
                    c.[Name],
                    c.[Job],
                    c.[Department],
                    c.[AuthMode],
                    l.[ServerName],
                    l.[SQLLogin],
                    m.DbName,
					m.DbUserName,
                    m.DefaultSchema,
                    c.isActive,
                    m.isLocked
                from [security].[Contacts] c
                    inner join [Security].[SQLlogins] l
                        on c.SQLLogin = l.SQLLogin
                    inner join [security].[SQLMappings] m
						on l.SqlLogin   = m.SqlLogin
					  and  l.ServerName = m.ServerName
				where m.isDefaultDb = 1'
EXEC (@SQL)
PRINT '    View [security].[logins] altered.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 


/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[DatabaseUsers] view that lists active Database Users

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
    24/04/2014  Jefferson Elias     Creation
									VERSION 1.0.0
    --------------------------------------------------------------------------------
	25/04/2014	Jefferson Elias		Modified to manage the new version of logins view
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'View [security].[DatabaseUsers] Creation'

DECLARE @SQL VARCHAR(MAX)
IF  NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[security].[DatabaseUsers]'))
BEGIN
    SET @SQL = 'CREATE view [security].[DatabaseUsers]
                AS
                select ''Not implemented'' as Col1' 
    EXEC (@SQL)
    if @@ERROR = 0 
		PRINT '    View [security].[DatabaseUsers] created.'
END

SET @SQL = 'ALTER view [security].[DatabaseUsers]
                AS
                select
                    [Name],
                    [Job],
                    [Department],
                    [ServerName],
					[DbName],
                    [DbUserName],                    
                    [DefaultSchema]
                from [security].[logins] 
                where isActive = 1'
EXEC (@SQL)
if @@ERROR = 0
BEGIN
	PRINT '    View [security].[DatabaseUsers] altered.'
END
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 


/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[SQLMappings] table.
		
		This table will contain informations about logins to database user mappings
		on a given server.

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
    24/04/2014  Jefferson Elias     Creation
    --------------------------------------------------------------------------------
	25/04/2014	Jefferson Elias		Added column isLocked
									Changed foreign key from Contacts to SQLLogins as
									a login must be defined on a given server to be 
									able to be mapped.
									TODO: make the DbUserName column to be filled 
									automatically when it's null (for insert)
									VERSION 1.0.0
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[SQLMappings] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[SQLMappings]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[SQLMappings] (
        [ServerName]      [VARCHAR](256) 	NOT NULL,		
        [SqlLogin]        [VARCHAR](256) 	NOT NULL,
		[DbName]	      [VARCHAR](64) 	NOT NULL, 
		[DbUserName]	  [VARCHAR](64) 	NOT NULL, 
        [DefaultSchema]   [VARCHAR](64) 	NOT NULL,
		[isDefaultDb]	  [BIT]				NOT NULL,
		[isLocked]	  	  [BIT]				NOT NULL,
        [CreationDate]    datetime 			NOT NULL,
        [lastmodified]    datetime 			NOT NULL
    )
    ON [PRIMARY]
	
	IF @@ERROR = 0
		PRINT '   Table [security].[SQLMappings] created.'
	ELSE
	BEGIN
		PRINT '   Error while trying to create table [security].[SQLMappings]'
		RETURN
	END
END
GO

IF NOT EXISTS( SELECT * from sys.columns where OBJECT_SCHEMA_NAME(object_id) = 'security' and OBJECT_NAME(object_id) = 'SQLMappings' and name = 'isLocked')
BEGIN
	ALTER TABLE [security].[SQLMappings] add [isLocked] BIT
	if @@ERROR = 0	
		PRINT '   Table altered : column isLocked added.'
	ELSE
		return
END
GO

IF (COLUMNPROPERTY(OBJECT_ID('[security].[SQLMappings]'),'isLocked','AllowsNull') = 1)
BEGIN
	update [security].[SQLMappings] set [isLocked] = 1 where [SQLLogin] in (select SQLLogin from [security].[Contacts] where isLocked = 1)
	update [security].[SQLMappings] set [isLocked] = 0 where [SQLLogin] not in (select SQLLogin from [security].[Contacts] where isLocked = 1)
	
	alter table [security].[SQLMappings] ALTER column isLocked BIT NOT NULL
	
	if @@ERROR = 0	
		PRINT '   Table altered : column isLocked altered.'
	ELSE
		return	
END
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[security].[FK_SQLMappings_Contacts]') AND parent_object_id = OBJECT_ID(N'[security].[SQLMappings]'))
	ALTER TABLE [security].[SQLMappings] DROP CONSTRAINT [FK_SQLMappings_Contacts]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[security].[FK_SQLMappings_SQLLogins]') AND parent_object_id = OBJECT_ID(N'[security].[SQLMappings]'))
BEGIN
    ALTER TABLE [security].[SQLMappings]
        ADD  CONSTRAINT [FK_SQLMappings_SQLLogins]
            FOREIGN KEY (
                [ServerName],[SqlLogin]
            )
        REFERENCES [security].[SQLLogins] ([ServerName],[SqlLogin])
	IF @@ERROR = 0
		PRINT '   Foreign Key [FK_SQLMappings_SQLLogins] created.'
	ELSE
	BEGIN
		PRINT '   Error while trying to create Foreign Key [FK_SQLMappings_Contacts]'
		RETURN
	END
END
GO

IF (OBJECTPROPERTY( OBJECT_ID( '[security].[PK_SQLMappings]' ), 'TableHasPrimaryKey' ) <> 1)
BEGIN
    ALTER TABLE [security].[SQLMappings]
        ADD  CONSTRAINT [PK_SQLMappings ]
            PRIMARY KEY (
                [ServerName],[SqlLogin],[DbName]
            )
	IF @@ERROR = 0
		PRINT '   Primary Key [PK_SQLMappings] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[SQLMappings]') AND name = N'IDX_UN_SQLMappings_DefaultDb')
BEGIN
	CREATE UNIQUE INDEX 
		[IDX_UN_SQLMappings_DefaultDb] 
	ON [security].[SQLMappings] (
		[ServerName],
		[SqlLogin],
		[DbName],
		[isDefaultDb]
	)
	
	IF @@ERROR = 0 
		PRINT '    Index [security].[IDX_UN_SQLMappings_DefaultDb] created.'
END


IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_SQLMappings_isDefaultDb]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[SQLMappings]
        ADD CONSTRAINT [DF_SQLMappings_isDefaultDb] DEFAULT (0) FOR [isDefaultDb]
	IF @@ERROR = 0
		PRINT '   Constraint [DF_SQLMappings_isDefaultDb] created.'
END

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_SQLMappings_isLocked]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[SQLMappings]
        ADD CONSTRAINT [DF_SQLMappings_isLocked] DEFAULT (0) FOR [isLocked]
	IF @@ERROR = 0
		PRINT '   Constraint [DF_SQLMappings_isLocked] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_SQLMappings_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[SQLMappings]
        ADD CONSTRAINT [DF_SQLMappings_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	IF @@ERROR = 0
		PRINT '   Constraint [DF_SQLMappings_CreationDate] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_SQLMappings_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[SQLMappings]
        ADD CONSTRAINT [DF_SQLMappings_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	IF @@ERROR = 0
		PRINT '   Constraint [DF_SQLMappings_LastModified] created.'
END

GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_SQLMappings]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_SQLMappings] ' + CHAR(13) +
               '  ON security.SQLMappings ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	IF @@ERROR = 0
		PRINT '   Trigger [TRG_I_SQLMappings] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_SQLMappings]' + CHAR(13) +
            '    ON security.SQLMappings' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].SQLMappings ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].SQLMappings o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName] = i.[ServerName]' +CHAR(13) +
            '           and o.[SQLLogin]   = i.[SQLLogin]' +CHAR(13) +
            '           and o.[DbName]     = i.[DbName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);

IF @@ERROR = 0
	PRINT '   Trigger [TRG_I_SQLMappings] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_SQLMappings]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_SQLMappings] ' + CHAR(13) +
               '  ON security.SQLMappings ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	IF @@ERROR = 0
		PRINT '   Trigger [TRG_U_SQLMappings] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_SQLMappings]' + CHAR(13) +
            '    ON security.SQLMappings' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].SQLMappings ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].SQLMappings o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName] = i.[ServerName]' +CHAR(13) +
            '           and o.[SQLLogin]   = i.[SQLLogin]' +CHAR(13) +
            '           and o.[DbName]     = i.[DbName]' +CHAR(13) +			
            'END' ;
EXEC (@SQL);
IF @@ERROR = 0
	PRINT '   Trigger [TRG_U_SQLMappings] altered.'
GO



/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[StandardOnSchemaRolesSecurity] table.
		This table will contain a list of privileges assigned to security roles defined by our standard.

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
    23/04/2014  Jefferson Elias     VERSION 1.0.0
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[StandardOnSchemaRolesSecurity] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[StandardOnSchemaRolesSecurity](
        [RoleName] [varchar](64) NOT NULL,
        [PrivName] [varchar](128) NOT NULL,
        [isRoleMembership] [bit] NOT NULL,
        [isDeny] [bit] NOT NULL,
        [isActive] [bit] NOT NULL,
        [CreationDate] [date] NOT NULL,
        [lastmodified] [date] NOT NULL
    ) ON [PRIMARY]
	
	PRINT '    Table [security].[StandardOnSchemaRolesSecurity] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRolesSecurity_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        ADD CONSTRAINT [DF_StandardOnSchemaRolesSecurity_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	
	PRINT '    Constraint [DF_StandardOnSchemaRolesSecurity_CreationDate] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRolesSecurity_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        ADD CONSTRAINT [DF_StandardOnSchemaRolesSecurity_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	PRINT '    Constraint [DF_StandardOnSchemaRolesSecurity_LastModified] created.'
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[security].[FK_StandardOnSchemaRolesSecurity_StandardOnSchemaRoles]') AND parent_object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]'))
BEGIN
    ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        ADD  CONSTRAINT [FK_StandardOnSchemaRolesSecurity_StandardOnSchemaRoles]
            FOREIGN KEY(
                [RoleName]
            )
        REFERENCES [security].[StandardOnSchemaRoles] ([RoleName])
	
	PRINT '    Foreign key [FK_StandardOnSchemaRolesSecurity_StandardOnSchemaRoles] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]') AND name = N'PK_StandardOnSchemaRolesSecurity')
BEGIN
    ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        ADD  CONSTRAINT [PK_StandardOnSchemaRolesSecurity]
            PRIMARY KEY CLUSTERED (
                [RoleName] ASC,
                [PrivName] ASC
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
	PRINT '    Primary key [PK_StandardOnSchemaRolesSecurity] created.'
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_StandardOnSchemaRolesSecurity]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_StandardOnSchemaRolesSecurity] ' + CHAR(13) +
               '  ON security.StandardOnSchemaRolesSecurity ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '    Trigger [security].[TRG_I_StandardOnSchemaRolesSecurity] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_StandardOnSchemaRolesSecurity]' + CHAR(13) +
            '    ON security.StandardOnSchemaRolesSecurity' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardOnSchemaRolesSecurity ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].StandardOnSchemaRolesSecurity o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[RoleName] = i.[RoleName]' +CHAR(13) +
            '           and o.[PrivName] = i.[PrivName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_StandardOnSchemaRolesSecurity] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_StandardOnSchemaRolesSecurity]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_StandardOnSchemaRolesSecurity] ' + CHAR(13) +
               '  ON security.StandardOnSchemaRolesSecurity ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '    Trigger [security].[TRG_U_StandardOnSchemaRolesSecurity] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_StandardOnSchemaRolesSecurity]' + CHAR(13) +
            '    ON security.StandardOnSchemaRolesSecurity' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardOnSchemaRolesSecurity ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].StandardOnSchemaRolesSecurity o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[RoleName] = i.[RoleName]' +CHAR(13) +
            '           and o.[PrivName] = i.[PrivName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_StandardOnSchemaRolesSecurity] altered.'
GO


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 



/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[Login2DbUserMappings] view that lists active Login2DbUserMappings

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
	24/04/2014	Jefferson Elias		View creation change : adding column name to 'Not Implemented'
									VERSION 1.0.1
    --------------------------------------------------------------------------------
	24/04/2014	Jefferson Elias		Changed view according to Logins view changes
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'View [security].[Login2DbUserMappings] Creation'

DECLARE @SQL VARCHAR(MAX)
IF  NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[security].[Login2DbUserMappings]'))
BEGIN
    SET @SQL =  'CREATE view [security].[Login2DbUserMappings]
                AS
                select ''Not implemented'' as Col1'
    EXEC (@SQL)
	
	IF @@ERROR = 0
		PRINT '    View [security].[Login2DbUserMappings] created.'
	ELSE
	BEGIN
		PRINT 'An error occured. Unable to carry on !'
		return
	END
	
END

SET @SQL = 'ALTER view [security].[Login2DbUserMappings]
                AS
				select
                    [Name],
                    [Job],
                    [Department],
                    [AuthMode],
                    [ServerName],
                    [SQLLogin],
                    [DbName],
                    [SQLLogin] as [UserName],
                    [DefaultSchema]
                from [security].[logins]
                where isActive = 1'
EXEC (@SQL)
GO
if @@ERROR = 0
	PRINT '    View [security].[Login2DbUserMappings] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 



/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[OnSchemaPrivs] table.
		This table will contain any privilege on schema

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
    23/04/2014  Jefferson Elias     VERSION 1.0.0
    --------------------------------------------------------------------------------
	25/04/2014	Jefferson Elias		Added foreign key to SQLMappings table
									Added Primary key to this table
									VERSION 1.0.1
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[OnSchemaPrivs] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[OnSchemaPrivs]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[OnSchemaPrivs] (
        [ServerName]   [VARCHAR](256) 	NOT NULL,
        [DbName]       [VARCHAR](64) 	NOT NULL,
        [SQLLogin]     [VARCHAR](256) 	NOT NULL,
        [SchemaName]   [VARCHAR](64) 	NOT NULL,
        [RoleName]     [VARCHAR](64) 	NOT NULL,
        [isActive]     [BIT]            NOT NULL,
        [CreationDate] [datetime] 		NOT NULL,
        [lastmodified] [datetime] 		NOT NULL
    )
    ON [PRIMARY]
	PRINT '    Table [security].[OnSchemaPrivs] created.'
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[security].[FK_OnSchemaPrivs_SQLMappings]') AND parent_object_id = OBJECT_ID(N'[security].[OnSchemaPrivs]'))
BEGIN
    ALTER TABLE [security].[OnSchemaPrivs]
        ADD  CONSTRAINT [FK_OnSchemaPrivs_SQLMappings]
            FOREIGN KEY (
                [ServerName],[SqlLogin],[DbName]
            )
        REFERENCES [security].[SQLMappings] ([ServerName],[SqlLogin],[DbName])
	PRINT '   Foreign Key [FK_OnSchemaPrivs_SQLMappings] created.'
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[security].[FK_OnSchemaPrivs_StandardOnSchemaRoles]') AND parent_object_id = OBJECT_ID(N'[security].[OnSchemaPrivs]'))
BEGIN
    ALTER TABLE [security].[OnSchemaPrivs]
        ADD  CONSTRAINT [FK_OnSchemaPrivs_StandardOnSchemaRoles]
            FOREIGN KEY(
                [RoleName]
            )
        REFERENCES [security].[StandardOnSchemaRoles] ([RoleName])
	
	PRINT '    Foreign key [FK_OnSchemaPrivs_StandardOnSchemaRoles] created.'
END
GO

IF (OBJECTPROPERTY( OBJECT_ID( '[security].[PK_OnSchemaPrivs]' ), 'TableHasPrimaryKey' ) <> 1)
BEGIN
    ALTER TABLE [security].[OnSchemaPrivs]
        ADD  CONSTRAINT [PK_OnSchemaPrivs ]
            PRIMARY KEY (
                [ServerName],[DbName],[SqlLogin],[SchemaName]
            )
	PRINT '   Primary Key [PK_OnSchemaPrivs] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_OnSchemaPrivs_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[OnSchemaPrivs]
        ADD CONSTRAINT [DF_OnSchemaPrivs_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	PRINT '    Constraint [DF_OnSchemaPrivs_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_OnSchemaPrivs_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[OnSchemaPrivs]
        ADD CONSTRAINT [DF_OnSchemaPrivs_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	PRINT '    Constraint [DF_OnSchemaPrivs_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_OnSchemaPrivs_ServerName]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[OnSchemaPrivs]
        ADD CONSTRAINT [DF_OnSchemaPrivs_ServerName] DEFAULT (@@SERVERNAME) FOR [ServerName]

	PRINT '    Constraint [DF_OnSchemaPrivs_ServerName] created.'		
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_OnSchemaPrivs_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[OnSchemaPrivs]
        ADD CONSTRAINT [DF_OnSchemaPrivs_isActive] DEFAULT (0) FOR  [isActive]

	PRINT '    Constraint [DF_OnSchemaPrivs_isActive] created.'				
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_OnSchemaPrivs]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_OnSchemaPrivs] ' + CHAR(13) +
               '  ON security.OnSchemaPrivs ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '    Trigger [security].[TRG_I_OnSchemaPrivs] created.'			
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_OnSchemaPrivs]' + CHAR(13) +
            '    ON security.OnSchemaPrivs' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].OnSchemaPrivs ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].OnSchemaPrivs o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName]  = i.[ServerName]' +CHAR(13) +
            '           and o.DbName        = i.DbName' +CHAR(13) +
            '           and o.[SQLLogin]    = i.[SQLLogin]' +CHAR(13) +
            '           and o.[SchemaName]  = i.[SchemaName]' +CHAR(13) +
            '           and o.[RoleName]    = i.[RoleName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);

PRINT '    Trigger [security].[TRG_I_OnSchemaPrivs] altered.'			

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_OnSchemaPrivs]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_OnSchemaPrivs] ' + CHAR(13) +
               '  ON security.OnSchemaPrivs ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '    Trigger [security].[TRG_U_OnSchemaPrivs] created.'			
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_OnSchemaPrivs]' + CHAR(13) +
            '    ON security.OnSchemaPrivs' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].OnSchemaPrivs ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].OnSchemaPrivs o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName]  = i.[ServerName]' +CHAR(13) +
            '           and o.DbName        = i.DbName' +CHAR(13) +
            '           and o.[SQLLogin]    = i.[SQLLogin]' +CHAR(13) +
            '           and o.[SchemaName]  = i.[SchemaName]' +CHAR(13) +
            '           and o.[RoleName]    = i.[RoleName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);

PRINT '    Trigger [security].[TRG_U_OnSchemaPrivs] altered.'		
GO


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 





/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[ReferencedSchemas] view that lists schemas 
		referenced into *privs + sqllogins

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
	24/04/2014	Jefferson Elias		View creation change : adding column name to 'Not Implemented'
									VERSION 1.0.1
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'View [security].[ReferencedSchemas] Creation'

DECLARE @SQL VARCHAR(MAX)
IF  NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[security].[ReferencedSchemas]'))
BEGIN
    SET @SQL =  'CREATE view [security].[ReferencedSchemas]
                AS
                select ''Not implemented'' as Col1'
    EXEC (@SQL)
	PRINT '    View [security].[logins] created.'
END

SET @SQL = 'ALTER view [security].[ReferencedSchemas]
            AS
                select distinct ServerName,DbName, SchemaName, ''Schema Permissions'' as [Source] from [Security].OnSchemaPrivs where isActive = 1
                union
                select distinct ServerName,DbName, SchemaName, ''Object Permissions'' as [Source] from [Security].OnObjectPrivs where isActive = 1
                union
                select distinct ServerName,DbName, DefaultSchema as SchemaName , ''Logins Information'' as [Source] from [Security].Logins
            '
EXEC (@SQL)
PRINT '    View [security].[ReferencedSchemas] altered.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 