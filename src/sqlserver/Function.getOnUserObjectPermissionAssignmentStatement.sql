/*requires Schema.Security.sql*/
/*requires Table.ApplicationParams.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getOnUserObjectPermissionAssignmentStatement] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getOnUserObjectPermissionAssignmentStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getOnUserObjectPermissionAssignmentStatement] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Function [security].[getOnUserObjectPermissionAssignmentStatement] created.'
END
GO

ALTER Function [security].[getOnUserObjectPermissionAssignmentStatement] (
    @DbName                         VARCHAR(64),
    @Grantee                        VARCHAR(256),
    @isUser                         BIT,
    @PermissionLevel                VARCHAR(10),
    @PermissionName                 VARCHAR(256),
    @isWithGrantOption              BIT,
    @ObjectClass                    VARCHAR(64),
    @ObjectType                     VARCHAR(64),
    @SchemaName                     VARCHAR(64),
    @ObjectName                     VARCHAR(64),
    @SubObjectName                  VARCHAR(64),
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
        <@PermissionLevel = GRANT|REVOKE|DENY> <PermissionName> ON SCHEMA::<@SchemaName>
    
 
  ARGUMENTS :

 
  REQUIREMENTS:
  
  EXAMPLE USAGE :
    PRINT [security].[getOnUserObjectPermissionAssignmentStatement](
                                                    'TESTING_ONLY_TESTING',
                                                    'jel_test',
                                                    1,
                                                    'GRANT',
                                                    'INSERT',
                                                    0,
                                                    'SCHEMA_OBJECT',
                                                    'TABLE',
                                                    'dbo',
                                                    'SchemaChangeLog',
                                                    null,
                                                    1,                                            
                                                    1, -- no header
                                                    1, -- no dependency check 
                                                    1
                                                )   
 
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
    23/12/2014  JEL         Version 0.1.0 
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
							  'DECLARE @SchemaName      VARCHAR(64)' + @LineFeed +
							  'DECLARE @ObjectName      VARCHAR(64)' + @LineFeed +
							  'DECLARE @SubObjectName   VARCHAR(64)' + @LineFeed +
                              'SET @Grantee         = ''' + QUOTENAME(@Grantee) + '''' + @LineFeed  +
                              'SET @PermissionLevel = ''' + @PermissionLevel + '''' + @LineFeed  +
                              'SET @PermissionName  = ''' + @PermissionName + '''' + @LineFeed  +
                              'SET @SchemaName      = ''' + QUOTENAME(@SchemaName) + '''' + @LineFeed + 
                              'SET @ObjectName      = ''' + QUOTENAME(@ObjectName) + '''' + @LineFeed  
    if @SubObjectName is not null 
    BEGIN 
        SET @DynDeclare = @DynDeclare +               
                          'SET @SubObjectName   = ''' + QUOTENAME(@SubObjectName) + '''' + @LineFeed  
    END
    
    if @ObjectClass not in ('SCHEMA_OBJECT')
    BEGIN 
        return cast('Unsupported Object Class ' + @ObjectClass as int);
    END 
                              
    SET @tsql = @DynDeclare  +
                'DECLARE @DbName      VARCHAR(64) = ''' + QUOTENAME(@DbName) + '''' + @LineFeed 

        
    SET @ErrorDbNotExists =  N'The given database ('+QUOTENAME(@DbName)+') does not exist'

    if @NoHeader = 0 
    BEGIN
        SET @tsql = @tsql + '/**' + @LineFeed +
                    ' * Database permission on schema assignment version ' + @versionNb + '.' + @LineFeed +
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
        -- TODO : add checks for Grantee and SchemaName and ObjectName and SubObjectName
    END
    
    SET @tsql = @tsql + 
                'USE ' + QUOTENAME(@DbName) + @LineFeed +
                + @LineFeed + 
                'DECLARE @CurPermLevel VARCHAR(10)' + @LineFeed +
                'select @CurPermLevel = state_desc' + @LineFeed +
                'from' + @LineFeed +
                'sys.database_permissions' + @LineFeed +
                'where' + @LineFeed +
                '    class_desc                                 = ''OBJECT_OR_COLUMN''' + @LineFeed + 
                'and QUOTENAME(USER_NAME(grantee_principal_id)) = @Grantee' + @LineFeed +
                'and QUOTENAME(OBJECT_SCHEMA_NAME(major_id))	= @SchemaName' + @LineFeed +
                'and QUOTENAME(OBJECT_NAME(major_id))	        = @ObjectName' + @LineFeed +
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
                    '    EXEC sp_executesql N''' + @PermissionLevel + ' ' + @PermissionName + ' ON OBJECT::' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName) +' to ' + QUOTENAME(@Grantee) + ' '
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
                    '    EXEC sp_executesql N''' + @PermissionLevel + ' ' + @PermissionName + ' ON OBJECT::' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName) +' to ' + QUOTENAME(@Grantee) + ' '
        SET @tsql = @tsql + 
                    ' AS ' + QUOTENAME(@PermAuthorization) + '''' + @LineFeed +
                    'END' + @LineFeed                    
        
    END 
    ELSE IF @PermissionLevel = 'REVOKE'
    BEGIN
        SET @tsql = @tsql +  
                    'if (@CurPermLevel is not null)' + @LineFeed +
                    'BEGIN' + @LineFeed +
                    '    EXEC sp_executesql N''' + @PermissionLevel + ' ' + @PermissionName + ' ON OBJECT::' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName) +' FROM ' + QUOTENAME(@Grantee) + ' AS ' + QUOTENAME(@PermAuthorization) + '''' + @LineFeed +
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

PRINT '    Function [security].[getOnUserObjectPermissionAssignmentStatement] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 