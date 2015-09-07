/*requires main.sql*/

/**
    Creation of the [SqlGeneration] schema
  ==================================================================================
    DESCRIPTION
		This script creates the [SqlGeneration] schema if it does not exist.
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
PRINT 'SCHEMA [SqlGeneration] CREATION'

IF  NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'SqlGeneration')
BEGIN	
    DECLARE @SQL VARCHAR(MAX);
    SET @SQL = 'CREATE SCHEMA [SqlGeneration] AUTHORIZATION [dbo]'
    EXEC (@SQL)
    
	PRINT '   SCHEMA [SqlGeneration] created.'
END
ELSE
	PRINT '   SCHEMA [SqlGeneration] already exists.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 
