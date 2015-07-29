/*requires Schema.Validator.sql*/
/*requires Table.inventory.SQLDatabases.sql*/
/*requires Table.DatabaseRoles.sql*/
/*requires Table.SQLMappings.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [validator].[isValidPermissionDescription] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[validator].[isValidPermissionDescription]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [validator].[isValidPermissionDescription] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Function created.'
END
GO
ALTER Function [validator].[isValidPermissionDescription] (
    @ServerName     varchar(512) ,
    @DbName         varchar(64)   ,
    @Grantee        varchar(64)  ,
    @GranteeIsUser  BIT     ,
    @ObjectClass    VARCHAR(128)  ,
    @ObjectType     VARCHAR(128)  ,
    @PermissionLevel VARCHAR(6)   ,
    @PermissionName  VARCHAR(128),
    @SchemaName      VARCHAR(64),
    @ObjectName      VARCHAR(128) ,
    @SubObjectName   VARCHAR(128) ,
    @isWithGrantOption BIT , 
    @Reason          VARCHAR(MAX),
    @isActive        BIT 
)
RETURNS BIT
AS
BEGIN   
    DECLARE @tsql               varchar(max);
    DECLARE @DynDeclare         varchar(512);
    DECLARE @ErrorDbNotExists   varchar(max);
    DECLARE @LineFeed 			VARCHAR(10) ;
    
    SET @LineFeed = CHAR(13) + CHAR(10);
    
    if(@isWithGrantOption is null)
    BEGIN 
        RETURN -1;
    END 
    
    if(@ServerName is null or len(@ServerName) = 0)
    BEGIN 
        RETURN 0;        
    END 
    
    if(@PermissionLevel not in ('GRANT','DENY','REVOKE'))
    BEGIN 
        RETURN 0;        
    END 
    
    if(@DbName is null or len(@DbName) = 0)
    BEGIN 
        -- SERVER LEVEL PERMISSIONS
        IF (@ObjectClass = 'SERVER')
        BEGIN 
            -- TODO : not yet implemented
            return 0;
        END 
    END 
    ELSE 
    BEGIN 
        
        -- check that the database exists in [inventory].[SQLDatabases].
        if(not exists (select 1 from [inventory].[SQLDatabases] where ServerName = @ServerName and DbName = @DbName))
        BEGIN       
            RETURN 0;
        END; 
         
        -- check that grantee exists in database 
        if(@GranteeIsUser = 0)
        BEGIN 
            -- lookup in [security].[DatabaseRoles]
            if(not exists (select 1 from [security].[DatabaseRoles] where ServerName = @ServerName and DbName = @DbName and RoleName = @Grantee))
            BEGIN       
                RETURN 0;
            END; 
        END 
        ELSE 
        BEGIN 
            -- lookup in [security].[SQLMappings]
            if(not exists (select 1 from [security].[SQLMappings] where ServerName = @ServerName and DbName = @DbName and DbUsername = @Grantee))
            BEGIN       
                RETURN 0;
            END; 
        END 
            
        if(@ObjectClass is null or len(@ObjectClass) = 0)
        BEGIN 
            RETURN 0;
        END 
        ELSE IF (@ObjectClass = 'DATABASE')
        BEGIN 
            
            -- TODO Validate PermissionName
            
            if(@SchemaName IS NULL AND @ObjectName = @DbName AND @SubObjectName IS NULL)
            BEGIN 
                RETURN 1;
            END;
        END 
        ELSE IF (@ObjectClass = 'DATABASE_SCHEMA')
        BEGIN 
            
            -- TODO Validate PermissionName            
            
            if(@SchemaName IS NULL AND @ObjectName IS NOT NULL AND @SubObjectName IS NULL)
            BEGIN 
                -- no validation of database schema name as there is a auto-creation through trigger when inserting in this table.
                RETURN 1;
            END;                        
        END 
        ELSE IF (@ObjectClass = 'DATABASE_USER')
        BEGIN 
            -- TODO : not yet implemented
            -- TODO Validate PermissionName
            return 0;
        END 
        ELSE IF (@ObjectClass = 'SCHEMA_OBJECT')
        BEGIN 

            -- TODO Validate ObjectType            
            
            DECLARE @ObjectTypeNeedsSubObjectName BIT ;
            SET @ObjectTypeNeedsSubObjectName = 0;
            
            -- TODO Determine value for @ObjectTypeNeedsSubObjectName
            
            -- TODO Validate PermissionName            
                        
            if(@SchemaName IS NOT NULL AND @ObjectName IS NOT NULL AND ((@ObjectTypeNeedsSubObjectName = 0 and @SubObjectName IS NULL) OR (@ObjectTypeNeedsSubObjectName = 1 and @SubObjectName IS NOT NULL)))
            BEGIN 
                -- no validation of database schema name as there is a auto-creation through trigger when inserting in this table.
                RETURN 1;
            END;                        
            
        END         
    END 
    
    RETURN 0;
END
go	

PRINT '    Function altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 

/*
sample usage : 

select 
	validator.isValidPermissionDescription(
		'SI-S-SERV183',	
		'Pharmalogic',
		'vanas_data_modifier',
		0,
		'DATABASE_SCHEMA',
		null,
		'GRANT',
		'DELETE',
		null,
		'vanas',
		null,
		0,
		'Defined by standard',
		1

)*/
