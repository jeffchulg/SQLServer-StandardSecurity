/*requires main.sql*/

/**
    Creation of the [SecurityDoc] schema
  ==================================================================================
    DESCRIPTION
		This script creates the [SecurityDoc] schema if it does not exist.
  ==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================
    ----------------------------------------------------------------------------------
  ==================================================================================
  Notes :
 
        Exemples :
        -------
 
  ==================================================================================
  Revision history
 
    Date        Name                Description
    ==========  ================    ================================================
    24/12/2014  Jefferson Elias     VERSION 1.0.0
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'SCHEMA [SecurityDoc] CREATION'

IF  NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'SecurityDoc')
BEGIN	
    DECLARE @SQL VARCHAR(MAX);
    SET @SQL = 'CREATE SCHEMA [SecurityDoc] AUTHORIZATION [dbo]'
    EXEC (@SQL)
    
	PRINT '   SCHEMA [SecurityDoc] created.'
END
ELSE
	PRINT '   SCHEMA [SecurityDoc] already exists.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 