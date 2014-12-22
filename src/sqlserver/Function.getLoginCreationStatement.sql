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
    @AuthMode                       VARCHAR(7) = 'SQLSRVR',-- Autre possibilité  'WINDOWS'
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
    @LoginName          Name of the login to create
    @AuthMode           Authentication mode : WINDOWS,SQLSRVR
    @Passwd             If @AuthMode = 'SQLSRVR', this parameter defines the password
                        to set by default
    @DefaultDatabase    Name of the default database for the given login
 
  REQUIREMENTS:
 
  ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================
	00001		0.1.3	ALTER LOGIN [XXX] WITH CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
							>> Cannot use parameter CHECK_EXPIRATION for a Windows login.
							>> Cannot use parameter CHECK_POLICY for a Windows login.
    ----------------------------------------------------------------------------------
	00003		0.1.3	No "GO" is added for login creation and default standard settings statements
						Add two extra spaces in addition after the GO statement
    ----------------------------------------------------------------------------------
	00016		0.1.4	Unable to set default database for logins that were not created before.
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
    22/04/2014  JEL         Version 0.1.0
 							TODO : gérer les guids
    ----------------------------------------------------------------------------------
	23/04/2014	JEL			Added missing quotes in RAISEERROR statement
							Version 0.1.1
	----------------------------------------------------------------------------------							
	24/04/2014	JEL			Removed "DefaultSchema" parameter.
							Added password policy management : 
								by default, no password policy
							Removed parenthesis surrounding sp_defaultdb level
							Version 0.1.2
	----------------------------------------------------------------------------------	
	07/05/2014	JEL			Correcting Bug #00001
	07/05/2014	JEL			Correcting Bug #00003
							Version 0.1.3
	----------------------------------------------------------------------------------	
	16/12/2014	JEL			Correction for Bug #00016
							Version 0.1.4
	----------------------------------------------------------------------------------	
    22/12/2014  JEL         Added some parameters :
                                @isActive                       BIT = 1,
                                @NoHeader                       BIT = 0,
                                @NoDependencyCheckGen           BIT = 0
                            and modified code associated with them
                            
                            make use of variables for minimizing ad hoc queries (usage of
                            the variable @loginToPlayWith set at the beginning of this function)
                            Added locking functionality
                            Version 0.2.0
 ===================================================================================
*/
BEGIN
    --SET NOCOUNT ON;
    DECLARE @versionNb              VARCHAR(16) = '0.2.0';
    DECLARE @tsql                   VARCHAR(max);
    DECLARE @LoginDeclaration       VARCHAR(512);
    DECLARE @ErrorDbNotExists       VARCHAR(max);
    DECLARE @LineFeed 			    VARCHAR(10)
    
    /* Sanitize our inputs */
	SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10) ,
        @LoginDeclaration   = 'DECLARE @loginToPlayWith VARCHAR(64)' + @LineFeed +
                              'SET @loginToPlayWith = QUOTENAME(''' + @LoginName + ''')' + @LineFeed  

    SET @tsql = @LoginDeclaration  
        
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
                '    EXEC (''USE [master] ; GRANT CONNECT SQL TO @loginToPlayWith'' );' + @LineFeed  +
                'END' + @LineFeed 
    END 

    SET @tsql = @tsql + @LineFeed +    
				'-- If necessary, set the default database for this login' + @LineFeed  + 
                'if ISNULL(@loginDefaultDb,''<null>'') <> QUOTENAME(''' + @DefaultDatabase + ''')' + @LineFeed +
                'BEGIN' + @LineFeed +
                'exec sp_defaultdb @loginame = @loginToPlayWith , @DefDb = ''' + @DefaultDatabase + '''' + @LineFeed +
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