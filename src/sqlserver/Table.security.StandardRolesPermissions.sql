/*requires Schema.Security.sql*/
/*requires Table.security.StandardRoles.sql*/

/**
  ==================================================================================
    DESCRIPTION
        Creation of the [security].[StandardRolesPermissions] table.
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
    24/12/2014  Jefferson Elias     Version 0.1.0
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[StandardRolesPermissions] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardRolesPermissions]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[StandardRolesPermissions](
		[RoleScope]			[varchar](16) NOT NULL,
        [RoleName]        	[varchar](64) NOT NULL,
        [ObjectClass]       [VARCHAR](128) NOT NULL, -- 'SERVER','DATABASE','DATABASE_SCHEMA','SCHEMA_OBJECT','SCHEMA_OBJECT_COLUMN','DATABASE_USER','SQL_LOGIN'
                                                     -- 'SERVER_ROLE','DATABASE_ROLE','DATABASE_ROLE_ON_SCHEMA' => OBJECT_NAME = the role
        [ObjectType]        [VARCHAR](128) ,
        [PermissionLevel]   [varchar](6) DEFAULT 'GRANT' not null,
        [PermissionName]    [VARCHAR](128) NOT NULL,
        [DbName]            [VARCHAR](128) ,
        [SchemaName]        [VARCHAR](64) ,
        [ObjectName]        [VARCHAR](128) NOT NULL,
        [SubObjectName]     [VARCHAR](128), -- column_name , partition_name
        [isWithGrantOption] BIT NOT NULL,
		[isDefinedByMSSQL] 	[BIT]			DEFAULT 0 NOT NULL,
        [Reason]            VARCHAR(2048),
        [isActive]          BIT            NOT NULL,
        [CreationDate]      [datetime] NULL,
        [lastmodified]      [datetime] NULL,
        [FullObjectType]    AS (
                                [ObjectClass] +  ISNULL([ObjectType],'')
                            ),
        [FullObjectName]    AS (
                                isNULL([DbName],'') + isNULL([SchemaName],'') + [ObjectName] + isNULL([SubObjectName],'')
                            )

    ) ON [PRIMARY]


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


IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardRolesPermissions]') AND name = N'UN_StandardRolesPermissions')
BEGIN
    ALTER TABLE [security].[StandardRolesPermissions]
        ADD CONSTRAINT [UN_StandardRolesPermissions]
            UNIQUE (
                [RoleScope],
                [RoleName],
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

    PRINT '    Primary Key [UN_StandardRolesPermissions] created.'
END
GO


IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[security].[FK_StandardRolesPermissions_StandardRoles]') AND parent_object_id = OBJECT_ID(N'[security].[StandardRolesPermissions]'))
BEGIN
    ALTER TABLE [security].[StandardRolesPermissions]
        ADD  CONSTRAINT [FK_StandardRolesPermissions_StandardRoles]
            FOREIGN KEY(
				[RoleScope],
                [RoleName]
            )
        REFERENCES [security].[StandardRoles] ([RoleScope],[RoleName])

	PRINT '    Foreign key [FK_StandardRolesPermissions_StandardRoles] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardRolesPermissions_ObjectClass]') AND parent_object_id = OBJECT_ID(N'[security].[StandardRolesPermissions]'))
BEGIN
    ALTER TABLE [security].[StandardRolesPermissions]
        WITH CHECK ADD CONSTRAINT [CK_StandardRolesPermissions_ObjectClass]
            CHECK (([ObjectClass] in ('SERVER','SQL_LOGIN','DATABASE','DATABASE_SCHEMA','SCHEMA_OBJECT','SCHEMA_OBJECT_COLUMN','DATABASE_USER','SERVER_ROLE','DATABASE_ROLE','DATABASE_ROLE_ON_SCHEMA')))
    PRINT '     Constraint [CK_StandardRolesPermissions_ObjectClass] created.'
END
GO


IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardRolesPermissions_PermissionLevel]') AND parent_object_id = OBJECT_ID(N'[security].[StandardRolesPermissions]'))
BEGIN
    ALTER TABLE [security].[StandardRolesPermissions]
        WITH CHECK ADD CONSTRAINT [CK_StandardRolesPermissions_PermissionLevel]
            CHECK (([PermissionLevel] in ('GRANT','REVOKE','DENY')))
    PRINT '     Constraint [CK_StandardRolesPermissions_PermissionLevel] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[CK_StandardRolesPermissions_OnlyGrantWithGrantOption]') AND type = 'C')
BEGIN
    ALTER TABLE [security].[StandardRolesPermissions]
        ADD  CONSTRAINT [CK_StandardRolesPermissions_OnlyGrantWithGrantOption]
            CHECK  ((NOT (PermissionLevel <> 'GRANT' AND [isWithGrantOption]=(1))))

    PRINT '    Constraint [CK_StandardRolesPermissions_OnlyGrantWithGrantOption] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardRolesPermissions_isWithGrantOption]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardRolesPermissions]
        ADD CONSTRAINT [DF_StandardRolesPermissions_isWithGrantOption]
            DEFAULT 0 FOR [isWithGrantOption]

    PRINT '    Constraint [DF_StandardRolesPermissions_isWithGrantOption] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardRolesPermissions_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardRolesPermissions]
        ADD CONSTRAINT [DF_StandardRolesPermissions_CreationDate]
            DEFAULT (Getdate()) FOR [CreationDate]

    PRINT '    Constraint [DF_StandardRolesPermissions_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardRolesPermissions_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardRolesPermissions]
        ADD CONSTRAINT [DF_StandardRolesPermissions_LastModified] DEFAULT (Getdate()) FOR [LastModified]

    PRINT '    Constraint [DF_StandardRolesPermissions_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardRolesPermissions_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardRolesPermissions]
        ADD CONSTRAINT [DF_StandardRolesPermissions_isActive] DEFAULT (0) FOR [isActive]

    PRINT '    Constraint [DF_StandardRolesPermissions_isActive] created.'
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_StandardRolesPermissions]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_StandardRolesPermissions] ' + CHAR(13) +
               '  ON security.StandardRolesPermissions ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
    PRINT '    Trigger [security].[TRG_I_StandardRolesPermissions] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_StandardRolesPermissions]' + CHAR(13) +
            '    ON security.StandardRolesPermissions' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardRolesPermissions ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = CASE WHEN i.CreationDate IS NULL THEN GETDATE() ELSE i.CreationDate END ' + CHAR(13) +
            '    FROM [security].StandardRolesPermissions o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
			'           ON o.RoleScope = i.RoleScope' + CHAR(13) +
            '           and o.RoleName = i.RoleName' +CHAR(13) +
            '           and o.[ObjectClass] = i.[ObjectClass]' +CHAR(13) +
            '           and ISNULL(o.[ObjectType],''null'') = ISNULL(i.[ObjectType],''null'')' +CHAR(13) +
            '           and o.[PermissionName] = i.[PermissionName]' +CHAR(13) +
            '           and ISNULL(o.[DbName],''null'') = ISNULL(i.[DbName],''null'')' +CHAR(13) +
            '           and ISNULL(o.[SchemaName],''null'') = ISNULL(i.[SchemaName],''null'')' +CHAR(13) +
            '           and o.[objectname] = i.[objectname]' +CHAR(13) +
            '           and ISNULL(o.[SubObjectName],''null'') = ISNULL(i.[SubObjectName],''null'')' +CHAR(13) +
            + CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_StandardRolesPermissions] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_StandardRolesPermissions]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_StandardRolesPermissions] ' + CHAR(13) +
               '  ON security.StandardRolesPermissions ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;

    PRINT '    Trigger [security].[TRG_U_StandardRolesPermissions] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_StandardRolesPermissions]' + CHAR(13) +
            '    ON security.StandardRolesPermissions' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardRolesPermissions ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].StandardRolesPermissions o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '           ON o.RoleScope = i.RoleScope' + CHAR(13) +
            '           and o.RoleName = i.RoleName' +CHAR(13) +
            '           and o.[ObjectClass] = i.[ObjectClass]' +CHAR(13) +
            '           and ISNULL(o.[ObjectType],''null'') = ISNULL(i.[ObjectType],''null'')' +CHAR(13) +
            '           and o.[PermissionName] = i.[PermissionName]' +CHAR(13) +
            '           and ISNULL(o.[DbName],''null'') = ISNULL(i.[DbName],''null'')' +CHAR(13) +
            '           and ISNULL(o.[SchemaName],''null'') = ISNULL(i.[SchemaName],''null'')' +CHAR(13) +
            '           and o.[objectname] = i.[objectname]' +CHAR(13) +
            '           and ISNULL(o.[SubObjectName],''null'') = ISNULL(i.[SubObjectName],''null'')' +CHAR(13) +
            + CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_StandardRolesPermissions] altered.'
GO

PRINT '    Getting back data from old version table (if exists).'

DECLARE @SQL VARCHAR(MAX)

BEGIN TRAN 
BEGIN TRY 

	IF(EXISTS( select 1 from sys.all_objects where OBJECT_ID = OBJECT_ID('[security].[StandardOnSchemaRolesSecurity]') and type_desc = 'USER_TABLE'))
	BEGIN 
		-- old 1.2.0 version and lower.
		
		PRINT '    Copying data from [security].[StandardOnSchemaRolesSecurity] into StandardRolesPermissions';
		
		SET @SQL = 'with standardSchemaRolesPerms' + CHAR(13) +
		'AS (' + CHAR(13) +
		'	select 	' + CHAR(13) +
		'		''SCHEMA'' 		  as RoleScope,' + CHAR(13) +
		'		RoleName		  as RoleName,' + CHAR(13) +
		'		PermissionClass   as ObjectClass,' + CHAR(13) +
		'		null 			  as ObjectType ,' + CHAR(13) +
		'		PermissionLevel	  as PermissionLevel,' + CHAR(13) +
		'		PrivName 		  as PermissionName,' + CHAR(13) +
		'		NULL			  as DbName,' + CHAR(13) +
		'		NULL			  as SchemaName,' + CHAR(13) +
		'		CASE WHEN PermissionClass = ''DATABASE_SCHEMA'' THEN ''<SCHEMA_NAME>'' WHEN PermissionClass = ''DATABASE'' THEN ''<DATABASE>'' ELSE NULL END ' + CHAR(13) +
		'						  as ObjectName /*No given schemaname in standard*/,' + CHAR(13) +
		'		NULL			  as SubObjectName,' + CHAR(13) +
		'		0			      as isWithGrantOption,' + CHAR(13) +
		'		0				  as isDefinedByMSSQL,' + CHAR(13) +
		'		NULL			  as Reason/*no column Reason*/,' + CHAR(13) +
		'		isActive		  as isActive,' + CHAR(13) +
		'		CreationDate	  as CreationDate ' + CHAR(13) +
		'	from [security].[StandardOnSchemaRolesSecurity]' + CHAR(13) +
		'	where isRoleMembership = 0 ' + CHAR(13) +
		')' + CHAR(13) +
		'MERGE [security].[StandardRolesPermissions] t' + CHAR(13) +
		'using standardSchemaRolesPerms i' + CHAR(13) +
		'on 	t.RoleScope 		= i.RoleScope' + CHAR(13) +
		'and t.RoleName 			= i.RoleName' + CHAR(13) +
		'and t.FullObjectType	= i.[ObjectClass] +  ISNULL(i.[ObjectType],'')' + CHAR(13) +
		'and t.PermissionName    = i.PermissionName' + CHAR(13) +
		'and t.FullObjectName 	= isNULL(i.[DbName],'') + isNULL(i.[SchemaName],'') + i.[ObjectName] + isNULL(i.[SubObjectName],'')		' + CHAR(13) +
		'WHEN MATCHED THEN ' + CHAR(13) +
		'	update set	' + CHAR(13) +
		'		t.PermissionLevel 	= i.PermissionLevel,' + CHAR(13) +
		'		t.isWithGrantOption = i.isWithGrantOption,' + CHAR(13) +
		'		--t.isDefinedByMSSQL  = i.isDefinedByMSSQL,' + CHAR(13) +
		'		t.Reason     		= i.Reason,' + CHAR(13) +
		'		t.isActive    		= i.isActive' + CHAR(13) +
		'WHEN NOT MATCHED THEN' + CHAR(13) +
		'	insert (' + CHAR(13) +
		'		RoleScope,RoleName,ObjectClass,ObjectType,PermissionLevel,PermissionName,DbName,SchemaName,ObjectName,SubObjectName,isWithGrantOption,isDefinedByMSSQL,Reason,isActive,CreationDate' + CHAR(13) +
		'	)' + CHAR(13) +
		'	values (' + CHAR(13) +
		'		i.RoleScope,i.RoleName,i.ObjectClass,i.ObjectType,i.PermissionLevel,i.PermissionName,i.DbName,i.SchemaName,i.ObjectName,i.SubObjectName,i.isWithGrantOption,i.isDefinedByMSSQL,i.Reason,i.isActive,i.CreationDate' + CHAR(13) +
		'	)' + CHAR(13) 
		;
		
		exec sp_executesql @SQL;
		
	END 
	ELSE
	BEGIN 
		with standardSchemaRolesPerms
		AS (
			select 	*
				FROM ( VALUES 
			        ('SCHEMA','data_modifier','DELETE','DATABASE_SCHEMA','GRANT',NULL,NULL,NULL,'<SCHEMA_NAME>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','data_modifier','INSERT','DATABASE_SCHEMA','GRANT',NULL,NULL,NULL,'<SCHEMA_NAME>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','data_modifier','UPDATE','DATABASE_SCHEMA','GRANT',NULL,NULL,NULL,'<SCHEMA_NAME>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','data_reader','SELECT','DATABASE_SCHEMA','GRANT',NULL,NULL,NULL,'<SCHEMA_NAME>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','endusers','SHOWPLAN','DATABASE','GRANT',NULL,NULL,NULL,'<DATABASE>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','prog_executors','EXECUTE','DATABASE_SCHEMA','GRANT',NULL,NULL,NULL,'<SCHEMA_NAME>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','struct_modifier','ALTER','DATABASE_SCHEMA','GRANT',NULL,NULL,NULL,'<SCHEMA_NAME>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','struct_modifier','CREATE FUNCTION','DATABASE','GRANT',NULL,NULL,NULL,'<DATABASE>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','struct_modifier','CREATE PROCEDURE','DATABASE','GRANT',NULL,NULL,NULL,'<DATABASE>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','struct_modifier','CREATE SYNONYM','DATABASE','GRANT',NULL,NULL,NULL,'<DATABASE>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','struct_modifier','CREATE TABLE','DATABASE','GRANT',NULL,NULL,NULL,'<DATABASE>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','struct_modifier','CREATE TYPE','DATABASE','GRANT',NULL,NULL,NULL,'<DATABASE>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','struct_modifier','CREATE VIEW','DATABASE','GRANT',NULL,NULL,NULL,'<DATABASE>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','struct_modifier','REFERENCES','DATABASE_SCHEMA','GRANT',NULL,NULL,NULL,'<SCHEMA_NAME>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','struct_viewer','VIEW DEFINITION','DATABASE_SCHEMA','GRANT',NULL,NULL,NULL,'<SCHEMA_NAME>',NULL,0,0,NULL,1,'2014-12-24 14:21:52.617'),
					('SCHEMA','struct_modifier','INSERT','SCHEMA_OBJECT','GRANT','TABLE',NULL,'auditlog','DatabaseChangeLog',NULL,0,0,'Allow insert into this table for DDL operations inside database',1,'2015-08-31 14:21:52.617')
				) c (
					RoleScope,RoleName,PermissionName,ObjectClass,PermissionLevel,ObjectType,DbName,SchemaName,ObjectName,SubObjectName,isWithGrantOption,isDefinedByMSSQL,Reason,isActive,CreationDate
				)
		)
		MERGE [security].[StandardRolesPermissions] t
		using standardSchemaRolesPerms i
		on 	t.RoleScope 		= i.RoleScope
		and t.RoleName 			= i.RoleName
		and t.FullObjectType	= i.[ObjectClass] +  ISNULL(i.[ObjectType],'')
		and t.PermissionName    = i.PermissionName
		and t.FullObjectName 	= isNULL(i.[DbName],'') + isNULL(i.[SchemaName],'') + i.[ObjectName] + isNULL(i.[SubObjectName],'')		
		WHEN MATCHED THEN 
			update set	
				t.PermissionLevel 	= i.PermissionLevel,
				t.isWithGrantOption = i.isWithGrantOption,
				--t.isDefinedByMSSQL  = i.isDefinedByMSSQL,
				t.Reason     		= i.Reason,
				t.isActive    		= i.isActive
		WHEN NOT MATCHED THEN
			insert (
				RoleScope,RoleName,ObjectClass,ObjectType,PermissionLevel,PermissionName,DbName,SchemaName,ObjectName,SubObjectName,isWithGrantOption,isDefinedByMSSQL,Reason,isActive,CreationDate
			)
			values (
				i.RoleScope,i.RoleName,i.ObjectClass,i.ObjectType,i.PermissionLevel,i.PermissionName,i.DbName,i.SchemaName,i.ObjectName,i.SubObjectName,i.isWithGrantOption,i.isDefinedByMSSQL,i.Reason,i.isActive,i.CreationDate
			)
		;	
	END 
	
	IF(EXISTS( select 1 from sys.all_objects where OBJECT_ID = OBJECT_ID('[security].[StandardOnDatabaseRolesSecurity]') and type_desc = 'USER_TABLE'))
	BEGIN 
		-- old 1.2.0 version and lower.
		
		PRINT '    Copying data from [security].[StandardOnDatabaseRolesSecurity] into StandardRolesPermissions';
		
		with standardDatabaseRolesPerms
		AS (
			select 	
				'DATABASE' 		  as RoleScope,
				DbRoleName		  as RoleName,
				ObjectClass	      as ObjectClass,
				null 			  as ObjectType ,
				PermissionLevel   as PermissionLevel,
				PermissionName    as PermissionName,
				DbName            as DbName,
				SchemaName		  as SchemaName,
				ObjectName   	  as ObjectName,
				SubObjectName	  as SubObjectName,
				isWithGrantOption as isWithGrantOption,
				0                 as isDefinedByMSSQL,
				Reason			  as Reason/*no column Reason*/,
				isActive		  as isActive,
				CreationDate	  as CreationDate 
			from [security].[StandardOnDatabaseRolesSecurity]		
		)
		MERGE [security].[StandardRolesPermissions] t
		using standardDatabaseRolesPerms i
		on 	t.RoleScope 		= i.RoleScope
		and t.RoleName 			= i.RoleName
		and t.FullObjectType	= i.[ObjectClass] +  ISNULL(i.[ObjectType],'')
		and t.PermissionName    = i.PermissionName
		and t.FullObjectName 	= isNULL(i.[DbName],'') + isNULL(i.[SchemaName],'') + i.[ObjectName] + isNULL(i.[SubObjectName],'')		
		WHEN MATCHED THEN 
			update set	
				t.PermissionLevel 	= i.PermissionLevel,
				t.isWithGrantOption = i.isWithGrantOption,				
				t.Reason     		= i.Reason,
				t.isActive    		= i.isActive
		WHEN NOT MATCHED THEN
			insert (
				RoleScope,RoleName,ObjectClass,ObjectType,PermissionLevel,PermissionName,DbName,SchemaName,ObjectName,SubObjectName,isWithGrantOption,isDefinedByMSSQL,Reason,isActive,CreationDate
			)
			values (
				i.RoleScope,i.RoleName,i.ObjectClass,i.ObjectType,i.PermissionLevel,i.PermissionName,i.DbName,i.SchemaName,i.ObjectName,i.SubObjectName,i.isWithGrantOption,i.isDefinedByMSSQL,i.Reason,i.isActive,i.CreationDate
			)
		;
	END ;	
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
