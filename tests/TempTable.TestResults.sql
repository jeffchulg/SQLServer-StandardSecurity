/*requires main.sql */

PRINT 'Creating temporary table in which tests results will be stored';

CREATE TABLE #testResults (
    TestID          BIGINT          NOT NULL ,
    TestName        VARCHAR(1024)   NOT NULL ,
    TestDescription NVARCHAR(MAX),
    TestResult      VARCHAR(16)     NOT NULL,
    ErrorMessage    NVARCHAR(MAX)
);
