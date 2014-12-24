/*requires Schema.Security.sql*/
/*requires Table.DatabasePermissions.sql*/

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
    24/12/2014  Jefferson Elias     Modified I/U triggers so that it creates automatically
                                    the specified schema if it doesn't exist.
                                    Added FK_DatabasePermissions_SchemaName
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

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[security].[FK_DatabasePermissions_SchemaName]') AND parent_object_id = OBJECT_ID(N'[security].[DatabasePermissions]'))
BEGIN
    ALTER TABLE [security].[DatabasePermissions]
        ADD  CONSTRAINT [FK_DatabasePermissions_SchemaName]
            FOREIGN KEY (
                [ServerName],[DbName],[SchemaName]
            )
        REFERENCES [security].[DatabaseSchemas] ([ServerName],[DbName],[SchemaName])
	IF @@ERROR = 0
		PRINT '   Foreign Key [FK_DatabasePermissions_SchemaName] created.'
	ELSE
	BEGIN
		PRINT '   Error while trying to create Foreign Key [FK_SQLMappings_Contacts]'
		RETURN
	END
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
            + CHAR(13) +
			'	DECLARE forEachRowCursor' + CHAR(13) + 
			'	CURSOR FOR' + CHAR(13) + 
			'		select distinct' + CHAR(13) + 
			'			ServerName,' + CHAR(13) + 
			'			DbName,' + CHAR(13) + 
			'			SchemaName' + CHAR(13) +
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
				'' + CHAR(13) + 
			'	OPEN forEachRowCursor;' + CHAR(13) + 
			'	FETCH next from forEachRowCursor ' + CHAR(13) + 
			'		into @currentServer,@currentDbName,@currentSchema' + CHAR(13) + 
				'' + CHAR(13) + 
			'	WHILE @@FETCH_STATUS = 0' + CHAR(13) + 
			'	BEGIN' + CHAR(13) + 
						'' + CHAR(13) + 
			'	     merge [security].DatabaseSchemas s' + CHAR(13) +
			'		 using ( ' + CHAR(13) + 
			'			select ' + CHAR(13) + 
			'				@currentServer  as ServerName,' + CHAR(13) + 
			'				@currentDbName  as DbName,' + CHAR(13) + 
			'				@currentSchema  as SchemaName' + CHAR(13) + 
			'		 ) i' + CHAR(13) + 
			'	     on  s.[ServerName]  = i.[ServerName]' + CHAR(13) +
			'	     and s.DbName        = i.DbName' + CHAR(13) +
			'	     and s.[SchemaName]  = i.[SchemaName]' + CHAR(13) +
			'/*' + CHAR(13) +
			'	     WHEN MATCHED then' + CHAR(13) +
			'	         update set' + CHAR(13) +			
			'	             isActive = 1' + CHAR(13) +
			'*/' + CHAR(13) +
			'	     WHEN NOT MATCHED BY TARGET THEN' + CHAR(13) +
			'	        insert (' + CHAR(13) +
			'	             ServerName,' + CHAR(13) +
			'	             DbName,' + CHAR(13) +
			'	             SchemaName,' + CHAR(13) +
			'	             Description,' + CHAR(13) +
			'	             isActive' + CHAR(13) +
			'	         )' + CHAR(13) +
			'	         values (' + CHAR(13) +
			'	             i.ServerName,' + CHAR(13) +
			'	             i.DbName,' + CHAR(13) +
			'	             i.SchemaName,' + CHAR(13) +
			'	             ''Created automatically from DatabasePermissions table'',' + CHAR(13) +
			'	             1' + CHAR(13) +
			'	         )' + CHAR(13) +
			'	     ;' + CHAR(13) +					
			'			FETCH next from forEachRowCursor ' + CHAR(13) + 
			'				into @currentServer,@currentDbName,@currentSchema' + CHAR(13) + 
			'	END;' + CHAR(13) + 
			'	CLOSE forEachRowCursor;' + CHAR(13) + 
			'	DEALLOCATE forEachRowCursor;' + CHAR(13) +            
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
            + CHAR(13) +
			'	DECLARE forEachRowCursor' + CHAR(13) + 
			'	CURSOR FOR' + CHAR(13) + 
			'		select distinct' + CHAR(13) + 
			'			ServerName,' + CHAR(13) + 
			'			DbName,' + CHAR(13) + 
			'			SchemaName' + CHAR(13) +
			'		from inserted' + CHAR(13) + 
            '       where SchemaName is not null' + CHAR(13) +
            '' + CHAR(13) + 
			'/**' + CHAR(13) + 
			' * As SQL Server doesn''t have a FOR EACH ROWS trigger, ' + CHAR(13) +
			' * and as we don''t merge on this table PRIMARY KEY, ' + CHAR(13) + 
			' * it is mandatory to use a cursor to loop on each rows!' + CHAR(13) + 
			' */' + CHAR(13) + 
			'	DECLARE @currentServer	[VARCHAR](256)' + CHAR(13) + 
			'	DECLARE @currentDbName	[VARCHAR](64)' + CHAR(13) + 
			'	DECLARE @currentSchema	[VARCHAR](64)' + CHAR(13) + 
				'' + CHAR(13) + 
			'	OPEN forEachRowCursor;' + CHAR(13) + 
			'	FETCH next from forEachRowCursor ' + CHAR(13) + 
			'		into @currentServer,@currentDbName,@currentSchema' + CHAR(13) + 
				'' + CHAR(13) + 
			'	WHILE @@FETCH_STATUS = 0' + CHAR(13) + 
			'	BEGIN' + CHAR(13) + 
						'' + CHAR(13) + 
			'	     merge [security].DatabaseSchemas s' + CHAR(13) +
			'		 using ( ' + CHAR(13) + 
			'			select ' + CHAR(13) + 
			'				@currentServer  as ServerName,' + CHAR(13) + 
			'				@currentDbName  as DbName,' + CHAR(13) + 
			'				@currentSchema  as SchemaName' + CHAR(13) + 
			'		 ) i' + CHAR(13) + 
			'	     on  s.[ServerName]  = i.[ServerName]' + CHAR(13) +
			'	     and s.DbName        = i.DbName' + CHAR(13) +
			'	     and s.[SchemaName]  = i.[SchemaName]' + CHAR(13) +
			'/*' + CHAR(13) +
			'	     WHEN MATCHED then' + CHAR(13) +
			'	         update set' + CHAR(13) +			
			'	             isActive = 1' + CHAR(13) +
			'*/' + CHAR(13) +
			'	     WHEN NOT MATCHED BY TARGET THEN' + CHAR(13) +
			'	        insert (' + CHAR(13) +
			'	             ServerName,' + CHAR(13) +
			'	             DbName,' + CHAR(13) +
			'	             SchemaName,' + CHAR(13) +
			'	             Description,' + CHAR(13) +
			'	             isActive' + CHAR(13) +
			'	         )' + CHAR(13) +
			'	         values (' + CHAR(13) +
			'	             i.ServerName,' + CHAR(13) +
			'	             i.DbName,' + CHAR(13) +
			'	             i.SchemaName,' + CHAR(13) +
			'	             ''Created automatically from DatabasePermissions table'',' + CHAR(13) +
			'	             1' + CHAR(13) +
			'	         )' + CHAR(13) +
			'	     ;' + CHAR(13) +					
			'			FETCH next from forEachRowCursor ' + CHAR(13) + 
			'				into @currentServer,@currentDbName,@currentSchema' + CHAR(13) + 
			'	END;' + CHAR(13) + 
			'	CLOSE forEachRowCursor;' + CHAR(13) + 
			'	DEALLOCATE forEachRowCursor;' + CHAR(13) +                  
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_DatabasePermissions] altered.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 