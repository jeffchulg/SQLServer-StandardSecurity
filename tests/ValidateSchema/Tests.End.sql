/*requires Tests.Start.sql*/
/*requires Test.Field.DbName.sql*/

PRINT ''
PRINT ''
PRINT ''
PRINT ''
PRINT ''

DECLARE @ResultsInErrorCnt BIGINT ;
SELECT @ResultsInErrorCnt = count(*) FROM $(TestingSchema).testResults WHERE Feature = '$(Feature)' and TestResult = 'FAILURE'

if(@ResultsInErrorCnt > 0)
BEGIN
	DECLARE @textMsg VARCHAR(2048);
	SET @textMsg = CONVERT(VARCHAR,@ResultsInErrorCnt) + ' errors found for the $(Feature) feature' ;
	RAISERROR(@textMsg,12,1);
END 
GO
