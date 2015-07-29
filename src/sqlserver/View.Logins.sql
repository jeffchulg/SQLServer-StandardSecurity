/*requires Schema.Security.sql*/
/*requires Table.SQLLogins.sql*/
/*requires Table.Contacts.sql*/
/*requires Table.SQLMappings.sql*/

/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[logins] view that lists active logins

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
    24/12/2014  Jefferson Elias     Version 0.1.0
    --------------------------------------------------------------------------------
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'View [security].[logins] Creation'

DECLARE @SQL VARCHAR(MAX)
IF  NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[security].[logins]'))
BEGIN
    SET @SQL =  'CREATE view [security].[logins]
                AS
                select ''Not implemented'' as Col1'
    EXEC (@SQL)
	PRINT '    View [security].[logins] created.'
END

SET @SQL = 'ALTER view [security].[logins]
                AS
                 select
                    c.[Name],
                    c.[Job],
                    c.[Department],
                    c.[AuthMode],
                    l.[ServerName],
                    l.[SQLLogin],
                    m.DbName,
					m.DbUserName,
                    m.DefaultSchema,
                    c.isActive,
                    m.isLocked
                from [security].[Contacts] c
                    inner join [Security].[SQLlogins] l
                        on c.SQLLogin = l.SQLLogin
                    inner join [security].[SQLMappings] m
						on l.SqlLogin   = m.SqlLogin
					  and  l.ServerName = m.ServerName
				where m.isDefaultDb = 1'
EXEC (@SQL)
PRINT '    View [security].[logins] altered.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 