/*requires Schema.SecurityHelpers.sql*/
/*requires Table.security.DatabaseRoles.sql*/
/*requires Table.security.DatabaseSchemas.sql*/
/*requires Table.security.DatabasePermissions.sql*/
/*requires Table.security.DatabaseRoleMembers.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [SecurityHelpers].[PrepareASPNETServerRegistrationToolInstallation] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SecurityHelpers].[PrepareASPNETServerRegistrationToolInstallation]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [SecurityHelpers].[PrepareASPNETServerRegistrationToolInstallation] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName        varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
    PRINT '    Procedure created.'
END
GO

ALTER PROCEDURE [SecurityHelpers].[PrepareASPNETServerRegistrationToolInstallation] (
    @ServerName         varchar(512) = @@ServerName,
    @DbName             varchar(64) ,
    @GranteeName        varchar(128),
    @GranteeIsRole      BIT,
    @AspNetSchema       varchar(64),
    @isActive           BIT          = 1,
    @Debug              BIT          = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
        This procedure sets up roles and permissions for ASPNET Server Registration tool
        to install correctly with its tool aspnet_regsql.exe
        For more informations about this tool, refer to https://msdn.microsoft.com/en-us/library/ms229862%28v=vs.140%29.aspx


   ARGUMENTS :
     @ServerName    

     @DbName        

     @GranteeName

     @GranteeIsRole

     @AspNetSchema


   REQUIREMENTS:

    EXAMPLE USAGE :
EXEC [SecurityHelpers].[PrepareASPNETServerRegistrationToolInstallation] 
    @ServerName		 = 'SI-S-SERV371',
    @DbName          = 'PacsPortalASPNET',
    @GranteeName     = 'PacsPortalUpdates',
    @GranteeIsRole   = 0,
    @AspNetSchema    = 'dbo',
    @Debug           = 1    

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

     Date        Nom         		Description
     ==========  ================== ==========================================================
     30/03/2015  JEL         		Version 0.0.1
     ----------------------------------------------------------------------------------
    07/08/2015  Jefferson Elias     Removed version number
    ----------------------------------------------------------------------------------	 
  ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    DECLARE @tsql               varchar(max);


    /*
        Checking parameters
    */

    if(@ServerName is null or LEN(@ServerName) = 0)
    BEGIN
        RAISERROR('No value set for @ServerName !',10,1)
    END
    if(@DbName is null or LEN(@DbName) = 0)
    BEGIN
        RAISERROR('No value set for @DbName !',10,1)
    END
    if(@GranteeName is null or LEN(@GranteeName) = 0)
    BEGIN
        RAISERROR('No value set for @GranteeName !',10,1)
    END
    if(@AspNetSchema is null or LEN(@AspNetSchema) = 0)
    BEGIN
        RAISERROR('No value set for @AspNetSchema !',10,1)
    END

    -- check that the schema exists in that database for that server
    if(not exists (select 1 from [security].[DatabaseSchemas] where ServerName = @ServerName and DbName = @DbName and SchemaName = @AspNetSchema))
    BEGIN
        RAISERROR('The given parameters does not match an existing record in DatabaseSchema table !',10,1)
    END

    DECLARE @isUser BIT
    set @isUser = 0

    if @GranteeIsRole = 0
        SET @isUser = 1

    BEGIN TRY
    BEGIN TRANSACTION

        if @Debug = 1
        BEGIN
            PRINT '--------------------------------------------------------------------------------------------------------------'
            PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Server Name         : ' + @ServerName
            PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Database Name       : ' + @DbName
            PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Grantee Name        : ' + @GranteeName
            PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - ASPNET Schema Name  : ' + @AspNetSchema
        END

        CREATE TABLE #ASPNETRoles (
            [RoleName]          [VARCHAR](64) NOT NULL
        );

        insert into #ASPNETRoles
        values
            ('aspnet_Membership_FullAccess'),
            ('aspnet_Membership_BasicAccess'),
            ('aspnet_Membership_ReportingAccess'),
            ('aspnet_Profile_FullAccess'),
            ('aspnet_Profile_BasicAccess'),
            ('aspnet_Profile_ReportingAccess'),
            ('aspnet_Roles_FullAccess'),
            ('aspnet_Roles_BasicAccess'),
            ('aspnet_Roles_ReportingAccess'),
            ('aspnet_Personalization_FullAccess'),
            ('aspnet_Personalization_BasicAccess'),
            ('aspnet_Personalization_ReportingAccess'),
            ('aspnet_WebEvent_FullAccess')
        ;

        CREATE TABLE #ASPNETRoleMemberships (
            [RoleName]      [VARCHAR](64) NOT NULL,
            [MemberName]    [VARCHAR](64) NOT NULL
        );
        insert into #ASPNETRoleMemberships
        values
            ('aspnet_Membership_BasicAccess', 'aspnet_Membership_FullAccess'),
            ('aspnet_Membership_ReportingAccess', 'aspnet_Membership_FullAccess'),
            ('aspnet_Profile_BasicAccess', 'aspnet_Profile_FullAccess'),
            ('aspnet_Profile_ReportingAccess', 'aspnet_Profile_FullAccess'),
            ('aspnet_Roles_BasicAccess', 'aspnet_Roles_FullAccess'),
            ('aspnet_Roles_ReportingAccess', 'aspnet_Roles_FullAccess'),
            ('aspnet_Personalization_BasicAccess', 'aspnet_Personalization_FullAccess'),
            ('aspnet_Personalization_ReportingAccess', 'aspnet_Personalization_FullAccess')
        ;

        CREATE TABLE #DbPermissions (
            [ObjectClass]       [VARCHAR](128) NOT NULL,
            [ObjectType]        [VARCHAR](128) ,
            [PermissionLevel]   [varchar](6) DEFAULT 'GRANT' not null,
            [PermissionName]    [VARCHAR](128) NOT NULL,
            [SchemaName]        [VARCHAR](64) ,
            [ObjectName]        [VARCHAR](128) NOT NULL,
            [SubObjectName]     [VARCHAR](128), -- column_name , partition_name
            [isWithGrantOption] BIT NOT NULL,
            [Reason]            VARCHAR(2048),
        );

        insert into #DbPermissions
        values
            ('DATABASE_SCHEMA',null,'GRANT','CONTROL',NULL,@AspNetSchema,null,0,'(ASPNET Server Registration) Allow user to grant permissions on objects in the schema'),
            ('DATABASE_SCHEMA',null,'DENY','TAKE OWNERSHIP',NULL,@AspNetSchema,null,0,'(ASPNET Server Registration) As user has CONTROL on schema, do not allow him to take ownership on schema...'),
            ('DATABASE',null,'GRANT','CREATE ROLE',NULL,@DbName,null,0,'(ASPNET Server Registration) allow user to run sp_addrolemember and so add role members to roles on which he has the control')
        ;

        if @Debug = 1
        BEGIN
            PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding Database Roles and role members information'
        END

        merge [security].[DatabaseRoles] d
        using (
                select
                    RoleName
                from #ASPNETRoles
            ) i
        on
            d.ServerName = @ServerName
        and d.DbName     = @DbName
        and d.RoleName   = i.RoleName
        WHEN NOT MATCHED BY TARGET THEN
            insert (
                ServerName,
                DbName,
                RoleName,
                isStandard,
                Reason,
                isActive
            )
            values (
                @ServerName,
                @DbName,
                i.RoleName,
                0,
                '(ASPNET Server Registration)',
                @isActive
            )
        WHEN MATCHED AND d.isActive <> @isActive THEN
            update set isActive = @isActive
        ;

        merge [security].DatabaseRoleMembers d
        using (
                select
                   RoleName,
                   MemberName
                from #ASPNETRoleMemberships
            ) i
        on
            d.ServerName = @ServerName
        and d.DbName     = @DbName
        and d.RoleName   = i.RoleName
        and d.MemberName = i.MemberName
        WHEN NOT MATCHED BY TARGET THEN
            insert (
                ServerName,
                DbName,
                RoleName,
                MemberName,
                MemberIsRole,
                Reason,
                isActive
            )
            values (
                @ServerName,
                @DbName,
                i.RoleName,
                i.MemberName,
                1,
                '(ASPNET Server Registration)',
                @isActive
            )
        WHEN MATCHED AND d.isActive <> @isActive THEN
            update set isActive = @isActive
        ;

        if @Debug = 1
        BEGIN
            PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Adding object permissions information'
        END

        merge [security].DatabasePermissions d
        using (
                select
                    ObjectClass,
                    ObjectType,
                    PermissionLevel,
                    PermissionName,
                    SchemaName,
                    ObjectName,
                    SubObjectName,
                    isWithGrantOption,
                    Reason
                from #DbPermissions
                union all 
                select 
                    'DATABASE_ROLE',
                    null,
                    'GRANT',
                    'ALTER',
                    NULL,
                    RoleName,
                    null,
                    0,
                    '(ASPNET Server Registration) Let end users see the role and manage it'
                from #ASPNETRoles
            ) i
            on
                d.ServerName                    = @ServerName
            and d.DbName                        = @DbName
            and d.Grantee                       = @GranteeName
            and d.ObjectClass                   = i.ObjectClass
            and ISNULL(d.ObjectType,'null')     = ISNULL(i.ObjectType,'null')
            and d.PermissionName                = i.PermissionName
            and ISNULL(d.SchemaName,'null')     = ISNULL(i.SchemaName,'null')
            and d.ObjectName                    = i.ObjectName
            and ISNULL(d.SubObjectName,'null')  = ISNULL(i.SubObjectName,'null')
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
                    @ServerName,
                    @DbName,
                    @GranteeName,
                    @isUser,
                    i.ObjectClass,
                    i.ObjectType,
                    i.PermissionLevel,
                    i.PermissionName,
                    i.SchemaName,
                    i.ObjectName,
                    i.SubObjectName,
                    i.isWithGrantOption,
                    i.Reason,
                    @isActive
                )
            ;

        DROP TABLE #DbPermissions
        DROP TABLE #ASPNETRoleMemberships
        DROP TABLE #ASPNETRoles

        if @Debug = 1
        BEGIN
            PRINT '--------------------------------------------------------------------------------------------------------------'
        END
    COMMIT

    END TRY

    BEGIN CATCH

        if(OBJECT_ID('tempdb..#DbPermissions') is not null)
            EXEC sp_executesql N'DROP TABLE #DbPermissions'
        if(OBJECT_ID('tempdb..#ASPNETRoleMemberships') is not null)
            EXEC sp_executesql N'DROP TABLE #ASPNETRoleMemberships'
        if(OBJECT_ID('tempdb..#ASPNETRoles') is not null)
            EXEC sp_executesql N'DROP TABLE #ASPNETRoles'

        SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;

        ROLLBACK
    END CATCH
END
GO

PRINT '    Procedure altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''