/*requires ..\main.sql*/

PRINT 'Creating temporary table in which tests results will be stored';

IF(OBJECT_ID('$(TestingSchema).testResults') is not null)
	DROP TABLE $(TestingSchema).testResults

CREATE TABLE $(TestingSchema).testResults (
    TestID          BIGINT          NOT NULL ,
	Feature         VARCHAR(1024)   NOT NULL,
    TestName        VARCHAR(1024)   NOT NULL ,
    TestDescription NVARCHAR(MAX),
    TestResult      VARCHAR(16)     NOT NULL,
    ErrorMessage    NVARCHAR(MAX)
);
