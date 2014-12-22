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



PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[SaveSecurityGenerationResult] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[SaveSecurityGenerationResult]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[SaveSecurityGenerationResult] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[SaveSecurityGenerationResult] created.'
END
GO

ALTER PROCEDURE [security].[SaveSecurityGenerationResult] (
    @OutputDatabaseName     NVARCHAR(128),
    @OutputSchemaName 	    NVARCHAR(256) ,
    @OutputTableName 	    NVARCHAR(256) ,
	@VersionNumber			VARCHAR(128),
	@Debug		 		    BIT		= 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
		This procedure saves the content of ##SecurityGenerationResults table
		to the table provided in parameters.
		If this table doesn't exist, it will create it.
		If this table exists, it will check that it is suitable for insertion and then
		perform the inserts.
  
   ARGUMENTS :

  
   REQUIREMENTS:
  
	EXAMPLE USAGE :
		
   ==================================================================================
   BUGS:
  
     BUGID       Fixed   Description
     ==========  =====   ==========================================================
     ----------------------------------------------------------------------------------
   ==================================================================================
   NOTES:
   AUTHORS:
        .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
        .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
        .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
  
   COMPANY: CHU Liege
   ==================================================================================
   Revision History
  
     Date        Nom         Description
     ==========  =====       ==========================================================
     19/12/2014  JEL         Version 0.0.1
     ----------------------------------------------------------------------------------
  ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    DECLARE @versionNb        	varchar(16) = '0.0.1';
    DECLARE @tsql             	varchar(max);

	DECLARE @LineFeed 			VARCHAR(10)
    DECLARE @StringToExecute    VARCHAR(MAX)
    
	/* Sanitize our inputs */
	SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10)	
	
	if @VersionNumber is null 
	BEGIN
		-- we'll get the global version number 
		select 
			@VersionNumber = ParamValue
		from [security].[ApplicationParams]
		where ParamName = 'Version'
		
		if @Debug = 1
		BEGIN 
			PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Generator version number set to ' + @VersionNumber
		END 
	END
	
	BEGIN TRY 

		IF OBJECT_ID('tempdb..##SecurityGenerationResults') is not null 
		    AND @OutputDatabaseName IS NOT NULL
			AND @OutputSchemaName IS NOT NULL
			AND @OutputTableName IS NOT NULL
			AND EXISTS ( SELECT *
						 FROM   sys.databases
						 WHERE  QUOTENAME([name]) = @OutputDatabaseName) 
		BEGIN
			if @Debug = 1 
			BEGIN
				PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Creating table (if not exists) where we must save results'
			END            
			SET @StringToExecute = 'USE '
				+ @OutputDatabaseName
				+ '; IF EXISTS(SELECT * FROM '
				+ @OutputDatabaseName
				+ '.INFORMATION_SCHEMA.SCHEMATA WHERE QUOTENAME(SCHEMA_NAME) = QUOTENAME('''
				+ @OutputSchemaName
				+ ''')) AND NOT EXISTS (SELECT * FROM '
				+ @OutputDatabaseName
				+ '.INFORMATION_SCHEMA.TABLES WHERE QUOTENAME(TABLE_SCHEMA) = QUOTENAME('''
				+ @OutputSchemaName + ''') AND QUOTENAME(TABLE_NAME) = QUOTENAME('''
				+ @OutputTableName + ''')) CREATE TABLE '
				+ @OutputSchemaName + '.'
				+ @OutputTableName
				+ ' (
				GenerationDate 	    DATETIME NOT NULL, 				
				ServerName 			VARCHAR(256) NOT NULL,
				DbName     			VARCHAR(64)  NULL,
				ObjectName          VARCHAR(512)  NULL,
				GeneratorVersion 	VARCHAR(16) NOT NULL,
				OperationOrder		BIGINT  NOT NULL,
				OperationType		VARCHAR(64) not null,
				QueryText			VARCHAR(MAX) NOT NULL,
				cc_ServerDb			AS [ServerName] + ISNULL('':'' + [DbName],'''') + ISNULL(''-'' + [ObjectName] + ''-'',''''), -- need for null values of DbName...
				CONSTRAINT [PK_' + CAST(NEWID() AS CHAR(36)) + '] PRIMARY KEY CLUSTERED (GenerationDate ASC, cc_ServerDb ASC ,OperationOrder ASC));'               
			
			EXEC(@StringToExecute);
							
			if @Debug = 1 
			BEGIN
				PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Filling in with results '                    
			END                                 
			
			SET @StringToExecute = N'IF EXISTS(SELECT * FROM '
				+ @OutputDatabaseName
				+ '.INFORMATION_SCHEMA.SCHEMATA WHERE (SCHEMA_NAME) = '''
				+ @OutputSchemaName + ''') ' + @LineFeed 
				+ '    INSERT '
				+ @OutputDatabaseName + '.'
				+ @OutputSchemaName + '.'
				+ @OutputTableName
				+ ' (' + @LineFeed 
				+ '        GenerationDate, ServerName, DbName, ObjectName,GeneratorVersion, OperationOrder, OperationType, QueryText' + @LineFeed 
				+ ')' + @LineFeed 
				+ '    SELECT ' + + @LineFeed 
				+ '        CAST (''' + CONVERT(VARCHAR,GETDATE(),121) + ''' AS DATETIME)' + @LineFeed 
				+ '        ,ServerName' + @LineFeed 
				+ '        ,DbName' + @LineFeed 
				+ '        ,ObjectName' + @LineFeed 
				+ '        ,''' + @VersionNumber+''''  + @LineFeed 
				+ '        ,OperationOrder' + @LineFeed 
				+ '        ,OperationType' + @LineFeed 
				+ '        ,QueryText' + @LineFeed 
				+ '    FROM ##SecurityGenerationResults ' + @LineFeed
				+ '    ORDER BY ServerName, OperationOrder,DbName';
			EXEC(@StringToExecute);
		END
/* TODO
		ELSE IF (SUBSTRING(@OutputTableName, 2, 2) = '##')
		BEGIN
			SET @StringToExecute = N' IF (OBJECT_ID(''tempdb..'
				+ @OutputTableName
				+ ''') IS NOT NULL) DROP TABLE ' + @OutputTableName + ';'
				+ 'CREATE TABLE '
				+ @OutputTableName
		END
*/	
		ELSE IF (SUBSTRING(@OutputTableName, 2, 1) = '#')
		BEGIN
			RAISERROR('Due to the nature of Dymamic SQL, only global (i.e. double pound (##)) temp tables are supported for @OutputTableName', 16, 0)
		END
	
	END TRY
	
	BEGIN CATCH
		declare @ErrorMessage nvarchar(max), @ErrorSeverity int, @ErrorState int;
		select @ErrorMessage = ERROR_MESSAGE() + ' Line ' + cast(ERROR_LINE() as nvarchar(5)), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
	    raiserror (@ErrorMessage, @ErrorSeverity, @ErrorState);
		
	END CATCH
END
GO

PRINT '    Procedure [security].[SaveSecurityGenerationResult] altered.'

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

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getSchemaCreationStatement] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getSchemaCreationStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getSchemaCreationStatement] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Function [security].[getSchemaCreationStatement] created.'
END
GO
ALTER Function [security].[getSchemaCreationStatement] (
    @DbName                         VARCHAR(64),
    @SchemaName                     VARCHAR(max),
    @isActive                       BIT = 1,
    @NoHeader                       BIT = 0,
    @NoDependencyCheckGen           BIT = 0,
    @Debug                          BIT = 0
)
RETURNS VARCHAR(max)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This function returns a string with the statements for a database schema creation 
    based on the given parameters.
 
  ARGUMENTS :

 
  REQUIREMENTS:
  
  EXAMPLE USAGE :
      DECLARE @test VARCHAR(max)
      select @test = [security].[getSchemaCreationStatement] ('TESTING_ONLY_TESTING','test_jel',1,1,1,1)
      PRINT @test
      -- EXEC @test
 
  ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================

  ==================================================================================
  NOTES:
  AUTHORS:
       .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
       .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
       .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
 
  COMPANY: CHU Liege
  ==================================================================================
  Revision History
 
    Date        Name        Description
    ==========  =====       ==========================================================
    22/12/2014  JEL         Version 0.1.0 
 ===================================================================================
*/
BEGIN
    --SET NOCOUNT ON;
    DECLARE @versionNb          varchar(16) = '0.1.0';
    DECLARE @tsql               varchar(max);
    DECLARE @DynDeclare         varchar(512);
    DECLARE @ErrorDbNotExists   varchar(max);
    DECLARE @LineFeed 			VARCHAR(10)
    
    /* Sanitize our inputs */
	SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10) ,
        @DynDeclare         = 'DECLARE @dynamicDeclaration VARCHAR(64)' + @LineFeed +
                              'SET @dynamicDeclaration = QUOTENAME(''' + @SchemaName + ''')' + @LineFeed  

    SET @tsql = @DynDeclare  +
                'DECLARE @DbName      VARCHAR(64) = ''' + QUOTENAME(@DbName) + '''' + @LineFeed 

        
    SET @ErrorDbNotExists =  N'The given database ('+QUOTENAME(@DbName)+') does not exist'

    if @NoHeader = 0 
    BEGIN
        SET @tsql = @tsql + '/**' + @LineFeed +
                    ' * Database Schema Creation version ' + @versionNb + '.' + @LineFeed +
                    ' */'   + @LineFeed +
                    ''      + @LineFeed 
    END 
    if @NoDependencyCheckGen = 0 
    BEGIN
        SET @tsql = @tsql + '-- 1.1 Check that the database actually exists' + @LineFeed +
                    'if (NOT exists (select * from sys.databases where QUOTENAME(name) = @DbName))' + @LineFeed  +
                    'BEGIN' + @LineFeed  +
                    '    RAISERROR ( ''' + @ErrorDbNotExists + ''',0,1 ) WITH NOWAIT' + @LineFeed  +
                    '    return' + @LineFeed +
                    'END' + @LineFeed  +
                    '' + @LineFeed           
    END
    
    SET @tsql = @tsql + 
                'USE ' + QUOTENAME(@DbName) + @LineFeed +
                + @LineFeed 
    
    DECLARE @SchemaAuthorization VARCHAR(64)    
    
    select 
        @SchemaAuthorization = ISNULL(ParamValue,ISNULL(DefaultValue,'dbo')) 
    from 
        security.ApplicationParams
    where 
        ParamName = 'SchemaAuthorization4Creation';
    
    SET @tsql = @tsql + 
                'DECLARE @SchemaOwner VARCHAR(64)' + @LineFeed +
                + @LineFeed +                
                'SELECT @SchemaOwner = QUOTENAME(SCHEMA_OWNER)' + @LineFeed +
                'FROM' + @LineFeed +
                '    INFORMATION_SCHEMA.SCHEMATA' + @LineFeed +
                'WHERE' + @LineFeed +
                '    QUOTENAME(CATALOG_NAME) = @DbName' + @LineFeed + 
                'AND QUOTENAME(SCHEMA_NAME)  = @dynamicDeclaration' + @LineFeed +
                'IF (@SchemaOwner is null ) -- then the schema does not exist ' + @LineFeed  +
                'BEGIN' + @LineFeed  +                
                '    -- create it !' + @LineFeed  +
                '    EXEC (''CREATE SCHEMA ' + QUOTENAME(@SchemaName) + ' AUTHORIZATION ' + QUOTENAME(@SchemaAuthorization) + ''')' + @LineFeed +
                'END' + @LineFeed +
                'ELSE IF @SchemaOwner <> ''' + QUOTENAME(@SchemaAuthorization) + '''' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    EXEC (''ALTER AUTHORIZATION on SCHEMA::' + QUOTENAME(@SchemaName) + ' TO ' + QUOTENAME(@SchemaAuthorization) + ''')' + @LineFeed +
                'END' + @LineFeed 
	
    SET @tsql = @tsql + @LineFeed  +
				'GO' + @LineFeed 
    RETURN @tsql
END
go	

PRINT '    Function [security].[getSchemaCreationStatement] altered.'

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

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getLoginCreationStatement] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getLoginCreationStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getLoginCreationStatement] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Function [security].[getLoginCreationStatement] created.'
END
GO
ALTER Function [security].[getLoginCreationStatement] (
    @LoginName                      VARCHAR(max),
    @AuthMode                       VARCHAR(7) = 'SQLSRVR',-- Autre possibilité  'WINDOWS'
    @Passwd                         VARCHAR(64) = '',
    @DefaultDatabase                VARCHAR(32),
    @isActive                       BIT = 1,
    @NoHeader                       BIT = 0,
    @NoDependencyCheckGen           BIT = 0,
    @NoGrantConnectSQL              BIT = 0,
    @Debug                          BIT = 0
)
RETURNS VARCHAR(max)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This function returns a string with the statements for a login creation based on
    the given parameters.
 
  ARGUMENTS :
    @LoginName          Name of the login to create
    @AuthMode           Authentication mode : WINDOWS,SQLSRVR
    @Passwd             If @AuthMode = 'SQLSRVR', this parameter defines the password
                        to set by default
    @DefaultDatabase    Name of the default database for the given login
 
  REQUIREMENTS:
 
  ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================
	00001		0.1.3	ALTER LOGIN [XXX] WITH CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
							>> Cannot use parameter CHECK_EXPIRATION for a Windows login.
							>> Cannot use parameter CHECK_POLICY for a Windows login.
    ----------------------------------------------------------------------------------
	00003		0.1.3	No "GO" is added for login creation and default standard settings statements
						Add two extra spaces in addition after the GO statement
    ----------------------------------------------------------------------------------
	00016		0.1.4	Unable to set default database for logins that were not created before.
    ----------------------------------------------------------------------------------
  ==================================================================================
  NOTES:
  AUTHORS:
       .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
       .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
       .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
 
  COMPANY: CHU Liege
  ==================================================================================
  Revision History
 
    Date        Name        Description
    ==========  =====       ==========================================================
    22/04/2014  JEL         Version 0.1.0
 							TODO : gérer les guids
    ----------------------------------------------------------------------------------
	23/04/2014	JEL			Added missing quotes in RAISEERROR statement
							Version 0.1.1
	----------------------------------------------------------------------------------							
	24/04/2014	JEL			Removed "DefaultSchema" parameter.
							Added password policy management : 
								by default, no password policy
							Removed parenthesis surrounding sp_defaultdb level
							Version 0.1.2
	----------------------------------------------------------------------------------	
	07/05/2014	JEL			Correcting Bug #00001
	07/05/2014	JEL			Correcting Bug #00003
							Version 0.1.3
	----------------------------------------------------------------------------------	
	16/12/2014	JEL			Correction for Bug #00016
							Version 0.1.4
	----------------------------------------------------------------------------------	
    22/12/2014  JEL         Added some parameters :
                                @isActive                       BIT = 1,
                                @NoHeader                       BIT = 0,
                                @NoDependencyCheckGen           BIT = 0
                            and modified code associated with them
                            
                            make use of variables for minimizing ad hoc queries (usage of
                            the variable @loginToPlayWith set at the beginning of this function)
                            Added locking functionality
                            Version 0.2.0
 ===================================================================================
*/
BEGIN
    --SET NOCOUNT ON;
    DECLARE @versionNb              VARCHAR(16) = '0.2.0';
    DECLARE @tsql                   VARCHAR(max);
    DECLARE @LoginDeclaration       VARCHAR(512);
    DECLARE @ErrorDbNotExists       VARCHAR(max);
    DECLARE @LineFeed 			    VARCHAR(10)
    
    /* Sanitize our inputs */
	SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10) ,
        @LoginDeclaration   = 'DECLARE @loginToPlayWith VARCHAR(64)' + @LineFeed +
                              'SET @loginToPlayWith = QUOTENAME(''' + @LoginName + ''')' + @LineFeed  

    SET @tsql = @LoginDeclaration  
        
    SET @ErrorDbNotExists =  N'The given default database ('+QUOTENAME(@DefaultDatabase)+') does not exist'

    if @NoHeader = 0 
    BEGIN
        SET @tsql = isnull(@tsql,'') + 
                    '/**' + @LineFeed +
                    ' * SQL Login Creation (both authentication) version ' + @versionNb + '.' + @LineFeed +
                    ' *     LoginName       : ' + @LoginName        + @LineFeed  +
                    ' *     AuthMode        : ' + @AuthMode         + @LineFeed  +
                    ' *     Passwd          : ' + ISNULL(@Passwd,'<null>')     + @LineFeed  +
                    ' *     DefaultDatabase : ' + @DefaultDatabase  + @LineFeed  +   
                    ' */'   + @LineFeed +
                    ''      + @LineFeed 
    END 
    
    SET @tsql = isnull(@tsql,'') + @LoginDeclaration  

    
    if @NoDependencyCheckGen = 0 
    BEGIN
        SET @tsql = @tsql + '-- 1.1 Check that the default database actually exists' + @LineFeed +
                    'if (NOT exists (select * from sys.databases where name = ''' +  @DefaultDatabase + '''))' + @LineFeed  +
                    'BEGIN' + @LineFeed  +
                    '    RAISERROR ( ''' + @ErrorDbNotExists + ''',0,1 ) WITH NOWAIT' + @LineFeed  +
                    '    return' + @LineFeed +
                    'END' + @LineFeed  +
                    '' + @LineFeed           
    END
    SET @tsql = @tsql + 'IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE  QUOTENAME(name) = @loginToPlayWith)' + @LineFeed  +
                'BEGIN' + @LineFeed  +
                '    -- create it !' + @LineFeed  +
                '    EXEC (''USE [master]; CREATE LOGIN ' + QUOTENAME(@LoginName) + ' ' 

    IF ( @AuthMode = 'WINDOWS' )
    BEGIN
        SET @tsql = @tsql + 'FROM WINDOWS '
    END
    ELSE
    BEGIN
        SET @tsql = @tsql + 'WITH PASSWORD=N''''' + @Passwd + ''''''
    END

    SET @tsql = @tsql + ' , DEFAULT_DATABASE=' + QUOTENAME(@DefaultDatabase) + ''')' + @LineFeed  +
                'END' + @LineFeed  +
				'GO' + @LineFeed  +
                @LineFeed +
                @LoginDeclaration + 
                '-- getting some infos to carry on' + @LineFeed +
                'DECLARE @loginIsDisabled BIT' + @LineFeed +
                'DECLARE @loginDefaultDb  SYSNAME' + @LineFeed +
                'select' + @LineFeed +
                '    @loginIsDisabled   = is_disabled ,' + @LineFeed + 
                '    @loginDefaultDb    = QUOTENAME(default_database_name)' + @LineFeed +
                'from' + @LineFeed +
                '    master.sys.server_principals' + @LineFeed + 
                'where QUOTENAME(name) = @loginToPlayWith' + @LineFeed +
                +@LineFeed +
                '-- ENABLE|DISABLE login' + @LineFeed + 
                'if @loginIsDisabled = ' + CAST(@isActive as CHAR(1)) + @LineFeed +
                'BEGIN' + @LineFeed +               
                '    ALTER LOGIN ' + QUOTENAME(@LoginName) + ' ' + CASE WHEN @isActive = 1 THEN 'ENABLE' ELSE 'DISABLE' END + @LineFeed +               
                'END' + @LineFeed 

    -- TODO : make it go to DatabasePermissions                
    if @NoGrantConnectSQL = 0 
    BEGIN
        SET @tsql = @tsql + @LineFeed +                 
                '-- If necessary, give the login the permission to connect the database engine' + @LineFeed  +
                'if not exists (select 1 from master.sys.server_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @loginToPlayWith and permission_name = ''CONNECT SQL'' and state_desc = ''GRANT'')' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    EXEC (''USE [master] ; GRANT CONNECT SQL TO @loginToPlayWith'' );' + @LineFeed  +
                'END' + @LineFeed 
    END 

    SET @tsql = @tsql + @LineFeed +    
				'-- If necessary, set the default database for this login' + @LineFeed  + 
                'if ISNULL(@loginDefaultDb,''<null>'') <> QUOTENAME(''' + @DefaultDatabase + ''')' + @LineFeed +
                'BEGIN' + @LineFeed +
                'exec sp_defaultdb @loginame = @loginToPlayWith , @DefDb = ''' + @DefaultDatabase + '''' + @LineFeed +
                'END' + @LineFeed 
                
	/* Password policy setup - TODO SHOULD be different, but not needed at the moment */                
                
	if (@AuthMode <> 'WINDOWS' )
	BEGIN
		SET @tsql = @tsql +
                '-- Password policy settings' + @LineFeed +
                '-- ------------------------' + @LineFeed +
                'DECLARE @loginHasPwdPolicyChecked BIT' + @LineFeed +
                'DECLARE @loginHasPwdExpireChecked BIT' + @LineFeed +                
                'select' + @LineFeed + 
                '    @loginHasPwdPolicyChecked = is_policy_checked,' + @LineFeed + 
                '    @loginHasPwdExpireChecked = is_expiration_checked' + @LineFeed +
                'from master.sys.sql_logins' + @LineFeed +
                'where QUOTENAME(name) = @loginToPlayWith' + @LineFeed +
                @LineFeed +
                '-- by default : no password policy is defined' + @LineFeed +
                'if @loginHasPwdPolicyChecked <> 0' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    ALTER LOGIN ' + QUOTENAME(@LoginName) + ' WITH CHECK_EXPIRATION=OFF' + @LineFeed +
                'END' + @LineFeed +                
                'if @loginHasPwdExpireChecked <> 0' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    ALTER LOGIN ' + QUOTENAME(@LoginName) + ' WITH CHECK_POLICY=OFF' + @LineFeed +
                'END' + @LineFeed                				
	END
	
    SET @tsql = @tsql + @LineFeed  +
				'GO' + @LineFeed 
    RETURN @tsql
END
go	

PRINT '    Function [security].[getLoginCreationStatement] altered.'

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


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[CreateTempTables4Generation] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[CreateTempTables4Generation]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[CreateTempTables4Generation] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[CreateTempTables4Generation] created.'
END
GO

ALTER PROCEDURE [security].[CreateTempTables4Generation] (
    @CanDropTempTables      BIT     = 1,
	@Debug		 		    BIT		= 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
		This procedure saves the content of ##SecurityGenerationResults table
		to the table provided in parameters.
		If this table doesn't exist, it will create it.
		If this table exists, it will check that it is suitable for insertion and then
		perform the inserts.
  
   ARGUMENTS :

  
   REQUIREMENTS:
  
	EXAMPLE USAGE :
		
   ==================================================================================
   BUGS:
  
     BUGID       Fixed   Description
     ==========  =====   ==========================================================
     ----------------------------------------------------------------------------------
   ==================================================================================
   NOTES:
   AUTHORS:
        .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
        .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
        .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
  
   COMPANY: CHU Liege
   ==================================================================================
   Revision History
  
     Date        Nom         Description
     ==========  =====       ==========================================================
     19/12/2014  JEL         Version 0.0.1
     ----------------------------------------------------------------------------------
  ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    DECLARE @versionNb        	varchar(16) = '0.0.1';
    DECLARE @tsql             	varchar(max);

	DECLARE @LineFeed 			VARCHAR(10)
    if @CanDropTempTables = 1 and OBJECT_ID('tempdb..##SecurityGenerationResults') IS NOT NULL 
    BEGIN 
        DROP TABLE ##SecurityGenerationResults;
    
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + '-- DEBUG - Table ##SecurityGenerationResults dropped'
        END                 
    END 
    
    if @CanDropTempTables = 1 and OBJECT_ID('tempdb..##SecurityScriptResultsCommandsOrder') IS NOT NULL 
    BEGIN 
        DROP TABLE ##SecurityScriptResultsCommandsOrder;
    
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + '-- DEBUG - Table ##SecurityScriptResultsCommandsOrder dropped'
        END                 
    END 

    IF OBJECT_ID('tempdb..##SecurityGenerationResults') is null 
    BEGIN 
        CREATE TABLE ##SecurityGenerationResults (
            ID 				INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
            ServerName		VARCHAR(256) NOT NULL,
            DbName			VARCHAR(64)  NULL,
            ObjectName      VARCHAR(512)  NULL, 
            OperationType 	VARCHAR(64) NOT NULL,
            OperationOrder	BIGINT,
            QueryText 		VARCHAR(MAX) NOT NULL
        )
        
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + '-- DEBUG - Table ##SecurityGenerationResults created'
        END             
    END
    
    if OBJECT_ID('tempdb..##SecurityScriptResultsCommandsOrder') IS NULL 
    BEGIN 
        CREATE TABLE ##SecurityScriptResultsCommandsOrder (
            OperationType	VARCHAR(256) NOT NULL,
            OperationOrder	BIGINT
        )
        
        insert ##SecurityScriptResultsCommandsOrder
            select 'CHECK_EXPECTED_SERVERNAME', 1
            union all
            select 'CHECK_DATABASE_EXISTS', 10
            union all
            select 'CHECK_AND_CREATE_SQL_LOGINS', 50
            union all
            select 'CHECK_AND_CREATE_DB_SCHEMA', 60
            union all
            select 'CHECK_AND_CREATE_DB_USER', 70
            union all
            select 'CHECK_AND_DO_LOGIN_2_DBUSER_MAPPING', 80
            union all
            select 'CHECK_AND_CREATE_DB_ROLE', 90
            union all
            select 'CHECK_AND_ASSIGN_DBROLE_MEMBERSHIP', 100
            union all
            select 'CHECK_AND_ASSIGN_OBJECT_PERMISSION', 101
            
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + '-- DEBUG - Table ##SecurityScriptResultsCommandsOrder created'
        END                        
    END    
END
GO

PRINT '    Procedure [security].[CreateTempTables4Generation] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 	

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getDbUserCreationStatement] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getDbUserCreationStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getDbUserCreationStatement] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Function [security].[getDbUserCreationStatement] created.'
END
GO

ALTER FUNCTION [security].[getDbUserCreationStatement] (
    @DbName  		                varchar(32),
	@LoginName		                varchar(32),
	@UserName		                varchar(32),
	@SchemaName		                varchar(32),
    @isActive                       BIT = 1,
    @NoHeader                       BIT = 0,
    @NoDependencyCheckGen           BIT = 0,
    @Debug                          BIT = 0
)
RETURNS VARCHAR(max)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This function returns a string with all statements for a database user creation
 	This procedure sets the default schema and doesn't do anything 
 	about login to user mapping.
 
  ARGUMENTS :
    @DbName         name of the database on that server in which execute the statements generated by this function
	@LoginName		Name of the login that will be used to connect on this database
 	@UserName		the database user to create
 	@SchemaName		the database schema to use by default for the specified user name
 
  REQUIREMENTS:
  
  EXAMPLE USAGE :
    PRINT [security].[getDbUserCreationStatement] ('TESTING_ONLY_TESTING','jel_test','jel_test','dbo',1,0,0,1)

 
  ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================
    ----------------------------------------------------------------------------------
  ==================================================================================
  NOTES:
  AUTHORS:
       .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
       .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
       .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
 
  COMPANY: CHU Liege
  ==================================================================================
  Revision History
 
    Date        Name        Description
    ==========  =====       ==========================================================
    24/04/2014  JEL         Version 0.1.0
    ----------------------------------------------------------------------------------
    22/12/2014  JEL         Added some parameter for new generator with backward compatibility
                            Version 0.2.0
    ----------------------------------------------------------------------------------
 ===================================================================================
*/
BEGIN

    --SET NOCOUNT ON;
    DECLARE @versionNb        varchar(16) = '0.2.0';
    DECLARE @tsql             varchar(max);    
    DECLARE @ErrorDbNotExists varchar(max);
    DECLARE @LineFeed 		  VARCHAR(10);
    DECLARE @DynDeclare  VARCHAR(512);
    
    /* Sanitize our inputs */
	SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10),
        @DynDeclare         = 'DECLARE @CurDbUser     VARCHAR(64)' + @LineFeed +
                              'DECLARE @CurDbName     VARCHAR(64)' + @LineFeed +
                              'DECLARE @CurLoginName  VARCHAR(64)' + @LineFeed +
                              'DECLARE @CurSchemaName VARCHAR(64)' + @LineFeed +
                              'SET @CurDbUser     = ''' + QUOTENAME(@UserName) + '''' + @LineFeed +
                              'SET @CurDbName     = ''' + QUOTENAME(@DbName) + '''' + @LineFeed +
                              'SET @CurLoginName  = ''' + QUOTENAME(@LoginName) + '''' + @LineFeed +
                              'SET @CurSchemaName = ''' + QUOTENAME(@SchemaName) + '''' + @LineFeed,                              
        @ErrorDbNotExists   =  N'The given database ('+QUOTENAME(@DbName)+') does not exist'
    
    
    if @NoHeader = 0 
    BEGIN    
        SET @tsql = isnull(@tsql,'') + 
                    '/**' +@LineFeed+
                    ' * Database user creation version ' + @versionNb + '.' +@LineFeed+
                    ' *   Database Name  : ' + @DbName +@LineFeed+
                    ' *   User Name 	 : ' + @UserName 	 +@LineFeed+
                    ' *   Default Schema : ' + @SchemaName 	 +@LineFeed+
                    ' */'   + @LineFeed+
                    ''      + @LineFeed
                
    END 
    
    set @tsql = isnull(@tsql,'') + @DynDeclare
    
    if @NoDependencyCheckGen = 0 
    BEGIN
        SET @tsql = @tsql + 
				'-- 1.1 Check that the database actually exists' + @LineFeed+
                'if (NOT exists (select 1 from sys.databases where QUOTENAME(name) = @CurDbName))' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    RAISERROR ( ''' + @ErrorDbNotExists + ''',0,1 ) WITH NOWAIT' + @LineFeed +
                '    return' + @LineFeed+
                'END' + @LineFeed +
                '' + @LineFeed +
                'Use '+ QUOTENAME(@DbName) + @LineFeed+
				'-- 1.2 Check that the schema exists in that database' + @LineFeed + 
				'if not exists (select 1 from sys.schemas where QUOTENAME(name) = @CurSchemaName)' + @LineFeed +
				'BEGIN' + @LineFeed + 
                '    RAISERROR ( ''The given schema ('+@SchemaName + ') does not exist'',0,1 ) WITH NOWAIT' + @LineFeed +
                '    return' + @LineFeed+	
				'END' + @LineFeed
    END
    
    SET @tsql = @tsql + 
                'Use '+ QUOTENAME(@DbName) + @LineFeed +
                'DECLARE @gotName       VARCHAR(64)' + @LineFeed +                
                'DECLARE @defaultSchema VARCHAR(64)' + @LineFeed +                
                'select @gotName = name, @defaultSchema = default_schema_name from sys.database_principals WHERE QUOTENAME(NAME) = @CurDbUser and Type in (''S'',''U'')' + @LineFeed +
                'IF @gotName is null' + @LineFeed +
				'BEGIN' + @LineFeed +
				'    EXEC (''create user '' + @CurDbUser + '' FOR LOGIN '' + @CurLoginName )' + @LineFeed +
				'END' + @LineFeed +
                'if isnull(@defaultSchema,''<NULL>'') <> isnull(@CurSchemaName,''<NULL>'')' + @LineFeed + 
                'BEGIN' + @LineFeed +
				'    EXEC (''alter user '' + @CurDbUser + '' WITH DEFAULT_SCHEMA = '' + @CurSchemaName )' + @LineFeed +
                'END' + @LineFeed    
    
    
    SET @tsql = @tsql +
				'GO'  + @LineFeed 
    
    RETURN @tsql
END
GO

PRINT '    Function [security].[getDbUserCreationStatement] altered.'

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


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getLogin2DbUserMappingStatement] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getLogin2DbUserMappingStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getLogin2DbUserMappingStatement] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Function [security].[getLogin2DbUserMappingStatement] created.'
END
GO

ALTER FUNCTION [security].getLogin2DbUserMappingStatement (
    @LoginName			    varchar(32),
    @DbName				    varchar(64),
    @UserName			    varchar(32),
    @DefaultSchemaName	    varchar(32),    
    @NoHeader               BIT = 0,
    @NoDependencyCheckGen   BIT = 0,
    @forceUserCreation	    bit = 0,
    @NoGrantConnect      BIT = 0,
    @Debug                  BIT = 0    
)
RETURNS VARCHAR(max)
AS
/*
#===================================================================================
# DESCRIPTION:
#   This function returns a string with all statements for mapping a given database 
#	user to a given SQL Login.
#
# ARGUMENTS :
#   @LoginName			Name of the login to map
#   @DbName				Name of the database on on which map the SQL Login
#	@UserName			Name of the database user in that database to map with the 
#						SQL Login. If this user doesn't exist in the database, it will be
#						created if @forceUserCreation is set to true (default behaviour).
#	@DefaultSchemaName	default schema for the given database user in the given SQL Server database.
#	@forceUserCreation	Set it to true if you want this procedure to force the database user
#						to be created
#
# REQUIREMENTS:
#
#   EXAMPLE USAGE :
        PRINT [security].getLogin2DbUserMappingStatement ('test_jel','TESTING_ONLY_TESTING','test_jel','dbo',1,1,0,0,1)
# ==================================================================================
# BUGS:
#
#   BUGID       Fixed   Description
#   ==========  =====   ==========================================================
#   ----------------------------------------------------------------------------------
# ==================================================================================
# NOTES:
# AUTHORS:
#      .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
#      .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
#      .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
#
# COMPANY: CHU Liege
# ==================================================================================
# Revision History
#
#   Date        Nom         Description
#   ==========  =====       ==========================================================
#   24/04/2014  JEL         Version 0.1.0
#   ----------------------------------------------------------------------------------
#   22/12/2014  JEL         New generation version => adjustments
#   ----------------------------------------------------------------------------------
#===================================================================================
*/
BEGIN

    --SET NOCOUNT ON;
    DECLARE @versionNb        varchar(16) = '0.2.0';
    DECLARE @tsql             varchar(max);   
    DECLARE @ErrorDbNotExists varchar(max);
    
    DECLARE @LineFeed 		  VARCHAR(10);
    DECLARE @DynDeclare       VARCHAR(512);    

    /* Sanitize our inputs */
	SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10),
        @DynDeclare         = 'DECLARE @CurDbUser     VARCHAR(64)' + @LineFeed +
                              'DECLARE @CurDbName     VARCHAR(64)' + @LineFeed +
                              'DECLARE @CurLoginName  VARCHAR(64)' + @LineFeed +
                              'DECLARE @CurSchemaName VARCHAR(64)' + @LineFeed +
                              'SET @CurDbUser     = ''' + QUOTENAME(@UserName) + '''' + @LineFeed +
                              'SET @CurDbName     = ''' + QUOTENAME(@DbName) + '''' + @LineFeed +
                              'SET @CurLoginName  = ''' + QUOTENAME(@LoginName) + '''' + @LineFeed +
                              'SET @CurSchemaName = ''' + QUOTENAME(@DefaultSchemaName) + '''' + @LineFeed,                              
        @ErrorDbNotExists   =  N'The given database ('+QUOTENAME(@DbName)+') does not exist'
        
    if @NoHeader = 0 
    BEGIN    
        SET @tsql = isnull(@tsql,'') + 
                    '/**' +@LineFeed+
                    ' * SQL Login to Db user mapping version ' + @versionNb + '.' +@LineFeed+
                    ' *   LoginName				 : ' + @LoginName + @LineFeed +
                    ' *   DBName				 : ' + @DbName +@LineFeed+
                    ' *   UserName				 : ' + @UserName + @LineFeed +
                    ' *   DefaultSchemaName      : ' + @DefaultSchemaName + @LineFeed +
                    ' *   Force DB User Creation : ' + convert(varchar(1),@forceUserCreation) + @LineFeed +
                    ' */'   + @LineFeed+
                    ''      + @LineFeed
    END
    
    set @tsql = isnull(@tsql,'') + @DynDeclare
    
    if @NoDependencyCheckGen = 0 
    BEGIN
        SET @tsql = @tsql + 
                '-- 1.1 Check that the database actually exists' + @LineFeed+
                'if (NOT exists (select 1 from sys.databases where QUOTENAME(name) = @CurDbName))' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    RAISERROR ( ''' + @ErrorDbNotExists + ''',0,1 ) WITH NOWAIT' + @LineFeed +
                '    return' + @LineFeed+
                'END' + @LineFeed +
                '' + @LineFeed +
                'Use '+ QUOTENAME(@DbName) + @LineFeed+
                '-- 1.2 Check that the login actually exists' + @LineFeed + 
                'if (NOT exists (select * from sys.syslogins where QUOTENAME(loginname) = @CurLoginName))' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    RAISERROR (''There is no login with name ''' + QUOTENAME(@LoginName) + ''''',0,1 ) WITH NOWAIT' + @LineFeed +
                '    return' + @LineFeed+
                'END' + @LineFeed +
                '-- 1.3 Check that the schema actually exists in the database' + @LineFeed +
                'if not exists (select 1 from sys.schemas where QUOTENAME(name) = @CurSchemaName)' + @LineFeed +
				'BEGIN' + @LineFeed + 
                '    RAISERROR ( ''The given schema ('+@DefaultSchemaName + ') does not exist'',0,1 ) WITH NOWAIT' + @LineFeed +
                '    return' + @LineFeed+	
				'END' + @LineFeed +
                '' + @LineFeed +
                'if not exists(select 1 from sys.database_principals WHERE QUOTENAME(NAME) = @CurDbUser and Type in (''S'',''U'')' + @LineFeed +
                'BEGIN' + @LineFeed
                
        if (@forceUserCreation = 0) 
        BEGIN
            SET @tsql = @tsql +				
                        '        RAISERROR(N''The given database user '''''+@UserName+ ''''' does not exist!'' ,0,1) WITH NOWAIT' +@LineFeed+
                        '        return' + @LineFeed
        END
        ELSE
        BEGIN
            SET @tsql = @tsql +		
                        [security].getDbUserCreationStatement(@DbName,@LoginName,@UserName,@DefaultSchemaName,0,@NoHeader,@NoDependencyCheckGen,@Debug)
        END
        
     
        SET @tsql = @tsql +
                    'END' + @LineFeed 
    END 
    
    
    SET @tsql = @tsql +
                'Use '+ QUOTENAME(@DbName) + @LineFeed +
                'if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    EXEC(''ALTER USER ''+''' + QUOTENAME(@UserName) + '''+ ''WITH LOGIN = '' + ''' + QUOTENAME(@LoginName) + ''' )' + @LineFeed +
                'END' + @LineFeed 
                
    
    -- TODO : make it go to DatabasePermissions
    if @NoGrantConnect = 0 
    BEGIN 
            SET @tsql = @tsql + @LineFeed +                 
                '-- If necessary, give the database user the permission to connect the database ' + @LineFeed  +
                'if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = ''CONNECT'' and state_desc = ''GRANT'')' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    EXEC (''USE ' + QUOTENAME(@DbName) + ' ; GRANT CONNECT TO ' + QUOTENAME(@UserName) + ''' );' + @LineFeed  +
                'END' + @LineFeed 
    END 
    
    SET @tsql = @tsql +
				'GO'  + @LineFeed 
    
    RETURN @tsql
END
GO

PRINT '    Function [security].[getLogin2DbUserMappingStatement] altered.'

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
		Creation of the [security].[DatabaseUsers] view that lists active Database Users

	==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================
	00013		1.0.1	This view does not give all database users !
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
	25/04/2014	Jefferson Elias		Modified to manage the new version of logins view
									Version 1.0.0
    --------------------------------------------------------------------------------
	07/05/2014	Jefferson Elias		Corrected Bug #00013
									Version 1.0.1
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
                    c.[Name],
                    c.[Job],
                    c.[Department],
                    l.[ServerName],
                    l.SQLLogin,
                    m.DbName,
					m.DbUserName,
                    m.DefaultSchema,
                    m.isLocked
                from [security].[Contacts] c
                    join [Security].[SQLlogins] l
                        on c.SQLLogin = l.SQLLogin
                    left join [security].[SQLMappings] m
						on l.SqlLogin   = m.SqlLogin
					  and  l.ServerName = m.ServerName
                where c.isActive = 1'
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







PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setStandardOnSchemaRolePermissions] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setStandardOnSchemaRolePermissions]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setStandardOnSchemaRolePermissions] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[setStandardOnSchemaRolePermissions] created.'
END
GO

ALTER PROCEDURE [security].[setStandardOnSchemaRolePermissions] (
    @ServerName  SYSNAME = @@SERVERNAME,
    @DbName      SYSNAME,
    @SchemaName  SYSNAME,
    @StdRoleName SYSNAME,
    @Debug       BIT          = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
     This function takes care of the generation of permissions associated to a given 
     Standard Database Roles for "on schema" access 
     according to its parameter values.
     
     As a prerequisite, all the defined roles must be created before execution
  
   ARGUMENTS :
     @ServerName    name of the server on which the SQL Server instance we want to modify is running.
                    By default, it's the current server
    
     @DbName        name of the database on that server for which create roles.
                    A NULL value (which is the default value) means that this procedure
                    has to take care of all "on schema" roles for any database on the given serer.
  
     @SchemaName    name of the schema for which execute this procedure
     
     @StdRoleName   name of the standard role for which execute this procedure
  
   REQUIREMENTS:
  
    EXAMPLE USAGE :

        EXEC [security].[setStandardOnSchemaRolePermissions] 
            @ServerName  = 'SI-S-SERV204',
            @DbName      = 'Pharmalogic',
            @SchemaName  = 'vanas',
            @StdRoleName = 'data_modifier',
            @Debug       = 1

        exec [security].[setStandardOnSchemaRolePermissions] 
            @ServerName  = 'SI-S-SERV183',
            @DbName      = 'Pharmalogic',
            @SchemaName  = 'vanas',
            @StdRoleName = 'endusers',
            @Debug       = 1
  
   ==================================================================================
   BUGS:
  
     BUGID       Fixed   Description
     ==========  =====   ==========================================================
     ----------------------------------------------------------------------------------
   ==================================================================================
   NOTES:
   AUTHORS:
        .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
        .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
        .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
  
   COMPANY: CHU Liege
   ==================================================================================
   Revision History
  
    Date        Nom         Description
    ==========  =====       ==========================================================
    17/12/2014  JEL         Version 0.0.1
    ----------------------------------------------------------------------------------    
  ===================================================================================
*/
BEGIN

    --SET NOCOUNT ON;
    DECLARE @versionNb          varchar(16) = '0.0.1';
    DECLARE @tsql               varchar(max);
    DECLARE @SchemaRoleSep      VARCHAR(64)
    
    if @Debug = 1
    BEGIN
        PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Getting naming convention (separator between schemaName and StdRoleName).'
    END
    
    select @SchemaRoleSep = ParamValue
    from [security].[ApplicationParams]
    where ParamName = 'Separator4OnSchemaStandardRole' ;    
    
    BEGIN TRY
    BEGIN TRANSACTION
        
        DECLARE getPermissions
        CURSOR LOCAL FOR
            select 
                @SchemaName + @SchemaRoleSep + RoleName,
                PermissionLevel,
                case WHEN isRoleMembership = 1 THEN @SchemaName + @SchemaRoleSep + PrivName
                    ELSE PrivName 
                    END as PrivName,
                isRoleMembership,
                isActive 
            from security.StandardOnSchemaRolesSecurity
            where RoleName = @StdRoleName
            
    
        DECLARE @RoleName        VARCHAR(64)
        DECLARE @PermissionLevel VARCHAR(6)
        DECLARE @PrivName        VARCHAR(128)
        DECLARE @isRoleMembership BIT
        DECLARE @isActive         BIT
        
        if @Debug = 1
        BEGIN
            PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Getting permissions for given parameters.'
        END
        
        open getPermissions
        FETCH NEXT
        FROM getPermissions INTO @RoleName,@PermissionLevel,@PrivName,@isRoleMembership,@isActive
        
        if @Debug = 1
        BEGIN
            PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Applying permissions for given parameters.'
        END        
        
        WHILE @@FETCH_STATUS = 0        
        BEGIN
            if @isRoleMembership = 0 
            BEGIN
                merge Security.DatabasePermissions p
                using (
                    select 
                        @ServerName             as ServerName,
                        @DbName                 as DbName,
                        @RoleName               as Grantee,
                        0                       as isUser,
                        'DATABASE_SCHEMA'       as ObjectClass,
                        null                    as ObjectType,
                        @PermissionLevel        as PermissionLevel,
                        @PrivName               as PermissionName,
                        null                    as SchemaName,
                        @SchemaName             as ObjectName,
                        null                    as SubObjectName,
                        0                       as isWithGrantOption,
                        'Defined by standard'   as Reason,
                        @isActive               as isActive     
                ) i
                on 
                    p.ServerName = i.ServerName
                and p.DbName     = i.DbName
                and p.Grantee    = i.Grantee 
                and p.ObjectClass = i.ObjectClass
                and isnull(p.ObjectType,'null') = isnull(i.ObjectType,'null')
                and p.PermissionName = i.PermissionName
                and isnull(p.schemaName,'null') = isnull(i.schemaName,'null')
                and p.ObjectName = i.ObjectName
                and isnull(p.SubObjectName,'null') = isnull(i.SubObjectName,'null')
                
                WHEN MATCHED THEN 
                    update set
                        PermissionLevel     = i.PermissionLevel,
                        isWithGrantOption   = i.isWithGrantOption,
                        Reason              = i.Reason,
                        isActive            = i.isActive
                        
                WHEN NOT MATCHED BY TARGET THEN
                    insert (
                        ServerName,
                        DbName,
                        Grantee,
                        isUser,
                        ObjectClass,
                        ObjectType,
                        PermissionLevel,
                        PermissionName,
                        SchemaName,
                        ObjectName,
                        SubObjectName,
                        isWithGrantOption,
                        Reason,
                        isActive
                    )
                    values (
                        i.ServerName,
                        i.DbName,
                        i.Grantee,
                        i.isUser,
                        i.ObjectClass,
                        i.ObjectType,
                        i.PermissionLevel,
                        i.PermissionName,
                        i.SchemaName,
                        i.ObjectName,
                        i.SubObjectName,
                        i.isWithGrantOption,
                        i.Reason,
                        i.isActive                    
                    )
                --WHEN NOT MATCHED BY SOURCE THEN TODO
                ;

            END
            ELSE
            BEGIN
                merge security.DatabaseRoleMembers drm
                using (
                    select 
                        @ServerName             as ServerName,
                        @DbName                 as DbName,
                        @PrivName               as RoleName,
                        @RoleName               as MemberName,   
                        @PermissionLevel        as PermissionLevel,
                        1                       as MemberIsRole,
                        'Defined by Standard'   as Reason,
                        @isActive               as isActive    
                ) i
                on
                    drm.ServerName  = i.ServerName
                and drm.DbName      = i.DbName
                and drm.RoleName    = i.RoleName
                and drm.MemberName  = i.MemberName
                
                WHEN MATCHED THEN 
                    update set      
                        PermissionLevel = i.PermissionLevel,
                        Reason          = i.Reason,
                        isActive        = i.isActive
                        
                WHEN NOT MATCHED BY TARGET THEN
                    insert (
                        ServerName,DbName,RoleName,MemberName,PermissionLevel,MemberIsRole,Reason,isActive
                    )
                    values (
                        i.ServerName,i.DbName,i.RoleName,i.MemberName,i.PermissionLevel,i.MemberIsRole,i.Reason,i.isActive
                    )
                --WHEN NOT MATCHED BY SOURCE THEN TODO
                ;
            END
        
            FETCH NEXT
            FROM getPermissions INTO @RoleName,@PermissionLevel,@PrivName,@isRoleMembership,@isActive        
                    
        END
        CLOSE getPermissions
        DEALLOCATE getPermissions                       
    
    COMMIT
    END TRY
    BEGIN CATCH
        SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
            

        if CURSOR_STATUS('local','getPermissions') >= 0 
        begin
            close getPermissions
            deallocate getPermissions 
        end            
        ROLLBACK
    END CATCH
END
GO


PRINT '    Procedure [security].[setStandardOnSchemaRolePermissions] altered.'
    
PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''    







PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[getDbSchemasCreationScript] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getDbSchemasCreationScript]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [security].[getDbSchemasCreationScript] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Procedure [security].[getDbSchemasCreationScript] created.'
END
GO

ALTER Procedure [security].[getDbSchemasCreationScript] (    
    @ServerName  		    varchar(512),    
    @DbName  		        varchar(64),    
    @SchemaName             varchar(64)     = NULL,	
	@AsOf 				    DATETIME 		= NULL ,
	@OutputType 		    VARCHAR(20) 	= 'TABLE' ,
    @OutputDatabaseName     NVARCHAR(128) 	= NULL ,
    @OutputSchemaName 	    NVARCHAR(256) 	= NULL ,
    @OutputTableName 	    NVARCHAR(256) 	= NULL ,	
    @NoDependencyCheckGen   BIT             = 0,   
    @CanDropTempTables      BIT             = 1,
	@Debug		 		    BIT		  	 	= 0    
)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This Procedure generates the statements for all the log
 
  ARGUMENTS :
    @ServerName     name of the server on which the SQL Server instance we want to modify is running.
 
  REQUIREMENTS:
 
  ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================
	00002		0.1.2	String ". Generating commands" shown like that in the resulting script
						making the generated script unusable directly.
    ----------------------------------------------------------------------------------
  ==================================================================================
  NOTES:
  AUTHORS:
       .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
       .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
       .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
 
  COMPANY: CHU Liege
  ==================================================================================
  Historique des revisions
 
    Date        Name	        	Description
    ==========  =================	===========================================================
    19/12/2014  Jefferson Elias		Creation
    ----------------------------------------------------------------------------------
 ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    
    DECLARE @versionNb          varchar(16) = '0.0.1';
    DECLARE @execTime			datetime;
    DECLARE @tsql               varchar(max);   
    DECLARE	@CurSchema   	  	varchar(64)
	DECLARE @LineFeed 			VARCHAR(10)
    DECLARE @StringToExecute    VARCHAR(MAX)
    
	/* Sanitize our inputs */
	SELECT 
		@OutputDatabaseName = QUOTENAME(@OutputDatabaseName),
		@LineFeed 			= CHAR(13) + CHAR(10),
		@execTime = GETDATE()
	
    /**
     * Checking parameters
     */
    if(@ServerName is null)
    BEGIN
        RAISERROR('No value set for @ServerName !',10,1)
    END		
    
    SET @CurSchema = @SchemaName

    exec security.CreateTempTables4Generation 
        @CanDropTempTables, 
        @Debug = @Debug 

    IF @OutputType = 'SCHEMA'
	BEGIN
		SELECT FieldList = 'GenerationDate DATETIME NOT NULL | ServerName VARCHAR(256) NOT NULL | DbName VARCHAR(64) NULL | ObjectName VARCHAR(512)  NULL | GeneratorVersion VARCHAR(16) NOT NULL | OperationOrder BIGINT  NOT NULL | OperationType VARCHAR(64) not null | QueryText	VARCHAR(MAX) NOT NULL'
	END
	ELSE IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL
    -- This mode is OK, just a TODO (make it with *named* fields)
	BEGIN
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Asof Mode detected'
        END       
		-- They want to look into the past.

        SET @StringToExecute = N' IF EXISTS(SELECT * FROM '
            + @OutputDatabaseName
            + '.INFORMATION_SCHEMA.SCHEMATA WHERE (SCHEMA_NAME) = '''
            + @OutputSchemaName + ''')' + @LineFeed 
            + '    SELECT GenerationDate, ServerName,DbName,ObjectName,GeneratorVersion,OperationOrder,OperationType,QueryText' + @LineFeed 
            + '    FROM '
            + @OutputDatabaseName + '.'
            + @OutputSchemaName + '.'
            + @OutputTableName + @LineFeed
            + '    WHERE GenerationDate = /*DATEADD(mi, -15, */CONVERT(DATETIME,''' + CONVERT(NVARCHAR(100),@AsOf,121) + ''',121)'
            + '    ORDER BY OperationOrder;'
        ;
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Query : ' + @LineFeed + @StringToExecute
        END  
        EXEC(@StringToExecute);
	END /* IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL */

	ELSE -- Security command generation
    BEGIN
        DECLARE @CurOpName VARCHAR(512)
        DECLARE @CurOpOrder BIGINT
        
		BEGIN TRY
		BEGIN TRANSACTION           
            SET @CurOpName = 'CHECK_EXPECTED_SERVERNAME'
                
            if(@NoDependencyCheckGen = 0 and not exists (select 1 from ##SecurityGenerationResults where ServerName = @ServerName and OperationType = @CurOpName))
            BEGIN     
                
                if @Debug = 1
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Adding Server name check'
                END                    
                
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                insert ##SecurityGenerationResults (
                    ServerName,		
                    DbName,			
                    OperationType, 	
                    OperationOrder,
                    QueryText 		
                )
                values (
                    @ServerName,		
                    null,
                    @CurOpName,
                    @CurOpOrder,
                    'IF (@@SERVERNAME <> ''' + (@ServerName) + '''' +  @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    RAISERROR(''Expected @@ServerName : "' + @ServerName + '"'', 16, 0)'  + @LineFeed +
                    'END' 
                )
                SET @CurOpName  = null
                SET @CurOpOrder = null
            END
            
            SET @CurOpName = 'CHECK_DATABASE_EXISTS'
            if(@NoDependencyCheckGen = 0 and not exists (select 1 from ##SecurityGenerationResults where ServerName = @ServerName and DbName = @DbName and OperationType = @CurOpName))
            BEGIN     
                if @Debug = 1
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Adding database existence check'
                END                 
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                insert ##SecurityGenerationResults (
                    ServerName,		
                    DbName,			
                    OperationType, 	
                    OperationOrder,
                    QueryText 		
                )
                values (
                    @ServerName,		
                    @DbName,
                    @CurOpName,
                    @CurOpOrder,
                    'IF NOT EXISTS( SELECT 1 FROM sys.databases where Name =  ''' + (@DbName) + ''')' +  @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    RAISERROR(''The Database named : "' + @DbName + '" doesn''t exist on server !'', 16, 0)'  + @LineFeed +
                    'END' 
                )
                SET @CurOpName  = null
                SET @CurOpOrder = null                    
            END
			if(@CurSchema is null) 
			BEGIN	
           		if @Debug = 1 
				BEGIN
					PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Every Schema generation detected.'
				END
                
                DECLARE getSchemas CURSOR LOCAL FOR
                    select
                        [SchemaName]
                    from 
                        [security].[DatabaseSchemas]        
                    where 
                        [ServerName] = @ServerName
                    and [DbName]     = @DbName
                
                open getSchemas
				FETCH NEXT
				FROM getSchemas INTO @CurSchema

                WHILE @@FETCH_STATUS = 0
				BEGIN						
					EXEC [security].[getDbSchemasCreationScript] 
						@ServerName 		    = @ServerName,
						@DbName 		        = @DbName,
						@SchemaName  		    = @CurSchema,
						@OutputType 		    = @OutputType,
						@OutputDatabaseName     = null,--@OutputDatabaseName,
						@OutputSchemaName 	    = null,--@OutputSchemaName,
						@OutputTableName 	    = null,--@OutputTableName,
                        @NoDependencyCheckGen   = 1,
                        @CanDropTempTables      = 0,
						@Debug 				    = @Debug
					-- carry on ...
					FETCH NEXT
					FROM getSchemas INTO @CurSchema
				END
				CLOSE getSchemas
				DEALLOCATE getSchemas			
            END
            ELSE  -- a schema name is given
            BEGIN                        
                DECLARE @isActive BIT
                
                select 
                    @isActive   = isActive
                from 
                    [security].[DatabaseSchemas]        
                where 
                    [ServerName] = @ServerName
                and [DbName]     = @DbName 
                and [SchemaName] = @CurSchema
    
                if @isActive is null 
                BEGIN
					DECLARE @ErrMsg VARCHAR(512) = 'The provided schema ' + QUOTENAME(@CurSchema) + ' does not exist.'
                    RAISERROR(@ErrMsg,16,0)
                END 
                                
                
                SET @StringToExecute = 'PRINT ''. Commands for Schema "' + @CurSchema + '" in database "' + @DbName + '"' + @LineFeed +
                                       [security].[getSchemaCreationStatement](
                                            @DbName,
                                            @CurSchema,
                                            @isActive,                                            
                                            1, -- no header
                                            1, -- no db check 
                                            @Debug
                                        ) 
                SET @CurOpName = 'CHECK_AND_CREATE_DB_SCHEMA'
                
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                insert ##SecurityGenerationResults (
                    ServerName,		
                    DbName,		
                    ObjectName,			
                    OperationType, 	
                    OperationOrder,
                    QueryText 		
                )
                values (
                    @ServerName,		
                    @DbName,		
                    @CurSchema,
                    @CurOpName,
                    @CurOpOrder,
                    @StringToExecute
                )
                SET @CurOpName  = null
                SET @CurOpOrder = null
            END 
            
            /*
                Now we have the table ##SecurityGenerationResults 
                with all we got from generation.
                
			    @OutputTableName lets us export the results to a permanent table 
				
                This way to process is highly inspired from Brent Ozar's 
            */
			--SELECT * from ##SecurityGenerationResults
            exec [security].[SaveSecurityGenerationResult] 
				@OutputDatabaseName     = @OutputDatabaseName,
				@OutputSchemaName 	    = @OutputSchemaName ,
				@OutputTableName 	    = @OutputTableName ,
				@VersionNumber		 	= @versionNb,
				@Debug		 		    = @Debug
        COMMIT
		
		END TRY
		
		BEGIN CATCH
			SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS ErrorSeverity
			,ERROR_STATE() AS ErrorState
			,ERROR_PROCEDURE() AS ErrorProcedure
			,ERROR_LINE() AS ErrorLine
			,ERROR_MESSAGE() AS ErrorMessage;
			
			if CURSOR_STATUS('local','getSchemas') >= 0 
			begin
				close getSchemas
				deallocate getSchemas 
			end

            IF @@TRANCOUNT > 0
                ROLLBACK
		END CATCH
	END
END
GO            


PRINT '    Procedure [security].[getDbSchemasCreationScript] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 







PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[getDbUsersCreationScript] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getDbUsersCreationScript]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [security].[getDbUsersCreationScript] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Procedure [security].[getDbUsersCreationScript] created.'
END
GO

ALTER Procedure [security].[getDbUsersCreationScript] (    
    @ServerName  		    varchar(512),
    @DbName  		        varchar(32),    
    @UserName               varchar(64)     = NULL,	
	@AsOf 				    DATETIME 		= NULL ,
	@OutputType 		    VARCHAR(20) 	= 'TABLE' ,
    @OutputDatabaseName     NVARCHAR(128) 	= NULL ,
    @OutputSchemaName 	    NVARCHAR(256) 	= NULL ,
    @OutputTableName 	    NVARCHAR(256) 	= NULL ,	
    @NoDependencyCheckGen   BIT             = 0,
    @CanDropTempTables      BIT             = 1,
	@Debug		 		    BIT		  	 	= 0    
)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This Procedure generates the statements for all the log
 
  ARGUMENTS :
    @ServerName     name of the server on which the SQL Server instance we want to modify is running.
 
  REQUIREMENTS:
 
  ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================

    ----------------------------------------------------------------------------------
  ==================================================================================
  NOTES:
  AUTHORS:
       .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
       .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
       .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
 
  COMPANY: CHU Liege
  ==================================================================================
  Historique des revisions
 
    Date        Name	        	Description
    ==========  =================	===========================================================
    22/12/2014  Jefferson Elias		Creation
    ----------------------------------------------------------------------------------
 ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    
    DECLARE @versionNb          varchar(16) = '0.0.1';
    DECLARE @execTime			datetime;
    DECLARE @tsql               varchar(max);   
    DECLARE	@CurUser     	  	varchar(64)
	DECLARE @LineFeed 			VARCHAR(10)
    DECLARE @StringToExecute    VARCHAR(MAX)
    
	/* Sanitize our inputs */
	SELECT 
		@OutputDatabaseName = QUOTENAME(@OutputDatabaseName),
		@LineFeed 			= CHAR(13) + CHAR(10),
		@execTime = GETDATE()
	
    /**
     * Checking parameters
     */
    if(@ServerName is null)
    BEGIN
        RAISERROR('No value set for @ServerName !',10,1)
    END		
    
    SET @CurUser = @UserName

    exec security.CreateTempTables4Generation 
            @CanDropTempTables, 
            @Debug = @Debug 

    IF @OutputType = 'SCHEMA'
	BEGIN
		SELECT FieldList = 'GenerationDate DATETIME NOT NULL | ServerName VARCHAR(256) NOT NULL | DbName VARCHAR(64) NULL | ObjectName VARCHAR(512)  NULL | GeneratorVersion VARCHAR(16) NOT NULL | OperationOrder BIGINT  NOT NULL | OperationType VARCHAR(64) not null | QueryText	VARCHAR(MAX) NOT NULL'
	END
	ELSE IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL
    -- This mode is OK, just a TODO (make it with *named* fields)
	BEGIN
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Asof Mode detected'
        END       
		-- They want to look into the past.

        SET @StringToExecute = N' IF EXISTS(SELECT * FROM '
            + @OutputDatabaseName
            + '.INFORMATION_SCHEMA.SCHEMATA WHERE (SCHEMA_NAME) = '''
            + @OutputSchemaName + ''')' + @LineFeed 
            + '    SELECT GenerationDate, ServerName,DbName,ObjectName,GeneratorVersion,OperationOrder,OperationType,QueryText' + @LineFeed 
            + '    FROM '
            + @OutputDatabaseName + '.'
            + @OutputSchemaName + '.'
            + @OutputTableName + @LineFeed
            + '    WHERE GenerationDate = /*DATEADD(mi, -15, */CONVERT(DATETIME,''' + CONVERT(NVARCHAR(100),@AsOf,121) + ''',121)'
            + '    ORDER BY OperationOrder;'
        ;
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Query : ' + @LineFeed + @StringToExecute
        END  
        EXEC(@StringToExecute);
	END /* IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL */

	ELSE -- Security command generation
    BEGIN
        DECLARE @CurOpName VARCHAR(512)
        DECLARE @CurOpOrder BIGINT
        
		BEGIN TRY
		BEGIN TRANSACTION           
            SET @CurOpName = 'CHECK_EXPECTED_SERVERNAME'
                
            if(@NoDependencyCheckGen = 0 and not exists (select 1 from ##SecurityGenerationResults where ServerName = @ServerName and OperationType = @CurOpName))
            BEGIN     
                
                if @Debug = 1
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Adding Server name check'
                END                    
                
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                insert ##SecurityGenerationResults (
                    ServerName,		
                    DbName,			
                    OperationType, 	
                    OperationOrder,
                    QueryText 		
                )
                values (
                    @ServerName,		
                    null,
                    @CurOpName,
                    @CurOpOrder,
                    'IF (@@SERVERNAME <> ''' + (@ServerName) + '''' +  @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    RAISERROR(''Expected @@ServerName : "' + @ServerName + '"'', 16, 0)'  + @LineFeed +
                    'END' 
                )
                SET @CurOpName  = null
                SET @CurOpOrder = null
            END
            
            SET @CurOpName = 'CHECK_DATABASE_EXISTS'
            if(@NoDependencyCheckGen = 0 and not exists (select 1 from ##SecurityGenerationResults where ServerName = @ServerName and DbName = @DbName and OperationType = @CurOpName))
            BEGIN     
                if @Debug = 1
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Adding database existence check'
                END                 
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                insert ##SecurityGenerationResults (
                    ServerName,		
                    DbName,			
                    OperationType, 	
                    OperationOrder,
                    QueryText 		
                )
                values (
                    @ServerName,		
                    @DbName,
                    @CurOpName,
                    @CurOpOrder,
                    'IF NOT EXISTS( SELECT 1 FROM sys.databases where Name =  ''' + (@DbName) + ''')' +  @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    RAISERROR(''The Database named : "' + @DbName + '" doesn''t exist on server !'', 16, 0)'  + @LineFeed +
                    'END' 
                )
                SET @CurOpName  = null
                SET @CurOpOrder = null                    
            END
            
			if(@CurUser is null) 
			BEGIN	
           		if @Debug = 1 
				BEGIN
					PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Every users in database generation detected.'
				END
                
                DECLARE getDbUsers CURSOR LOCAL FOR
                    select 
                        DbUserName
                    from security.DatabaseUsers
                    where 
                        [ServerName] = @ServerName 
                    and [DbName]     = @DbName 
                    order by 1
        
                open getDbUsers
				FETCH NEXT
				FROM getDbUsers INTO @CurUser

                WHILE @@FETCH_STATUS = 0
				BEGIN						
					EXEC [security].[getDbUsersCreationScript] 
						@ServerName 		    = @ServerName,
						@DbName     		    = @DbName,
						@UserName  			    = @CurUser,
						@OutputType 		    = @OutputType,
						@OutputDatabaseName     = null,--@OutputDatabaseName,
						@OutputSchemaName 	    = null,--@OutputSchemaName,
						@OutputTableName 	    = null,--@OutputTableName,
                        @NoDependencyCheckGen   = 1,
                        @CanDropTempTables      = 0,
						@Debug 				    = @Debug
					-- carry on ...
					FETCH NEXT
					FROM getDbUsers INTO @CurUser
				END
				CLOSE getDbUsers
				DEALLOCATE getDbUsers			
            END
            ELSE  -- a login name is given
            BEGIN   

                if @Debug = 1
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - ServerName ' + @ServerName 
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - DbName     ' + @DbName 
                END
            
                DECLARE @isLocked           BIT
                DECLARE @SQLLogin           VARCHAR(64)
                DECLARE @DefaultSchema      VARCHAR(64)    
                
                select 
                    @SQLLogin       = SQLLogin,
                    @DefaultSchema  = DefaultSchema,
                    @isLocked       = isLocked
                from 
                    [security].[DatabaseUsers]        
                where 
                    [ServerName]    = @ServerName 
                and [DbName]        = @DbName 
                and [DbUserName]    = @CurUser 
    
                if @SQLLogin is null 
                BEGIN
					DECLARE @ErrMsg VARCHAR(512) = 'The provided database user ' + QUOTENAME(@CurUser) + ' does not exist.'
                    RAISERROR(@ErrMsg,16,0)
                END 
                
                if @debug = 1 
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of user ' + @CurUser 
                END    

                SET @StringToExecute = 'PRINT ''. Commands for Database User "' + @CurUser+ '" in database "' + @DbName + '"' + @LineFeed +
                                        [security].[getDbUserCreationStatement](
                                            @DbName,
                                            @SQLLogin,
                                            @CurUser,
                                            @DefaultSchema,
                                            @isLocked,                                            
                                            1, -- no header
                                            1, -- no db check 
                                            @Debug
                                        ) 
                SET @CurOpName = 'CHECK_AND_CREATE_DB_USER'
                
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                insert ##SecurityGenerationResults (
                    ServerName,	
                    DbName,	
                    ObjectName,			
                    OperationType, 	
                    OperationOrder,
                    QueryText 		
                )
                values (
                    @ServerName,		
                    @DbName,
                    @CurUser,
                    @CurOpName,
                    @CurOpOrder,
                    @StringToExecute
                )
                SET @CurOpName  = null
                SET @CurOpOrder = null
            END 
            
            /*
                Now we have the table ##SecurityGenerationResults 
                with all we got from generation.
                
			    @OutputTableName lets us export the results to a permanent table 
				
                This way to process is highly inspired from Brent Ozar's 
            */
			--SELECT * from ##SecurityGenerationResults
            exec [security].[SaveSecurityGenerationResult] 
				@OutputDatabaseName     = @OutputDatabaseName,
				@OutputSchemaName 	    = @OutputSchemaName ,
				@OutputTableName 	    = @OutputTableName ,
				@VersionNumber		 	= @versionNb,
				@Debug		 		    = @Debug
        COMMIT
		
		END TRY
		
		BEGIN CATCH
			SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS ErrorSeverity
			,ERROR_STATE() AS ErrorState
			,ERROR_PROCEDURE() AS ErrorProcedure
			,ERROR_LINE() AS ErrorLine
			,ERROR_MESSAGE() AS ErrorMessage;
			
			if CURSOR_STATUS('local','getDbUsers') >= 0 
			begin
				close getDbUsers
				deallocate getDbUsers 
			end

            IF @@TRANCOUNT > 0
                ROLLBACK
		END CATCH
	END
END
GO            


PRINT '    Procedure [security].[getDbUsersCreationScript] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 







PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[getLoginsCreationScript] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getLoginsCreationScript]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [security].[getLoginsCreationScript] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Procedure [security].[getLoginsCreationScript] created.'
END
GO

ALTER Procedure [security].[getLoginsCreationScript] (    
    @ServerName  		    varchar(512),
    @LoginName              varchar(64)     = NULL,	
	@AsOf 				    DATETIME 		= NULL ,
	@OutputType 		    VARCHAR(20) 	= 'TABLE' ,
    @OutputDatabaseName     NVARCHAR(128) 	= NULL ,
    @OutputSchemaName 	    NVARCHAR(256) 	= NULL ,
    @OutputTableName 	    NVARCHAR(256) 	= NULL ,	
    @NoDependencyCheckGen   BIT             = 0,
    @CanDropTempTables      BIT             = 1,
	@Debug		 		    BIT		  	 	= 0    
)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This Procedure generates the statements for all the log
 
  ARGUMENTS :
    @ServerName     name of the server on which the SQL Server instance we want to modify is running.
 
  REQUIREMENTS:
 
  ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================
	00002		0.1.2	String ". Generating commands" shown like that in the resulting script
						making the generated script unusable directly.
    ----------------------------------------------------------------------------------
  ==================================================================================
  NOTES:
  AUTHORS:
       .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
       .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
       .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
 
  COMPANY: CHU Liege
  ==================================================================================
  Historique des revisions
 
    Date        Name	        	Description
    ==========  =================	===========================================================
    19/12/2014  Jefferson Elias		Creation
    ----------------------------------------------------------------------------------
 ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    
    DECLARE @versionNb          varchar(16) = '0.0.1';
    DECLARE @execTime			datetime;
    DECLARE @tsql               varchar(max);   
    DECLARE	@CurLogin   	  	varchar(64)
	DECLARE @LineFeed 			VARCHAR(10)
    DECLARE @StringToExecute    VARCHAR(MAX)
    
	/* Sanitize our inputs */
	SELECT 
		@OutputDatabaseName = QUOTENAME(@OutputDatabaseName),
		@LineFeed 			= CHAR(13) + CHAR(10),
		@execTime = GETDATE()
	
    /**
     * Checking parameters
     */
    if(@ServerName is null)
    BEGIN
        RAISERROR('No value set for @ServerName !',10,1)
    END		
    
    SET @CurLogin = @LoginName

    exec security.CreateTempTables4Generation 
            @CanDropTempTables, 
            @Debug = @Debug 

    IF @OutputType = 'SCHEMA'
	BEGIN
		SELECT FieldList = 'GenerationDate DATETIME NOT NULL | ServerName VARCHAR(256) NOT NULL | DbName VARCHAR(64) NULL | ObjectName VARCHAR(512)  NULL | GeneratorVersion VARCHAR(16) NOT NULL | OperationOrder BIGINT  NOT NULL | OperationType VARCHAR(64) not null | QueryText	VARCHAR(MAX) NOT NULL'
	END
	ELSE IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL
    -- This mode is OK, just a TODO (make it with *named* fields)
	BEGIN
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Asof Mode detected'
        END       
		-- They want to look into the past.

        SET @StringToExecute = N' IF EXISTS(SELECT * FROM '
            + @OutputDatabaseName
            + '.INFORMATION_SCHEMA.SCHEMATA WHERE (SCHEMA_NAME) = '''
            + @OutputSchemaName + ''')' + @LineFeed 
            + '    SELECT GenerationDate, ServerName,DbName,ObjectName,GeneratorVersion,OperationOrder,OperationType,QueryText' + @LineFeed 
            + '    FROM '
            + @OutputDatabaseName + '.'
            + @OutputSchemaName + '.'
            + @OutputTableName + @LineFeed
            + '    WHERE GenerationDate = /*DATEADD(mi, -15, */CONVERT(DATETIME,''' + CONVERT(NVARCHAR(100),@AsOf,121) + ''',121)'
            + '    ORDER BY OperationOrder;'
        ;
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Query : ' + @LineFeed + @StringToExecute
        END  
        EXEC(@StringToExecute);
	END /* IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL */

	ELSE -- Security command generation
    BEGIN
        DECLARE @CurOpName VARCHAR(512)
        DECLARE @CurOpOrder BIGINT
        
		BEGIN TRY
		BEGIN TRANSACTION           
            SET @CurOpName = 'CHECK_EXPECTED_SERVERNAME'
                
            if(@NoDependencyCheckGen = 0 and not exists (select 1 from ##SecurityGenerationResults where ServerName = @ServerName and OperationType = @CurOpName))
            BEGIN     
                
                if @Debug = 1
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Adding Server name check'
                END                    
                
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                insert ##SecurityGenerationResults (
                    ServerName,		
                    DbName,			
                    OperationType, 	
                    OperationOrder,
                    QueryText 		
                )
                values (
                    @ServerName,		
                    null,
                    @CurOpName,
                    @CurOpOrder,
                    'IF (@@SERVERNAME <> ''' + (@ServerName) + '''' +  @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    RAISERROR(''Expected @@ServerName : "' + @ServerName + '"'', 16, 0)'  + @LineFeed +
                    'END' 
                )
                SET @CurOpName  = null
                SET @CurOpOrder = null
            END
			if(@CurLogin is null) 
			BEGIN	
           		if @Debug = 1 
				BEGIN
					PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Every logins generation detected.'
				END
                
                DECLARE getLogins CURSOR LOCAL FOR
                    select
                        [SQLLogin]
                    from [security].[logins]        
                    where [ServerName] = @ServerName
                
                open getLogins
				FETCH NEXT
				FROM getLogins INTO @CurLogin

                WHILE @@FETCH_STATUS = 0
				BEGIN						
					EXEC [security].[getLoginsCreationScript] 
						@ServerName 		    = @ServerName,
						@LoginName 			    = @CurLogin,
						@OutputType 		    = @OutputType,
						@OutputDatabaseName     = null,--@OutputDatabaseName,
						@OutputSchemaName 	    = null,--@OutputSchemaName,
						@OutputTableName 	    = null,--@OutputTableName,
                        @NoDependencyCheckGen   = 1,
                        @CanDropTempTables      = 0,
						@Debug 				    = @Debug
					-- carry on ...
					FETCH NEXT
					FROM getLogins INTO @CurLogin
				END
				CLOSE getLogins
				DEALLOCATE getLogins			
            END
            ELSE  -- a login name is given
            BEGIN                        
                DECLARE @Department         VARCHAR(256)
                DECLARE @Name               VARCHAR(64)
                DECLARE @AuthMode           VARCHAR(64)    
                DECLARE @DefaultDb          VARCHAR(64)
                DECLARE @isActive           BIT

                DECLARE @DefaultPassword VARCHAR(128) 

                select 
                    @DefaultPassword = ParamValue   
                from [security].[ApplicationParams]
                where ParamName = 'MSSQL_LoginSecurity_DefaultPassword'
                
                select 
                    @Department = Department,
                    @Name       = Name,
                    @AuthMode   = AuthMode,
                    @DefaultDb  = DbName,
                    @isActive   = isActive
                from 
                    [security].[logins]        
                where 
                    [ServerName] = @ServerName
                and SQLLogin     = @CurLogin
    
                if @AuthMode is null 
                BEGIN
					DECLARE @ErrMsg VARCHAR(512) = 'The provided login ' + QUOTENAME(@CurLogin) + ' does not exist.'
                    RAISERROR(@ErrMsg,16,0)
                END 
                
                if @debug = 1 
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of login ' + @CurLogin + ' (' + @Name + ')'
                END    

                SET @StringToExecute = 'PRINT ''. Commands for "' + @Name + '" from department "' + @Department + '"''' + @LineFeed +
                                       [security].[getLoginCreationStatement](
                                            @CurLogin,
                                            @AuthMode,
                                            @DefaultPassword,
                                            @DefaultDb,
                                            @isActive,                                            
                                            1, -- no header
                                            1, -- no db check 
                                            0,  -- GRANT CONNECT SQL YES ! TODO change it !!
                                            @Debug
                                        ) 
                SET @CurOpName = 'CHECK_AND_CREATE_SQL_LOGINS'
                
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                insert ##SecurityGenerationResults (
                    ServerName,		
                    ObjectName,			
                    OperationType, 	
                    OperationOrder,
                    QueryText 		
                )
                values (
                    @ServerName,		
                    @CurLogin,
                    @CurOpName,
                    @CurOpOrder,
                    @StringToExecute
                )
                SET @CurOpName  = null
                SET @CurOpOrder = null
            END 
            
            /*
                Now we have the table ##SecurityGenerationResults 
                with all we got from generation.
                
			    @OutputTableName lets us export the results to a permanent table 
				
                This way to process is highly inspired from Brent Ozar's 
            */
			--SELECT * from ##SecurityGenerationResults
            exec [security].[SaveSecurityGenerationResult] 
				@OutputDatabaseName     = @OutputDatabaseName,
				@OutputSchemaName 	    = @OutputSchemaName ,
				@OutputTableName 	    = @OutputTableName ,
				@VersionNumber		 	= @versionNb,
				@Debug		 		    = @Debug
        COMMIT
		
		END TRY
		
		BEGIN CATCH
			SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS ErrorSeverity
			,ERROR_STATE() AS ErrorState
			,ERROR_PROCEDURE() AS ErrorProcedure
			,ERROR_LINE() AS ErrorLine
			,ERROR_MESSAGE() AS ErrorMessage;
			
			if CURSOR_STATUS('local','getLogins') >= 0 
			begin
				close getLogins
				deallocate getLogins 
			end

            IF @@TRANCOUNT > 0
                ROLLBACK
		END CATCH
	END
END
GO            


PRINT '    Procedure [security].[getLoginsCreationScript] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 








PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[CloneSecurity] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[CloneSecurity]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[CloneSecurity] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[CloneSecurity] created.'
END
GO

ALTER PROCEDURE [security].[CloneSecurity] (
    @ServerName  		varchar(512) = @@ServerName,
	@DbName		 		varchar(64)  = NULL,
	@TargetServerName	varchar(512) = @@ServerName,
	@TargetDbName		varchar(64)  = NULL,
	@ExactCopy	 		BIT		  	 = 0,
	@Debug		 		BIT		  	 = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
		This function is a helper for one to quickly copy the security model set
		for a database in a server. If no database is set, the whole server is used.
		This can lead to problematic situations as there can be databases that exists
		on the source server and doesn't on the target server.
		So, be aware of what you are doing !
  
   ARGUMENTS :
     @ServerName    name of the server from which the we want to copy the security
					By default, it's the current server
	
	 @DbName		name of the database to consider on that server.
					A NULL value (which is the default value) means that this procedure
					has to take care of every databases existing on that server.
  
	 @TargetServerName
					name of the server for which we want to set the same configuration
  
	 @TargetDbName	name of the server for which we want to set the same configuration
					A NULL value means that we will use @DbName value.
  
	 @ExactCopy		specifies if we need to scratch configuration for @TargetServer
  
   REQUIREMENTS:
  
	EXAMPLE USAGE :
		
		[security].[CloneSecurity]
			@ServerName  		= 'SI-S-SERV204',
			@DbName		 		= 'Pharmalogic',
			@TargetServerName	= 'SI-S-SERV183',
			@TargetDbName		= NULL,
			@ExactCopy	 		= 1,
			@Debug		 		= 0		
   ==================================================================================
   BUGS:
  
     BUGID       Fixed   Description
     ==========  =====   ==========================================================
     ----------------------------------------------------------------------------------
   ==================================================================================
   NOTES:
   AUTHORS:
        .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
        .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
        .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
  
   COMPANY: CHU Liege
   ==================================================================================
   Revision History
  
     Date        Nom         Description
     ==========  =====       ==========================================================
     16/12/2014  JEL         Version 0.0.1
     ----------------------------------------------------------------------------------
  ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    DECLARE @versionNb        	varchar(16) = '0.0.1';
    DECLARE @tsql             	varchar(max);

	DECLARE	@CurDbName		  	varchar(64)
	DECLARE @TgtDbName			varchar(64)
	
	/*
		Checking parameters
	*/
	
	if(@ServerName is null)
	BEGIN
		RAISERROR('No value set for @ServerName !',10,1)
	END		
	if(@TargetServerName is null)
	BEGIN
		RAISERROR('No value set for @TargetServerName !',10,1)
	END		
	
	SET @TgtDbName = @TargetDbName
	SET @CurDbName = @DbName		
	
	BEGIN TRY
	BEGIN TRANSACTION
	
		if(@CurDbName is null) 
		BEGIN

			if @ExactCopy = 1
			BEGIN
				if @Debug = 1
				BEGIN
					RAISERROR('Exact copy mode not yet implemented',10,1)
					--PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Deleting every information about target database'
					-- TODO: Mark all logins as to be dropped
				END	
			END		
		
			-- needs to loop on all dbs defined in SQLMappings
			-- no parameterized cursor in MSSQL ... viva Oracle!
			DECLARE getServerDatabases CURSOR LOCAL FOR
				select distinct
					DbName
				from security.SQLMappings
				where 
					[ServerName] = @ServerName 
				order by 1			
			open getServerDatabases
			FETCH NEXT
			FROM getServerDatabases INTO @CurDbName
			
			WHILE @@FETCH_STATUS = 0
			BEGIN						
				EXEC [security].[CloneSecurity] @ServerName = @ServerName, @DbName = @CurDbName,@TargetServerName = @TargetServerName,@TargetDbName = @TgtDbName, @ExactCopy = @ExactCopy, @Debug = @Debug
				-- carry on ...
				FETCH NEXT
				FROM getServerDatabases INTO @CurDbName
			END
			CLOSE getServerDatabases
			DEALLOCATE getServerDatabases				
		
		END
		ELSE
		BEGIN
			
			if @Debug = 1
			BEGIN
				PRINT '--------------------------------------------------------------------------------------------------------------'
				PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Source server Name : ' + @ServerName				
				PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Target server Name : ' + @TargetServerName				
			END	
			-- setting source database name
			if @Debug = 1
			BEGIN
				PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Source server database set to ' + @CurDbName				
			END		
			
			-- setting target database name
			if(@TargetDbName is null)
			BEGIN
				SET @TgtDbName = @CurDbName
				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Target server database set to ' + @TgtDbName				
				END						
			END
			ELSE
			BEGIN
				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Target server database name :' + @TgtDbName				
				END									
			END
			
			-- Checking we won't be in a problematic situation...
			if(@ServerName = @TargetServerName and @TgtDbName = @CurDbName)
			BEGIN
				PRINT CONVERT(VARCHAR,GETDATE()) + ' - WARN - Skipping execution for this settings : same server name, same database name.'				
			END
			ELSE 
			BEGIN
			
				if @ExactCopy = 1
				BEGIN
					if @Debug = 1
					BEGIN
						RAISERROR('Exact copy mode not yet implemented',10,1)
						--PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Deleting every information about target database'
						-- TODO: Procedure to mark as to be dropped everything about @TgtDbName on @TargetServer
					END	
				END			
				
				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding logins information'
				END									
				
				merge security.SQLlogins l
					using (					
						select 
							@TargetServerName as ServerName, 
							SqlLogin,
							isActive 
						from security.SQLlogins 
						where ServerName = @ServerName
					) i
					on
						l.ServerName = i.ServerName
					and l.sqlLogin   = i.SqlLogin			
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							SqlLogin,
							isActive
						)
						values (
							i.ServerName,
							i.SqlLogin,
							i.isActive
						)
					;			
				
				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding database schemas information'
				END		
				
				merge security.DatabaseSchemas d
				using (					
						select 
							@TargetServerName as ServerName, 
							@TgtDbName        as DbName,
							SchemaName,
							Description,						
							isActive 
						from security.DatabaseSchemas
						where ServerName = @ServerName
						  and DbName     = @CurDbName
					) i
					on
						d.ServerName = i.ServerName
					and d.DbName     = i.DbName			
					and d.SchemaName = i.SchemaName
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							DbName,
							SchemaName,
							Description,
							isActive
						)
						values (
							i.ServerName,
							i.DbName,
							i.SchemaName,
							i.Description,
							i.isActive
						)
					;		

				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding SQL Mappings information'
				END		
						
				merge security.SQLMappings d
				using (					
						select 
							@TargetServerName as ServerName, 
							SQLLogin,
							@TgtDbName        as DbName,
							DbUserName,
							DefaultSchema,
							isDefaultDb,	
							isLocked
						from security.SQLMappings
						where ServerName = @ServerName
						  and DbName     = @CurDbName
					) i
					on
						d.ServerName = i.ServerName
					and d.DbName     = i.DbName			
					and d.SQLLogin   = i.SQLLogin
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							SQLLogin,
							DbName,
							DbUserName,
							DefaultSchema,
							isDefaultDb,
							isLocked
						)
						values (
							i.ServerName,
							i.SQLLogin,
							i.DbName,
							i.DbUserName,
							i.DefaultSchema,
							i.isDefaultDb,
							i.isLocked
						)
					;		
				

				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding Database Roles and role members information'
				END			
				
				merge security.DatabaseRoles d
				using (					
						select 
							@TargetServerName as ServerName, 
							@TgtDbName        as DbName,
							RoleName,
							isStandard,
							Reason,	
							isActive
						from security.DatabaseRoles
						where ServerName = @ServerName
						  and DbName     = @CurDbName
					) i
					on
						d.ServerName = i.ServerName
					and d.DbName     = i.DbName			
					and d.RoleName   = i.RoleName
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							DbName,
							RoleName,
							isStandard,
							Reason,
							isActive
						)
						values (
							i.ServerName,
							i.DbName,
							i.RoleName,
							i.isStandard,
							i.Reason,
							i.isActive
						)
					;			

				merge security.DatabaseRoleMembers d
				using (					
						select 
							@TargetServerName as ServerName, 
							@TgtDbName        as DbName,
							RoleName,
							MemberName,
							MemberIsRole,
							Reason,	
							isActive
						from security.DatabaseRoleMembers
						where ServerName = @ServerName
						  and DbName     = @CurDbName
					) i
					on
						d.ServerName = i.ServerName
					and d.DbName     = i.DbName			
					and d.RoleName   = i.RoleName
					and d.MemberName = i.MemberName
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							DbName,
							RoleName,
							MemberName,
							MemberIsRole,
							Reason,
							isActive
						)
						values (
							i.ServerName,
							i.DbName,
							i.RoleName,
							i.MemberName,
							i.MemberIsRole,
							i.Reason,
							i.isActive
						)
					;					
				
				if @Debug = 1
				BEGIN
					PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding object permissions information'
				END					
				
				merge security.DatabasePermissions d
				using (					
						select 
							@TargetServerName as ServerName, 
							@TgtDbName        as DbName,
							Grantee,
							isUser,
							ObjectClass,
							ObjectType,	
							PermissionLevel,	
							PermissionName,	
							SchemaName,	
							ObjectName,	
							SubObjectName,	
							isWithGrantOption,	
							Reason,	
							isActive
						from security.DatabasePermissions
						where ServerName = @ServerName
						  and DbName     = @CurDbName
					) i
					on
						d.ServerName  					= i.ServerName
					and d.DbName      					= i.DbName			
					and d.Grantee     					= i.Grantee
					and d.ObjectClass 					= i.ObjectClass
					and ISNULL(d.ObjectType,'null')		= ISNULL(i.ObjectType,'null')
					and d.PermissionName  				= i.PermissionName
					and ISNULL(d.SchemaName,'null') 	= ISNULL(i.SchemaName,'null')
					and d.ObjectName  	    			= i.ObjectName
					and ISNULL(d.SubObjectName,'null')	= ISNULL(i.SubObjectName,'null')
					WHEN NOT MATCHED BY TARGET THEN
						insert (
							ServerName,
							DbName,
							Grantee,
							isUser,
							ObjectClass,
							ObjectType,
							PermissionLevel,
							PermissionName,
							SchemaName,
							ObjectName,
							SubObjectName,
							isWithGrantOption,
							Reason,
							isActive
						)
						values (
							i.ServerName,
							i.DbName,
							i.Grantee,
							i.isUser,
							i.ObjectClass,
							i.ObjectType,
							i.PermissionLevel,
							i.PermissionName,
							i.SchemaName,
							i.ObjectName,
							i.SubObjectName,
							i.isWithGrantOption,
							i.Reason,
							i.isActive
						)
					;					
			END
			if @Debug = 1 
			BEGIN
				PRINT '--------------------------------------------------------------------------------------------------------------'
			END
		END
	COMMIT
	
	END TRY
	
	BEGIN CATCH
		SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
		
		if CURSOR_STATUS('local','getServerDatabases') >= 0 
		begin
			close getServerDatabases
			deallocate getServerDatabases 
		end
		
		ROLLBACK
	END CATCH
END
GO

PRINT '    Procedure [security].[CloneSecurity] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 	









PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setStandardOnSchemaRoles] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setStandardOnSchemaRoles]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setStandardOnSchemaRoles] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName        varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
    PRINT '    Procedure [security].[setStandardOnSchemaRoles] created.'
END
GO

ALTER PROCEDURE [security].[setStandardOnSchemaRoles] (
    @ServerName  varchar(512) = @@SERVERNAME,
    @DbName      varchar(64)  = NULL,
    @SchemaName  varchar(64)  = NULL,
    @StdRoleName varchar(64)  = NULL,
    @Debug       BIT          = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
     This function takes care of the generation of Database Roles for "on schema" access 
     according to its parameter values.
  
   ARGUMENTS :
     @ServerName    name of the server on which the SQL Server instance we want to modify is running.
                    By default, it's the current server
    
     @DbName        name of the database to take care of.
                    A NULL value (which is the default value) means that this procedure
                    has to take care of all "on schema" roles for any database on the given server.
     
     @SchemaName    name of the schema for which execute this procedure
                    if NULL given, all schemas references in the security inventory will be taken
     
     @StdRoleName   name of the standard role for which execute this procedure
                    if NULL given, all standard roles are being taken into account
  
   REQUIREMENTS:
  
    EXAMPLE USAGE :
        
        -- All standard security roles on all servers
        exec [security].[setStandardOnSchemaRoles] @ServerName = null
        
        -- All standard security roles on all servers for DBA database
        exec [security].[setStandardOnSchemaRoles] @ServerName = null, @DbName = 'DBA'
        
        -- All standard security roles on server 'SI-S-SERV308' for DBA database
        exec [security].[setStandardOnSchemaRoles] @ServerName = 'SI-S-SERV308', @DbName = 'DBA'        
        
        -- All standard security roles on local server for all database (uses variable @@SERVERNAME)
        exec [security].[setStandardOnSchemaRoles]
        
        -- All standard security roles on local server for DBA database (uses variable @@SERVERNAME)
        exec [security].[setStandardOnSchemaRoles] @DbName = 'DBA'
  
   ==================================================================================
   BUGS:
  
     BUGID       Fixed   Description
     ==========  =====   ==========================================================
     ----------------------------------------------------------------------------------
   ==================================================================================
   NOTES:
   AUTHORS:
        .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
        .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
        .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
  
   COMPANY: CHU Liege
   ==================================================================================
   Revision History
  
    Date        Nom         Description
    ==========  =====       ==========================================================
    28/11/2014  JEL         Version 0.0.1
    ----------------------------------------------------------------------------------
    16/12/2014  JEL         Added the possibility to set standard schema role for
    17/12/2014              either a single schema on a database, or a single 
                            standard role (the OR isn't exclusive).
                            
                            We can now ensure that roles are created in the correct
                            order.
                            
                            We can now set permissions for roles 
                                (Database and role assignments)
                            
                            Version 0.0.2
    ----------------------------------------------------------------------------------
  ===================================================================================
*/
BEGIN

    --SET NOCOUNT ON;
    DECLARE @versionNb          varchar(16) = '0.0.2';
    DECLARE @tsql               varchar(max);
    DECLARE @CurServerName      varchar(512)
    DECLARE @CurDbName          varchar(64)
    DECLARE @CurRoleName        varchar(64) 
    DECLARE @CurDescription     varchar(2048)
    DECLARE @curIsActive        BIT
    DECLARE @SchemaRoleSep      VARCHAR(64)
    
    select @SchemaRoleSep = ParamValue
    from [security].[ApplicationParams]
    where ParamName = 'Separator4OnSchemaStandardRole' ;
    
    SET @CurServerName = @ServerName
    SET @CurDbName     = @DbName
    
    BEGIN TRY
    BEGIN TRANSACTION
        if(@CurServerName is null) 
        BEGIN
            -- needs to loop on all servers defined in SQLMappings
            -- no parameterized cursor in MSSQL ... viva Oracle!
            
            if @Debug = 1
            BEGIN           
                PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - No ServerName Given. Overall repository security update.'
            END
            
            DECLARE getServers CURSOR LOCAL FOR
                select distinct
                    ServerName
                from    
                    security.SQLMappings        
                order by 1
                
            open getServers
            FETCH NEXT
            FROM getServers INTO @CurServerName
            
            WHILE @@FETCH_STATUS = 0
            BEGIN               
                EXEC [security].[setStandardOnSchemaRoles] @ServerName = @CurServerName, @DbName = @CurDbName,@Debug = @Debug
                -- carry on ...
                FETCH NEXT
                FROM getServers INTO @CurServerName
            END
            CLOSE getServers
            DEALLOCATE getServers
        END
        else if(@CurServerName is not null and @CurDbName is null) 
        BEGIN
            -- needs to loop on all dbs defined in SQLMappings
            -- no parameterized cursor in MSSQL ... viva Oracle!
            DECLARE getServerDatabases CURSOR LOCAL FOR
                select distinct
                    DbName
                from security.SQLMappings
                where 
                    [ServerName] = @CurServerName 
                and [DbName] not in (
                    select 
                        ObjectName 
                    from 
                        security.StandardExclusion
                    where 
                        ObjectType = 'DATABASE'
                    and isActive = 1            
                )
                order by 1          
            open getServerDatabases
            FETCH NEXT
            FROM getServerDatabases INTO @CurDbName
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC [security].[setStandardOnSchemaRoles] @ServerName = @CurServerName, @DbName = @CurDbName,@Debug = @Debug
                -- carry on ...
                FETCH NEXT
                FROM getServerDatabases INTO @CurDbName
            END
            CLOSE getServerDatabases
            DEALLOCATE getServerDatabases   
        END 
        else
        BEGIN           
            if @Debug = 1
            BEGIN
                PRINT '--------------------------------------------------------------------------------------------------------------'
                PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of server ' + @CurServerName             
                PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of Database ' + @CurDbName               
            END     
            
            -- Get the list of standard roles to create/update
            
            -- no parameterized cursor in MSSQL ... viva Oracle!
            
            DECLARE getSchemasRoles CURSOR LOCAL FOR
                select s.SchemaName, r.[Level],r.RoleName, r.isActive, r.Description
                from 
                    security.DatabaseSchemas as S 
                cross join
                    security.StandardOnSchemaRolesTreeView as r 
                where 
                    s.ServerName = @CurServerName
                and s.DbName     = @CurDbName
                and s.SchemaName not in (
                        select 
                            ObjectName 
                        from 
                            security.StandardExclusion
                        where 
                            ObjectType = 'DATABASE_SCHEMA'
                        and isActive = 1    
                    )
                order by s.SchemaName,r.[Level]           
            
            Declare @CurSchemaName VARCHAR(64)
            DECLARE @CurRoleSuffix VARCHAR(64);
            DECLARE @RoleTreeLevel BIGINT;
            open getSchemasRoles
            FETCH NEXT
            FROM getSchemasRoles INTO @CurSchemaName,@RoleTreeLevel,@CurRoleSuffix,@curIsActive,@CurDescription
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
            
                if( (@SchemaName is not null and @CurSchemaName <> @SchemaName) 
                    or (
                    @StdRoleName is not null and @CurRoleSuffix <> @StdRoleName))
                BEGIN
                    PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Not taking care of Schema "' + ISNULL(@CurRoleName,'<N/A>') + '" | Standard Role "' + ISNULL(@CurRoleSuffix,'<N/A>') + '"'
                    FETCH NEXT
                        FROM getSchemasRoles INTO @CurSchemaName,@RoleTreeLevel,@CurRoleSuffix,@curIsActive,@CurDescription
                    CONTINUE
                END
            
                SET @CurRoleName = @CurSchemaName + @SchemaRoleSep + @CurRoleSuffix 
            
                if @Debug = 1
                BEGIN
                    PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of Standard Role ' + @CurRoleName
                END

                merge security.DatabaseRoles r
                using (
                    select 
                        @CurServerName  as ServerName,
                        @CurDbName      as DbName,
                        @CurRoleName    as RoleName,
                        @curIsActive    as isActive,
                        @curDescription as Description 
                ) i
                on
                    r.ServerName = i.ServerName
                and r.DbName     = i.DbName
                and r.RoleName   = i.RoleName
                WHEN MATCHED THEN
                    update set
                        isActive = i.isActive
                WHEN NOT MATCHED BY TARGET THEN
                    insert (
                        ServerName,
                        DbName,
                        RoleName,
                        isStandard,
                        Reason,
                        isActive
                    )
                    values (
                        i.ServerName,
                        i.DbName,
                        i.RoleName,
                        1,
                        i.Description,
                        i.isActive
                    )
                /*
                WHEN NOT MATCHED BY SOURCE THEN
                    -- TODO make a procedure to undo the missing standard privilege
                */
                ;
                
                -- now the role is created, we can add its permissions
                EXEC [security].[setStandardOnSchemaRolePermissions] 
                    @ServerName  = @CurServerName,
                    @DbName      = @CurDbName,
                    @SchemaName  = @CurSchemaName,
                    @StdRoleName = @CurRoleSuffix,
                    @Debug       = @Debug
                
                -- carry on ...
                FETCH NEXT
                    FROM getSchemasRoles INTO @CurSchemaName,@RoleTreeLevel,@CurRoleSuffix,@curIsActive,@CurDescription
            END
            CLOSE getSchemasRoles
            DEALLOCATE getSchemasRoles              
            if(@Debug = 1) 
            BEGIN
                PRINT '--------------------------------------------------------------------------------------------------------------'
            END
        end
    COMMIT
    END TRY
    BEGIN CATCH
        SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
        
        if CURSOR_STATUS('local','getServers') >= 0 
        begin
            close getServers
            deallocate getServers 
        end     
        if CURSOR_STATUS('local','getServerDatabases') >= 0 
        begin
            close getServerDatabases
            deallocate getServerDatabases 
        end
        if CURSOR_STATUS('local','getSchemasRoles') >= 0 
        begin
            close getSchemasRoles
            deallocate getSchemasRoles 
        end
        ROLLBACK
    END CATCH
END
GO


PRINT '    Procedure [security].[setStandardOnSchemaRoles] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''    













PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[getSecurityScript] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getSecurityScript]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[getSecurityScript] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[getSecurityScript] created.'
END
GO

ALTER PROCEDURE [security].[getSecurityScript] (
    @ServerName  		    varchar(512) 	= @@ServerName,
	@DbName		 		    varchar(64)  	= NULL,
	@AsOf 				    DATETIME 		= NULL ,
	@OutputType 		    VARCHAR(20) 	= 'TABLE' ,
    @OutputDatabaseName     NVARCHAR(128) 	= NULL ,
    @OutputSchemaName 	    NVARCHAR(256) 	= NULL ,
    @OutputTableName 	    NVARCHAR(256) 	= NULL ,	
    @NoServerNameCheckGen   BIT             = 0,
    @NoLoginGen             BIT             = 0,
    @CanDropTempTables      BIT             = 1,
    @DisplayResult          BIT             = 1,
	@Debug		 		    BIT		  	 	= 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
		This function is a helper for one to quickly copy the security model set
		for a database in a server. If no database is set, the whole server is used.
		This can lead to problematic situations as there can be databases that exists
		on the source server and doesn't on the target server.
		So, be aware of what you are doing !
  
   ARGUMENTS :
     @ServerName    name of the server from which the we want to copy the security
					By default, it's the current server
	
	 @DbName		name of the database to consider on that server.
					A NULL value (which is the default value) means that this procedure
					has to take care of every databases existing on that server.

  
   REQUIREMENTS:
  
	EXAMPLE USAGE :
		exec [security].[getSecurityScript] 
    @ServerName  		= 'SI-S-SERV308',
	@DbName		 		= NULL, --'DBA',
	@AsOf 				= NULL ,
	@OutputType 		= 'TABLE' ,
    @OutputDatabaseName = 'TESTING_ONLY_TESTING' ,
    @OutputSchemaName 	= 'dbo' ,
    @OutputTableName 	= 'tst_getSecurityScript' ,	
	@Debug		 		= 1
	
DROP TABLE ##getSecurityScriptResults

DECLARE @asOf DATETIME
select @asOf = CAST( '2014-12-19 07:22:15.073' AS DATETIME)
exec [security].[getSecurityScript] 
    @ServerName  		= 'SI-S-SERV308',
	@DbName		 		= NULL, --'DBA',
	@AsOf 				= @asOf,
	@OutputType 		= 'TABLE' ,
    @OutputDatabaseName = 'TESTING_ONLY_TESTING' ,
    @OutputSchemaName 	= 'dbo' ,
    @OutputTableName 	= 'tst_getSecurityScript' ,	
	@Debug		 		= 1	
   ==================================================================================
   BUGS:
  
     BUGID       Fixed   Description
     ==========  =====   ==========================================================
     ----------------------------------------------------------------------------------
   ==================================================================================
   NOTES:
   AUTHORS:
        .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
        .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
        .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
  
   COMPANY: CHU Liege
   ==================================================================================
   Revision History
  
     Date        Nom         Description
     ==========  =====       ==========================================================
     18/12/2014  JEL         Version 0.0.1
     ----------------------------------------------------------------------------------
  ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
	
    DECLARE @versionNb        	varchar(16) = '0.0.1';
    DECLARE @tsql             	varchar(max);
	DECLARE @execTime			datetime;
	DECLARE	@CurDbName		  	varchar(64)
	DECLARE @LineFeed 			VARCHAR(10)
    DECLARE @StringToExecute    VARCHAR(MAX)
    
	/* Sanitize our inputs */
	SELECT 
		@OutputDatabaseName = QUOTENAME(@OutputDatabaseName),
		@LineFeed 			= CHAR(13) + CHAR(10),
		@execTime = GETDATE()
	
    /**
     * Checking parameters
     */
    if(@ServerName is null)
    BEGIN
        RAISERROR('No value set for @ServerName !',10,1)
    END		
    
    SET @CurDbName = @DbName		
    
    exec security.CreateTempTables4Generation 
            @CanDropTempTables, 
            @Debug = @Debug 
    
	
	IF @OutputType = 'SCHEMA'
	BEGIN
		SELECT FieldList = 'GenerationDate DATETIME NOT NULL | ServerName VARCHAR(256) NOT NULL | DbName VARCHAR(64) NULL | ObjectName VARCHAR(512)  NULL | GeneratorVersion VARCHAR(16) NOT NULL | OperationOrder BIGINT  NOT NULL | OperationType VARCHAR(64) not null | QueryText	VARCHAR(MAX) NOT NULL'
	END
	ELSE IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL
    -- This mode is OK, just a TODO (make it with *named* fields)
	BEGIN
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Asof Mode detected'
        END       
		-- They want to look into the past.

        SET @StringToExecute = N' IF EXISTS(SELECT * FROM '
            + @OutputDatabaseName
            + '.INFORMATION_SCHEMA.SCHEMATA WHERE (SCHEMA_NAME) = '''
            + @OutputSchemaName + ''')' + @LineFeed 
            + '    SELECT GenerationDate, ServerName,DbName,ObjectName,GeneratorVersion,OperationOrder,OperationType,QueryText' + @LineFeed 
            + '    FROM '
            + @OutputDatabaseName + '.'
            + @OutputSchemaName + '.'
            + @OutputTableName + @LineFeed
            + '    WHERE GenerationDate = /*DATEADD(mi, -15, */CONVERT(DATETIME,''' + CONVERT(NVARCHAR(100),@AsOf,121) + ''',121)'
            + '    ORDER BY OperationOrder;'
        ;
        if @debug = 1 
        BEGIN
            PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Query : ' + @LineFeed + @StringToExecute
        END  
        EXEC(@StringToExecute);
	END /* IF @AsOf IS NOT NULL AND @OutputDatabaseName IS NOT NULL AND @OutputSchemaName IS NOT NULL AND @OutputTableName IS NOT NULL */

	ELSE -- Security command generation
	BEGIN
        DECLARE @CurOpOrder BIGINT
        DECLARE @CurOpName  VARCHAR(256)	
		BEGIN TRY
		BEGIN TRANSACTION           
            
            SET @CurOpName = 'CHECK_EXPECTED_SERVERNAME'
            
            if(@NoServerNameCheckGen = 0 and not exists (select 1 from ##SecurityGenerationResults where ServerName = @ServerName and OperationType = @CurOpName))
            BEGIN     
                
                if @Debug = 1
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Adding Server name check'
                END                    
                
                select @CurOpOrder = OperationOrder 
                from ##SecurityScriptResultsCommandsOrder 
                where OperationType = @CurOpName

                insert ##SecurityGenerationResults (
                    ServerName,		
                    DbName,			
                    OperationType, 	
                    OperationOrder,
                    QueryText 		
                )
                values (
                    @ServerName,		
                    null,
                    @CurOpName,
                    @CurOpOrder,
                    'IF (@@SERVERNAME <> ''' + (@ServerName) + '''' +  @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    RAISERROR(''Expected @@ServerName : "' + @ServerName + '"'', 16, 0)'  + @LineFeed +
                    'END' 
                )
                SET @CurOpName  = null
                SET @CurOpOrder = null
            END            
            
            if @NoLoginGen = 0 
            BEGIN 
                if @Debug = 1
                BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Login creation statements'                
                END                 

                EXEC [security].[getLoginsCreationScript]
                        @ServerName             = @ServerName, 
                        @NoDependencyCheckGen   = 1,
                        @CanDropTempTables      = 0,
                        @Debug                  = @Debug 
            END 
            
			if(@CurDbName is null) 
			BEGIN	
           		if @Debug = 1 
				BEGIN
					PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Full server generation mode detected.'
				END
				-- needs to loop on all dbs defined in SQLMappings
				-- no parameterized cursor in MSSQL ... viva Oracle!
				DECLARE getServerDatabases CURSOR LOCAL FOR
					select distinct
						DbName
					from security.SQLMappings
					where 
						[ServerName] = @ServerName 
					order by 1			
				open getServerDatabases
				FETCH NEXT
				FROM getServerDatabases INTO @CurDbName
				
				WHILE @@FETCH_STATUS = 0
				BEGIN						
					EXEC [security].[getSecurityScript] 
						@ServerName 		    = @ServerName,
						@DbName 			    = @CurDbName,
						@OutputType 		    = @OutputType,
						@OutputDatabaseName     = null,--@OutputDatabaseName,
						@OutputSchemaName 	    = null,--@OutputSchemaName,
						@OutputTableName 	    = null,--@OutputTableName,
                        @NoServerNameCheckGen   = 1,
                        @NoLoginGen             = 1,     
                        @CanDropTempTables      = 0,
                        @DisplayResult          = 0,
						@Debug 				    = @Debug
					-- carry on ...
					FETCH NEXT
					FROM getServerDatabases INTO @CurDbName
				END
				CLOSE getServerDatabases
				DEALLOCATE getServerDatabases				
            
			END
			ELSE -- a database name is given
			BEGIN
                                
				if @Debug = 1
				BEGIN
					PRINT '--------------------------------------------------------------------------------------------------------------'
					PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Server Name : ' + @ServerName				
					PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Database set to ' + @CurDbName				
                    PRINT ''
				END	 
                               
                SET @CurOpName = 'CHECK_DATABASE_EXISTS'
                
                if(not exists (select 1 from ##SecurityGenerationResults where ServerName = @ServerName and DbName = @CurDbName and OperationType = @CurOpName))
                BEGIN   
                    if @Debug = 1
                    BEGIN
                        PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Adding database existence check'
                    END                 
                    select @CurOpOrder = OperationOrder 
                    from ##SecurityScriptResultsCommandsOrder 
                    where OperationType = @CurOpName

                    insert ##SecurityGenerationResults (
                        ServerName,		
                        DbName,			
                        OperationType, 	
                        OperationOrder,
                        QueryText 		
                    )
                    values (
                        @ServerName,		
                        @CurDbName,
                        @CurOpName,
                        @CurOpOrder,
                        'IF NOT EXISTS( SELECT 1 FROM sys.databases where Name =  ''' + (@CurDbName) + ''')' +  @LineFeed +
                        'BEGIN' + @LineFeed +
                        '    RAISERROR(''The Database named : "' + @CurDbName + '" doesn''t exist on server !'', 16, 0)'  + @LineFeed +
                        'END' 
                    )
                    SET @CurOpName  = null
                    SET @CurOpOrder = null                    
                END                
                                               
                
                if @Debug = 1
				BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Schema creation statements'
                END 
                
                EXEC [security].[getDbSchemasCreationScript] 
                    @ServerName  		    = @ServerName,    
                    @DbName  		        = @CurDbName,    
                    @SchemaName             = NULL,	
                    @AsOf 				    = NULL ,
                    @OutputType 		    = @OutputType,
                    @OutputDatabaseName     = NULL ,
                    @OutputSchemaName 	    = NULL ,
                    @OutputTableName 	    = NULL ,	
                    @NoDependencyCheckGen   = 0,
                    @CanDropTempTables      = 0,
                    @Debug		 		    = @Debug
                    
                    
                if @Debug = 1
				BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Database user creation statements'
                END 
                
                EXEC [security].[getDbUsersCreationScript] 
                    @ServerName  		    = @ServerName,    
                    @DbName  		        = @CurDbName,    
                    @UserName               = NULL,	
                    @AsOf 				    = NULL ,
                    @OutputType 		    = @OutputType,
                    @OutputDatabaseName     = NULL ,
                    @OutputSchemaName 	    = NULL ,
                    @OutputTableName 	    = NULL ,	
                    @NoDependencyCheckGen   = 0,
                    @CanDropTempTables      = 0,
                    @Debug		 		    = @Debug
                    
                if @Debug = 1
				BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Login to database user creation statements'
                END  
                
                
                if @Debug = 1
				BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Database Roles creation and assignment statements'
                END   
                
                
                if @Debug = 1
				BEGIN
                    PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -     > Object-level permission assignment statements'
                END 
                
                
                
                
                PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - INFO - Generation successful'
                
				if @Debug = 1 
				BEGIN
					PRINT '--------------------------------------------------------------------------------------------------------------'
				END
			END
			
            
            /*
                Now we have the table ##SecurityGenerationResults 
                with all we got from generation.
                
			    @OutputTableName lets us export the results to a permanent table 
				
                This way to process is highly inspired from Brent Ozar's 
            */
			--SELECT * from ##SecurityGenerationResults
            exec [security].[SaveSecurityGenerationResult] 
				@OutputDatabaseName     = @OutputDatabaseName,
				@OutputSchemaName 	    = @OutputSchemaName ,
				@OutputTableName 	    = @OutputTableName ,
				@VersionNumber		 	= @versionNb,
				@Debug		 		    = @Debug
             
            if @DisplayResult = 1 and @OutputType = 'TABLE'
            BEGIN 
                SELECT * 
                from ##SecurityGenerationResults
                order by [ServerName], [OperationOrder],[DbName]
            END 
            ELSE if @OutputType = 'SCRIPT' 
            BEGIN
                DECLARE Cursor4ResultScript CURSOR LOCAL FOR
					SELECT QueryText
					from ##SecurityGenerationResults
					order by [ServerName], [OperationOrder],[DbName]
                
                DECLARE @toDisplay VARCHAR(MAX) 
                open Cursor4ResultScript; 
                FETCH NEXT
				FROM Cursor4ResultScript INTO @toDisplay
                
                WHILE @@FETCH_STATUS = 0
				BEGIN						
					PRINT @toDisplay 
					-- carry on ...
                    FETCH NEXT
                    FROM Cursor4ResultScript INTO @toDisplay
				END
				CLOSE Cursor4ResultScript
				DEALLOCATE Cursor4ResultScript				
            
            END 
            
		COMMIT
		
		END TRY
		
		BEGIN CATCH
			SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS ErrorSeverity
			,ERROR_STATE() AS ErrorState
			,ERROR_PROCEDURE() AS ErrorProcedure
			,ERROR_LINE() AS ErrorLine
			,ERROR_MESSAGE() AS ErrorMessage;
			
			if CURSOR_STATUS('local','getServerDatabases') >= 0 
			begin
				close getServerDatabases
				deallocate getServerDatabases 
			end
            if CURSOR_STATUS('local','Cursor4ResultScript') >= 0 
			begin
				close Cursor4ResultScript
				deallocate Cursor4ResultScript 
			end			
/*            
            if OBJECT_ID('tempdb..##SecurityGenerationResults') IS NOT NULL 
            BEGIN 
                exec sp_executesql N'DROP TABLE tempdb..##SecurityGenerationResults';             
            END 
            
            if OBJECT_ID('tempdb..##SecurityScriptResultsCommandsOrder') IS NOT NULL 
            BEGIN 
                exec sp_executesql N'DROP TABLE tempdb..##SecurityScriptResultsCommandsOrder';
            END             
*/            
            IF @@TRANCOUNT > 0
                ROLLBACK
		END CATCH
	END
END
GO

PRINT '    Procedure [security].[getSecurityScript] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 	