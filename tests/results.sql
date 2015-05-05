/*requires cleanups.sql */
/*requires Cleanup.LoginCreation.sql */
/*requires Cleanup.ContactCreation.sql */


-- =========================================================================================================

PRINT ''
PRINT ''
PRINT '-------------------------------------------------------'

DECLARE @TestCount BIGINT ;

SELECT @TestCount = count(*) 
from #TestResults 

if @ErrorCount = 0
BEGIN 
    PRINT 'All tests (' + CONVERT(VARCHAR,@TestCount) + ' / ' + CONVERT(VARCHAR,@TestCount) + ') ended successfully';
END 
ELSE 
BEGIN 
    PRINT CONVERT(VARCHAR,@ErrorCount) + ' / ' + CONVERT(VARCHAR,@TestCount) + ' tests were unsuccessful';
    PRINT 'Please, review code to ensure everything is OK and maybe check the tests...';
END 


PRINT '-------------------------------------------------------'
PRINT ''
PRINT ''

if(OBJECT_ID('tempdb..#testResults') is not null)
BEGIN
    execute sp_executesql N'DROP TABLE #testResults';
END 