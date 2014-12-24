/*requires Schema.Security.sql*/

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
    24/12/2014  Jefferson Elias     Version 0.1.0
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