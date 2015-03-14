/*requires Schema.Security.sql*/
/*requires Table.security.StandardOnDatabaseRoles.sql*/

/**
  ==================================================================================
    DESCRIPTION
        Creation of the [security].[StandardOnDatabaseRolesSecurity] table.
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
PRINT 'Table [security].[StandardOnDatabaseRolesSecurity] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardOnDatabaseRolesSecurity]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[StandardOnDatabaseRolesSecurity](
        [DbRoleName]        [varchar](64) NOT NULL,
        [ObjectClass]       [VARCHAR](128) NOT NULL, -- 'SERVER','DATABASE','DATABASE_SCHEMA','SCHEMA_OBJECT','SCHEMA_OBJECT_COLUMN','DATABASE_USER'
                                                     -- 'DATABASE_ROLE','DATABASE_ROLE_ON_SCHEMA' => OBJECT_NAME = the role 
        [ObjectType]        [VARCHAR](128) ,
        [PermissionLevel]   [varchar](6) DEFAULT 'GRANT' not null,
        [PermissionName]    [VARCHAR](128) NOT NULL,
        [DbName]            [VARCHAR](64) ,
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


IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardOnDatabaseRolesSecurity]') AND name = N'UN_StandardOnDatabaseRolesSecurity')
BEGIN
    ALTER TABLE [security].[StandardOnDatabaseRolesSecurity]
        ADD CONSTRAINT [UN_StandardOnDatabaseRolesSecurity]
            UNIQUE (
                [DbRoleName],
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
    
    PRINT '    Primary Key [UN_StandardOnDatabaseRolesSecurity] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardOnDatabaseRolesSecurity_ObjectClass]') AND parent_object_id = OBJECT_ID(N'[security].[StandardOnDatabaseRolesSecurity]'))
BEGIN
    ALTER TABLE [security].[StandardOnDatabaseRolesSecurity]
        WITH CHECK ADD CONSTRAINT [CK_StandardOnDatabaseRolesSecurity_ObjectClass]
            CHECK (([ObjectClass] in ('SERVER','DATABASE','DATABASE_SCHEMA','SCHEMA_OBJECT','SCHEMA_OBJECT_COLUMN','DATABASE_USER','DATABASE_ROLE','DATABASE_ROLE_ON_SCHEMA')))
    PRINT '     Constraint [CK_StandardOnDatabaseRolesSecurity_ObjectClass] created.'
END
GO


IF  NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[security].[CK_StandardOnDatabaseRolesSecurity_PermissionLevel]') AND parent_object_id = OBJECT_ID(N'[security].[StandardOnDatabaseRolesSecurity]'))
BEGIN
    ALTER TABLE [security].[StandardOnDatabaseRolesSecurity]
        WITH CHECK ADD CONSTRAINT [CK_StandardOnDatabaseRolesSecurity_PermissionLevel]
            CHECK (([PermissionLevel] in ('GRANT','REVOKE','DENY')))
    PRINT '     Constraint [CK_StandardOnDatabaseRolesSecurity_PermissionLevel] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[CK_StandardOnDatabaseRolesSecurity_OnlyGrantWithGrantOption]') AND type = 'C')
BEGIN
    ALTER TABLE [security].[StandardOnDatabaseRolesSecurity]
        ADD  CONSTRAINT [CK_StandardOnDatabaseRolesSecurity_OnlyGrantWithGrantOption]
            CHECK  ((NOT (PermissionLevel <> 'GRANT' AND [isWithGrantOption]=(1))))
    
    PRINT '    Constraint [CK_StandardOnDatabaseRolesSecurity_OnlyGrantWithGrantOption] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnDatabaseRolesSecurity_isWithGrantOption]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardOnDatabaseRolesSecurity]
        ADD CONSTRAINT [DF_StandardOnDatabaseRolesSecurity_isWithGrantOption]
            DEFAULT 0 FOR [isWithGrantOption]
    
    PRINT '    Constraint [DF_StandardOnDatabaseRolesSecurity_isWithGrantOption] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnDatabaseRolesSecurity_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardOnDatabaseRolesSecurity]
        ADD CONSTRAINT [DF_StandardOnDatabaseRolesSecurity_CreationDate]
            DEFAULT (Getdate()) FOR [CreationDate]
    
    PRINT '    Constraint [DF_StandardOnDatabaseRolesSecurity_CreationDate] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnDatabaseRolesSecurity_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardOnDatabaseRolesSecurity]
        ADD CONSTRAINT [DF_StandardOnDatabaseRolesSecurity_LastModified] DEFAULT (Getdate()) FOR [LastModified]
    
    PRINT '    Constraint [DF_StandardOnDatabaseRolesSecurity_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnDatabaseRolesSecurity_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardOnDatabaseRolesSecurity]
        ADD CONSTRAINT [DF_StandardOnDatabaseRolesSecurity_isActive] DEFAULT (0) FOR [isActive]
    
    PRINT '    Constraint [DF_StandardOnDatabaseRolesSecurity_isActive] created.'
END
GO

DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_StandardOnDatabaseRolesSecurity]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_StandardOnDatabaseRolesSecurity] ' + CHAR(13) +
               '  ON security.StandardOnDatabaseRolesSecurity ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
    PRINT '    Trigger [security].[TRG_I_StandardOnDatabaseRolesSecurity] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_StandardOnDatabaseRolesSecurity]' + CHAR(13) +
            '    ON security.StandardOnDatabaseRolesSecurity' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardOnDatabaseRolesSecurity ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].StandardOnDatabaseRolesSecurity o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '           and o.DbRoleName = i.DbRoleName' +CHAR(13) +
            '           and o.[grantee] = i.[grantee]' +CHAR(13) +
            '           and o.[ObjectClass] = i.[ObjectClass]' +CHAR(13) +
            '           and ISNULL(o.[ObjectType],''null'') = ISNULL(i.[ObjectType],''null'')' +CHAR(13) +
            '           and o.[PermissionName] = i.[PermissionName]' +CHAR(13) +
            '           and ISNULL(o.[SchemaName],''null'') = ISNULL(i.[SchemaName],''null'')' +CHAR(13) +
            '           and o.[objectname] = i.[objectname]' +CHAR(13) +        
            '           and ISNULL(o.[SubObjectName],''null'') = ISNULL(i.[SubObjectName],''null'')' +CHAR(13) +        
            + CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_StandardOnDatabaseRolesSecurity] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_StandardOnDatabaseRolesSecurity]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_StandardOnDatabaseRolesSecurity] ' + CHAR(13) +
               '  ON security.StandardOnDatabaseRolesSecurity ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
    
    PRINT '    Trigger [security].[TRG_U_StandardOnDatabaseRolesSecurity] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_StandardOnDatabaseRolesSecurity]' + CHAR(13) +
            '    ON security.StandardOnDatabaseRolesSecurity' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardOnDatabaseRolesSecurity ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].StandardOnDatabaseRolesSecurity o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '           and o.DbRoleName = i.DbRoleName' +CHAR(13) +
            '           and o.[grantee] = i.[grantee]' +CHAR(13) +
            '           and o.[ObjectClass] = i.[ObjectClass]' +CHAR(13) +
            '           and ISNULL(o.[ObjectType],''null'') = ISNULL(i.[ObjectType],''null'')' +CHAR(13) +
            '           and o.[PermissionName] = i.[PermissionName]' +CHAR(13) +
            '           and ISNULL(o.[SchemaName],''null'') = ISNULL(i.[SchemaName],''null'')' +CHAR(13) +
            '           and o.[objectname] = i.[objectname]' +CHAR(13) +        
            '           and ISNULL(o.[SubObjectName],''null'') = ISNULL(i.[SubObjectName],''null'')' +CHAR(13) +     
            + CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_StandardOnDatabaseRolesSecurity] altered.'
GO

/* Roles to be defined :
CHULG_SAI_RA 
> dbo.SchemaChangeLog SELECT 
> DBA.dbo.CPUStatsHistory (etc.) SELECT

ApplicationSchemas_EndUsers > All OnSchema "endusers"
ApplicationSchemas_FullAccess > All OnSchema "FullAccess"

*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 
