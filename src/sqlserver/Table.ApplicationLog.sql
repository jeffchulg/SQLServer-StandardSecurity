/*requires Schema.Security.sql*/
/**
    Creation of an application log table
*/
/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[ApplicationLog] table.
		an application log table

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
    16/04/2014  Jefferson Elias     Creation
    23/04/2014  Jefferson Elias     VERSION 0.1.0
    --------------------------------------------------------------------------------
	25/11/2014	Jefferson Elias		Date columns transformed to datetime.
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [security].[ApplicationLog] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[ApplicationLog]') AND type in (N'U'))
BEGIN
    CREATE TABLE [security].[ApplicationLog](
        [runid]         [numeric](20, 0) 				NOT NULL,
        [entryid]       [numeric](20, 0) IDENTITY(1,1) 	NOT NULL,
        [moment]        [datetime]   					NOT NULL,
        [program]       [varchar](256) 					NOT NULL,
        [loglevel]      [varchar](8) 					NOT NULL,
        [logmessage]    [varchar](max) 					NOT NULL
    ) ON [PRIMARY]
	
	PRINT '    Table [security].[ApplicationLog] created.'
END
ELSE
BEGIN
    IF EXISTS( 
	    SELECT 1 
		FROM  sys.columns 
        WHERE Name = 'moment' and Object_ID = Object_ID(N'[security].[ApplicationLog]') and system_type_id = 40
    )
	BEGIN
	    execute sp_executesql N'ALTER TABLE [security].[ApplicationLog] ALTER COLUMN [moment] datetime not null'
		PRINT '    Column moment from [security].[ApplicationLog] modified from date to datetime.'
	END
END
GO


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 