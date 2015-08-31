/*requires Schema.Security.sql*/
/*requires Table.security.StandardRoles.sql*/

/**
  ==================================================================================
    DESCRIPTION
        Creation of the [security].[StandardRoleMembers] table.
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
    24/12/2014  Jefferson Elias     Version 0.1.0
    ----------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[StandardRoleMembers] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardRoleMembers]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[StandardRoleMembers](
        [RoleScope]         [varchar](16) NOT NULL,
        [RoleName]          [varchar](64) NOT NULL,
        [RoleMemberScope]   [varchar](16) NOT NULL,
        [MemberName]        [varchar](64) NOT NULL,
        --[MemberIsRole]        [bit] NOT NULL, -- !! ONLY ROLES !!!
        [PermissionLevel]   [varchar](6) DEFAULT 'GRANT' NOT NULL ,
        [Reason]            [varchar](2048),
        [isActive]          [bit] NOT NULL,
        [isDefinedByMSSQL]  [BIT]           DEFAULT 0 NOT NULL,
        [CreationDate]      [datetime] NOT NULL,
        [lastmodified]      [datetime] NOT NULL
    ) ON [PRIMARY]

    PRINT '    Table [security].[StandardRoleMembers] created.'
END
/*
ESLE
BEGIN
    PRINT '    Table [security].[StandardRoleMembers] modified.'
END
*/
GO

IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardRoleMembers_PermissionLevel]') AND parent_object_id = OBJECT_ID(N'[security].[StandardRoleMembers]'))
BEGIN
    ALTER TABLE [security].[StandardRoleMembers]
        WITH CHECK ADD CONSTRAINT [CK_StandardRoleMembers_PermissionLevel]
            CHECK (([PermissionLevel] in ('GRANT','REVOKE')))
    PRINT '     Constraint [CK_StandardRoleMembers_PermissionLevel] created.'
END
GO


IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardRoleMembers_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardRoleMembers]
        ADD CONSTRAINT [DF_StandardRoleMembers_CreationDate]
            DEFAULT (Getdate()) FOR [CreationDate]

    PRINT '    Constraint [DF_StandardRoleMembers_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardRoleMembers_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardRoleMembers]
        ADD CONSTRAINT [DF_StandardRoleMembers_LastModified] DEFAULT (Getdate()) FOR [LastModified]

    PRINT '    Constraint [DF_CustomRoles_LastModified] created.'
END
GO


IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardRoleMembers_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardRoleMembers]
        ADD CONSTRAINT [DF_StandardRoleMembers_isActive] DEFAULT (0) FOR [isActive]

    PRINT '    Constraint [DF_StandardRoleMembers_isActive] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardRoleMembers]') AND name = N'PK_StandardRoleMembers')
BEGIN
    ALTER TABLE [security].[StandardRoleMembers]
        ADD CONSTRAINT [PK_StandardRoleMembers]
            PRIMARY KEY CLUSTERED (
                [RoleScope],
                [RoleName],
                [RoleMemberScope],
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

    PRINT '    Primary Key [PK_StandardRoleMembers] created.'
END
GO


IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardRoles]') AND name = N'PK_StandardRoles')
    and not EXISTS (SELECT * FROM sys.foreign_keys  WHERE parent_object_id = OBJECT_ID(N'[security].[StandardRoleMembers]') AND name = N'FK_StandardRoleMembers_StandardRoles_Role')
BEGIN
    ALTER TABLE [security].[StandardRoleMembers]
        ADD CONSTRAINT [FK_StandardRoleMembers_StandardRoles_Role]
            FOREIGN KEY (
                [RoleScope],
                [RoleName]
            )
            REFERENCES [security].[StandardRoles] (
                [RoleScope],
                [RoleName]
            )

    PRINT '    Foreign Key [FK_StandardRoleMembers_StandardRoles_Role] created.'
END
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardRoles]') AND name = N'PK_StandardRoles')
    and not EXISTS (SELECT * FROM sys.foreign_keys  WHERE parent_object_id = OBJECT_ID(N'[security].[StandardRoleMembers]') AND name = N'FK_StandardRoleMembers_StandardRoles_Member')
BEGIN
    ALTER TABLE [security].[StandardRoleMembers]
        ADD CONSTRAINT [FK_StandardRoleMembers_StandardRoles_Member]
            FOREIGN KEY (
                [RoleMemberScope],
                [MemberName]
            )
            REFERENCES [security].[StandardRoles] (
                [RoleScope],
                [RoleName]
            )

    PRINT '    Foreign Key [FK_StandardRoleMembers_StandardRoles_Member] created.'
END
GO


IF  NOT EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[CK_StandardRoleMembers_MembershipTypes]') AND type = 'C')
BEGIN
    ALTER TABLE [security].[StandardRoleMembers]
        ADD  CONSTRAINT [CK_StandardRoleMembers_MembershipTypes]
            CHECK  (
                (RoleScope in ('DATABASE','SCHEMA') and RoleMemberScope in ('DATABASE','SCHEMA'))
            OR  (RoleScope = 'SERVER' and RoleMemberScope = 'SERVER')
            )

    PRINT '    Constraint [CK_StandardRoleMembers_OnlyGrantWithGrantOption] created.'
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_StandardRoleMembers]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_StandardRoleMembers] ' + CHAR(13) +
               '  ON security.StandardRoleMembers ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;

    PRINT '    Trigger [security].[TRG_I_StandardRoleMembers] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_StandardRoleMembers]' + CHAR(13) +
            '    ON security.StandardRoleMembers' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardRoleMembers ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].StandardRoleMembers o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on     o.RoleScope         = i.RoleScope' +CHAR(13) +
            '            and    o.RoleName          = i.RoleName' +CHAR(13) +
            '            and    o.RoleMemberScope   = i.[RoleMemberScope]' +CHAR(13) +
            '            and    o.MemberName        = i.MemberName' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_StandardRoleMembers] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_StandardRoleMembers]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_StandardRoleMembers] ' + CHAR(13) +
               '  ON security.StandardRoleMembers ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
    PRINT '    Trigger [security].[TRG_U_StandardRoleMembers] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_StandardRoleMembers]' + CHAR(13) +
            '    ON security.StandardRoleMembers' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardRoleMembers ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].StandardRoleMembers o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on     o.RoleScope         = i.RoleScope' +CHAR(13) +
            '            and    o.RoleName          = i.RoleName' +CHAR(13) +
            '            and    o.RoleMemberScope   = i.[RoleMemberScope]' +CHAR(13) +
            '            and    o.MemberName        = i.MemberName' +CHAR(13) +

            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_StandardRoleMembers] altered.'
GO

PRINT '    Getting back data from old version table (if exists).'

DECLARE @tsql NVARCHAR(MAX);
BEGIN TRAN
BEGIN TRY

    IF(EXISTS( select 1 from sys.all_objects where OBJECT_ID = OBJECT_ID('[security].[StandardOnSchemaRolesSecurity]') and type_desc = 'USER_TABLE'))
    BEGIN
        -- old 1.2.0 version and lower.

        PRINT '    Copying data from [security].[StandardOnSchemaRolesSecurity] into StandardRoleMembers';

		SET @tsql = '
        with standardSchemaRolesPerms
        AS (
            select
                ''SCHEMA''        as RoleScope,
                PrivName          as RoleName,
                ''SCHEMA''        as RoleMemberScope,
                RoleName          as MemberName ,
                PermissionLevel   as PermissionLevel,                
                NULL              as Reason/*no column Reason*/,
                isActive          as isActive,
                0                 as isDefinedByMSSQL,
                CreationDate      as CreationDate
            from [security].[StandardOnSchemaRolesSecurity]
            where isRoleMembership = 1
        )
        MERGE [security].[StandardRoleMembers] t
        using standardSchemaRolesPerms i
        on  t.RoleScope         = i.RoleScope
        and t.RoleName          = i.RoleName
        and t.RoleMemberScope   = i.[RoleMemberScope]
        and t.MemberName        = i.MemberName
        WHEN MATCHED THEN
            update set
                t.PermissionLevel   = i.PermissionLevel,               
                --t.isDefinedByMSSQL  = i.isDefinedByMSSQL,
                t.Reason            = i.Reason,
                t.isActive          = i.isActive
        WHEN NOT MATCHED THEN
            insert (
                RoleScope,RoleName,RoleMemberScope,MemberName,PermissionLevel,isDefinedByMSSQL,Reason,isActive,CreationDate
            )
            values (
                i.RoleScope,i.RoleName,i.RoleMemberScope,i.MemberName,i.PermissionLevel,i.isDefinedByMSSQL,i.Reason,i.isActive,i.CreationDate
            )
        ;';

		exec sp_executesql @tsql;
    END
	ELSE 
	BEGIN 
        with standardSchemaRolesPerms
        AS (
			select * from ( values
			('SCHEMA','data_modifier','SCHEMA','endusers','GRANT','',1,0,'2014-12-24 14:21:52.617'),
			('SCHEMA','data_reader','SCHEMA','endusers','GRANT','',1,0,'2014-12-24 14:21:52.617'),
			('SCHEMA','prog_executors','SCHEMA','endusers','GRANT','',1,0,'2014-12-24 14:21:52.617'),
			('SCHEMA','endusers','SCHEMA','full_access','GRANT','',1,0,'2014-12-24 14:21:52.617'),
			('SCHEMA','managers','SCHEMA','full_access','GRANT','',1,0,'2014-12-24 14:21:52.617'),
			('SCHEMA','struct_modifier','SCHEMA','managers','GRANT','',1,0,'2014-12-24 14:21:52.617'),
			('SCHEMA','struct_viewer','SCHEMA','managers','GRANT','',1,0,'2014-12-24 14:21:52.617'),
			('SCHEMA','data_modifier','SCHEMA','responsible','GRANT','',1,0,'2014-12-24 14:21:52.617'),
			('SCHEMA','data_reader','SCHEMA','responsible','GRANT','',1,0,'2014-12-24 14:21:52.617'),
			('SCHEMA','managers','SCHEMA','responsible','GRANT','',1,0,'2014-12-24 14:21:52.617')
        ) c (
			RoleScope,RoleName,RoleMemberScope,MemberName,PermissionLevel,Reason,isActive,isDefinedByMSSQL,CreationDate
		))
        MERGE [security].[StandardRoleMembers] t
        using standardSchemaRolesPerms i
        on  t.RoleScope         = i.RoleScope
        and t.RoleName          = i.RoleName
        and t.RoleMemberScope   = i.[RoleMemberScope]
        and t.MemberName        = i.MemberName
        WHEN MATCHED THEN
            update set
                t.PermissionLevel   = i.PermissionLevel,               
                --t.isDefinedByMSSQL  = i.isDefinedByMSSQL,
                t.Reason            = i.Reason,
                t.isActive          = i.isActive
        WHEN NOT MATCHED THEN
            insert (
                RoleScope,RoleName,RoleMemberScope,MemberName,PermissionLevel,isDefinedByMSSQL,Reason,isActive,CreationDate
            )
            values (
                i.RoleScope,i.RoleName,i.RoleMemberScope,i.MemberName,i.PermissionLevel,i.isDefinedByMSSQL,i.Reason,i.isActive,i.CreationDate
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
