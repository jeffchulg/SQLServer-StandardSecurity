/*requires Schema.Security.sql*/
/*requires Table.ApplicationParams.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getDbRoleCreationStatement] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getDbRoleCreationStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getDbRoleCreationStatement] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Function [security].[getDbRoleCreationStatement] created.'
END
GO
ALTER Function [security].[getDbRoleCreationStatement] (
    @DbName                         VARCHAR(128),
    @RoleName                       VARCHAR(max),
    @isStandard                     BIT = 0,
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
    This function returns a string with the statements for a database role creation 
    based on the given parameters.
 
  ARGUMENTS :
        @DbName                 name of the database in which we have some job to do 
        @RoleName               name of the role we need to take care of
        @isStandard             If set to 1, it just says that the role is part of the 
                                security standard
        @isActive               If set to 1, the assignment is active and must be done,
                                TODO if set to 0, this should be like a REVOKE !
        @NoHeader               If set to 1, no header will be displayed in the generated statements
        @NoDependencyCheckGen   if set to 1, no check for server name, database name and so on are generated
        @Debug                  If set to 1, then we are in debug mode
 
  REQUIREMENTS:
  
  EXAMPLE USAGE :
      DECLARE @test VARCHAR(max)
      select @test = [security].[getDbRoleCreationStatement] ('TESTING_ONLY_TESTING','test_jel_role',0,1,1,1,1)
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
        @DynDeclare         = 'DECLARE @dynamicDeclaration VARCHAR(64)' + @LineFeed +
                              'SET @dynamicDeclaration = QUOTENAME(''' + @RoleName + ''')' + @LineFeed  

    SET @tsql = @DynDeclare  +
                'DECLARE @DbName      VARCHAR(64) = ''' + QUOTENAME(@DbName) + '''' + @LineFeed 

        
    SET @ErrorDbNotExists =  N'The given database ('+QUOTENAME(@DbName)+') does not exist'

    if @NoHeader = 0 
    BEGIN
        SET @tsql = @tsql + '/**' + @LineFeed +
                    ' * Database Role Creation version ' + @versionNb + '.' + @LineFeed +
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
    END
    /*
    SET @tsql = @tsql + 
                'USE ' + QUOTENAME(@DbName) + @LineFeed +
                + @LineFeed 
    */
    DECLARE @RoleAuthorization VARCHAR(64)    
    
    select 
        @RoleAuthorization = ISNULL(ParamValue,ISNULL(DefaultValue,'dbo')) 
    from 
        security.ApplicationParams
    where 
        ParamName = 'RoleAuthorization4Creation';
    
    SET @tsql = @tsql + 
                'DECLARE @RoleOwner VARCHAR(64)' + @LineFeed +
                + @LineFeed +                
                'SELECT @RoleOwner = QUOTENAME(USER_NAME(owning_principal_id)) COLLATE French_CI_AS' + @LineFeed +
                'FROM' + @LineFeed +
                '    ' + QUOTENAME(@DbName) + '.sys.database_principals' + @LineFeed +
                'WHERE' + @LineFeed +
                '    QUOTENAME(name) COLLATE French_CI_AS = @dynamicDeclaration COLLATE French_CI_AS' + @LineFeed + 
                'AND type = ''R''' + @LineFeed +
                'IF (@RoleOwner is null ) -- then the schema does not exist ' + @LineFeed  +
                'BEGIN' + @LineFeed  +                
                '    -- create it !' + @LineFeed  +
                '    EXEC (''USE ' + QUOTENAME(@DbName) + '; execute sp_executesql N''''CREATE ROLE ' + QUOTENAME(@RoleName) + ' AUTHORIZATION ' + QUOTENAME(@RoleAuthorization) + ''''''')' + @LineFeed +
                'END' + @LineFeed +
                'ELSE IF @RoleOwner <> ''' + QUOTENAME(@RoleAuthorization) + '''' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    EXEC (''USE ' + QUOTENAME(@DbName) + '; EXEC ''''ALTER AUTHORIZATION on ROLE::' + QUOTENAME(@RoleName) + ' TO ' + QUOTENAME(@RoleAuthorization) + ''''''')' + @LineFeed +
                'END' + @LineFeed 
	
    SET @tsql = @tsql + @LineFeed  +
				'GO' + @LineFeed 
    RETURN @tsql
END
go	

PRINT '    Function [security].[getDbRoleCreationStatement] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 