/*requires main.sql*/

/**
    Creation of the [Reporting] schema
  ==================================================================================
    DESCRIPTION
		This script creates the [Reporting] schema if it does not exist.
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
PRINT 'SCHEMA [Reporting] CREATION'

IF  NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Reporting')
BEGIN	
    DECLARE @SQL VARCHAR(MAX);
    SET @SQL = 'CREATE SCHEMA [Reporting] AUTHORIZATION [dbo]'
    EXEC (@SQL)
    
	PRINT '   SCHEMA [Reporting] created.'
END
ELSE
	PRINT '   SCHEMA [Reporting] already exists.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 