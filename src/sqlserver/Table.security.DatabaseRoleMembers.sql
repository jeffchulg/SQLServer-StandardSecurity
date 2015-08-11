/*requires Schema.Security.sql*/
/*requires Table.security.DatabaseRoles.sql*/
/*requires View.security.DatabaseUsers.sql*/
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
    24/12/2014  Jefferson Elias     Version 0.1.0
    ----------------------------------------------------------------------------------                                    
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[DatabaseRoleMembers] Creation'


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[DatabaseRoleMembers]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[DatabaseRoleMembers](
        [ServerName]    [varchar](256) NOT NULL,
        [DbName]        [varchar](128) NOT NULL,
        [RoleName]      [varchar](64) NOT NULL,
        [MemberName]    [varchar](64) NOT NULL,
        [MemberIsRole]  [bit] NOT NULL,
        [PermissionLevel] [varchar](6) DEFAULT 'GRANT' NOT NULL ,
        [Reason]        [varchar](2048),
        [isActive]      [bit] NOT NULL,
        [CreationDate]  [datetime] NOT NULL,
        [lastmodified]  [datetime] NOT NULL
    ) ON [PRIMARY]
    
    PRINT '    Table [security].[DatabaseRoleMembers] created.'
END
/*
ESLE
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
            '    -- Validate the Member to be either a Role or a user according to isUser parameter' + CHAR(13) +
            '    -- and DatabaseUsers or DatabaseRoles table'+ CHAR(13) +
            '    DECLARE @tmpCnt  BIGINT ;' + CHAR(13) +
            '    DECLARE @tmpCnt2 BIGINT ;' + CHAR(13) +
            '    SELECT @tmpCnt = COUNT(*) FROM (SELECT distinct ServerName,DbName,MemberName,MemberIsRole FROM inserted) i ; ' + CHAR(13) +
            '    SELECT @tmpCnt2 = COUNT(*)' + CHAR(13) +
            '    FROM (' + CHAR(13) +
            '       SELECT distinct ServerName,DbName,MemberName,MemberIsRole' + CHAR(13) +
            '       FROM inserted' + CHAR(13) +            
            '       INTERSECT (' + CHAR(13) +            
            '            select ServerName,DbName,RoleName, 1 as MemberIsRole' + CHAR(13) +
            '            from security.DatabaseRoles' + CHAR(13) +
            '            union all' + CHAR(13) +
            '            select ServerName,DbName,DbUserName, 0 as MemberIsRole' + CHAR(13) +
            '            from security.DatabaseUsers' + CHAR(13) +
            '        )' + CHAR(13) +
            '    ) i' + CHAR(13) +
            '    IF @tmpCnt <> @tmpCnt2 -- then there is a problem with the MemberName' + CHAR(13) +
            '    BEGIN' + CHAR(13) +
			'        DECLARE @ErrMsg VARCHAR(2048);' + CHAR(13) +
			'        SET @ErrMsg = CONVERT(VARCHAR,@tmpCnt) + '' rows to insert '' + '' <> '' + CONVERT(VARCHAR,@tmpCnt2) + '' rows found in definition '' + CHAR(13) + ' + CHAR(13) + 
            '			           ''One or more rows use an undefined MemberName or error with MemberIsRole parameter''' + CHAR(13) +
			'        ROLLBACK; ' + CHAR(13) +
            '        RAISERROR(@ErrMsg,15,1)' + CHAR(13) +
			'        RETURN;' + CHAR(13) +
            '    END' + CHAR(13) +
            '    UPDATE [security].DatabaseRoleMembers ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            ',           CreationDate = CASE WHEN i.CreationDate IS NULL THEN GETDATE() ELSE i.CreationDate END ' + CHAR(13) +
            '    FROM [security].DatabaseRoleMembers o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '            on o.[ServerName]  = i.[ServerName]' +CHAR(13) +
            '           and o.DbName        = i.DbName' +CHAR(13) +
            '           and o.[RoleName]    = i.[RoleName]' +CHAR(13) +
			'           and o.[MemberName]    = i.[MemberName]' +CHAR(13) +
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
            '           and o.[MemberName]    = i.[MemberName]' +CHAR(13) +

            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_U_DatabaseRoleMembers] altered.'
GO


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 
