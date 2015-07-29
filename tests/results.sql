/*requires main.sql */
/*requires Tests.Start.sql*/
/*requires Tests.End.sql*/
/*requires cleanups.sql*/
/*requires Cleanup.SQLMappingsCreation.sql*/
/*requires Cleanup.DatabaseSchemas.sql*/
/*requires Cleanup.LoginCreation.sql*/
/*requires Cleanup.ContactCreation.sql*/



-- =========================================================================================================

PRINT ''
PRINT ''
PRINT '-------------------------------------------------------'

DECLARE @TestCount BIGINT ;
DECLARE @SkippedTestCount BIGINT ;
SELECT @TestCount = count(*) 
from $(TestingSchema).testResults 

SELECT @SkippedTestCount = count(*)
FROM $(TestingSchema).testResults
WHERE TestResult Collate French_CI_AI = 'SKIPPED' Collate French_CI_AI

if(@SkippedTestCount > 0)
BEGIN 
    PRINT CONVERT(VARCHAR,@SkippedTestCount)  + ' tests were skipped.';
END 
    
if @ErrorCount = 0 
BEGIN 
    PRINT CONVERT(VARCHAR,@TestCount - @SkippedTestCount) + ' / ' + CONVERT(VARCHAR,@TestCount) + ' tests ended successfully.';    
END 
ELSE 
BEGIN 
    PRINT CONVERT(VARCHAR,@TestCount - @SkippedTestCount - @ErrorCount) + ' / ' + CONVERT(VARCHAR,@TestCount) + ' tests ended successfully.';
    PRINT CONVERT(VARCHAR,@ErrorCount) + ' / ' + CONVERT(VARCHAR,@TestCount) + ' tests failed.';
    PRINT 'Please, review code to ensure everything is OK and maybe check the tests...';
END 


PRINT '-------------------------------------------------------'
PRINT ''
PRINT ''

if(OBJECT_ID('$(TestingSchema).testResults') is not null)
BEGIN
    execute sp_executesql N'DROP TABLE $(TestingSchema).testResults';
END 