/*requires Schema.Security.sql*/
/*requires Table.ApplicationParams.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getOnDbRolePermissionAssignmentStatement] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getOnDbRolePermissionAssignmentStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getOnDbRolePermissionAssignmentStatement] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Function [security].[getOnDbRolePermissionAssignmentStatement] created.'
END
GO

ALTER Function [security].[getOnDbRolePermissionAssignmentStatement] (
    @DbName                         VARCHAR(64),
    @Grantee                        VARCHAR(256),
    @isUser                         BIT,
    @PermissionLevel                VARCHAR(10),
    @PermissionName                 VARCHAR(256),
    @isWithGrantOption              BIT,
    @RoleName                       VARCHAR(128),
    @isActive                       BIT = 1,
    @NoHeader                       BIT = 0,
    @NoDependencyCheckGen           BIT = 0,
    @Debug                          BIT = 0
)
RETURNS VARCHAR(max)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This function returns a string with the statements for a permission assignment 
    with syntax :
        <@PermissionLevel = GRANT|REVOKE|DENY> <PermissionName> ON ROLE::<@RoleName> TO <@Grantee>
    
 
  ARGUMENTS :
        @DbName                 name of the database in which we have some job to do 
        @Grantee                name of the role or user which has a permission to be granted 
        @isUser                 If set to 1, @Grantee is a user 
        @PermissionLevel        'GRANT','REVOKE','DENY'
        @PermissionName         Name of the permission to assign to @Grantee 
        @isWithGrantOption      If set to 1, @Grantee can grant this permission
        @RoleName             Name of the schema on which the permission is about
        @isActive               If set to 1, the assignment is active and must be done,
                                TODO if set to 0, this should be like a REVOKE !
        @NoHeader               If set to 1, no header will be displayed in the generated statements
        @NoDependencyCheckGen   if set to 1, no check for server name, database name and so on are generated
        @Debug                  If set to 1, then we are in debug mode
 
  REQUIREMENTS:
  
  EXAMPLE USAGE :

 
  ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================

  ==================================================================================
  NOTES:
  AUTHORS:
       .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
       .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
       .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
 
  COMPANY: CHU Liege
  ==================================================================================
  Revision History
 
    Date        Name        Description
    ==========  =====       ==========================================================
    30/03/2015  JEL         Version 0.1.0 
 ===================================================================================
*/
BEGIN
    --SET NOCOUNT ON;
    DECLARE @versionNb          varchar(16) = '0.1.0';
    DECLARE @tsql               varchar(max);
    DECLARE @DynDeclare         varchar(512);
    DECLARE @ErrorDbNotExists   varchar(max);
    DECLARE @LineFeed 			VARCHAR(10)
    
    /* Sanitize our inputs */
	SELECT  
		@LineFeed 			= CHAR(13) + CHAR(10) ,
        @DynDeclare         = 'DECLARE @Grantee         VARCHAR(256)' + @LineFeed +
							  'DECLARE @PermissionLevel VARCHAR(10)' + @LineFeed +
							  'DECLARE @PermissionName  VARCHAR(256)' + @LineFeed +
							  'DECLARE @RoleName        VARCHAR(64)' + @LineFeed +
                              'SET @Grantee         = ''' + QUOTENAME(@Grantee) + '''' + @LineFeed  +
                              'SET @PermissionLevel = ''' + @PermissionLevel + '''' + @LineFeed  +
                              'SET @PermissionName  = ''' + @PermissionName + '''' + @LineFeed  +
                              'SET @RoleName        = ''' + QUOTENAME(@RoleName) + '''' + @LineFeed 

    SET @tsql = @DynDeclare  +
                'DECLARE @DbName      VARCHAR(64) = ''' + QUOTENAME(@DbName) + '''' + @LineFeed 

        
    SET @ErrorDbNotExists =  N'The given database ('+QUOTENAME(@DbName)+') does not exist'

    if @NoHeader = 0 
    BEGIN
        SET @tsql = @tsql + '/**' + @LineFeed +
                    ' * Database permission assignment on Database Role version ' + @versionNb + '.' + @LineFeed +
                    ' */'   + @LineFeed +
                    ''      + @LineFeed 
    END 
    if @NoDependencyCheckGen = 0 
    BEGIN
        SET @tsql = @tsql + '-- 1.1 Check that the database actually exists' + @LineFeed +
                    'if (NOT exists (select * from sys.databases where QUOTENAME(name) = @DbName))' + @LineFeed  +
                    'BEGIN' + @LineFeed  +
                    '    RAISERROR ( ''' + @ErrorDbNotExists + ''',0,1 ) WITH NOWAIT' + @LineFeed  +
                    '    return' + @LineFeed +
                    'END' + @LineFeed  +
                    '' + @LineFeed 
        -- TODO : add checks for Grantee and RoleName
    END
    
    SET @tsql = @tsql + 
                'USE ' + QUOTENAME(@DbName) + @LineFeed +
                + @LineFeed + 
                'DECLARE @RoleID INT' + @LineFeed +
                'SELECT @RoleID = principal_id ' + @LineFeed + 
                'FROM ' + @LineFeed + 
                '    sys.database_principals' + @LineFeed + 
                'WHERE type_desc = ''DATABASE_ROLE''' + @LineFeed + 
                'AND [name] = @RoleName' + @LineFeed +
                'DECLARE @CurPermLevel VARCHAR(10)' + @LineFeed +
                'select @CurPermLevel = state_desc' + @LineFeed +
                'from' + @LineFeed +
                'sys.database_permissions' + @LineFeed +
                'where' + @LineFeed +
                '    class_desc                                 = ''DATABASE_PRINCIPAL''' + @LineFeed + 
                'and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee' + @LineFeed +
                'and major_id			                        = @RoleID' + @LineFeed +
                'and QUOTENAME(permission_name)                 = QUOTENAME(@PermissionName)' + @LineFeed

    DECLARE @PermAuthorization VARCHAR(64)    
    
    select 
        @PermAuthorization = ISNULL(ParamValue,ISNULL(DefaultValue,'dbo')) 
    from 
        security.ApplicationParams
    where 
        ParamName = 'ObjectPermissionGrantorDenier';
                
    if @PermissionLevel = 'GRANT'
    BEGIN 
        SET @tsql = @tsql +  
                    'if (@CurPermLevel is null OR @CurPermLevel <> ''GRANT'')' + @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    EXEC sp_executesql N''' + @PermissionLevel + ' ' + @PermissionName + ' ON ROLE::' + QUOTENAME(@RoleName) + ' to ' + QUOTENAME(@Grantee) + ' '
        if @isWithGrantOption = 1
        BEGIN 
            SET @tsql = @tsql +
                        'WITH GRANT OPTION '
        END               
        
        SET @tsql = @tsql + 
                    ' AS ' + QUOTENAME(@PermAuthorization) + '''' + @LineFeed +
                    'END' + @LineFeed
    END 
    ELSE if @PermissionLevel = 'DENY' 
    BEGIN 
        SET @tsql = @tsql +  
                    'if (@CurPermLevel <> ''DENY'')' + @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    EXEC sp_executesql N''' + @PermissionLevel + ' ' + @PermissionName + ' ON ROLE::' + QUOTENAME(@RoleName) + ' to ' + QUOTENAME(@Grantee) + ' '
        SET @tsql = @tsql + 
                    ' AS ' + QUOTENAME(@PermAuthorization) + '''' + @LineFeed +
                    'END' + @LineFeed                    
        
    END 
    ELSE IF @PermissionLevel = 'REVOKE'
    BEGIN
        SET @tsql = @tsql +  
                    'if (@CurPermLevel is not null)' + @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    EXEC sp_executesql N''' + @PermissionLevel + ' ' + @PermissionName + ' ON ROLE::' + QUOTENAME(@RoleName) + ' FROM ' + QUOTENAME(@Grantee) + ' AS ' + QUOTENAME(@PermAuthorization) + '''' + @LineFeed +
                    'END' + @LineFeed
    END
    ELSE
    BEGIN 
        return cast('Unknown PermissionLevel ' + @PermissionLevel as int);
    END     
	
    SET @tsql = @tsql + @LineFeed  +
				'GO' + @LineFeed 
                
    RETURN @tsql
END
go	

PRINT '    Function [security].[getOnDbRolePermissionAssignmentStatement] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 