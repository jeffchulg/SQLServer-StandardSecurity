/*requires Schema.Security.sql*/
/*requires Function.getDbUserCreationStatement.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getLogin2DbUserMappingStatement] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getLogin2DbUserMappingStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getLogin2DbUserMappingStatement] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Function [security].[getLogin2DbUserMappingStatement] created.'
END
GO

ALTER FUNCTION [security].getLogin2DbUserMappingStatement (
    @LoginName			    varchar(32),
    @DbName				    varchar(64),
    @UserName			    varchar(32),
    @DefaultSchemaName	    varchar(32),    
    @NoHeader               BIT = 0,
    @NoDependencyCheckGen   BIT = 0,
    @forceUserCreation	    bit = 0,
    @NoGrantConnect         BIT = 0,
    @Debug                  BIT = 0    
)
RETURNS VARCHAR(max)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This function returns a string with all statements for mapping a given database 
 	user to a given SQL Login.
 
  ARGUMENTS :
    @LoginName			    Name of the login to map
    @DbName				    Name of the database on on which map the SQL Login
 	@UserName			    Name of the database user in that database to map with the 
                            SQL Login. If this user doesn't exist in the database, it will be
                            created if @forceUserCreation is set to true (default behaviour).
 	@DefaultSchemaName	    default schema for the given database user in the given SQL Server database.
    @NoHeader               If set to 1, no header will be displayed in the generated statements
    @NoDependencyCheckGen   if set to 1, no check for server name, database name and so on are generated        
 	@forceUserCreation	    Set it to true if you want this procedure to force the database user
                            to be created
    @NoGrantConnect         If set to 1, the GRANT connect statement to the database principal is not generated
    @Debug                  If set to 1, then we are in debug mode
    
 
  REQUIREMENTS:
 
    EXAMPLE USAGE :
        PRINT [security].getLogin2DbUserMappingStatement ('test_jel','TESTING_ONLY_TESTING','test_jel','dbo',1,1,0,0,1)
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
    24/12/2014  JEL         Version 0.1.0
    ----------------------------------------------------------------------------------
 ===================================================================================
*/
BEGIN

    --SET NOCOUNT ON;
    DECLARE @versionNb        varchar(16) = '0.1.0';
    DECLARE @tsql             varchar(max);   
    DECLARE @ErrorDbNotExists varchar(max);
    
    DECLARE @LineFeed 		  VARCHAR(10);
    DECLARE @DynDeclare       VARCHAR(512);    

    /* Sanitize our inputs */
	SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10),
        @DynDeclare         = 'DECLARE @CurDbUser     VARCHAR(64)' + @LineFeed +
                              'DECLARE @CurDbName     VARCHAR(64)' + @LineFeed +
                              'DECLARE @CurLoginName  VARCHAR(64)' + @LineFeed +
                              'DECLARE @CurSchemaName VARCHAR(64)' + @LineFeed +
                              'SET @CurDbUser     = ''' + QUOTENAME(@UserName) + '''' + @LineFeed +
                              'SET @CurDbName     = ''' + QUOTENAME(@DbName) + '''' + @LineFeed +
                              'SET @CurLoginName  = ''' + QUOTENAME(@LoginName) + '''' + @LineFeed +
                              'SET @CurSchemaName = ''' + QUOTENAME(@DefaultSchemaName) + '''' + @LineFeed,                              
        @ErrorDbNotExists   =  N'The given database ('+QUOTENAME(@DbName)+') does not exist'
        
    if @NoHeader = 0 
    BEGIN    
        SET @tsql = isnull(@tsql,'') + 
                    '/**' +@LineFeed+
                    ' * SQL Login to Db user mapping version ' + @versionNb + '.' +@LineFeed+
                    ' *   LoginName				 : ' + @LoginName + @LineFeed +
                    ' *   DBName				 : ' + @DbName +@LineFeed+
                    ' *   UserName				 : ' + @UserName + @LineFeed +
                    ' *   DefaultSchemaName      : ' + @DefaultSchemaName + @LineFeed +
                    ' *   Force DB User Creation : ' + convert(varchar(1),@forceUserCreation) + @LineFeed +
                    ' */'   + @LineFeed+
                    ''      + @LineFeed
    END
    
    set @tsql = isnull(@tsql,'') + @DynDeclare
    
    if @NoDependencyCheckGen = 0 
    BEGIN
        SET @tsql = @tsql + 
                '-- 1.1 Check that the database actually exists' + @LineFeed+
                'if (NOT exists (select 1 from sys.databases where QUOTENAME(name) = @CurDbName))' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    RAISERROR ( ''' + @ErrorDbNotExists + ''',0,1 ) WITH NOWAIT' + @LineFeed +
                '    return' + @LineFeed+
                'END' + @LineFeed +
                '' + @LineFeed +
                'Use '+ QUOTENAME(@DbName) + @LineFeed+
                '-- 1.2 Check that the login actually exists' + @LineFeed + 
                'if (NOT exists (select * from sys.syslogins where QUOTENAME(loginname) = @CurLoginName))' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    RAISERROR (''There is no login with name ''' + QUOTENAME(@LoginName) + ''''',0,1 ) WITH NOWAIT' + @LineFeed +
                '    return' + @LineFeed+
                'END' + @LineFeed +
                '-- 1.3 Check that the schema actually exists in the database' + @LineFeed +
                'if not exists (select 1 from sys.schemas where QUOTENAME(name) = @CurSchemaName)' + @LineFeed +
				'BEGIN' + @LineFeed + 
                '    RAISERROR ( ''The given schema ('+@DefaultSchemaName + ') does not exist'',0,1 ) WITH NOWAIT' + @LineFeed +
                '    return' + @LineFeed+	
				'END' + @LineFeed +
                '' + @LineFeed +
                'if not exists(select 1 from sys.database_principals WHERE QUOTENAME(NAME) = @CurDbUser and Type in (''S'',''U'')' + @LineFeed +
                'BEGIN' + @LineFeed
                
        if (@forceUserCreation = 0) 
        BEGIN
            SET @tsql = @tsql +				
                        '        RAISERROR(N''The given database user '''''+@UserName+ ''''' does not exist!'' ,0,1) WITH NOWAIT' +@LineFeed+
                        '        return' + @LineFeed
        END
        ELSE
        BEGIN
            SET @tsql = @tsql +		
                        [security].getDbUserCreationStatement(@DbName,@LoginName,@UserName,@DefaultSchemaName,0,@NoHeader,@NoDependencyCheckGen,@Debug)
        END
        
     
        SET @tsql = @tsql +
                    'END' + @LineFeed 
    END 
    
    
    SET @tsql = @tsql +
                'Use '+ QUOTENAME(@DbName) + @LineFeed +
                'if NOT EXISTS (SELECT  1 FROM  sys.database_principals princ  LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] where QUOTENAME(ulogin.name) = @CurLoginName and QUOTENAME(princ.name)  = @CurDbUser )' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    EXEC(''ALTER USER ''+''' + QUOTENAME(@UserName) + '''+ ''WITH LOGIN = '' + ''' + QUOTENAME(@LoginName) + ''' )' + @LineFeed +
                'END' + @LineFeed 
                
    
    -- TODO : make it go to DatabasePermissions
    if @NoGrantConnect = 0 
    BEGIN 
            SET @tsql = @tsql + @LineFeed +                 
                '-- If necessary, give the database user the permission to connect the database ' + @LineFeed  +
                'if not exists (select 1 from sys.database_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @CurDbUser and permission_name = ''CONNECT'' and state_desc = ''GRANT'')' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    EXEC (''USE ' + QUOTENAME(@DbName) + ' ; GRANT CONNECT TO ' + QUOTENAME(@UserName) + ''' );' + @LineFeed  +
                'END' + @LineFeed 
    END 
    
    SET @tsql = @tsql +
				'GO'  + @LineFeed 
    
    RETURN @tsql
END
GO

PRINT '    Function [security].[getLogin2DbUserMappingStatement] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 