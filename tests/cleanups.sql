/*requires main.sql */
/*requires TempTable.TestResults.sql */
/*requires TempTable.TestContacts.sql */
/*requires Tests.ContactCreation.sql */
/*requires Tests.LoginCreation.sql */
/*requires Tests.SQLMappingsCreation.sql */

-- =========================================================================================================

PRINT ''
PRINT 'Now cleaning up'
PRINT ''

DECLARE @SQLLogin VARCHAR(512) ;