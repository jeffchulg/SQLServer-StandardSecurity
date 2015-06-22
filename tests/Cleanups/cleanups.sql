/*requires ..\main.sql*/


:setvar Feature "Cleanups"

-- =========================================================================================================

PRINT ''

if($(NoCleanups) = 0) 
BEGIN 
    PRINT 'Now cleaning up'
    
    if(OBJECT_ID('[security].[$(GeneratedScriptBackupTable)]') is not null)
    BEGIN
        execute sp_executesql N'DROP TABLE [security].[$(GeneratedScriptBackupTable)]';
    END 

END 
ELSE
BEGIN 
    PRINT 'Skipping cleanup (check script parameters)'
END 
 
PRINT ''

DECLARE @SQLLogin VARCHAR(512) ;

SELECT @TestID = MAX(testID) from $(TestingSchema).testResults;

if(@TestID is NULL)
	SET @TestID = 1;