/*requires Schema.Security.sql*/
/*requires Table.StandardOnSchemaRoles.sql*/
/*requires Table.ApplicationParams.sql*/

-- /**
  -- ==================================================================================
    -- DESCRIPTION
		-- Creation of the [security].[StandardOnSchemaRolesSecurity] table.
		-- This table will contain a list of privileges assigned to security roles defined by our standard.

	-- ==================================================================================
  -- BUGS:
 
    -- BUGID       Fixed   Description
    -- ==========  =====   ==========================================================
    -- ----------------------------------------------------------------------------------
  -- ==================================================================================
  -- Notes :
 
        -- Exemples :
        -- -------
 
  -- ==================================================================================
  -- Revision history
 
    -- Date        Name                Description
    -- ==========  ================    ================================================
    -- 24/12/2014  Jefferson Elias     Version 0.1.0
  -- ==================================================================================
-- */

-- PRINT '--------------------------------------------------------------------------------------------------------------'
-- PRINT 'Table [security].[StandardOnSchemaRolesSecurity] Creation'


-- IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]') AND type in (N'U'))
-- BEGIN
    -- CREATE TABLE [security].[StandardOnSchemaRolesSecurity](
        -- [RoleName] 				[varchar](64) NOT NULL,
        -- [PrivName] 				[varchar](128) NOT NULL,
        -- [isRoleMembership] 		[bit] NOT NULL,
        -- [PermissionClass]       [varchar](16) DEFAULT 'DATABASE_SCHEMA' not null, -- can be 'SERVER','DATABASE' or 'DATABASE_SCHEMA'
		-- [PermissionLevel] 		[varchar](6) DEFAULT 'GRANT' not null,
        -- [isActive] 				[bit] NOT NULL,
        -- [CreationDate] 			[date] NOT NULL,
        -- [lastmodified] 			[date] NOT NULL
    -- ) ON [PRIMARY]
	
	-- PRINT '    Table [security].[StandardOnSchemaRolesSecurity] created.'
-- END
-- /*
-- ELSE
-- BEGIN
    
-- END
-- */
-- GO

-- IF  EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardOnSchemaRolesSecurity_PermissionLevel]') AND parent_object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]'))
-- BEGIN
    -- if EXISTS (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'security' and TABLE_NAME = 'ApplicationParams' and TABLE_TYPE = 'BASE TABLE') 
    -- BEGIN
        -- DECLARE @VersionNumber VARCHAR(1024)
        -- DECLARE @sqlCmd NVARCHAR(MAX)
        -- SET @sqlCmd = 'select @val = ParamValue from security.ApplicationParams where ParamName = @p'
        -- EXECUTE sp_executesql @sqlCmd , N'@p varchar(64),@val varchar(128) OUTPUT',@p = 'Version', @val = @VersionNumber OUTPUT
        -- if(isnull(@VersionNumber,'0.0.0') < '0.1.1')
        -- BEGIN
            -- ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
                -- DROP CONSTRAINT [CK_StandardOnSchemaRolesSecurity_PermissionLevel]
            -- PRINT '     Constraint [CK_StandardOnSchemaRolesSecurity_PermissionLevel] dropped.'
        -- END       
    -- END
-- END
-- GO

-- IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardOnSchemaRolesSecurity_PermissionClass]') AND parent_object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]'))
-- BEGIN
    -- ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        -- WITH CHECK ADD CONSTRAINT [CK_StandardOnSchemaRolesSecurity_PermissionClass]
            -- CHECK (PermissionClass in ('SERVER','DATABASE','DATABASE_SCHEMA'))
	-- PRINT '     Constraint [CK_StandardOnSchemaRolesSecurity_PermissionClass] created.'
-- END
-- GO


-- IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardOnSchemaRolesSecurity_PermissionLevel]') AND parent_object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]'))
-- BEGIN
    -- ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        -- WITH CHECK ADD CONSTRAINT [CK_StandardOnSchemaRolesSecurity_PermissionLevel]
            -- CHECK (([isRoleMembership] = 0 and [PermissionLevel] in ('GRANT','REVOKE','DENY'))
                   -- or ([isRoleMembership] = 1 and [PermissionLevel] <> 'DENY'))
	-- PRINT '     Constraint [CK_StandardOnSchemaRolesSecurity_PermissionLevel] created.'
-- END
-- GO

-- IF  /*NOT*/ EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardOnSchemaRolesSecurity_PermissionLevel_NoDeny]') AND parent_object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]'))
-- BEGIN
    -- ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        -- DROP CONSTRAINT [CK_StandardOnSchemaRolesSecurity_PermissionLevel_NoDeny]            
	-- PRINT '     Constraint [CK_StandardOnSchemaRolesSecurity_PermissionLevel_NoDeny] dropped.'
-- /*
    -- ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        -- WITH CHECK ADD CONSTRAINT [CK_StandardOnSchemaRolesSecurity_PermissionLevel_NoDeny]
            -- CHECK (not ([isRoleMembership] = 1 and [PermissionLevel] = 'DENY'))
	-- PRINT '     Constraint [CK_StandardOnSchemaRolesSecurity_PermissionLevel_NoDeny] created.'
-- */
-- END
-- GO

-- IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRolesSecurity_CreationDate]') AND type = 'D')
-- BEGIN
    -- ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        -- ADD CONSTRAINT [DF_StandardOnSchemaRolesSecurity_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	
	-- PRINT '    Constraint [DF_StandardOnSchemaRolesSecurity_CreationDate] created.'
-- END

-- GO

-- IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRolesSecurity_LastModified]') AND type = 'D')
-- BEGIN
    -- ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        -- ADD CONSTRAINT [DF_StandardOnSchemaRolesSecurity_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	-- PRINT '    Constraint [DF_StandardOnSchemaRolesSecurity_LastModified] created.'
-- END
-- GO

-- IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[security].[FK_StandardOnSchemaRolesSecurity_StandardOnSchemaRoles]') AND parent_object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]'))
-- BEGIN
    -- ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        -- ADD  CONSTRAINT [FK_StandardOnSchemaRolesSecurity_StandardOnSchemaRoles]
            -- FOREIGN KEY(
                -- [RoleName]
            -- )
        -- REFERENCES [security].[StandardOnSchemaRoles] ([RoleName])
	
	-- PRINT '    Foreign key [FK_StandardOnSchemaRolesSecurity_StandardOnSchemaRoles] created.'
-- END
-- GO

-- IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesSecurity]') AND name = N'PK_StandardOnSchemaRolesSecurity')
-- BEGIN
    -- ALTER TABLE [security].[StandardOnSchemaRolesSecurity]
        -- ADD  CONSTRAINT [PK_StandardOnSchemaRolesSecurity]
            -- PRIMARY KEY CLUSTERED (
                -- [RoleName] ASC,
                -- [PrivName] ASC
        -- )
    -- WITH (
        -- PAD_INDEX               = OFF,
        -- STATISTICS_NORECOMPUTE  = OFF,
        -- SORT_IN_TEMPDB          = OFF,
        -- IGNORE_DUP_KEY          = OFF,
        -- ONLINE                  = OFF,
        -- ALLOW_ROW_LOCKS         = ON,
        -- ALLOW_PAGE_LOCKS        = ON
    -- )
    -- ON [PRIMARY]
	-- PRINT '    Primary key [PK_StandardOnSchemaRolesSecurity] created.'
-- END
-- GO

-- DECLARE @SQL VARCHAR(MAX)

-- IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_StandardOnSchemaRolesSecurity]'))
-- BEGIN
    -- SET @SQL = 'CREATE TRIGGER [security].[TRG_I_StandardOnSchemaRolesSecurity] ' + CHAR(13) +
               -- '  ON security.StandardOnSchemaRolesSecurity ' + CHAR(13) +
               -- '    FOR INSERT ' + CHAR(13) +
               -- 'AS' + CHAR(13) +
               -- 'BEGIN' + CHAR(13) +
               -- '    DECLARE @a varchar(MAX)' + CHAR(13) +
               -- '    select @a = ''123''' + CHAR(13) +
               -- 'END' + CHAR(13);

    -- EXEC (@SQL) ;
	
	-- PRINT '    Trigger [security].[TRG_I_StandardOnSchemaRolesSecurity] created.'
-- END

-- SET @SQL =  'ALTER TRIGGER [security].[TRG_I_StandardOnSchemaRolesSecurity]' + CHAR(13) +
            -- '    ON security.StandardOnSchemaRolesSecurity' + CHAR(13) +
            -- '    FOR INSERT' +CHAR(13) +
            -- 'AS' + CHAR(13) +
            -- 'BEGIN' + CHAR(13) +
            -- '    UPDATE [security].StandardOnSchemaRolesSecurity ' + CHAR(13) +
            -- '        SET LastModified = GETDATE()'+CHAR(13) +
            -- '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            -- '    FROM [security].StandardOnSchemaRolesSecurity o ' + CHAR(13) +
            -- '        INNER JOIN inserted i' +CHAR(13) +
            -- '            on o.[RoleName] = i.[RoleName]' +CHAR(13) +
            -- '           and o.[PrivName] = i.[PrivName]' +CHAR(13) +
            -- 'END' ;
-- EXEC (@SQL);
-- PRINT '    Trigger [security].[TRG_I_StandardOnSchemaRolesSecurity] altered.'

-- IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_StandardOnSchemaRolesSecurity]'))
-- BEGIN
    -- SET @SQL = 'CREATE TRIGGER [security].[TRG_U_StandardOnSchemaRolesSecurity] ' + CHAR(13) +
               -- '  ON security.StandardOnSchemaRolesSecurity ' + CHAR(13) +
               -- '    FOR UPDATE ' + CHAR(13) +
               -- 'AS' + CHAR(13) +
               -- 'BEGIN' + CHAR(13) +
               -- '    DECLARE @a varchar(MAX)' + CHAR(13) +
               -- '    select @a = ''123''' + CHAR(13) +
               -- 'END' + CHAR(13);

    -- EXEC (@SQL) ;
	-- PRINT '    Trigger [security].[TRG_U_StandardOnSchemaRolesSecurity] created.'
-- END

-- SET @SQL =  'ALTER TRIGGER [security].[TRG_U_StandardOnSchemaRolesSecurity]' + CHAR(13) +
            -- '    ON security.StandardOnSchemaRolesSecurity' + CHAR(13) +
            -- '    FOR UPDATE' +CHAR(13) +
            -- 'AS' + CHAR(13) +
            -- 'BEGIN' + CHAR(13) +
            -- '    UPDATE [security].StandardOnSchemaRolesSecurity ' + CHAR(13) +
            -- '        SET LastModified = GETDATE()'+CHAR(13) +
            -- '    FROM [security].StandardOnSchemaRolesSecurity o ' + CHAR(13) +
            -- '        INNER JOIN inserted i' +CHAR(13) +
            -- '            on o.[RoleName] = i.[RoleName]' +CHAR(13) +
            -- '           and o.[PrivName] = i.[PrivName]' +CHAR(13) +
            -- 'END' ;
-- EXEC (@SQL);
-- PRINT '    Trigger [security].[TRG_U_StandardOnSchemaRolesSecurity] altered.'
-- GO

-- PRINT '    Adding default data to [security].[StandardOnSchemaRolesSecurity].'

-- set nocount on;
-- ;with cte_data(
-- [RoleName],[PrivName],[isRoleMembership],[PermissionClass],[PermissionLevel],[isActive],[CreationDate],[lastmodified])
-- as (
    -- select * 
    -- from (
        -- values
        -- ('data_modifier','DELETE',0,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
-- --        ('data_modifier','EXECUTE',0,'DATABASE_SCHEMA','REVOKE',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('data_modifier','INSERT',0,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('data_modifier','UPDATE',0,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
-- --        ('data_reader','EXECUTE',0,'DATABASE_SCHEMA','REVOKE',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('data_reader','SELECT',0,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('endusers','SHOWPLAN',0,'DATABASE','GRANT',1,GETDATE(),GETDATE()),
        -- ('endusers','data_modifier',1,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('endusers','data_reader',1,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('endusers','prog_executors',1,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('full_access','endusers',1,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('full_access','managers',1,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('managers','struct_modifier',1,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('managers','struct_viewer',1,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('prog_executors','EXECUTE',0,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('responsible','data_modifier',1,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('responsible','data_reader',1,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('responsible','managers',1,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('struct_modifier','ALTER',0,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('struct_modifier','CREATE FUNCTION',0,'DATABASE','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:23:59.500'),
        -- ('struct_modifier','CREATE PROCEDURE',0,'DATABASE','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:23:59.500'),
        -- ('struct_modifier','CREATE SYNONYM',0,'DATABASE','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:23:59.500'),
        -- ('struct_modifier','CREATE TABLE',0,'DATABASE','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:23:59.500'),
        -- ('struct_modifier','CREATE TYPE',0,'DATABASE','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:23:59.500'),
        -- ('struct_modifier','CREATE VIEW',0,'DATABASE','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:23:59.500'),
        -- ('struct_modifier','REFERENCES',0,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623'),
        -- ('struct_viewer','VIEW DEFINITION',0,'DATABASE_SCHEMA','GRANT',1,'2014-12-24 14:21:52.617','2014-12-24 14:21:52.623')
    -- ) c (
        -- [RoleName],[PrivName],[isRoleMembership],[PermissionClass],[PermissionLevel],[isActive],[CreationDate],[lastmodified]
    -- )
-- )
-- merge [security].[StandardOnSchemaRolesSecurity] as t
-- using cte_data as s
-- on		1=1 and t.[RoleName] = s.[RoleName] and t.[PrivName] = s.[PrivName]
-- when matched then
	-- update set
	-- [isRoleMembership] = s.[isRoleMembership],[PermissionClass] = s.[PermissionClass],[PermissionLevel] = s.[PermissionLevel],[isActive] = s.[isActive],[CreationDate] = s.[CreationDate],[lastmodified] = s.[lastmodified]
-- when not matched by target then
	-- insert([RoleName],[PrivName],[isRoleMembership],[PermissionClass],[PermissionLevel],[isActive],[CreationDate],[lastmodified])
	-- values(s.[RoleName],s.[PrivName],s.[isRoleMembership],s.[PermissionClass],s.[PermissionLevel],s.[isActive],s.[CreationDate],s.[lastmodified])
-- ;


-- PRINT '--------------------------------------------------------------------------------------------------------------'
-- PRINT '' 
