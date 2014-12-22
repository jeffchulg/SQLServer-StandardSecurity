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
	26/11/2014	Jefferson Elias		Added enclosing BEGIN-END in the creation of 
									CK_Contacts_AuthMode.
									VERSION 1.0.1
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
BEGIN
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
END
GO


IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_Contacts_AuthMode]') AND parent_object_id = OBJECT_ID(N'[security].[Contacts]'))
BEGIN
    ALTER TABLE [security].[Contacts]
        WITH CHECK ADD CONSTRAINT [CK_Contacts_AuthMode]
            CHECK (([authmode]='SQLSRVR' OR [authmode]='WINDOWS'))
	PRINT '     Constraint [CK_Contacts_AuthMode] created.'
END
GO

IF NOT EXISTS (SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = OBJECT_ID('[security].[CK_Contacts_AuthMode]') AND [name] = N'MS_Description' AND [minor_id] = 0)
BEGIN 
    EXEC sys.Sp_addextendedproperty
      @name=N'MS_Description',
      @value=N'Vérifie que la valeur est dans (''WINDOWS'',''SQLSRVR)',
      @level0type=N'SCHEMA',
      @level0name=N'security',
      @level1type=N'TABLE',
      @level1name=N'Contacts',
      @level2type=N'CONSTRAINT',
      @level2name=N'CK_Contacts_AuthMode'	  
END
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
	25/11/2014	Jefferson Elias		Date columns transformed to datetime
    --------------------------------------------------------------------------------
    17/12/2014  Jefferson Elias     Added MERGE statement for default parameters    
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
        [creationdate]  [datetime]      NOT NULL,
        [lastmodified]  [datetime]      NOT NULL,

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
ELSE
BEGIN

	IF EXISTS( 
	    SELECT 1 
		FROM  sys.columns 
        WHERE Name = 'CreationDate' and Object_ID = Object_ID(N'[security].[ApplicationParams]') and system_type_id = 40
    )
	BEGIN
		-- no other way I know ... drop default constraint and it will be re-created afterwards in this script.
		
		IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_ApplicationParams_CreationDate]') AND type = 'D')
		BEGIN
			execute sp_executesql N'alter table [security].[ApplicationParams] drop constraint DF_ApplicationParams_CreationDate'
		END 
		
	    execute sp_executesql N'ALTER TABLE [security].[ApplicationParams] ALTER COLUMN [CreationDate] datetime not null'
		PRINT '    Column CreationDate from [security].[ApplicationParams] modified from date to datetime.'
	END
	
	IF EXISTS( 
	    SELECT 1 
		FROM  sys.columns 
        WHERE Name = 'lastmodified' and Object_ID = Object_ID(N'[security].[ApplicationParams]') and system_type_id = 40
    )
	BEGIN
		
		-- no other way I know ... drop default constraint and it will be re-created afterwards in this script.
		
		IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_ApplicationParams_lastmodified]') AND type = 'D')
		BEGIN
			execute sp_executesql N'alter table [security].[ApplicationParams] drop constraint DF_ApplicationParams_lastmodified'
		END 
		
	    execute sp_executesql N'ALTER TABLE [security].[ApplicationParams] ALTER COLUMN [lastmodified] datetime not null'
		PRINT '    Column lastmodified from [security].[ApplicationParams] modified from date to datetime.'
	END

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

PRINT 'Adding default data'
GO

merge security.ApplicationParams p
using (
	select 'Separator4OnSchemaStandardRole' as ParamName, '_' as ParamValue,'_' as DefaultValue,0 as isDepreciated ,'Separator for standard generated roles' as Description
	union all
	select 'MSSQL_LoginSecurity_DefaultPassword','123456a.','123456a.',0,'Default password to assign to a newly created SQL Server authenticated login.'
	union all
	select 'ObjectPermissionGrantorDenier','dbo','dbo',0,'Name of the grantor to use for object permission grant/deny GRANT <PERMISSION> ON <OBJECT> TO <GRANTEE> AS <ObjectPermissionGrantorDenier>'
	union all
	select 'SchemaAuthorization4Creation','dbo','dbo',0,'Value in the TSQL Command CREATE SCHEMA ... AUTHORIZATION [<SchemaAuthorization4Creation>]'
	union all 
	select 'Version','0.1.0','0.1.0',0,'Version number for the solution'
) i
on p.ParamName = i.ParamName
WHEN MATCHED THEN
	update set
		ParamValue    = i.ParamValue,
		DefaultValue  = i.DefaultValue,
		isDepreciated = i.isDepreciated,
		[Description] = i.[Description]
WHEN NOT MATCHED BY TARGET THEN
	insert (
		ParamName,
		ParamValue,
		DefaultValue,
		isDepreciated,
		[Description]
	)
	values (
		i.ParamName,
		i.ParamValue,
		i.DefaultValue,
		i.isDepreciated,
		i.Description
	)
;
PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 



/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[StandardExclusion] table.
		
		This table will contain exclusion to standard application such as default 
		schema names and so on.

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
    25/11/2014  Jefferson Elias     Creation
    --------------------------------------------------------------------------------
	26/11/2014	Jefferson Elias		Added merge statements for default exclusion
									to force the upsert of values.
									Added check constraint for ObjectType to be in 
										(DATABASE,DATABASE_SCHEMA)
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[StandardExclusion] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardExclusion]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[StandardExclusion] (
        [ObjectType]   		[VARCHAR](256) NOT NULL, /* DATABASE ; DATABASE_SCHEMA */
        [ObjectName]   		[VARCHAR](256) NOT NULL,
		[Description]		[varchar](2048) NOT NULL,
		[isActive]	  		BIT		NOT NULL,
        [CreationDate]    	datetime NOT NULL,
        [lastmodified]    	datetime NOT NULL
    )
    ON [PRIMARY]
	PRINT '   Table [StandardExclusion] created.'
END
GO

IF (OBJECTPROPERTY( OBJECT_ID( '[security].[PK_StandardExclusion]' ), 'TableHasPrimaryKey' ) <> 1)
BEGIN
    ALTER TABLE [security].[StandardExclusion]
        ADD  CONSTRAINT [PK_StandardExclusion ]
            PRIMARY KEY (
                [ObjectType],[ObjectName]
            )
	PRINT '   Primary Key [PK_StandardExclusion] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardExclusion_ObjectType]') AND parent_object_id = OBJECT_ID(N'[security].[StandardExclusion]'))
BEGIN
    ALTER TABLE [security].[StandardExclusion]
        WITH CHECK ADD CONSTRAINT [CK_StandardExclusion_ObjectType]
            CHECK ([ObjectType] in ('DATABASE','DATABASE_SCHEMA'))
	PRINT '     Constraint [CK_StandardExclusion_ObjectType] created.'
END
GO



IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardExclusion_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardExclusion]
        ADD CONSTRAINT [DF_StandardExclusion_isActive] DEFAULT (1) FOR [isActive]
	PRINT '   Constraint [DF_StandardExclusion_isActive] created.'
END

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardExclusion_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardExclusion]
        ADD CONSTRAINT [DF_StandardExclusion_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	PRINT '   Constraint [DF_StandardExclusion_CreationDate] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardExclusion_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardExclusion]
        ADD CONSTRAINT [DF_StandardExclusion_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	PRINT '   Constraint [DF_StandardExclusion_LastModified] created.'
END

GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_StandardExclusion]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_StandardExclusion] ' + CHAR(13) +
               '  ON security.StandardExclusion ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '   Trigger [TRG_I_StandardExclusion] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_StandardExclusion]' + CHAR(13) +
            '    ON security.StandardExclusion' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardExclusion ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].StandardExclusion o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ObjectType] = i.[ObjectType]' +CHAR(13) +
            '           and o.[ObjectName] = i.[ObjectName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '   Trigger [TRG_I_StandardExclusion] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_StandardExclusion]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_StandardExclusion] ' + CHAR(13) +
               '  ON security.StandardExclusion ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '   Trigger [TRG_U_StandardExclusion] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_StandardExclusion]' + CHAR(13) +
            '    ON security.StandardExclusion' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardExclusion ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].StandardExclusion o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ObjectType] = i.[ObjectType]' +CHAR(13) +
            '           and o.[ObjectName] = i.[ObjectName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '   Trigger [TRG_U_StandardExclusion] altered.'
GO

PRINT 'Populating table with default data'
PRINT ''

create table #tmp_StandardExclusion (
        [ObjectType]   		[VARCHAR](256) NOT NULL, /* DATABASE ; SCHEMA */
        [ObjectName]   		[VARCHAR](256) NOT NULL,
		[Description]		[varchar](2048) NOT NULL,
		[isActive]	  		BIT		NOT NULL
)
GO

insert into #tmp_StandardExclusion (
	[ObjectType],
	[ObjectName],
	[Description],
	[isActive]
)
values 
	(
		'DATABASE',
		'master',
		'System database - should be used wisely and for punctual permission assignments',
		1
	),
	(
		'DATABASE' ,
		'msdb',
		'System Utility database - should be used wisely and for punctual permission assignments',
		1
	),
	(
		'DATABASE' ,
		'tempdb',
		'System Utility database - no known usage of implementing security in this database',
		1
	),
	( 
		'DATABASE' ,
		'model',
		'System database - is of no use as itself for permissions. Way better to make it for each database created !',
		1
	),
	( 
		'DATABASE_SCHEMA' ,
		'dbo',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),
	(
		'DATABASE_SCHEMA' ,
		'sys',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),
	( 
		'DATABASE_SCHEMA' ,
		'information_schema',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),	
	( 
		'DATABASE_SCHEMA' ,
		'db_accessadmin',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),
	( 
		'DATABASE_SCHEMA' ,
		'db_backupoperator',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),
	( 
		'DATABASE_SCHEMA' ,
		'db_datareader',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),
	( 
		'DATABASE_SCHEMA' ,
		'db_datawriter',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),	
	( 
		'DATABASE_SCHEMA' ,
		'db_ddladmin',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),	
	( 
		'DATABASE_SCHEMA' ,
		'db_denydatareader',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),
	( 
		'DATABASE_SCHEMA' ,
		'db_denydatawriter',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),
	( 
		'DATABASE_SCHEMA' ,
		'db_owner',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),
	( 
		'DATABASE_SCHEMA' ,
		'db_securityadmin',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	),
	( 
		'DATABASE_SCHEMA' ,
		'guest',
		'System schema - should be used wisely and for punctual permission assignments',
		1
	)	

--select * from #tmp_StandardExclusion

merge security.StandardExclusion c
using #tmp_StandardExclusion n
  on c.objectType = n.objectType
  and c.objectName = n.objectName
WHEN MATCHED THEN 
	UPDATE SET 
		[Description] = n.[description],
		[isActive]    = n.[isActive] 
WHEN NOT MATCHED BY TARGET THEN
	INSERT (ObjectType,ObjectName,[Description],isActive)
		VALUES (n.[ObjectType],n.[ObjectName],n.[Description],n.[isActive])
/*WHEN NOT MATCHED BY SOURCE THEN
	DELETE */
;
drop table #tmp_StandardExclusion;

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 

GO

/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[DatabaseRoles] table.
		This table will contain all database roles that are created in a given 
		database on a given server.

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
    26/11/2014  Jefferson Elias     Creation
	--------------------------------------------------------------------------------	
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[DatabaseRoles] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[DatabaseRoles]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[DatabaseRoles] (
        [ServerName]        [VARCHAR](256) NOT NULL,
        [DbName]            [VARCHAR](64) NOT NULL,
        [RoleName]          [VARCHAR](64) NOT NULL,
        [isStandard]        [BIT] NOT NULL,
		[Reason]            VARCHAR(2048),		
        [isActive]          BIT            NOT NULL,
        [CreationDate]      [datetime] NULL,
        [lastmodified]      [datetime] NULL
    )
    ON [PRIMARY]
	PRINT '    Table [security].[DatabaseRoles] created.'
END/*
ELSE
BEGIN
    PRINT '    No modifications for table [security].[DatabaseRoles]'
END*/
GO

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[DatabaseRoles]') AND name = N'PK_DatabaseRoles')
BEGIN    
	ALTER TABLE [security].[DatabaseRoles]
        ADD CONSTRAINT [PK_DatabaseRoles]
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
	
	PRINT '    Primary Key [PK_DatabaseRoles] created.'
END
GO


IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseRoles_isStandard]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseRoles]
        ADD CONSTRAINT [DF_DatabaseRoles_isStandard]
            DEFAULT 0 FOR [isStandard]
	
	PRINT '    Constraint [DF_DatabaseRoles_isStandard] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseRoles_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseRoles]
        ADD CONSTRAINT [DF_DatabaseRoles_CreationDate]
            DEFAULT (Getdate()) FOR [CreationDate]
	
	PRINT '    Constraint [DF_DatabaseRoles_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseRoles_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseRoles]
        ADD CONSTRAINT [DF_DatabaseRoles_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	PRINT '    Constraint [DF_DatabaseRoles_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseRoles_ServerName]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseRoles]
        ADD CONSTRAINT [DF_DatabaseRoles_ServerName] DEFAULT (@@SERVERNAME) FOR [ServerName]
	
	PRINT '    Constraint [DF_DatabaseRoles_ServerName] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseRoles_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseRoles]
        ADD CONSTRAINT [DF_DatabaseRoles_isActive] DEFAULT (0) FOR [isActive]
	
	PRINT '    Constraint [DF_DatabaseRoles_isActive] created.'
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_DatabaseRoles]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_DatabaseRoles] ' + CHAR(13) +
               '  ON security.DatabaseRoles ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '    Trigger [security].[TRG_I_DatabaseRoles] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_DatabaseRoles]' + CHAR(13) +
            '    ON security.DatabaseRoles' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].DatabaseRoles ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].DatabaseRoles o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName] = i.[ServerName]' +CHAR(13) +
            '           and o.DbName = i.DbName' +CHAR(13) +
            '           and o.[RoleName] = i.[RoleName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_DatabaseRoles] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_DatabaseRoles]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_DatabaseRoles] ' + CHAR(13) +
               '  ON security.DatabaseRoles ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '    Trigger [security].[TRG_U_DatabaseRoles] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_DatabaseRoles]' + CHAR(13) +
            '    ON security.DatabaseRoles' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].DatabaseRoles ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].DatabaseRoles o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName] = i.[ServerName]' +CHAR(13) +
            '           and o.DbName = i.DbName' +CHAR(13) +
            '           and o.[RoleName] = i.[RoleName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_DatabaseRoles] altered.'
GO


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
	25/11/2014	Jefferson Elias		Date columns transformed to datetime.
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
        [moment]        [datetime]   					NOT NULL,
        [program]       [varchar](256) 					NOT NULL,
        [loglevel]      [varchar](8) 					NOT NULL,
        [logmessage]    [varchar](max) 					NOT NULL
    ) ON [PRIMARY]
	
	PRINT '    Table [security].[ApplicationLog] created.'
END
ELSE
BEGIN
    IF EXISTS( 
	    SELECT 1 
		FROM  sys.columns 
        WHERE Name = 'moment' and Object_ID = Object_ID(N'[security].[ApplicationLog]') and system_type_id = 40
    )
	BEGIN
	    execute sp_executesql N'ALTER TABLE [security].[ApplicationLog] ALTER COLUMN [moment] datetime not null'
		PRINT '    Column moment from [security].[ApplicationLog] modified from date to datetime.'
	END
END
GO


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 


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
    28/11/2014  Jefferson Elias     Creation
	--------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[DatabaseSchemas] Creation'

IF  NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[security].[DatabaseSchemas]'))
BEGIN
	CREATE TABLE [security].[DatabaseSchemas](
		[ServerName]    [varchar](256) NOT NULL,
		[DbName]        [varchar](64) NOT NULL,
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
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_DatabaseSchemas] altered.'
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
	25/11/2014	Jefferson Elias		Date columns transformed to datetime
    --------------------------------------------------------------------------------	
	28/11/2014	Jefferson Elias		Added column 'Description'
    --------------------------------------------------------------------------------	
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[StandardOnSchemaRoles] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRoles]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[StandardOnSchemaRoles](
        [RoleName]      [varchar](64) 	NOT NULL,
		[Description]	[varchar](2048),
        [isActive]      [bit]		 	NOT NULL,
        [CreationDate]  [datetime] 		NOT NULL,
        [lastmodified]  [datetime] 		NOT NULL
    ) ON [PRIMARY]
	PRINT '    Table [security].[StandardOnSchemaRoles] created.'
END
ELSE
BEGIN

	IF EXISTS( 
	    SELECT 1 
		FROM  sys.columns 
        WHERE Name = 'CreationDate' and Object_ID = Object_ID(N'[security].[StandardOnSchemaRoles]') and system_type_id = 40
    )
	BEGIN
		-- no other way I know ... drop default constraint and it will be re-created afterwards in this script.
		
		IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRoles_CreationDate]') AND type = 'D')
		BEGIN
			execute sp_executesql N'alter table [security].[StandardOnSchemaRoles] drop constraint DF_StandardOnSchemaRoles_CreationDate'
		END 
		
	    execute sp_executesql N'ALTER TABLE [security].[StandardOnSchemaRoles] ALTER COLUMN [CreationDate] datetime not null'
		PRINT '    Column CreationDate from [security].[StandardOnSchemaRoles] modified from date to datetime.'
	END
	
	IF EXISTS( 
	    SELECT 1 
		FROM  sys.columns 
        WHERE Name = 'lastmodified' and Object_ID = Object_ID(N'[security].[StandardOnSchemaRoles]') and system_type_id = 40
    )
	BEGIN
		
		-- no other way I know ... drop default constraint and it will be re-created afterwards in this script.
		
		IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRoles_lastmodified]') AND type = 'D')
		BEGIN
			execute sp_executesql N'alter table [security].[StandardOnSchemaRoles] drop constraint DF_StandardOnSchemaRoles_lastmodified'
		END 
		
	    execute sp_executesql N'ALTER TABLE [security].[StandardOnSchemaRoles] ALTER COLUMN [lastmodified] datetime not null'
		PRINT '    Column lastmodified from [security].[StandardOnSchemaRoles] modified from date to datetime.'
	END

	IF NOT EXISTS( SELECT * from sys.columns where OBJECT_SCHEMA_NAME(object_id) = 'security' and OBJECT_NAME(object_id) = 'StandardOnSchemaRoles' and name = 'Description')
	BEGIN
		ALTER TABLE [security].[StandardOnSchemaRoles] add [Description] [varchar](2048)
		PRINT '   Table altered : column Description added.'
	END
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
		Creation of the [security].[DatabasePermissions] table.
		This table will contain any permission in a given database. 
			These permissions can be of class  (at the moment) :
				'SERVER','DATABASE','DATABASE_SCHEMA','SCHEMA_OBJECT','SCHEMA_OBJECT_COLUMN','DATABASE_USER'

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
    28/11/2014  Jefferson Elias     Creation
    ----------------------------------------------------------------------------------
    17/12/2014  Jefferson Elias     Added 2 computed columns for the unique constraint
                                    to be correct...
                                    Changed the unique constraint.
                                    As previous version wasn't a stable release,
                                    no ALTER for that.
    ----------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[DatabasePermissions] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[DatabasePermissions]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[DatabasePermissions] (
        [ServerName]        [VARCHAR](256) NOT NULL,
        [DbName]            [VARCHAR](64) NOT NULL,
        [Grantee]           [VARCHAR](64) NOT NULL,
        [isUser]            [BIT] NOT NULL,
		[ObjectClass]       [VARCHAR](128) NOT NULL,
		[ObjectType]        [VARCHAR](128) ,
		[PermissionLevel] 	[varchar](6) DEFAULT 'GRANT' not null,
        [PermissionName]    [VARCHAR](128) NOT NULL,
        [SchemaName]        [VARCHAR](64) ,
        [ObjectName]        [VARCHAR](128) NOT NULL,        
        [SubObjectName]     [VARCHAR](128), -- column_name , partition_name        		
        [isWithGrantOption] BIT NOT NULL,
		[Reason]            VARCHAR(2048),
        [isActive]          BIT            NOT NULL,
        [CreationDate]      [datetime] NULL,
        [lastmodified]      [datetime] NULL,  
        [FullObjectType]    AS (
                                [ObjectClass] +  ISNULL([ObjectType],'')
                            ),
        [FullObjectName]    AS (
                                isNULL([SchemaName],'') + [ObjectName] + isNULL([SubObjectName],'')
                            )
    )
    ON [PRIMARY]
	PRINT '    Table [security].[DatabasePermissions] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[DatabasePermissions]') AND name = N'UN_DatabasePermissions')
BEGIN
    ALTER TABLE [security].[DatabasePermissions]
        ADD CONSTRAINT [UN_DatabasePermissions]
            UNIQUE (
                [ServerName],
				[DbName],
				[Grantee],
				[FullObjectType],
				[PermissionName],
				[FullObjectName]
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
	
	PRINT '    Primary Key [UN_DatabasePermissions] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_DatabasePermissions_ObjectClass]') AND parent_object_id = OBJECT_ID(N'[security].[DatabasePermissions]'))
BEGIN
    ALTER TABLE [security].[DatabasePermissions]
        WITH CHECK ADD CONSTRAINT [CK_DatabasePermissions_ObjectClass]
            CHECK (([ObjectClass] in ('SERVER','DATABASE','DATABASE_SCHEMA','SCHEMA_OBJECT','SCHEMA_OBJECT_COLUMN','DATABASE_USER')))
	PRINT '     Constraint [CK_DatabasePermissions_ObjectClass] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_DatabasePermissions_PermissionLevel]') AND parent_object_id = OBJECT_ID(N'[security].[DatabasePermissions]'))
BEGIN
    ALTER TABLE [security].[DatabasePermissions]
        WITH CHECK ADD CONSTRAINT [CK_DatabasePermissions_PermissionLevel]
            CHECK (([PermissionLevel] in ('GRANT','REVOKE','DENY')))
	PRINT '     Constraint [CK_DatabasePermissions_PermissionLevel] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[CK_DatabasePermissions_OnlyGrantWithGrantOption]') AND type = 'C')
BEGIN
    ALTER TABLE [security].[DatabasePermissions]
        ADD  CONSTRAINT [CK_DatabasePermissions_OnlyGrantWithGrantOption]
            CHECK  ((NOT (PermissionLevel <> 'GRANT' AND [isWithGrantOption]=(1))))
	
	PRINT '    Constraint [CK_DatabasePermissions_OnlyGrantWithGrantOption] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabasePermissions_isWithGrantOption]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabasePermissions]
        ADD CONSTRAINT [DF_DatabasePermissions_isWithGrantOption]
            DEFAULT 0 FOR [isWithGrantOption]
	
	PRINT '    Constraint [DF_DatabasePermissions_isWithGrantOption] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabasePermissions_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabasePermissions]
        ADD CONSTRAINT [DF_DatabasePermissions_CreationDate]
            DEFAULT (Getdate()) FOR [CreationDate]
	
	PRINT '    Constraint [DF_DatabasePermissions_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabasePermissions_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabasePermissions]
        ADD CONSTRAINT [DF_DatabasePermissions_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	PRINT '    Constraint [DF_DatabasePermissions_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabasePermissions_ServerName]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabasePermissions]
        ADD CONSTRAINT [DF_DatabasePermissions_ServerName] DEFAULT (@@SERVERNAME) FOR [ServerName]
	
	PRINT '    Constraint [DF_DatabasePermissions_ServerName] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabasePermissions_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabasePermissions]
        ADD CONSTRAINT [DF_DatabasePermissions_isActive] DEFAULT (0) FOR [isActive]
	
	PRINT '    Constraint [DF_DatabasePermissions_isActive] created.'
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_DatabasePermissions]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_DatabasePermissions] ' + CHAR(13) +
               '  ON security.DatabasePermissions ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '    Trigger [security].[TRG_I_DatabasePermissions] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_DatabasePermissions]' + CHAR(13) +
            '    ON security.DatabasePermissions' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].DatabasePermissions ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].DatabasePermissions o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName] = i.[ServerName]' +CHAR(13) +
            '           and o.DbName = i.DbName' +CHAR(13) +
            '           and o.[grantee] = i.[grantee]' +CHAR(13) +
            '           and o.[ObjectClass] = i.[ObjectClass]' +CHAR(13) +
            '           and ISNULL(o.[ObjectType],''null'') = ISNULL(i.[ObjectType],''null'')' +CHAR(13) +
            '           and o.[PermissionName] = i.[PermissionName]' +CHAR(13) +
            '           and ISNULL(o.[SchemaName],''null'') = ISNULL(i.[SchemaName],''null'')' +CHAR(13) +
            '           and o.[objectname] = i.[objectname]' +CHAR(13) +        
            '           and ISNULL(o.[SubObjectName],''null'') = ISNULL(i.[SubObjectName],''null'')' +CHAR(13) +        
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_DatabasePermissions] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_DatabasePermissions]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_DatabasePermissions] ' + CHAR(13) +
               '  ON security.DatabasePermissions ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '    Trigger [security].[TRG_U_DatabasePermissions] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_DatabasePermissions]' + CHAR(13) +
            '    ON security.DatabasePermissions' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].DatabasePermissions ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].DatabasePermissions o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName] = i.[ServerName]' +CHAR(13) +
            '           and o.DbName = i.DbName' +CHAR(13) +
            '           and o.[grantee] = i.[grantee]' +CHAR(13) +
            '           and o.[ObjectClass] = i.[ObjectClass]' +CHAR(13) +
            '           and ISNULL(o.[ObjectType],''null'') = ISNULL(i.[ObjectType],''null'')' +CHAR(13) +
            '           and o.[PermissionName] = i.[PermissionName]' +CHAR(13) +
            '           and ISNULL(o.[SchemaName],''null'') = ISNULL(i.[SchemaName],''null'')' +CHAR(13) +
            '           and o.[objectname] = i.[objectname]' +CHAR(13) +        
            '           and ISNULL(o.[SubObjectName],''null'') = ISNULL(i.[SubObjectName],''null'')' +CHAR(13) +     
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_DatabasePermissions] altered.'
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

/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[DatabaseRoleMembers] table.
		This table will define members of a any database role that will be create for 
		a given database on a given server.
		A member can be either a user or a role

		Note : this table should be split in two for data integrity insurance.
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
    27/11/2014  Jefferson Elias     Creation
    ----------------------------------------------------------------------------------
    17/12/2014  Jefferson Elias     Added column "PermissionLevel" with 
                                    available values  : GRANT, REVOKE 
                                    and default value GRANT
    ----------------------------------------------------------------------------------                                    
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[DatabaseRoleMembers] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[DatabaseRoleMembers]') AND type in (N'U'))
BEGIN
	CREATE TABLE [security].[DatabaseRoleMembers](
		[ServerName]    [varchar](256) NOT NULL,
		[DbName]        [varchar](64) NOT NULL,
		[RoleName]      [varchar](64) NOT NULL,
		[MemberName]	[varchar](64) NOT NULL,
		[MemberIsRole]	[bit] NOT NULL,
        [PermissionLevel] [varchar](6) DEFAULT 'GRANT' NOT NULL ,
		[Reason]		[varchar](2048),
		[isActive]      [bit] NOT NULL,
		[CreationDate]  [datetime] NOT NULL,
		[lastmodified]  [datetime] NOT NULL
	) ON [PRIMARY]
	
	PRINT '    Table [security].[DatabaseRoleMembers] created.'
END
/*
BEGIN
	PRINT '    Table [security].[DatabaseRoleMembers] modified.'	
END
*/
GO

IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_DatabaseRoleMembers_PermissionLevel]') AND parent_object_id = OBJECT_ID(N'[security].[DatabaseRoleMembers]'))
BEGIN
    ALTER TABLE [security].[DatabaseRoleMembers]
        WITH CHECK ADD CONSTRAINT [CK_DatabaseRoleMembers_PermissionLevel]
            CHECK (([PermissionLevel] in ('GRANT','REVOKE')))
	PRINT '     Constraint [CK_DatabaseRoleMembers_PermissionLevel] created.'
END
GO


IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseRoleMembers_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseRoleMembers]
        ADD CONSTRAINT [DF_DatabaseRoleMembers_CreationDate]
            DEFAULT (Getdate()) FOR [CreationDate]
		
	PRINT '    Constraint [DF_DatabaseRoleMembers_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseRoleMembers_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseRoleMembers]
        ADD CONSTRAINT [DF_DatabaseRoleMembers_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	PRINT '    Constraint [DF_CustomRoles_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseRoleMembers_ServerName]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseRoleMembers]
        ADD CONSTRAINT [DF_DatabaseRoleMembers_ServerName] DEFAULT (@@SERVERNAME) FOR [ServerName]
	
	PRINT '    Constraint [DF_DatabaseRoleMembers_ServerName] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_DatabaseRoleMembers_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[DatabaseRoleMembers]
        ADD CONSTRAINT [DF_DatabaseRoleMembers_isActive] DEFAULT (0) FOR [isActive]
		
	PRINT '    Constraint [DF_DatabaseRoleMembers_isActive] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[DatabaseRoleMembers]') AND name = N'PK_DatabaseRoleMembers')
BEGIN
    ALTER TABLE [security].[DatabaseRoleMembers]
        ADD CONSTRAINT [PK_DatabaseRoleMembers]
            PRIMARY KEY CLUSTERED (
                [ServerName],
				[DbName],
				[RoleName],
				[MemberName]
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
	
	PRINT '    Primary Key [PK_DatabaseRoleMembers] created.'
END
GO


IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[DatabaseRoles]') AND name = N'PK_DatabaseRoles')
	and not EXISTS (SELECT * FROM sys.foreign_keys  WHERE parent_object_id = OBJECT_ID(N'[security].[DatabaseRoleMembers]') AND name = N'FK_DatabaseRoleMembers_DatabaseRoles')
BEGIN
    ALTER TABLE [security].[DatabaseRoleMembers]
        ADD CONSTRAINT [FK_DatabaseRoleMembers_DatabaseRoles]
            FOREIGN KEY (
                [ServerName],
				[DbName],
				[RoleName]
            )			
			REFERENCES [security].[DatabaseRoles] (
                [ServerName],
				[DbName],
				[RoleName]
            )
	
	PRINT '    Foreign Key [FK_DatabaseRoleMembers_CustomRoles] created.'
END
GO


DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_DatabaseRoleMembers]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_DatabaseRoleMembers] ' + CHAR(13) +
               '  ON security.DatabaseRoleMembers ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '    Trigger [security].[TRG_I_DatabaseRoleMembers] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_DatabaseRoleMembers]' + CHAR(13) +
            '    ON security.DatabaseRoleMembers' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].DatabaseRoleMembers ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].DatabaseRoleMembers o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName]  = i.[ServerName]' +CHAR(13) +
            '           and o.DbName        = i.DbName' +CHAR(13) +
            '           and o.[RoleName]    = i.[RoleName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_DatabaseRoleMembers] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_DatabaseRoleMembers]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_DatabaseRoleMembers] ' + CHAR(13) +
               '  ON security.DatabaseRoleMembers ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '    Trigger [security].[TRG_U_DatabaseRoleMembers] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_DatabaseRoleMembers]' + CHAR(13) +
            '    ON security.DatabaseRoleMembers' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].DatabaseRoleMembers ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].DatabaseRoleMembers o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName]  = i.[ServerName]' +CHAR(13) +
            '           and o.DbName        = i.DbName' +CHAR(13) +
            '           and o.[RoleName]    = i.[RoleName]' +CHAR(13) +

            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_DatabaseRoleMembers] altered.'
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
    --------------------------------------------------------------------------------
	28/11/2014	Jefferson Elias		Modified triggers I/U so that database schema 
									referenced in this table are always also in the
									DatabaseSchema table.
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
    WHERE [isDefaultDb] = 1
	
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
            '            on upper(o.[ServerName]) = upper(i.[ServerName])' +CHAR(13) +
            '           and upper(o.[SQLLogin])   = upper(i.[SQLLogin])' +CHAR(13) +
            '           and upper(o.[DbName])     = upper(i.[DbName])' +CHAR(13) +
            + CHAR(13) +
			'	DECLARE forEachRowCursor' + CHAR(13) + 
			'	CURSOR FOR' + CHAR(13) + 
			'		select ' + CHAR(13) + 
			'			ServerName,' + CHAR(13) + 
			'			DbName,' + CHAR(13) + 
			'			DefaultSchema,' + CHAR(13) + 
			'			creationDate,' + CHAR(13) + 
			'			lastModified' + CHAR(13) + 
			'		from inserted' + CHAR(13) + 
			'' + CHAR(13) + 
			'/**' + CHAR(13) + 
			' * As SQL Server doesn''t have a FOR EACH ROWS trigger, ' + CHAR(13) +
			' * and as we don''t merge on this table PRIMARY KEY, ' + CHAR(13) + 
			' * it is mandatory to use a cursor to loop on each rows!' + CHAR(13) + 
			' */' + CHAR(13) + 
			'	DECLARE @currentServer	[VARCHAR](256)' + CHAR(13) + 
			'	DECLARE @currentDbName	[VARCHAR](64)' + CHAR(13) + 
			'	DECLARE @currentSchema	[VARCHAR](64)' + CHAR(13) + 
			'	DECLARE @currentCreate	datetime' + CHAR(13) + 
			'	DECLARE @currentLastMod	datetime' + CHAR(13) + 
				'' + CHAR(13) + 
			'	OPEN forEachRowCursor;' + CHAR(13) + 
			'	FETCH next from forEachRowCursor ' + CHAR(13) + 
			'		into @currentServer,@currentDbName,@currentSchema,@currentCreate,@currentLastMod' + CHAR(13) + 
				'' + CHAR(13) + 
			'	WHILE @@FETCH_STATUS = 0' + CHAR(13) + 
			'	BEGIN' + CHAR(13) + 
						'' + CHAR(13) + 
			'	     merge [security].DatabaseSchemas s' + CHAR(13) +
			'		 using ( ' + CHAR(13) + 
			'			select ' + CHAR(13) + 
			'				@currentServer  as ServerName,' + CHAR(13) + 
			'				@currentDbName  as DbName,' + CHAR(13) + 
			'				@currentSchema  as DefaultSchema,' + CHAR(13) + 
			'				@currentCreate  as creationDate,' + CHAR(13) + 
			'				@currentLastMod as  lastmodified' + CHAR(13) + 
			'		 ) i' + CHAR(13) + 
			'	     on  s.[ServerName]  = i.[ServerName]' + CHAR(13) +
			'	     and s.DbName        = i.DbName' + CHAR(13) +
			'	     and s.[SchemaName]  = i.[DefaultSchema]' + CHAR(13) +
			'/*' + CHAR(13) +
			'	     WHEN MATCHED then' + CHAR(13) +
			'	         update set' + CHAR(13) +			
			'	             isActive = 1' + CHAR(13) +
			'*/' + CHAR(13) +
			'	     WHEN NOT MATCHED BY TARGET THEN' + CHAR(13) +
			'	        insert (' + CHAR(13) +
			'	            ServerName,' + CHAR(13) +
			'	            DbName,' + CHAR(13) +
			'	            SchemaName,' + CHAR(13) +
			'	             Description,' + CHAR(13) +
			'	             isActive,' + CHAR(13) +
			'	             creationDate,' + CHAR(13) +
			'	             lastmodified' + CHAR(13) +
			'	         )' + CHAR(13) +
			'	         values (' + CHAR(13) +
			'	             i.ServerName,' + CHAR(13) +
			'	             i.DbName,' + CHAR(13) +
			'	             i.DefaultSchema,' + CHAR(13) +
			'	             ''Created automatically from SQLMappings table'',' + CHAR(13) +
			'	             1,' + CHAR(13) +
			'	             i.creationDate,' + CHAR(13) +
			'	             i.lastModified	' + CHAR(13) +
			'	         )' + CHAR(13) +
			'	     ;' + CHAR(13) +					
			'			FETCH next from forEachRowCursor ' + CHAR(13) + 
			'				into @currentServer,@currentDbName,@currentSchema,@currentCreate,@currentLastMod			' + CHAR(13) + 
			'	END;' + CHAR(13) + 
			'	CLOSE forEachRowCursor;' + CHAR(13) + 
			'	DEALLOCATE forEachRowCursor;' + CHAR(13) + 		
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
			'            on upper(o.[ServerName]) = upper(i.[ServerName])' +CHAR(13) +	
            '           and upper(o.[SQLLogin])   = upper(i.[SQLLogin])' +CHAR(13) +
            '           and upper(o.[DbName])     = upper(i.[DbName])' +CHAR(13) +	
			+CHAR(13) +
			'	DECLARE forEachRowCursor' + CHAR(13) + 
			'	CURSOR FOR' + CHAR(13) + 
			'		select ' + CHAR(13) + 
			'			ServerName,' + CHAR(13) + 
			'			DbName,' + CHAR(13) + 
			'			DefaultSchema,' + CHAR(13) + 
			'			creationDate,' + CHAR(13) + 
			'			lastModified' + CHAR(13) + 
			'		from inserted' + CHAR(13) + 
			'' + CHAR(13) + 
			'/**' + CHAR(13) + 
			' * As SQL Server doesn''t have a FOR EACH ROWS trigger, ' + CHAR(13) +
			' * and as we don''t merge on this table PRIMARY KEY, ' + CHAR(13) + 
			' * it is mandatory to use a cursor to loop on each rows!' + CHAR(13) + 
			' */' + CHAR(13) + 
			'	DECLARE @currentServer	[VARCHAR](256)' + CHAR(13) + 
			'	DECLARE @currentDbName	[VARCHAR](64)' + CHAR(13) + 
			'	DECLARE @currentSchema	[VARCHAR](64)' + CHAR(13) + 
			'	DECLARE @currentCreate	datetime' + CHAR(13) + 
			'	DECLARE @currentLastMod	datetime' + CHAR(13) + 
				'' + CHAR(13) + 
			'	OPEN forEachRowCursor;' + CHAR(13) + 
			'	FETCH next from forEachRowCursor ' + CHAR(13) + 
			'		into @currentServer,@currentDbName,@currentSchema,@currentCreate,@currentLastMod' + CHAR(13) + 
				'' + CHAR(13) + 
			'	WHILE @@FETCH_STATUS = 0' + CHAR(13) + 
			'	BEGIN' + CHAR(13) + 
						'' + CHAR(13) + 
			'	     merge [security].DatabaseSchemas s' + CHAR(13) +
			'		 using ( ' + CHAR(13) + 
			'			select ' + CHAR(13) + 
			'				@currentServer  as ServerName,' + CHAR(13) + 
			'				@currentDbName  as DbName,' + CHAR(13) + 
			'				@currentSchema  as DefaultSchema,' + CHAR(13) + 
			'				@currentCreate  as creationDate,' + CHAR(13) + 
			'				@currentLastMod as  lastmodified' + CHAR(13) + 
			'		 ) i' + CHAR(13) + 
			'	     on  s.[ServerName]  = i.[ServerName]' + CHAR(13) +
			'	     and s.DbName        = i.DbName' + CHAR(13) +
			'	     and s.[SchemaName]  = i.[DefaultSchema]' + CHAR(13) +
			'/*' + CHAR(13) +
			'	     WHEN MATCHED then' + CHAR(13) +
			'	         update set' + CHAR(13) +			
			'	             isActive = 1' + CHAR(13) +
			'*/' + CHAR(13) +
			'	     WHEN NOT MATCHED BY TARGET THEN' + CHAR(13) +
			'	        insert (' + CHAR(13) +
			'	            ServerName,' + CHAR(13) +
			'	            DbName,' + CHAR(13) +
			'	            SchemaName,' + CHAR(13) +
			'	             Description,' + CHAR(13) +
			'	             isActive,' + CHAR(13) +
			'	             creationDate,' + CHAR(13) +
			'	             lastmodified' + CHAR(13) +
			'	         )' + CHAR(13) +
			'	         values (' + CHAR(13) +
			'	             i.ServerName,' + CHAR(13) +
			'	             i.DbName,' + CHAR(13) +
			'	             i.DefaultSchema,' + CHAR(13) +
			'	             ''Created automatically from SQLMappings table'',' + CHAR(13) +
			'	             1,' + CHAR(13) +
			'	             i.creationDate,' + CHAR(13) +
			'	             i.lastModified	' + CHAR(13) +
			'	         )' + CHAR(13) +
			'	     ;' + CHAR(13) +					
			'			FETCH next from forEachRowCursor ' + CHAR(13) + 
			'				into @currentServer,@currentDbName,@currentSchema,@currentCreate,@currentLastMod			' + CHAR(13) + 
			'	END;' + CHAR(13) + 
			'	CLOSE forEachRowCursor;' + CHAR(13) + 
			'	DEALLOCATE forEachRowCursor;' + CHAR(13) + 
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
	25/11/2014  Jefferson Elias     Added a column "PermissionLevel" 
									where 0 = revoke / remove membership
									      1 = grant  / add membership
										  2 = deny   / N/A
									Date columns transformed to datetime
	--------------------------------------------------------------------------------
	26/11/2014	Jefferson Elias		Switched Permission level from tinyint to varchar
									with GRANT, DENY, REVOKE as possible values.									
									Added check constraint for it to stick to those
									values
									Added check constraint to be sure a DENY is not 
									set to a roleMembership.
    --------------------------------------------------------------------------------
    17/12/2014  Jefferson Elias     Dropped constraint CK_StandardOnSchemaRolesSecurity_PermissionLevel_NoDeny
                                    Modified check constraint named 
                                    CK_StandardOnSchemaRolesSecurity_PermissionLevel
                                    for it to be more precise : no DENY for group membership                                    
                                    I preferred one constraint instead of 2...
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[StandardOnSchemaRolesSecurity] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[StandardOnSchemaRolesSecurity](
        [RoleName] 				[varchar](64) NOT NULL,
        [PrivName] 				[varchar](128) NOT NULL,
        [isRoleMembership] 		[bit] NOT NULL,
		[PermissionLevel] 		[varchar](6) DEFAULT 'GRANT' not null,
        [isDeny] 				[bit] NOT NULL,
        [isActive] 				[bit] NOT NULL,
        [CreationDate] 			[date] NOT NULL,
        [lastmodified] 			[date] NOT NULL
    ) ON [PRIMARY]
	
	PRINT '    Table [security].[StandardOnSchemaRolesSecurity] created.'
END
ELSE
BEGIN

	IF EXISTS( 
	    SELECT 1 
		FROM  sys.columns 
        WHERE Name = 'CreationDate' and Object_ID = Object_ID(N'[security].[StandardOnSchemaRolesSecurity]') and system_type_id = 40
    )
	BEGIN
		-- no other way I know ... drop default constraint and it will be re-created afterwards in this script.
		
		IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRolesSecurity_CreationDate]') AND type = 'D')
		BEGIN
			execute sp_executesql N'alter table [security].[StandardOnSchemaRolesSecurity] drop constraint DF_StandardOnSchemaRolesSecurity_CreationDate'
		END 
		
	    execute sp_executesql N'ALTER TABLE [security].[StandardOnSchemaRolesSecurity] ALTER COLUMN [CreationDate] datetime not null'
		PRINT '    Column CreationDate from [security].[StandardOnSchemaRolesSecurity] modified from date to datetime.'
	END
	
	IF EXISTS( 
	    SELECT 1 
		FROM  sys.columns 
        WHERE Name = 'lastmodified' and Object_ID = Object_ID(N'[security].[StandardOnSchemaRolesSecurity]') and system_type_id = 40
    )
	BEGIN
		
		-- no other way I know ... drop default constraint and it will be re-created afterwards in this script.
		
		IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRolesSecurity_lastmodified]') AND type = 'D')
		BEGIN
			execute sp_executesql N'alter table [security].[StandardOnSchemaRolesSecurity] drop constraint DF_StandardOnSchemaRolesSecurity_lastmodified'
		END 
		
	    execute sp_executesql N'ALTER TABLE [security].[StandardOnSchemaRolesSecurity] ALTER COLUMN [lastmodified] datetime not null'
		PRINT '    Column lastmodified from [security].[StandardOnSchemaRolesSecurity] modified from date to datetime.'
	END
	
	/** Adding permissionlevel column if necessary AND modify it according to the value in isDeny column */
    IF NOT EXISTS( 
	    SELECT 1 
		FROM  sys.columns 
        WHERE Name = 'PermissionLevel' and Object_ID = Object_ID(N'[security].[StandardOnSchemaRolesSecurity]')
    )
	BEGIN
	    execute sp_executesql N'ALTER TABLE [security].[StandardOnSchemaRolesSecurity] add [PermissionLevel] [varchar](6) DEFAULT ''GRANT'' not null'
		PRINT '    Column PermissionLevel added to [security].[StandardOnSchemaRolesSecurity].'
		
		IF NOT EXISTS( 
			SELECT 1 
			FROM  sys.columns 
			WHERE Name = 'isDeny' and Object_ID = Object_ID(N'[security].[StandardOnSchemaRolesSecurity]')
		)
		BEGIN
			execute sp_executesql 'update security.StandardOnSchemaRolesSecurity set PermissionLevel = ''DENY'' where isDeny = 1'
		END
	END
END
GO

IF  EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardOnSchemaRolesSecurity_PermissionLevel]') AND parent_object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]'))
BEGIN
    if EXISTS (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'security' and TABLE_NAME = 'ApplicationParams' and TABLE_TYPE = 'BASE TABLE') 
    BEGIN
        DECLARE @VersionNumber VARCHAR(1024)
        DECLARE @sqlCmd NVARCHAR(MAX)
        SET @sqlCmd = 'select @val = ParamValue from security.ApplicationParams where ParamName = @p'
        EXECUTE sp_executesql @sqlCmd , N'@p varchar(64),@val varchar(128) OUTPUT',@p = 'Version', @val = @VersionNumber OUTPUT
        if(isnull(@VersionNumber,'0.0.0') < '0.1.1')
        BEGIN
            ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
                DROP CONSTRAINT [CK_StandardOnSchemaRolesSecurity_PermissionLevel]
            PRINT '     Constraint [CK_StandardOnSchemaRolesSecurity_PermissionLevel] dropped.'
        END       
    END
END
GO


IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardOnSchemaRolesSecurity_PermissionLevel]') AND parent_object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]'))
BEGIN
    ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        WITH CHECK ADD CONSTRAINT [CK_StandardOnSchemaRolesSecurity_PermissionLevel]
            CHECK (([isRoleMembership] = 0 and [PermissionLevel] in ('GRANT','REVOKE','DENY'))
                   or ([isRoleMembership] = 1 and [PermissionLevel] <> 'DENY'))
	PRINT '     Constraint [CK_StandardOnSchemaRolesSecurity_PermissionLevel] created.'
END
GO

IF  /*NOT*/ EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardOnSchemaRolesSecurity_PermissionLevel_NoDeny]') AND parent_object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]'))
BEGIN
    ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        DROP CONSTRAINT [CK_StandardOnSchemaRolesSecurity_PermissionLevel_NoDeny]            
	PRINT '     Constraint [CK_StandardOnSchemaRolesSecurity_PermissionLevel_NoDeny] dropped.'
/*
    ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        WITH CHECK ADD CONSTRAINT [CK_StandardOnSchemaRolesSecurity_PermissionLevel_NoDeny]
            CHECK (not ([isRoleMembership] = 1 and [PermissionLevel] = 'DENY'))
	PRINT '     Constraint [CK_StandardOnSchemaRolesSecurity_PermissionLevel_NoDeny] created.'
*/
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
		Creation of the [security].[StandardOnSchemaRolesTreeView] view.
        This view intends to display a hierarchical display for standard on schema 
        database roles.

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
    17/12/2014  Jefferson Elias     Creation
    --------------------------------------------------------------------------------	
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'View [security].[logins] Creation'

DECLARE @SQL VARCHAR(MAX)
IF  NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesTreeView]'))
BEGIN
    SET @SQL =  'CREATE view [security].[StandardOnSchemaRolesTreeView]
                AS
                select ''Not implemented'' as Col1'
    EXEC (@SQL)
	PRINT '    View [security].[StandardOnSchemaRolesTreeView] created.'
END

SET @SQL = 'ALTER view [security].[StandardOnSchemaRolesTreeView]
                AS
                    with TreeView ([RoleName],ParentRole,[Level])
                    as (
                        select RoleName, CAST('''' as VARCHAR(64)) as ParentRole,0 
                        from security.StandardOnSchemaRoles
                        where RoleName not in (
                            select RoleName
                            from security.StandardOnSchemaRolesSecurity
                            where isRoleMembership = 1 and PermissionLevel = ''GRANT''
                        )
                        union all
                        select r.RoleName,CAST(r.PrivName AS varchar(64)),[Level]+1
                        from security.StandardOnSchemaRolesSecurity r	
                        INNER JOIN TreeView p ON r.PrivName = p.RoleName
                        where isRoleMembership = 1 and PermissionLevel = ''GRANT''
                    )
                    select tv.[Level],r.RoleName,r.isActive,r.Description,r.CreationDate,r.lastModified                 
                    from (
                        select max(tv1.[Level]) as [Level],tv1.RoleName
                        from 
                            TreeView tv1
                        group by RoleName
                    ) tv
                    inner join security.StandardOnSchemaRoles r
                    on
                        tv.RoleName = r.RoleName
                    '
EXEC (@SQL)
PRINT '    View [security].[StandardOnSchemaRolesTreeView] altered.'
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