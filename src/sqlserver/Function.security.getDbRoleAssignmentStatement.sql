/*requires Schema.Security.sql*/
/*requires Table.security.ApplicationParams.sql*/
/*requires Function.security.getDbRoleCreationStatement.sql*/
/*requires Function.security.getDbUserCreationStatement.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getDbRoleAssignmentStatement] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getDbRoleAssignmentStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getDbRoleAssignmentStatement] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Function [security].[getDbRoleAssignmentStatement] created.'
END
GO

ALTER Function [security].[getDbRoleAssignmentStatement] (
    @DbName                         VARCHAR(128),
    @RoleName                       VARCHAR(max),
    @MemberName                     VARCHAR(max),
    @PermissionLevel                VARCHAR(10),
    @MemberIsRole                   BIT = 0,
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
    This function returns a string with the statements for a database role assignment 
    based on the given parameters.
 
  ARGUMENTS :
        @DbName                 name of the database in which we have some job to do 
        @RoleName               name of the role we need to take care of
        @MemberName             name of the member of the role we need to take care of
        @PermissionLevel        'GRANT','REVOKE','DENY'
        @MemberIsRole           If set to 1, the MemberName is actually a role in @DbName database
        @isActive               If set to 1, the assignment is active and must be done,
                                TODO if set to 0, this should be like a REVOKE !
        @NoHeader               If set to 1, no header will be displayed in the generated statements
        @NoDependencyCheckGen   if set to 1, no check for server name, database name and so on are generated
        @Debug                  If set to 1, then we are in debug mode

 
  REQUIREMENTS:
  
  EXAMPLE USAGE :
      DECLARE @test VARCHAR(max)
      select @test = [security].[getDbRoleAssignmentStatement] ('TESTING_ONLY_TESTING','test_jel_role',0,1,1,1,1)
      PRINT @test
      -- EXEC @test
 
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
    24/12/2014  JEL         Version 0.1.0 
    --------------------------------------------------------------------------------
    02/04/2014  JEL         Corrected bug when database and server collations are different.      
	----------------------------------------------------------------------------------	
	19/06/2015  JEL         Changed parameter DbName from 32 chars to 128
    ----------------------------------------------------------------------------------	
	07/08/2015 	JEL			Removed version number from function
    ----------------------------------------------------------------------------------	
 ===================================================================================
*/
BEGIN
    --SET NOCOUNT ON;    
    DECLARE @tsql               varchar(max);
    DECLARE @DynDeclare         varchar(512);
    DECLARE @ErrorDbNotExists   varchar(max);
    DECLARE @LineFeed 			VARCHAR(10)
    
    /* Sanitize our inputs */
	SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10) ,
        @DynDeclare         = 'DECLARE @RoleName   VARCHAR(64)' + @LineFeed +
							  'DECLARE @MemberName VARCHAR(64)' + @LineFeed +
                              'SET @RoleName   = QUOTENAME(''' + @RoleName + ''')' + @LineFeed  +
                              'SET @MemberName = QUOTENAME(''' + @MemberName + ''')' + @LineFeed  

    SET @tsql = @DynDeclare  +
                'DECLARE @DbName      VARCHAR(64) = ''' + QUOTENAME(@DbName) + '''' + @LineFeed 

        
    SET @ErrorDbNotExists =  N'The given database ('+QUOTENAME(@DbName)+') does not exist'

    if @NoHeader = 0 
    BEGIN
        SET @tsql = @tsql + '/**' + @LineFeed +
                    ' * Database Role assignment.' + @LineFeed +
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
                    '' + @LineFeed /*+
                    -- TODO GET values marked as null :
                    [security].[getDbRoleCreationStatement](@DbName,@RoleName,null,@isActive,@NoHeader,1,@Debug)
                    */
/*                    
        if @MemberIsRole = 1 
        BEGIN
            
            -- TODO GET values marked as null :
            
            SET @tsql = @tsql +
                        [security].[getDbRoleCreationStatement](@DbName,@MemberName,null,null,@NoHeader,1,@Debug)
            
        END
        ELSE 
        BEGIN 
            
                -- TODO GET values marked as null :
            SET @tsql = @tsql +
                        [security].[getDbUserCreationStatement(@DbName,null,@MemberName,null,null,@NoHeader,1,@Debug)
            
        END 
*/      
    END
    /*
    SET @tsql = @tsql + 
                'USE ' + QUOTENAME(@DbName) + @LineFeed +
                + @LineFeed        */
    
    if @PermissionLevel = 'GRANT'
    BEGIN 
        SET @tsql = @tsql +  
                    'if not exists ( '+ @LineFeed +
                    '    select 1 ' + @LineFeed +
                    '    from ' + QUOTENAME(@DbName) + '.sys.database_role_members ' + @LineFeed +
                    '    where QUOTENAME(USER_NAME(member_principal_id)) COLLATE French_CI_AS = @MemberName COLLATE French_CI_AS' + @LineFeed +
                    '    and QUOTENAME(USER_NAME(role_principal_id ))  COLLATE French_CI_AS = @RoleName COLLATE French_CI_AS' + @LineFeed +
                    ')' + @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    EXEC (''USE ' + QUOTENAME(@DbName) + '; exec sp_addrolemember @rolename = ''''' + @RoleName + ''''', @MemberName = ''''' + @MemberName + ''''''')' + @LineFeed +
                    '    -- TODO : check return code to ensure role member is really added' + @LineFeed +
                    'END' + @LineFeed
    END 
    ELSE if @PermissionLevel = 'DENY' 
    BEGIN 
        SET @tsql = @tsql +  
                    'if exists ( '+ @LineFeed +
                    '    select 1 ' + @LineFeed +
                    '    from ' + QUOTENAME(@DbName) + '.sys.database_role_members ' + @LineFeed +
                    '    where QUOTENAME(USER_NAME(member_principal_id)) COLLATE French_CI_AS = @MemberName COLLATE French_CI_AS' + @LineFeed +
                    '''    and QUOTENAME(USER_NAME(role_principal_id )) COLLATE French_CI_AS  = @RoleName COLLATE French_CI_AS' + @LineFeed +
                    ')' + @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    EXEC (''USE ' + QUOTENAME(@DbName) + '; exec sp_droprolemember @rolename = '''''' + @RoleName + '''''', @MemberName = '''''' + @MemberName + '''''''')' + @LineFeed +
                    '    -- TODO : check return code to ensure role member is really dropped' + @LineFeed +
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

PRINT '    Function [security].[getDbRoleAssignmentStatement] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 