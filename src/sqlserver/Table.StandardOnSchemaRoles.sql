-- /*requires Schema.Security.sql*/

-- /**
  -- ==================================================================================
    -- DESCRIPTION
		-- Creation of the [security].[StandardOnSchemaRoles] table.
		-- This table will contain a list of security roles defined by our standard.

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
-- PRINT 'Table [security].[StandardOnSchemaRoles] Creation'

-- IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRoles]') AND type in (N'U'))
-- BEGIN
    -- CREATE TABLE [security].[StandardOnSchemaRoles](
        -- [RoleName]      [varchar](64) 	NOT NULL,
		-- [Description]	[varchar](2048),
        -- [isActive]      [bit]		 	NOT NULL,
        -- [CreationDate]  [datetime] 		NOT NULL,
        -- [lastmodified]  [datetime] 		NOT NULL
    -- ) ON [PRIMARY]
	-- PRINT '    Table [security].[StandardOnSchemaRoles] created.'
-- END
-- /*
-- ELSE
-- BEGIN 
-- END
-- */
-- GO

-- IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRoles_CreationDate]') AND type = 'D')
-- BEGIN
    -- ALTER TABLE [security].[StandardOnSchemaRoles]
        -- ADD CONSTRAINT [DF_StandardOnSchemaRoles_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	
	-- PRINT '    Constraint [DF_StandardOnSchemaRoles_CreationDate] created.'
-- END

-- GO

-- IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnSchemaRoles_LastModified]') AND type = 'D')
-- BEGIN
    -- ALTER TABLE [security].[StandardOnSchemaRoles]
        -- ADD CONSTRAINT [DF_StandardOnSchemaRoles_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	-- PRINT '    Constraint [DF_StandardOnSchemaRoles_LastModified] created.'
-- END
-- GO

-- IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRoles]') AND name = N'PK_StandardOnSchemaRoles')
-- BEGIN
    -- ALTER TABLE [security].[StandardOnSchemaRoles]
        -- ADD CONSTRAINT [PK_StandardOnSchemaRoles]
            -- PRIMARY KEY CLUSTERED (
                -- [RoleName] ASC
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
	
	-- PRINT '    Primary key [PK_StandardOnSchemaRoles] created.'
-- END
-- GO


-- DECLARE @SQL VARCHAR(MAX)

-- IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_StandardOnSchemaRoles]'))
-- BEGIN
    -- SET @SQL = 'CREATE TRIGGER [security].[TRG_I_StandardOnSchemaRoles] ' + CHAR(13) +
               -- '  ON security.StandardOnSchemaRoles ' + CHAR(13) +
               -- '    FOR INSERT ' + CHAR(13) +
               -- 'AS' + CHAR(13) +
               -- 'BEGIN' + CHAR(13) +
               -- '    DECLARE @a varchar(MAX)' + CHAR(13) +
               -- '    select @a = ''123''' + CHAR(13) +
               -- 'END' + CHAR(13);

    -- EXEC (@SQL) ;
	
	-- PRINT '    Trigger [security].[TRG_I_StandardOnSchemaRoles] created.'
-- END

-- SET @SQL =  'ALTER TRIGGER [security].[TRG_I_StandardOnSchemaRoles]' + CHAR(13) +
            -- '    ON security.StandardOnSchemaRoles' + CHAR(13) +
            -- '    FOR INSERT' +CHAR(13) +
            -- 'AS' + CHAR(13) +
            -- 'BEGIN' + CHAR(13) +
            -- '    UPDATE [security].StandardOnSchemaRoles ' + CHAR(13) +
            -- '        SET LastModified = GETDATE()'+CHAR(13) +
            -- '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            -- '    FROM [security].StandardOnSchemaRoles o ' + CHAR(13) +
            -- '        INNER JOIN inserted i' +CHAR(13) +
            -- '    on o.[RoleName] = i.[RoleName]' +CHAR(13) +
            -- 'END' ;
-- EXEC (@SQL);
-- PRINT '    Trigger [security].[TRG_I_StandardOnSchemaRoles] altered.'

-- IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_StandardOnSchemaRoles]'))
-- BEGIN
    -- SET @SQL = 'CREATE TRIGGER [security].[TRG_U_StandardOnSchemaRoles] ' + CHAR(13) +
               -- '  ON security.StandardOnSchemaRoles ' + CHAR(13) +
               -- '    FOR UPDATE ' + CHAR(13) +
               -- 'AS' + CHAR(13) +
               -- 'BEGIN' + CHAR(13) +
               -- '    DECLARE @a varchar(MAX)' + CHAR(13) +
               -- '    select @a = ''123''' + CHAR(13) +
               -- 'END' + CHAR(13);

    -- EXEC (@SQL) ;
	-- PRINT '    Trigger [security].[TRG_U_StandardOnSchemaRoles] created.'
-- END

-- SET @SQL =  'ALTER TRIGGER [security].[TRG_U_StandardOnSchemaRoles]' + CHAR(13) +
            -- '    ON security.StandardOnSchemaRoles' + CHAR(13) +
            -- '    FOR UPDATE' +CHAR(13) +
            -- 'AS' + CHAR(13) +
            -- 'BEGIN' + CHAR(13) +
            -- '    UPDATE [security].StandardOnSchemaRoles ' + CHAR(13) +
            -- '        SET LastModified = GETDATE()'+CHAR(13) +
            -- '    FROM [security].StandardOnSchemaRoles o ' + CHAR(13) +
            -- '        INNER JOIN inserted i' +CHAR(13) +
            -- '    on o.[RoleName] = i.[RoleName]' +CHAR(13) +
            -- 'END' ;
-- EXEC (@SQL);

-- PRINT '    Trigger [security].[TRG_U_StandardOnSchemaRoles] altered.'
-- GO

-- PRINT '    Adding default data to [security].[StandardOnSchemaRoles].'

-- --[StandardOnSchemaRoles]---------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- set nocount on;
-- ;with cte_data(
-- [RoleName],[isActive],[CreationDate],[lastmodified],[Description])
-- as (
    -- select * 
    -- from (
        -- values
        -- ('data_modifier',1,'2014-04-23 00:00:00.000','2014-04-23 00:00:00.000',null),
        -- ('data_reader',1,'2014-04-23 00:00:00.000','2014-04-23 00:00:00.000',null),
        -- ('endusers',1,'2014-04-23 00:00:00.000','2014-04-23 00:00:00.000',null),
        -- ('full_access',1,'2014-04-23 00:00:00.000','2014-04-23 00:00:00.000',null),
        -- ('managers',1,'2014-04-23 00:00:00.000','2014-04-23 00:00:00.000',null),
        -- ('prog_executors',1,'2014-11-25 00:00:00.000','2014-11-25 00:00:00.000',null),
        -- ('responsible',1,'2014-04-23 00:00:00.000','2014-04-23 00:00:00.000',null),
        -- ('struct_modifier',1,'2014-04-23 00:00:00.000','2014-04-23 00:00:00.000',null),
        -- ('struct_viewer',1,'2014-04-23 00:00:00.000','2014-04-23 00:00:00.000',null)
    -- ) c (
        -- [RoleName],[isActive],[CreationDate],[lastmodified],[Description]
    -- )
-- )
-- merge [security].[StandardOnSchemaRoles] as t
-- using cte_data as s
-- on		1=1 and t.[RoleName] = s.[RoleName]
-- when matched then
	-- update set
	-- [isActive] = s.[isActive],[CreationDate] = s.[CreationDate],[lastmodified] = s.[lastmodified],[Description] = s.[Description]
-- when not matched by target then
	-- insert([RoleName],[isActive],[CreationDate],[lastmodified],[Description])
	-- values(s.[RoleName],s.[isActive],s.[CreationDate],s.[lastmodified],s.[Description])
-- ;




-- PRINT '--------------------------------------------------------------------------------------------------------------'
-- PRINT '' 