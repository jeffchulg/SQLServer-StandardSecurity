/*requires Schema.Security.sql*/
/*requires Table.security.ApplicationParams.sql*/
/*requires Table.security.DatabasePermissions.sql*/
/*requires Table.security.DatabaseRoleMembers.sql*/
/*requires View.security.StandardOnSchemaRolesSecurity.sql*/
/*requires Table.security.SQLMappings.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setStandardOnSchemaRolePermissions] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setStandardOnSchemaRolePermissions]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setStandardOnSchemaRolePermissions] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[setStandardOnSchemaRolePermissions] created.'
END
GO

ALTER PROCEDURE [security].[setStandardOnSchemaRolePermissions] (
    @ServerName  SYSNAME = @@SERVERNAME,
    @DbName      SYSNAME,
    @SchemaName  SYSNAME,
    @StdRoleName SYSNAME,
    @Debug       BIT          = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
     This function takes care of the generation of permissions associated to a given 
     Standard Database Roles for "on schema" access 
     according to its parameter values.
     
     As a prerequisite, all the defined roles must be created before execution
  
   ARGUMENTS :
     @ServerName    name of the server on which the SQL Server instance we want to modify is running.
                    By default, it's the current server
    
     @DbName        name of the database on that server for which create roles.
                    A NULL value (which is the default value) means that this procedure
                    has to take care of all "on schema" roles for any database on the given serer.
  
     @SchemaName    name of the schema for which execute this procedure
     
     @StdRoleName   name of the standard role for which execute this procedure
     
     @Debug                  If set to 1, then we are in debug mode

  
   REQUIREMENTS:
  
    EXAMPLE USAGE :

        EXEC [security].[setStandardOnSchemaRolePermissions] 
            @ServerName  = 'SI-S-SERV204',
            @DbName      = 'Pharmalogic',
            @SchemaName  = 'vanas',
            @StdRoleName = 'data_modifier',
            @Debug       = 1

        exec [security].[setStandardOnSchemaRolePermissions] 
            @ServerName  = 'SI-S-SERV183',
            @DbName      = 'Pharmalogic',
            @SchemaName  = 'vanas',
            @StdRoleName = 'endusers',
            @Debug       = 1
  
   ==================================================================================
   BUGS:
  
     BUGID       Fixed   Description
     ==========  =====   ==========================================================
     ----------------------------------------------------------------------------------
   ==================================================================================
   NOTES:
   AUTHORS:
        .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
        .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
        .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
  
   COMPANY: CHU Liege
   ==================================================================================
   Revision History
  
    Date        Nom         Description
    ==========  =====       ==========================================================
    24/12/2014  JEL         Version 0.0.1
    ----------------------------------------------------------------------------------    
  ===================================================================================
*/
BEGIN

    --SET NOCOUNT ON;
    DECLARE @versionNb          varchar(16) = '0.0.1';
    DECLARE @tsql               varchar(max);
    DECLARE @SchemaRoleSep      VARCHAR(64)
    
    if @Debug = 1
    BEGIN
        PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Getting naming convention (separator between schemaName and StdRoleName).'
    END
    
    select @SchemaRoleSep = ParamValue
    from [security].[ApplicationParams]
    where ParamName = 'Separator4OnSchemaStandardRole' ;    
    
    BEGIN TRY
    BEGIN TRANSACTION
        
        DECLARE getPermissions
        CURSOR LOCAL FOR
            select 
                @SchemaName + @SchemaRoleSep + RoleName,
                PermissionClass,
                PermissionLevel,
                case WHEN isRoleMembership = 1 THEN @SchemaName + @SchemaRoleSep + PrivName
                    ELSE PrivName 
                    END as PrivName,
                isRoleMembership,
                isActive 
            from security.StandardOnSchemaRolesSecurity
            where RoleName = @StdRoleName
            
    
        DECLARE @RoleName        VARCHAR(64)
        DECLARE @PermissionClass VARCHAR(16)
        DECLARE @PermissionLevel VARCHAR(6)
        DECLARE @PrivName        VARCHAR(128)
        DECLARE @isRoleMembership BIT
        DECLARE @isActive         BIT
        
        if @Debug = 1
        BEGIN
            PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Getting permissions for given parameters.'
        END
        
        open getPermissions
        FETCH NEXT
        FROM getPermissions INTO @RoleName,@PermissionClass,@PermissionLevel,@PrivName,@isRoleMembership,@isActive
        
        if @Debug = 1
        BEGIN
            PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Applying permissions for given parameters.'
        END        
        
        WHILE @@FETCH_STATUS = 0        
        BEGIN
            if @isRoleMembership = 0 
            BEGIN
                merge Security.DatabasePermissions p
                using (
                    select 
                        @ServerName             as ServerName,
                        @DbName                 as DbName,
                        @RoleName               as Grantee,
                        0                       as isUser,
                        @PermissionClass        as ObjectClass,
                        null                    as ObjectType,
                        @PermissionLevel        as PermissionLevel,
                        @PrivName               as PermissionName,
                        null                    as SchemaName,
                        CASE 
                            WHEN @PermissionClass = 'DATABASE_SCHEMA'
                                THEN @SchemaName
                            WHEN @PermissionClass = 'DATABASE' 
                                THEN @Dbname 
                            ELSE NULL
                        END           as ObjectName,
                        null                    as SubObjectName,
                        0                       as isWithGrantOption,
                        'Defined by standard'   as Reason,
                        @isActive               as isActive     
                ) i
                on 
                    p.ServerName = i.ServerName
                and p.DbName     = i.DbName
                and p.Grantee    = i.Grantee 
                and p.ObjectClass = i.ObjectClass
                and isnull(p.ObjectType,'null') = isnull(i.ObjectType,'null')
                and p.PermissionName = i.PermissionName
                and isnull(p.schemaName,'null') = isnull(i.schemaName,'null')
                and p.ObjectName = i.ObjectName
                and isnull(p.SubObjectName,'null') = isnull(i.SubObjectName,'null')
                
                WHEN MATCHED THEN 
                    update set
                        PermissionLevel     = i.PermissionLevel,
                        isWithGrantOption   = i.isWithGrantOption,
                        Reason              = i.Reason,
                        isActive            = i.isActive
                        
                WHEN NOT MATCHED BY TARGET THEN
                    insert (
                        ServerName,
                        DbName,
                        Grantee,
                        isUser,
                        ObjectClass,
                        ObjectType,
                        PermissionLevel,
                        PermissionName,
                        SchemaName,
                        ObjectName,
                        SubObjectName,
                        isWithGrantOption,
                        Reason,
                        isActive
                    )
                    values (
                        i.ServerName,
                        i.DbName,
                        i.Grantee,
                        i.isUser,
                        i.ObjectClass,
                        i.ObjectType,
                        i.PermissionLevel,
                        i.PermissionName,
                        i.SchemaName,
                        i.ObjectName,
                        i.SubObjectName,
                        i.isWithGrantOption,
                        i.Reason,
                        i.isActive                    
                    )
                --WHEN NOT MATCHED BY SOURCE THEN TODO
                ;

            END
            ELSE
            BEGIN
                merge security.DatabaseRoleMembers drm
                using (
                    select 
                        @ServerName             as ServerName,
                        @DbName                 as DbName,
                        @PrivName               as RoleName,
                        @RoleName               as MemberName,   
                        @PermissionLevel        as PermissionLevel,
                        1                       as MemberIsRole,
                        'Defined by Standard'   as Reason,
                        @isActive               as isActive    
                ) i
                on
                    drm.ServerName  = i.ServerName
                and drm.DbName      = i.DbName
                and drm.RoleName    = i.RoleName
                and drm.MemberName  = i.MemberName
                
                WHEN MATCHED THEN 
                    update set      
                        PermissionLevel = i.PermissionLevel,
                        Reason          = i.Reason,
                        isActive        = i.isActive
                        
                WHEN NOT MATCHED BY TARGET THEN
                    insert (
                        ServerName,DbName,RoleName,MemberName,PermissionLevel,MemberIsRole,Reason,isActive
                    )
                    values (
                        i.ServerName,i.DbName,i.RoleName,i.MemberName,i.PermissionLevel,i.MemberIsRole,i.Reason,i.isActive
                    )
                --WHEN NOT MATCHED BY SOURCE THEN TODO
                ;
            END
        
            FETCH NEXT
            FROM getPermissions INTO @RoleName,@PermissionClass,@PermissionLevel,@PrivName,@isRoleMembership,@isActive        
                    
        END
        CLOSE getPermissions
        DEALLOCATE getPermissions                       
    
    COMMIT
    END TRY
    BEGIN CATCH
        SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
            

        if CURSOR_STATUS('local','getPermissions') >= 0 
        begin
            close getPermissions
            deallocate getPermissions 
        end            
        ROLLBACK
    END CATCH
END
GO


PRINT '    Procedure [security].[setStandardOnSchemaRolePermissions] altered.'
    
PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''    