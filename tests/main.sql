set :SolutionName "Security Manager" 
set :DomainName   "CHULg"
set :DomainUser1  "SAI_Db"
set :DomainUser2  "c168350"

/*

Find and replace : 

${SolutionName} "Security Manager" 
${DomainName}   "CHULg"
${DomainUser1}  "SAI_Db"
${DomainUser2}  "c168350"

*/

SET NOCOUNT ON;

DECLARE @TestID             BIGINT ;
DECLARE @TestName           VARCHAR(1024);
DECLARE @TestDescription    NVARCHAR(MAX);
DECLARE @TestResult         VARCHAR(16);
DECLARE @ErrorMessage       NVARCHAR(MAX);
DECLARE @tsql               NVARCHAR(MAX);
DECLARE @LineFeed           VARCHAR(10) ;
DECLARE @ErrorCount         BIGINT ;
DECLARE @ProcedureName      VARCHAR(128) ;
DECLARE @CreationWasOK      BIT ;

SET @LineFeed = CHAR(13) + CHAR(10);
SET @ErrorCount = 0;

PRINT 'Starting testing for solution ${SolutionName}';
PRINT '' ;