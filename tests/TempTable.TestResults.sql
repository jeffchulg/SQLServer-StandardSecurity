/*requires main.sql*/

PRINT 'Creating temporary table in which tests results will be stored';

IF(OBJECT_ID('tempdb..#testResults') is not null)
	DROP TABLE #testResults

CREATE TABLE #testResults (
    TestID          BIGINT          NOT NULL ,
    TestName        VARCHAR(1024)   NOT NULL ,
    TestDescription NVARCHAR(MAX),
    TestResult      VARCHAR(16)     NOT NULL,
    ErrorMessage    NVARCHAR(MAX)
);
