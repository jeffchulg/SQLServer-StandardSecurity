/*requires Schema.Security.sql*/
/*requires Table.DatabaseRoles.sql*/
/*requires Table.DatabasePermissions.sql*/
/*requires Table.security.StandardOnDatabaseRoles.sql*/
/*requires Table.security.StandardOnDatabaseRolesSecurity.sql*/
/*requires Table.StandardExclusion.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setStandardOnDatabaseRolePermissions] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setStandardOnDatabaseRolePermissions]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setStandardOnDatabaseRolePermissions] ( ' +
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


ALTER PROCEDURE [security].[setStandardOnDatabaseRolePermissions] (
    @ServerName  varchar(512) = @@SERVERNAME,
    @DbName      varchar(64)  = NULL,
    @RoleName varchar(64)  = NULL,
    @Debug       BIT          = 0
)
AS
BEGIN 
    --SET NOCOUNT ON;
    DECLARE @versionNb          varchar(16) = '0.0.1';
    DECLARE @tsql               varchar(max);
    DECLARE @CurServerName      varchar(512)
    DECLARE @CurDbName          varchar(64)
    DECLARE @CurRoleName        varchar(64) 
END
GO


IF @@ERROR = 0
    PRINT '   PROCEDURE altered.'
ELSE
BEGIN
    PRINT '   Error while trying to alter procedure'
    RETURN
END   

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''   