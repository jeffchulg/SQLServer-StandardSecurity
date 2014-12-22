/*requires Schema.Security.sql*/



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