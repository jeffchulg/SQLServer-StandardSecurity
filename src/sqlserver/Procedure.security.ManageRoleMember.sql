/*requires Schema.Security.sql*/
/*requires Table.security.DatabaseRoleMembers.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[ManageRoleMember] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[ManageRoleMember]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE Procedure [security].[ManageRoleMember] ( ' +
            ' @ServerName    VARCHAR(512), ' +
            ' @DbName    VARCHAR(50) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   SELECT ''Not implemented'' ' +
            'END') ;

    IF @@ERROR = 0
        PRINT '   PROCEDURE created.';
    ELSE
    BEGIN
        PRINT '   Error while trying to create procedure';
        RETURN;
    END;
END;
GO


ALTER PROCEDURE [security].[ManageRoleMember] (
    @DbName         VARCHAR(128) = DB_NAME,
    @SchemaName     VARCHAR(128) = 'dbo',
    @TableName      VARCHAR(128),
    @ValueTmpTbl    VARCHAR(256),
    @Debug          BIT = 0
)
AS
BEGIN
    RAISERROR('Not yet implemented',14,1);
END ;
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
GO