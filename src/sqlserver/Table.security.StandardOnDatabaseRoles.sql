/*requires Schema.Security.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[StandardOnDatabaseRoles] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[StandardOnDatabaseRoles]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[StandardOnDatabaseRoles](
        [RoleName]      [varchar](64) 	NOT NULL,
		[Description]	[varchar](2048),
        [isActive]      [bit]		 	NOT NULL,
        [CreationDate]  [datetime] 		NOT NULL,
        [lastmodified]  [datetime] 		NOT NULL
    ) ON [PRIMARY];
	
	IF @@ERROR = 0
		PRINT '   Table created.'
	ELSE
	BEGIN
		PRINT '   Error while trying to create table.'
		RETURN
	END
END;
/*
ELSE
BEGIN 
END
*/
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnDatabaseRoles_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardOnDatabaseRoles]
        ADD CONSTRAINT [DF_StandardOnDatabaseRoles_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	
	PRINT '    Constraint [DF_StandardOnDatabaseRoles_CreationDate] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[security].[DF_StandardOnDatabaseRoles_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [security].[StandardOnDatabaseRoles]
        ADD CONSTRAINT [DF_StandardOnDatabaseRoles_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	PRINT '    Constraint [DF_StandardOnDatabaseRoles_LastModified] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[security].[StandardOnDatabaseRoles]') AND name = N'PK_StandardOnDatabaseRoles')
BEGIN
    ALTER TABLE [security].[StandardOnDatabaseRoles]
        ADD CONSTRAINT [PK_StandardOnDatabaseRoles]
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
	
	PRINT '    Primary key [PK_StandardOnDatabaseRoles] created.'
END
GO


DECLARE @SQL VARCHAR(MAX)

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_I_StandardOnDatabaseRoles]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_I_StandardOnDatabaseRoles] ' + CHAR(13) +
               '  ON security.StandardOnDatabaseRoles ' + CHAR(13) +
               '    FOR INSERT ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	
	PRINT '    Trigger [security].[TRG_I_StandardOnDatabaseRoles] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_I_StandardOnDatabaseRoles]' + CHAR(13) +
            '    ON security.StandardOnDatabaseRoles' + CHAR(13) +
            '    FOR INSERT' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardOnDatabaseRoles ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '        ,   CreationDate = GETDATE() ' + CHAR(13) +
            '    FROM [security].StandardOnDatabaseRoles o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '    on o.[RoleName] = i.[RoleName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);
PRINT '    Trigger [security].[TRG_I_StandardOnDatabaseRoles] altered.'

IF  NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[security].[TRG_U_StandardOnDatabaseRoles]'))
BEGIN
    SET @SQL = 'CREATE TRIGGER [security].[TRG_U_StandardOnDatabaseRoles] ' + CHAR(13) +
               '  ON security.StandardOnDatabaseRoles ' + CHAR(13) +
               '    FOR UPDATE ' + CHAR(13) +
               'AS' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '    DECLARE @a varchar(MAX)' + CHAR(13) +
               '    select @a = ''123''' + CHAR(13) +
               'END' + CHAR(13);

    EXEC (@SQL) ;
	PRINT '    Trigger [security].[TRG_U_StandardOnDatabaseRoles] created.'
END

SET @SQL =  'ALTER TRIGGER [security].[TRG_U_StandardOnDatabaseRoles]' + CHAR(13) +
            '    ON security.StandardOnDatabaseRoles' + CHAR(13) +
            '    FOR UPDATE' +CHAR(13) +
            'AS' + CHAR(13) +
            'BEGIN' + CHAR(13) +
            '    UPDATE [security].StandardOnDatabaseRoles ' + CHAR(13) +
            '        SET LastModified = GETDATE()'+CHAR(13) +
            '    FROM [security].StandardOnDatabaseRoles o ' + CHAR(13) +
            '        INNER JOIN inserted i' +CHAR(13) +
            '    on o.[RoleName] = i.[RoleName]' +CHAR(13) +
            'END' ;
EXEC (@SQL);

PRINT '    Trigger [security].[TRG_U_StandardOnDatabaseRoles] altered.'
GO

PRINT '    Adding default data to [security].[StandardOnDatabaseRoles].'

--[StandardOnDatabaseRoles]---------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
set nocount on;
;

with cte_data(
[RoleName],[isActive],[CreationDate],[lastmodified],[Description])
as (
    select * 
    from (
        values
        ('CHULG_SAI_RA',1,'2015-03-14 00:00:00.000','2015-03-14 00:00:00.000','Standard role for application managers at CHU Liege')
    ) c (
        [RoleName],[isActive],[CreationDate],[lastmodified],[Description]
    )
)
merge [security].[StandardOnDatabaseRoles] as t
using cte_data as s
on		t.[RoleName] = s.[RoleName]
when matched then
	update set
	[isActive] = s.[isActive],[CreationDate] = s.[CreationDate],[lastmodified] = s.[lastmodified],[Description] = s.[Description]
when not matched by target then
	insert([RoleName],[isActive],[CreationDate],[lastmodified],[Description])
	values(s.[RoleName],s.[isActive],s.[CreationDate],s.[lastmodified],s.[Description])
;




PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 