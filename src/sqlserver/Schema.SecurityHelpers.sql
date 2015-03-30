/**
    Creation of the [SecurityHelpers] schema
  ==================================================================================
    DESCRIPTION
		This script creates the [SecurityHelpers] schema if it does not exist.
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
PRINT 'SCHEMA [SecurityHelpers] CREATION'

IF  NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'SecurityHelpers')
BEGIN	
    DECLARE @SQL VARCHAR(MAX);
    SET @SQL = 'CREATE SCHEMA [SecurityHelpers] AUTHORIZATION [dbo]'
    EXEC (@SQL)
    
	PRINT '   SCHEMA [SecurityHelpers] created.'
END
ELSE
	PRINT '   SCHEMA [SecurityHelpers] already exists.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 