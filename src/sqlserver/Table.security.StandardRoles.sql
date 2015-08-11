/*requires Schema.Security.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[StandardRoles] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardRoles]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[StandardRoles](
		[RoleScope]     	[varchar](16)   NOT NULL,
        [RoleName]      	[varchar](64) 	NOT NULL,
		[needsPrefix]   	[BIT]			NOT NULL,
		[isDefinedByMSSQL] 	[BIT]			DEFAULT 0 NOT NULL,		
		[Description]		[varchar](2048),
        [isActive]      	[bit]		 	NOT NULL,
        [CreationDate]  	[datetime] 		NOT NULL,
        [lastmodified]  	[datetime] 		NOT NULL
    ) ON [PRIMARY];
	
	IF @@ERROR = 0
		PRINT '   Table created.'
	ELSE
	BEGIN
		PRINT '   Error while trying to create table.'
		RETURN
	END
END
/*
ELSE
BEGIN 
END
*/
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardRoles_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardRoles]
        ADD CONSTRAINT [DF_StandardRoles_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	
	PRINT '    Constraint [DF_StandardRoles_CreationDate] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardRoles_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardRoles]
        ADD CONSTRAINT [DF_StandardRoles_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	PRINT '    Constraint [DF_StandardRoles_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[CK_StandardRoles_NeedsPrefix]') AND type = 'C')
BEGIN
    ALTER TABLE [security].[StandardRoles]
        ADD CONSTRAINT [CK_StandardRoles_NeedsPrefix] CHECK (
			([RoleScope] COLLATE FRENCH_CI_AI = 'SCHEMA' AND [NeedsPrefix] = 1)
		OR  ([RoleScope] COLLATE FRENCH_CI_AI <> 'SCHEMA')
		)
	
	PRINT '    Constraint [CK_StandardRoles_NeedsPrefix] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardRoles]') AND name = N'PK_StandardRoles')
BEGIN
    ALTER TABLE [security].[StandardRoles]
        ADD CONSTRAINT [PK_StandardRoles]
            PRIMARY KEY CLUSTERED (
				[RoleScope]	ASC,
                [RoleName] 	ASC
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
	
	PRINT '    Primary key [PK_StandardRoles] created.'
END
GO


DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_StandardRoles]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_StandardRoles] ' + CHAR(13) +
               '  ON security.StandardRoles ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '    Trigger [security].[TRG_I_StandardRoles] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_StandardRoles]' + CHAR(13) +
            '    ON security.StandardRoles' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardRoles ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            ',           CreationDate = CASE WHEN i.CreationDate IS NULL THEN GETDATE() ELSE i.CreationDate END ' + CHAR(13) +
            '    FROM [security].StandardRoles o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '           ON o.RoleScope = i.RoleScope' + CHAR(13) +
            '           and o.RoleName = i.RoleName' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_StandardRoles] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_StandardRoles]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_StandardRoles] ' + CHAR(13) +
               '  ON security.StandardRoles ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '    Trigger [security].[TRG_U_StandardRoles] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_StandardRoles]' + CHAR(13) +
            '    ON security.StandardRoles' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardRoles ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].StandardRoles o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
           '           ON o.RoleScope = i.RoleScope' + CHAR(13) +
            '           and o.RoleName = i.RoleName' +CHAR(13) +
            'END' ;
EXEC (@SQL);

PRINT '    Trigger [security].[TRG_U_StandardRoles] altered.'
GO

PRINT '    Adding default data to [security].[StandardRoles].'

--[StandardRoles]---------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
set nocount on;
;

with cte_data(
	[RoleScope],[RoleName],[needsPrefix],[isDefinedByMSSQL],[Description],[isActive]
)
as (
    select * 
    from (
        values
			('SERVER','public',0,1,'Defined by Microsoft for server access regulation',1),
			('SERVER','sysadmin',0,1,'Defined by Microsoft for server access regulation',1),
			('SERVER','securityadmin',0,1,'Defined by Microsoft for server access regulation',1),
			('SERVER','serveradmin',0,1,'Defined by Microsoft for server access regulation',1),
			('SERVER','setupadmin',0,1,'Defined by Microsoft for server access regulation',1),
			('SERVER','processadmin',0,1,'Defined by Microsoft for server access regulation',1),
			('SERVER','diskadmin',0,1,'Defined by Microsoft for server access regulation',1),
			('SERVER','dbcreator',0,1,'Defined by Microsoft for server access regulation',1),
			('SERVER','bulkadmin',0,1,'Defined by Microsoft for server access regulation',1),
			('DATABASE','public',0,1,'Defined by Microsoft for database access regulation',1),
			('DATABASE','db_owner',0,1,'Defined by Microsoft for database access regulation',1),
			('DATABASE','db_accessadmin',0,1,'Defined by Microsoft for database access regulation',1),
			('DATABASE','db_securityadmin',0,1,'Defined by Microsoft for database access regulation',1),
			('DATABASE','db_ddladmin',0,1,'Defined by Microsoft for database access regulation',1),
			('DATABASE','db_backupoperator',0,1,'Defined by Microsoft for database access regulation',1),
			('DATABASE','db_datareader',0,1,'Defined by Microsoft for database access regulation',1),
			('DATABASE','db_datawriter',0,1,'Defined by Microsoft for database access regulation',1),
			('DATABASE','db_denydatareader',0,1,'Defined by Microsoft for database access regulation',1),
			('DATABASE','db_denydatawriter',0,1,'Defined by Microsoft for database access regulation',1),
		    ('DATABASE','CHULG_SAI_RA',0,0,'Standard role for application managers at CHU Liege',1),		    
			('SCHEMA','data_modifier',1,0,'Can modify data in schema',1),
			('SCHEMA','data_reader',1,0,'Can read data in schema',1),
			('SCHEMA','endusers',1,0,'Has all the permissions an application database user should have',1),
			('SCHEMA','full_access',1,0,'Can do everything inside the schema',1),
			('SCHEMA','managers',1,0,'Can manage a database schema',1),
			('SCHEMA','prog_executors',1,0,'Can execute things in a database schema',1),
			('SCHEMA','responsible',1,0,'A role for application responsible (vs. DBA) at CHU Liege',1),
			('SCHEMA','struct_modifier',1,0,'Can run DDL commands',1),
			('SCHEMA','struct_viewer',1,0,'Can extract DDL from an object in the schema',1)
    ) c (
        [RoleScope],[RoleName],[needsPrefix],[isDefinedByMSSQL],[Description],[isActive]
    )
)
merge [security].[StandardRoles] as t
using cte_data as s
on	
	t.[RoleScope] = s.[RoleScope]	
and	t.[RoleName]  = s.[RoleName]
when matched and (t.[RoleScope] <> 'SERVER' OR t.[isDefinedByMSSQL] <> 1) then
	update set
		[isActive] 			= s.[isActive],
		[lastmodified] 		= GETDATE(),
		[Description] 		= s.[Description]
when not matched by target then
	insert([RoleScope],[RoleName],[needsPrefix],[isDefinedByMSSQL],[Description],[isActive])
	values(s.[RoleScope],s.[RoleName],s.[needsPrefix],s.[isDefinedByMSSQL],s.[Description],s.[isActive])
;

GO 

BEGIN TRAN 
BEGIN TRY 

	IF(EXISTS( select 1 from sys.all_objects where OBJECT_ID = OBJECT_ID('[security].[StandardOnSchemaRoles]') and type_desc = 'USER_TABLE'))
	BEGIN 
		-- old 1.2.0 version and lower.
		
		PRINT '    Copying data from [security].StandardOnSchemaRoles into StandardRoles';
		
		with standardSchemaRoles
		AS (
			select RoleName, Description, isActive,CreationDate 
			from [security].[StandardOnSchemaRoles]
		)
		MERGE [security].[StandardRoles] t
		using standardSchemaRoles i
		on t.RoleScope = 'SCHEMA'
		and t.RoleName = i.RoleName
		WHEN MATCHED THEN 
			update set	t.Description = i.Description,
						t.isActive    = i.isActive
		WHEN NOT MATCHED THEN
			insert (
				RoleScope,RoleName,needsPrefix,isDefinedByMSSQL,Description,isActive,CreationDate
			)
			values (
				'SCHEMA',i.RoleName,1,0,i.[Description],i.isActive,i.CreationDate
			)
		;
	END ;

	IF(EXISTS( select 1 from sys.all_objects where OBJECT_ID = OBJECT_ID('[security].[StandardOnDatabaseRoles]') and type_desc = 'USER_TABLE'))
	BEGIN 
		-- old 1.2.0 version
		
		PRINT '    Copying data from [security].StandardOnDatabaseRoles into StandardRoles';
		
		with standardDatabaseRoles
		AS (
			select RoleName, Description, isActive,CreationDate 
			from [security].[StandardOnDatabaseRoles]
		)
		MERGE [security].[StandardRoles] t
		using standardDatabaseRoles i
		on t.RoleScope = 'DATABASE'
		and t.RoleName = i.RoleName
		WHEN MATCHED THEN 
			update set	t.Description = i.Description,
						t.isActive    = i.isActive
		WHEN NOT MATCHED THEN
			insert (
				RoleScope,RoleName,needsPrefix,isDefinedByMSSQL,Description,isActive,CreationDate
			)
			values (
				'DATABASE',i.RoleName,0,0,i.[Description],i.isActive,i.CreationDate
			)
		;
	END 
	
	
END TRY 

BEGIN CATCH 
	ROLLBACK 
END CATCH 

IF @@TRANCOUNT > 0
BEGIN 
	COMMIT ;
END 
ELSE 
	RAISERROR ('Error while trying to copy standard roles from older version. Rolled back',12,1);
GO




PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 