/*requires Tests.Start.sql*/

SET @TestID = 1 ;
SET @TestName = 'ValidateSchema-DbName fields';
SET @TestDescription = 'Ensure DbName fields are at least VARCHAR(128)';
SET @TestResult = 'SUCCESS';
SET @ErrorMessage = NULL;


PRINT 'Running test #' + CONVERT(VARCHAR,@TestID) + '(' + @TestName + ')';

DECLARE WrongTypeObjects CURSOR LOCAL FOR 
	select 
		OBJECT_SCHEMA_NAME(object_id) as SchemaName, 
		OBJECT_NAME(object_id)        as ObjectName,   
		(select name from sys.types t where t.system_type_id = ac.system_type_id) as ObjectType,
		max_length  
	from sys.all_columns ac
	where OBJECT_SCHEMA_NAME(object_id) in ('security','inventory')
	and  name = 'DbName' 
	and (
			ac.system_type_id <> (
				select system_type_id from sys.types t where t.name = 'varchar' 
			)
		or  ac.max_length < 128 
	) ;
DECLARE @SchemaName SYSNAME;
DECLARE @ObjectName SYSNAME;
DECLARE @ObjectType SYSNAME;
DECLARE @max_length BIGINT;

OPEN WrongTypeObjects;
FETCH NEXT FROM WrongTypeObjects INTO @SchemaName,@ObjectName,@ObjectType,@max_length;

WHILE @@FETCH_STATUS = 0
BEGIN 

	SET @ErrorCount = @ErrorCount + 1
    SET @TestResult = 'FAILURE';
    SET @ErrorMessage = ISNULL(@ErrorMessage ,'')+ 'Table ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName) + ' not OK ' + '[TYPE=' + @ObjectType + ' | LENGTH=' + CONVERT(VARCHAR,@max_length) + ']' + @LineFeed;

	FETCH NEXT FROM WrongTypeObjects INTO @SchemaName,@ObjectName,@ObjectType,@max_length;
END ;

if(LEN(@ErrorMessage) > 0)
BEGIN 
	PRINT '    > ERROR ' + REPLACE(REPLACE(@ErrorMessage,CHAR(10),' ') , CHAR(13) , ' ')		;	
END
      
BEGIN TRAN
INSERT into $(TestingSchema).testResults values (@TestID ,'$(Feature)', @TestName , @TestDescription, @TestResult , @ErrorMessage );
COMMIT;

-- ---------------------------------------------------------------------------------------------------------

