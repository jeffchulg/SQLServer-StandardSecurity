/*requires Schema.Security.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getSchemaCreationStatement] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getSchemaCreationStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getSchemaCreationStatement] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Function [security].[getSchemaCreationStatement] created.'
END
GO
ALTER Function [security].[getSchemaCreationStatement] (
    @DbName                         VARCHAR(64),
    @SchemaName                     VARCHAR(max),
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
    This function returns a string with the statements for a database schema creation 
    based on the given parameters.
 
  ARGUMENTS :
        @DbName                 name of the database in which we have some job to do 
        @SchemaName             name of the schema we need to create 
        @isActive               If set to 1, the assignment is active and must be done,
                                TODO if set to 0, this should be like a REVOKE !
        @NoHeader               If set to 1, no header will be displayed in the generated statements
        @NoDependencyCheckGen   if set to 1, no check for server name, database name and so on are generated
        @Debug                  If set to 1, then we are in debug mode        
 
  REQUIREMENTS:
  
  EXAMPLE USAGE :
      DECLARE @test VARCHAR(max)
      select @test = [security].[getSchemaCreationStatement] ('TESTING_ONLY_TESTING','test_jel',1,1,1,1)
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
                              'SET @dynamicDeclaration = QUOTENAME(''' + @SchemaName + ''')' + @LineFeed  

    SET @tsql = @DynDeclare  +
                'DECLARE @DbName      VARCHAR(64) = ''' + QUOTENAME(@DbName) + '''' + @LineFeed 

        
    SET @ErrorDbNotExists =  N'The given database ('+QUOTENAME(@DbName)+') does not exist'

    if @NoHeader = 0 
    BEGIN
        SET @tsql = @tsql + '/**' + @LineFeed +
                    ' * Database Schema Creation version ' + @versionNb + '.' + @LineFeed +
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
    DECLARE @SchemaAuthorization VARCHAR(64)    
    
    select 
        @SchemaAuthorization = ISNULL(ParamValue,ISNULL(DefaultValue,'dbo')) 
    from 
        security.ApplicationParams
    where 
        ParamName = 'SchemaAuthorization4Creation';
    
    SET @tsql = @tsql + 
                'DECLARE @SchemaOwner VARCHAR(64)' + @LineFeed +
                + @LineFeed +                
                'SELECT @SchemaOwner = QUOTENAME(SCHEMA_OWNER) COLLATE French_CI_AS' + @LineFeed +
                'FROM' + @LineFeed +
                '    ' + QUOTENAME(@DbName) + '.INFORMATION_SCHEMA.SCHEMATA' + @LineFeed +
                'WHERE' + @LineFeed +
                '    QUOTENAME(CATALOG_NAME) COLLATE French_CI_AS = @DbName COLLATE French_CI_AS' + @LineFeed + 
                'AND QUOTENAME(SCHEMA_NAME)  COLLATE French_CI_AS = @dynamicDeclaration COLLATE French_CI_AS' + @LineFeed +
                'IF (@SchemaOwner is null ) -- then the schema does not exist ' + @LineFeed  +
                'BEGIN' + @LineFeed  +                
                '    -- create it !' + @LineFeed  +
                '    EXEC (''USE ' + QUOTENAME(@DbName) + ' ; EXEC sp_executesql N''''CREATE SCHEMA [tdoc] AUTHORIZATION [dbo]'''''')' + @LineFeed +
                'END' + @LineFeed +
                'ELSE IF @SchemaOwner <> ''' + QUOTENAME(@SchemaAuthorization) + '''' + @LineFeed +
                'BEGIN' + @LineFeed +
                '    EXEC (''ALTER AUTHORIZATION on SCHEMA::' + QUOTENAME(@SchemaName) + ' TO ' + QUOTENAME(@SchemaAuthorization) + ''')' + @LineFeed +
                'END' + @LineFeed 
	
    SET @tsql = @tsql + @LineFeed  +
				'GO' + @LineFeed 
    RETURN @tsql
END
go	

PRINT '    Function [security].[getSchemaCreationStatement] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 