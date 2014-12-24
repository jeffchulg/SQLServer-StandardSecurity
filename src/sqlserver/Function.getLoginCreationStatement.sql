/*requires Schema.Security.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getLoginCreationStatement] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getLoginCreationStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getLoginCreationStatement] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Function [security].[getLoginCreationStatement] created.'
END
GO
ALTER Function [security].[getLoginCreationStatement] (
    @LoginName                      VARCHAR(max),
    @AuthMode                       VARCHAR(7) = 'SQLSRVR',-- Other possibility  'WINDOWS'
    @Passwd                         VARCHAR(64) = '',
    @DefaultDatabase                VARCHAR(32),
    @isActive                       BIT = 1,
    @NoHeader                       BIT = 0,
    @NoDependencyCheckGen           BIT = 0,
    @NoGrantConnectSQL              BIT = 0,
    @Debug                          BIT = 0
)
RETURNS VARCHAR(max)
AS
/*
 ===================================================================================
  DESCRIPTION:
    This function returns a string with the statements for a login creation based on
    the given parameters.
 
  ARGUMENTS :
    @LoginName              Name of the login to create
    @AuthMode               Authentication mode : WINDOWS,SQLSRVR
    @Passwd                 If @AuthMode = 'SQLSRVR', this parameter defines the password
                            to set by default
    @DefaultDatabase        Name of the default database for the given login
    @isActive               If set to 1, the assignment is active and must be done,
                            TODO if set to 0, this should be like a REVOKE !    
    @NoHeader               If set to 1, no header will be displayed in the generated statements
    @NoDependencyCheckGen   if set to 1, no check for server name, database name and so on are generated
    @Debug                  If set to 1, then we are in debug mode 
    
    
  REQUIREMENTS:
 
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
 
    Date        Name        Description
    ==========  =====       ==========================================================
    24/12/2014  JEL         Version 0.1.0
 							TODO : manage GUIDs
    ----------------------------------------------------------------------------------
 ===================================================================================
*/
BEGIN
    --SET NOCOUNT ON;
    DECLARE @versionNb              VARCHAR(16) = '0.1.0';
    DECLARE @tsql                   VARCHAR(max);
    DECLARE @LoginDeclaration       VARCHAR(512);
    DECLARE @ErrorDbNotExists       VARCHAR(max);
    DECLARE @LineFeed 			    VARCHAR(10)
    
    /* Sanitize our inputs */
	SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10) ,
        @LoginDeclaration   = 'DECLARE @loginToPlayWith VARCHAR(64)' + @LineFeed +
                              'SET @loginToPlayWith = QUOTENAME(''' + @LoginName + ''')' + @LineFeed  
        
    SET @ErrorDbNotExists =  N'The given default database ('+QUOTENAME(@DefaultDatabase)+') does not exist'

    if @NoHeader = 0 
    BEGIN
        SET @tsql = isnull(@tsql,'') + 
                    '/**' + @LineFeed +
                    ' * SQL Login Creation (both authentication) version ' + @versionNb + '.' + @LineFeed +
                    ' *     LoginName       : ' + @LoginName        + @LineFeed  +
                    ' *     AuthMode        : ' + @AuthMode         + @LineFeed  +
                    ' *     Passwd          : ' + ISNULL(@Passwd,'<null>')     + @LineFeed  +
                    ' *     DefaultDatabase : ' + @DefaultDatabase  + @LineFeed  +   
                    ' */'   + @LineFeed +
                    ''      + @LineFeed 
    END 
    
    SET @tsql = isnull(@tsql,'') + @LoginDeclaration  

    
    if @NoDependencyCheckGen = 0 
    BEGIN
        SET @tsql = @tsql + '-- 1.1 Check that the default database actually exists' + @LineFeed +
                    'if (NOT exists (select * from sys.databases where name = ''' +  @DefaultDatabase + '''))' + @LineFeed  +
                    'BEGIN' + @LineFeed  +
                    '    RAISERROR ( ''' + @ErrorDbNotExists + ''',0,1 ) WITH NOWAIT' + @LineFeed  +
                    '    return' + @LineFeed +
                    'END' + @LineFeed  +
                    '' + @LineFeed           
    END
    SET @tsql = @tsql + 'IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE  QUOTENAME(name) = @loginToPlayWith)' + @LineFeed  +
                'BEGIN' + @LineFeed  +
                '    -- create it !' + @LineFeed  +
                '    EXEC (''USE [master]; CREATE LOGIN ' + QUOTENAME(@LoginName) + ' ' 

    IF ( @AuthMode = 'WINDOWS' )
    BEGIN
        SET @tsql = @tsql + 'FROM WINDOWS '
    END
    ELSE
    BEGIN
        SET @tsql = @tsql + 'WITH PASSWORD=N''''' + @Passwd + ''''''
    END

    SET @tsql = @tsql + ' , DEFAULT_DATABASE=' + QUOTENAME(@DefaultDatabase) + ''')' + @LineFeed  +
                'END' + @LineFeed  +
				'GO' + @LineFeed  +
                @LineFeed +
                @LoginDeclaration + 
                '-- getting some infos to carry on' + @LineFeed +
                'DECLARE @loginIsDisabled BIT' + @LineFeed +
                'DECLARE @loginDefaultDb  SYSNAME' + @LineFeed +
                'select' + @LineFeed +
                '    @loginIsDisabled   = is_disabled ,' + @LineFeed + 
                '    @loginDefaultDb    = QUOTENAME(default_database_name)' + @LineFeed +
                'from' + @LineFeed +
                '    master.sys.server_principals' + @LineFeed + 
                'where QUOTENAME(name) = @loginToPlayWith' + @LineFeed +
                +@LineFeed +
                '-- ENABLE|DISABLE login' + @LineFeed + 
                'if @loginIsDisabled = ' + CAST(@isActive as CHAR(1)) + @LineFeed +
                'BEGIN' + @LineFeed +               
                '    ALTER LOGIN ' + QUOTENAME(@LoginName) + ' ' + CASE WHEN @isActive = 1 THEN 'ENABLE' ELSE 'DISABLE' END + @LineFeed +               
                'END' + @LineFeed 

    -- TODO : make it go to DatabasePermissions                
    if @NoGrantConnectSQL = 0 
    BEGIN
        SET @tsql = @tsql + @LineFeed +                 
                '-- If necessary, give the login the permission to connect the database engine' + @LineFeed  +
                'if not exists (select 1 from master.sys.server_permissions where QUOTENAME(SUSER_NAME(grantee_principal_id)) = @loginToPlayWith and permission_name = ''CONNECT SQL'' and state_desc = ''GRANT'')' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    EXEC (''USE [master] ; GRANT CONNECT SQL TO ' + QUOTENAME(@LoginName) + ''' );' + @LineFeed  +
                'END' + @LineFeed 
    END 

    SET @tsql = @tsql + @LineFeed +    
				'-- If necessary, set the default database for this login' + @LineFeed  + 
                'if ISNULL(@loginDefaultDb,''<null>'') <> QUOTENAME(''' + @DefaultDatabase + ''')' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    exec sp_defaultdb @loginame = ''' + @LoginName + ''' , @DefDb = ''' + @DefaultDatabase + '''' + @LineFeed +
                'END' + @LineFeed 
                
	/* Password policy setup - TODO SHOULD be different, but not needed at the moment */                
                
	if (@AuthMode <> 'WINDOWS' )
	BEGIN
		SET @tsql = @tsql +
                '-- Password policy settings' + @LineFeed +
                '-- ------------------------' + @LineFeed +
                'DECLARE @loginHasPwdPolicyChecked BIT' + @LineFeed +
                'DECLARE @loginHasPwdExpireChecked BIT' + @LineFeed +                
                'select' + @LineFeed + 
                '    @loginHasPwdPolicyChecked = is_policy_checked,' + @LineFeed + 
                '    @loginHasPwdExpireChecked = is_expiration_checked' + @LineFeed +
                'from master.sys.sql_logins' + @LineFeed +
                'where QUOTENAME(name) = @loginToPlayWith' + @LineFeed +
                @LineFeed +
                '-- by default : no password policy is defined' + @LineFeed +
                'if @loginHasPwdPolicyChecked <> 0' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    ALTER LOGIN ' + QUOTENAME(@LoginName) + ' WITH CHECK_EXPIRATION=OFF' + @LineFeed +
                'END' + @LineFeed +                
                'if @loginHasPwdExpireChecked <> 0' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    ALTER LOGIN ' + QUOTENAME(@LoginName) + ' WITH CHECK_POLICY=OFF' + @LineFeed +
                'END' + @LineFeed                				
	END
	
    SET @tsql = @tsql + @LineFeed  +
				'GO' + @LineFeed 
    RETURN @tsql
END
go	

PRINT '    Function [security].[getLoginCreationStatement] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 