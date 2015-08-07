/*requires Schema.Security.sql*/
/*requires Table.security.ApplicationParams.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Function [security].[getStandardOnSchemaRoleName] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[getStandardOnSchemaRoleName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
    EXECUTE ('CREATE FUNCTION [security].[getStandardOnSchemaRoleName] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    varchar(50) ' +
            ') ' +
            'RETURNS VARCHAR(max) ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
			
	PRINT '    Function [security].[getStandardOnSchemaRoleName] created.'
END
GO

ALTER Function [security].[getStandardOnSchemaRoleName] (
    @SchemaName         varchar(64)  = NULL,
    @StandardRoleName   varchar(64)  = NULL
)
RETURNS VARCHAR(256)
AS
/*
 ===================================================================================
  DESCRIPTION:

 
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
    16/04/2015  JEL         Version 0.1.0
	
 ===================================================================================
*/
BEGIN

    DECLARE @SchemaRoleSep      VARCHAR(64)

    select @SchemaRoleSep = ParamValue
    from [security].[ApplicationParams]
    where ParamName = 'Separator4OnSchemaStandardRole' ;

    RETURN @SchemaName + @SchemaRoleSep + @StandardRoleName 
END
go	

PRINT '    Function [security].[getStandardOnSchemaRoleName] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 