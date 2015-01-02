/*requires Schema.Security.sql*/
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
    24/12/2014  Jefferson Elias     Version 0.1.0
    --------------------------------------------------------------------------------
	02/01/2015	Jefferson Elias		Added columns isGeneratedByCollection and LastCollectionDate
									for automatic collection and contact creation.
									Version 0.1.1
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[Contacts] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[Contacts]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[Contacts] (
        [SqlLogin]        			[VARCHAR](256) NOT NULL,
        [Name]            			[VARCHAR](max) NOT NULL,
        [Job]             			[VARCHAR](64) NOT NULL,
        [isActive]        			[BIT] NOT NULL,
        [Department]      			[VARCHAR](64) NOT NULL,
        [authmode]        			[VARCHAR](64) NOT NULL,
        [CreationDate]    			[datetime] NOT NULL,
        [lastmodified]    			[datetime] NOT NULL,
		[isGeneratedByCollection] 	[BIT] DEFAULT 0 NOT NULL,
		[LastCollectionDate] 		[DATETIME]
    )
    ON [PRIMARY]
	PRINT '    Table [security].[Contacts] created.'
END
ELSE 

	DECLARE @ColumnName     VARCHAR(128)    = QUOTENAME('isGeneratedByCollection')
	DECLARE @ColumnDef      NVARCHAR(MAX)   = '[BIT] DEFAULT 0 NOT NULL'
	DECLARE @FullTableName  NVARCHAR(MAX)   = N'[security].[Contacts]'
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
	
	SELECT 
		@ColumnName = QUOTENAME('LastCollectionDate'),
		@ColumnDef  = '[DATETIME]'
	
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
GO



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
      @value=N'Checks that Authmode is in (''WINDOWS'',''SQLSRVR)',
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