/*requires Schema.Security.sql*/
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
    23/12/2014  Jefferson Elias     Added parameter RoleAuthorization4Creation as 
                                    ParamName in this table.
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
    select 'RoleAuthorization4Creation','dbo','dbo',0,'Value in the TSQL Command CREATE ROLE ... AUTHORIZATION [<RoleAuthorization4Creation>]'
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