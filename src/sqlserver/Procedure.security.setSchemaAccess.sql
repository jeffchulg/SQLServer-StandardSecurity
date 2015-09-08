/*requires Schema.Security.sql*/
/*requires Table.security.Contacts.sql*/
/*requires Table.security.SQLLogins.sql*/
/*requires Table.security.SQLMappings.sql*/
/*requires Table.security.DatabaseSchemas.sql*/
/*requires Table.security.DatabaseRoles.sql*/
/*requires Table.security.DatabaseRoleMembers.sql*/
/*requires View.security.StandardOnSchemaRoles.sql*/
/*requires Procedure.security.setServerAccess.sql*/
/*requires Function.security.getStandardOnSchemaRoleName.sql*/
/*requires Procedure.security.PrepareAccessSettings.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setSchemaAccess] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setSchemaAccess]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setSchemaAccess] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName        varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
    PRINT '    Procedure [security].[setSchemaAccess] created.'
END
GO

ALTER PROCEDURE [security].[setSchemaAccess] (
    @ServerName                 VARCHAR(512) = @@ServerName,
    @DbName                     VARCHAR(128) = DB_NAME,
    @SchemaName                 VARCHAR(128) ,
    @StandardRoleName           VARCHAR(128) ,
    @ContactDepartment          VARCHAR(512) = NULL,
    @ContactsJob                VARCHAR(256) = NULL,
    @ContactName                VARCHAR(256) = NULL,
    @ContactLogin               VARCHAR(128) = NULL,
    @Reason                     VARCHAR(MAX) ,
    @exactMatch                 BIT          = 1,
    @isAllow                    BIT          = 1,
    @isActive                   BIT          = 1,
    @_noTmpTblDrop              BIT          = 0,
    @Debug                      BIT          = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
        Helper to give access to a given database schema.
        It can (un)set for a set of contacts by department, job title, or just their name
        The database username that will be used is the same as the sql login

   ARGUMENTS :
        @ServerName         name of the server from which the we want to work with
                            By default, it's the current server
        @DbName             The name of the database to which give access
                            By default, it's the current database name
        @SchemaName         name of the schema in @DbName on which set a standard role
        @StandardRoleName   role to assign to contacts
        @ContactDepartment  name of the department for lookup
        @ContactsJob        job title for which we need to give access
        @ContactName        name of the contact
        @ContactLogin       login defined in the inventory for the contact
        @exactMatch         If set to 1, use "=" for lookups
                            If set to 0, use "like" for lookups
        @isAllow            If set to 1, it adds the permission
                            TODO If set to 0, it marks the permission as to be revoked
        @isActive           If set to 1, the access is active
        @Debug              If set to 1, we are in debug mode


    REQUIREMENTS:

    EXAMPLE USAGE :


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

    Date        Name                Description
    ==========  ================    ================================================
    16/04/2015  Jefferson Elias     VERSION 0.1.1
    --------------------------------------------------------------------------------
    07/08/2015  Jefferson Elias     Removed version number
    ----------------------------------------------------------------------------------
    11/08/2015  Jefferson Elias     moved a part of the logic to security.PrepareAccessSettings
    ----------------------------------------------------------------------------------
  ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    DECLARE @tsql               nvarchar(max);
    DECLARE @LineFeed           VARCHAR(10);
    DECLARE @tmpCnt             BIGINT;

    /*
     * Sanitize input
     */

    SELECT
        @LineFeed           = CHAR(13) + CHAR(10),
        @ServerName         = case when len(@ServerName)        = 0 THEN NULL else @ServerName END ,
        @DbName             = case when len(@DbName)            = 0 THEN NULL else @DbName END ,
        @SchemaName         = case when len(@SchemaName)        = 0 THEN NULL else @SchemaName END ,
        @StandardRoleName   = case when len(@StandardRoleName)  = 0 THEN NULL else @StandardRoleName END

    /*
        Checking parameters
    */

    if(@ServerName is null)
    BEGIN
        RAISERROR('No value set for @ServerName !',12,1);
    END;
    if(@DbName is null)
    BEGIN
        RAISERROR('No value set for @DbName !',12,1);
    END;

    if(not EXISTS (select 1 from security.StandardOnSchemaRoles where RoleName = @StandardRoleName))
    BEGIN
        RAISERROR('Parameter StandardRoleName is not a valid standard role',12,1);
    END;

    if( not EXISTS (select 1 from security.DatabaseSchemas where ServerName = @ServerName and DbName = @DbName and SchemaName = @SchemaName))
    BEGIN
        RAISERROR('Provided schema does not exist',12,1);
    END;

    DECLARE @StandardOnSchemaRoleName VARCHAR(256) = security.getStandardOnSchemaRoleName(@SchemaName,@StandardRoleName);

    if( not EXISTS (select 1 from security.DatabaseRoles where ServerName = @ServerName and DbName = @DbName and RoleName = @StandardOnSchemaRoleName and isStandard = 1))
    BEGIN
        RAISERROR('Generated Standard role for the provided schema does not exist',10,1);
    END;

    if(@Debug = 1) 
    BEGIN 
        PRINT '----------------------------------------';
        PRINT 'ServerName     : ' + @ServerName ;
        PRINT 'DatabaseName   : ' + @DbName ;
        PRINT 'Standard Role  : ' + @StandardOnSchemaRoleName ;        
        PRINT '----------------------------------------';
    END ;
    
    BEGIN TRY
        exec [security].[PrepareAccessSettings]
                        @AccessLevel        = 'SCHEMA',
                        @ServerName         = @ServerName,
                        @ContactDepartment  = @ContactDepartment,
                        @ContactsJob        = @ContactsJob,
                        @ContactName        = @ContactName,
                        @ContactLogin       = @ContactLogin,
                        @exactMatch         = @exactMatch,
                        @withTmpTblDrop     = 0,
                        @Debug              = @Debug ;

        -- Loop on logins with existing SQL Mappings
        DECLARE GetAssignments CURSOR LOCAL FOR
            select l.ServerName,/*, @DbName as DbName , @StandardOnSchemaRoleName as RoleName, */sm.DbUserName as MemberName/*, 0 as MemberIsRole*/
            from
                ##logins l
            inner join
                [security].[SQLMappings] sm
            on
                sm.ServerName   = l.ServerName
            and sm.DbName       = @DbName
            and sm.SqlLogin     = l.Name
        ;

        DECLARE @CurServerName VARCHAR(256);
        DECLARE @MemberName    VARCHAR(64);

        OPEN GetAssignments ;

        FETCH NEXT FROM GetAssignments INTO @CurServerName , @MemberName ;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @tmpCnt = count(*)
            FROM [security].[DatabaseRoleMembers] m
            WHERE
                m.[ServerName]      = @CurServerName
            and m.[DbName]          = @DbName
            and m.[RoleName]        = @StandardOnSchemaRoleName
            and m.[MemberName]      = @MemberName
            and m.[MemberIsRole]    = 0
            ;

            IF(@tmpCnt = 0)
            BEGIN
                if(@Debug = 1) 
                BEGIN 
                    PRINT 'New Member Role Definition detected (New Member = ' + QUOTENAME(@MemberName) + ')';
                END ;
                
                INSERT INTO [security].[DatabaseRoleMembers](
                    ServerName,
                    DbName,
                    RoleName,
                    MemberName,
                    MemberIsRole,
                    PermissionLevel,
                    Reason,
                    isActive
                )
                values (
                    @CurServerName,
                    @DbName,
                    @StandardOnSchemaRoleName,
                    @MemberName,
                    0,
                    CASE WHEN @isAllow = 1 THEN 'GRANT' ELSE 'REVOKE' END ,
                    CASE WHEN @Reason IS NULL THEN 'Added during setSchemaAccess call' ELSE @Reason END ,
                    @isActive
                );
            END
            ELSE
            BEGIN     
                if(@Debug = 1) 
                BEGIN 
                    PRINT 'Member Role Update detected (Member = ' + QUOTENAME(@MemberName) + ')';
                END ;    
                
                update [security].[DatabaseRoleMembers]
                    set
                        PermissionLevel = CASE WHEN @isAllow = 1 THEN 'GRANT' ELSE 'REVOKE' END,
                        isActive = @isActive
                WHERE
                    [ServerName]      = @CurServerName
                and [DbName]          = @DbName
                and [RoleName]        = @StandardOnSchemaRoleName
                and [MemberName]      = @MemberName
                and [MemberIsRole]    = 0;
            END ;
            FETCH NEXT FROM GetAssignments INTO @CurServerName , @MemberName ;
        END ;

        CLOSE       GetAssignments ;
        DEALLOCATE  GetAssignments ;

        -- Loop on logins without SQL Mappings to display an error for each of them.

        DECLARE GetSkipped CURSOR LOCAL FOR
            select l.ServerName, l.name as SQLLogin
            from
                ##logins l
            EXCEPT  (
                select distinct sm.ServerName, sm.SqlLogin
                FROM [security].[SQLMappings] sm
                WHERE sm.DbName = @DbName
            )
        ;

        DECLARE @HasSkippedLogins BIT ;
        SET @HasSkippedLogins = 0;

        OPEN GetSkipped;
        FETCH NEXT FROM GetSkipped INTO @ServerName, @MemberName ;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @HasSkippedLogins = 1;

            PRINT 'ERROR : Skipped Contact with login ' + @MemberName + ' because no SQL Mapping defined.';

            FETCH NEXT FROM GetSkipped INTO @ServerName, @MemberName ;
        END ;

        IF(@HasSkippedLogins = 1)
        BEGIN
            exec sp_executesql N'DROP TABLE ##logins';
            RAISERROR('One or more login have not been covered by the procedure.',12,1);
        END ;

        /*
        SET @tsql = '
        MERGE
            [security].[DatabaseRoleMembers] m
            using   (
                select l.ServerName, @DbName as DbName , @StandardOnSchemaRoleName as RoleName, sm.DbUserName as MemberName, 0 as MemberIsRole
                from
                    ##logins l
                inner join
                    [security].[SQLMappings] sm
                on
                    sm.ServerName   = l.ServerName
                and sm.DbName       = @DbName
                and sm.SqlLogin     = l.Name
            ) i
            on
                m.[ServerName]      = i.[ServerName]
            and m.[DbName]          = i.[DbName]
            and m.[RoleName]        = i.[RoleName]
            and m.[MemberName]      = i.[MemberName]
            and m.[MemberIsRole]    = i.[MemberIsRole]
            WHEN MATCHED THEN
                update set
                    PermissionLevel = CASE WHEN @isAllow = 1 THEN ''GRANT'' ELSE ''REVOKE'' END,
                    --CASE WHEN @Reason IS NULL THEN ''Added during setSchemaAccess call'' ELSE @Reason
                    isActive = @isActive
            WHEN NOT MATCHED THEN
                insert (
                    ServerName,
                    DbName,
                    RoleName,
                    MemberName,
                    MemberIsRole,
                    PermissionLevel,
                    Reason,
                    isActive
                )
                values (
                    i.ServerName,
                    i.DbName,
                    i.RoleName,
                    i.MemberName,
                    i.MemberIsRole,
                    CASE WHEN @isAllow = 1 THEN ''GRANT'' ELSE ''REVOKE'' END ,
                    CASE WHEN @Reason IS NULL THEN ''Added during setSchemaAccess call'' ELSE @Reason END ,
                    @isActive
                )
        ;';

        exec sp_executesql
                @tsql,
                N'@ServerName varchar(512),@DbName VARCHAR(128),@StandardOnSchemaRoleName VARCHAR(256),@isAllow BIT,@Reason VARCHAR(MAX),@isActive BIT',
                @ServerName = @ServerName,
                @DbName = @DbName,
                @StandardOnSchemaRoleName = @StandardOnSchemaRoleName,
                @isAllow = @isAllow,
                @Reason = @Reason,
                @isActive = @isActive ;*/

        if @_noTmpTblDrop = 0 and OBJECT_ID('tempdb..##logins' ) is not null
            exec sp_executesql N'DROP TABLE ##logins' ;

    END TRY

    BEGIN CATCH
        SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;

        if @_noTmpTblDrop = 0 and OBJECT_ID('tempdb..##logins' ) is not null
            exec sp_executesql N'DROP TABLE ##logins' ;

        if CURSOR_STATUS('local','loginsToManage') >= 0
        begin
            close loginsToManage
            deallocate loginsToManage
        end

    END CATCH
END
GO

PRINT '    Procedure [security].[setSchemaAccess] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''