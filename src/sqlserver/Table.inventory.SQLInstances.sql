/*requires Schema.Inventory.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [inventory].[SQLInstances] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inventory].[SQLInstances]') AND type in (N'U'))
BEGIN
    CREATE TABLE [inventory].[SQLInstances] (
        ServerName          VARCHAR(256)    NOT NULL,        
        Description         VARCHAR(MAX)    NULL,
        AppEnvironment      VARCHAR(16)     NULL,
        ServerCollation     VARCHAR(128)    NULL,
        PrimaryBU           VARCHAR(256)    NULL,        
        PrimaryHostName     as  CASE WHEN CHARINDEX('\', ServerName) = 0 THEN ServerName 
                                    ELSE SUBSTRING(ServerName,0,CHARINDEX('\',ServerName)) 
                                END,
        InstanceName        as  CASE WHEN CHARINDEX('\', ServerName) = 0 THEN 'MSSQLSERVER'
                                    ELSE SUBSTRING(ServerName,CHARINDEX('\',ServerName)+1,LEN(ServerName)) 
                                END,        
        ServerCreationDate  [datetime]      NULL,
        SQLVersion          VARCHAR(256)    NULL,
        SQLEdition          VARCHAR(256)    NULL,
        [CreationDate]      [datetime] 		NOT NULL,
        [lastmodified]      [datetime] 		NOT NULL
    )
    
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


IF (OBJECTPROPERTY( OBJECT_ID( '[inventory].[SQLInstances]' ), 'TableHasPrimaryKey' ) <> 1)
BEGIN
    ALTER TABLE [inventory].[SQLInstances]
        ADD  CONSTRAINT [PK_SQLInstances ]
            PRIMARY KEY (
                [ServerName]
            )
    IF @@ERROR = 0
        PRINT '   Primary Key [PK_SQLInstances] created.'
END
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[inventory].[DF_SQLInstances_CreationDate]') AND type = 'D')
BEGIN
    ALTER TABLE [inventory].[SQLInstances]
        ADD CONSTRAINT [DF_SQLInstances_CreationDate] DEFAULT (Getdate()) FOR [CreationDate]
	
	PRINT '    Constraint [DF_SQLInstances_CreationDate] created.'
END

GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[inventory].[DF_SQLInstances_LastModified]') AND type = 'D')
BEGIN
    ALTER TABLE [inventory].[SQLInstances]
        ADD CONSTRAINT [DF_SQLInstances_LastModified] DEFAULT (Getdate()) FOR [LastModified]
	
	PRINT '    Constraint [DF_SQLInstances_LastModified] created.'
END
GO
