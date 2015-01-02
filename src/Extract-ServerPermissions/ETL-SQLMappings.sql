/*
  ===================================================================================
   DESCRIPTION:
  
   ARGUMENTS :

  
   REQUIREMENTS:
  
	EXAMPLE USAGE :
   ==================================================================================
   BUGS:
  
     BUGID       Fixed   Description
     ==========  =====   ==========================================================
     ----------------------------------------------------------------------------------
   ==================================================================================
   NOTES:
   AUTHORS:
        .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
        .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
        .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)
  
   COMPANY: CHU Liege
   ==================================================================================
   Revision History
  
     Date        Nom         Description
     ==========  =====       ==========================================================
     30/12/2014  JEL         Version 0.0.1
     ----------------------------------------------------------------------------------
  ===================================================================================
*/

SET NOCOUNT ON;

-- global variables
DECLARE @InventoryServerName VARCHAR(256) = '<INVENTORY_SERVERNAME>' 
DECLARE @DatabaseToAnalyze   VARCHAR(64)  = '<ANALYSIS_DBNAME>'
DECLARE @Debug		BIT				 	  = <DEBUG>

-- handling global variable NULL value
if @Debug is null
BEGIN
	SET @Debug = 0
END

if @InventoryServerName is null or len(@InventoryServerName) = 0
BEGIN
	SET @InventoryServerName = @@SERVERNAME
/*	IF @Debug = 1
	BEGIN
		PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Server name set to ' + @InventoryServerName  
	END*/
END
/*
if @Debug = 1
BEGIN
	PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Preparing the extraction'
END
*/

if @DatabaseToAnalyze is null or len(@DatabaseToAnalyze) = 0
BEGIN
	SET @DatabaseToAnalyze = NULL ;
END 
-- now, let's get logins defined on @InventoryServerName

DECLARE getDatabases CURSOR LOCAL FOR
	select 
		name	as [DbName]
	from sys.databases
;

DECLARE @tsql_schemas  NVARCHAR(MAX) ;

DECLARE @LineFeed		VARCHAR(10);


-- initializing
SELECT 
	@LineFeed = CHAR(13) + CHAR(10)

/*
if @Debug = 1
BEGIN
	PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Creating temporary tables.'
END
*/
DECLARE @tsql NVARCHAR(MAX) = 
'if object_id(''tempdb..#insert_statements'') is not null' + @LineFeed +
'BEGIN' + @LineFeed +
'	DROP table #insert_statements' + @LineFeed +
'END'  ;

exec sp_executesql @tsql 

Create table #insert_statements (
	stmts varchar(4096)
);


-- now the miscellaneous variables used for MERGE statement generation

SET @tsql_schemas  = 	'if (OBJECT_ID(''tempdb..#tmpSQLMappings'') is not null)' + @LineFeed +
						'BEGIN' + @LineFeed +
						'    DROP TABLE #tmpSQLMappings'  + @LineFeed +
						'END;' + @LineFeed +
						'GO' + @LineFeed +
						'CREATE TABLE #tmpSQLMappings (' + @LineFeed +
						'	 ServerName 	VARCHAR(256) DEFAULT ''' + @@SERVERNAME + ''',' + @LineFeed +
						'    SQLLogin       VARCHAR(256) NOT NULL,' + @LineFeed +
						'    DbName    		VARCHAR(64) NOT NULL,' + @LineFeed +
						'    DbUserName		VARCHAR(128) NOT NULL,' + @LineFeed +
						'    DefaultSchema  VARCHAR(128) NOT NULL' + @LineFeed +
						'    isDefaultDb    BIT,' + @LineFeed;
						'    isLocked       BIT' + @LineFeed;
						');' + @LineFeed +
						'GO' + @LineFeed +
						'INSERT into #tmpSQLMappings (' + @LineFeed +
						'    SQLLogin,DbName,DbUserName,DefaultSchema,isDefaultDb,isLocked' + @LineFeed +
						')' + @LineFeed +
						'VALUES' + @LineFeed 


DECLARE @CurDbName  VARCHAR(64)

open  getDatabases

fetch getDatabases
into @CurDbName

while @@FETCH_STATUS = 0
BEGIN
	if @DatabaseToAnalyze is not null and @CurDbName <> @DatabaseToAnalyze 
	BEGIN
		-- carry on
		fetch getDatabases
		into @CurDbName
		CONTINUE ;
	END 
/*
	if @Debug = 1 
	BEGIN
		PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of database  '+ @CurDbName + '.'
	END 
*/	
	DECLARE @tsql_tmpSchemas NVARCHAR(MAX);
	
	SET @tsql_tmpSchemas =  'USE ' + QUOTENAME(@CurDbName) + @LineFeed +
							'DECLARE getSqlMappings CURSOR LOCAL FOR' + @LineFeed +
							'SELECT' + @LineFeed +
							'	ulogin.name as [SQLLogin],' + @LineFeed + 
							'	princ.name as [DbUserName],' + @LineFeed +
							'	princ.default_schema_name as [DefaultSchema],' + @LineFeed +
							'	case when DB_NAME() = ulogin.default_database_name then 1' + @LineFeed +
							'	else 0' + @LineFeed +
							'	end as [isDefaultDb],' + @LineFeed +
							'	0 as [isLocked]' + @LineFeed +
							'FROM  ' + @LineFeed + 
							'	sys.database_principals princ ' + @LineFeed + 
							'INNER JOIN ' + @LineFeed +
							'	sys.server_principals ulogin ' + @LineFeed +
							'on' + @LineFeed +
							'	princ.[sid] = ulogin.[sid]' + @LineFeed + 
							'where ' + @LineFeed +
							'	princ.type in (''U'',''S'')' + @LineFeed +
							'DECLARE @CurLogin VARCHAR(256);' + @LineFeed + 
							'DECLARE @CubDbUser VARCHAR(256);' + @LineFeed + 
							'DECLARE @CurSchema VARCHAR(256);' + @LineFeed + 
							'DECLARE @isDefaultDb BIT;' + @LineFeed + 
							'DECLARE @isLocked BIT;' + @LineFeed + 
							'DECLARE @iterNb BIGINT = 0' + @LineFeed +
							'SELECT @iterNb = count(*) from #insert_statements' + @LineFeed +
							'DECLARE @tsql VARCHAR(MAX) = ''''' + @LineFeed +
							'open getSqlMappings ;' + @LineFeed +
							'fetch getSqlMappings into @CurLogin,@CubDbUser,@CurSchema,@isDefaultDb,@isLocked ;' + @LineFeed +
							@LineFeed +
							'while @@FETCH_STATUS = 0' + @LineFeed + 
							'BEGIN' + @LineFeed +
							'    SET @iterNb = @iterNb + 1' + @LineFeed +							
							'    if @iterNb > 1' + @LineFeed + 
							'    BEGIN' + @LineFeed +
							'        SET @tsql  = '',''' + @LineFeed  +
							'    END' + @LineFeed +					
							'    ELSE' + @LineFeed +
							'        SET @tsql = ''''' + @LineFeed +
                            '    SET @tsql  += ''(@CurLogin,''''' + @CurDbName + ''''',@CubDbUser,@CurSchema,@isDefaultDb,@isLocked)''' + @LineFeed +
							'    insert into #insert_statements values (@tsql)' + @LineFeed +
							'    -- carry on' + @LineFeed +
							'    fetch getSqlMappings into @CurLogin,@CubDbUser,@CurSchema,@isDefaultDb,@isLocked ;' + @LineFeed +
							'END' + @LineFeed +
							+ @LineFeed +
							'close getSqlMappings ;' + @LineFeed +
							'deallocate getSqlMappings;'
/*
	if @Debug = 1 
	BEGIN
		PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Generated TSQL statement'+ @LineFeed + @tsql_tmpSchemas
	END 
*/	
	EXEC sp_executesql @tsql_tmpSchemas ;
	
	-- carry on
	fetch getDatabases
	into @CurDbName
END 
CLOSE getDatabases;
DEALLOCATE getDatabases;

-- here we have a set of lines saved in #insert_statements.
-- Let's now add it to @tsql_schemas 

DECLARE getStatements CURSOR LOCAL FOR 
	select stmts 
	from #insert_statements
;
open getStatements ;

DECLARE @vals VARCHAR(MAX);
fetch getStatements
into @vals;

DECLARE @hasValues BIT = 0;
while @@FETCH_STATUS = 0
BEGIN 
	SET @hasValues = 1;
	SET @tsql_schemas += '    ' + @vals + @LineFeed ;
	-- carry on
	fetch getStatements
	into @vals;

END 

close getStatements;
deallocate getStatements;

if @hasValues = 0
BEGIN
	if @DatabaseToAnalyze is null 
	BEGIN 
		DECLARE @msg NVARCHAR(1024) = 'The database has not been found on server ' + @DatabaseToAnalyze
		RAISERROR(@msg,16,0);
	END
	ELSE
		RAISERROR('No schemas defined on server. There could be a design error in this procedure...',16,0);
	return;
END

SET @tsql_schemas +=   @LineFeed + @LineFeed +
                        'MERGE [security].[SQLMappings] d' + @LineFeed +
						'USING (select * from #tmpSQLMappings) i' + @LineFeed +
						'ON' + @LineFeed +
						'    d.ServerName = i.ServerName' + @LineFeed +
						'AND d.DbName     = i.DbName' + @LineFeed +
						'AND d.SQLLogin   = i.SQLLogin' + @LineFeed +
						'WHEN MATCHED THEN' + @LineFeed + 
						'    UPDATE SET LastCollectionDate = GETDATE()' + @LineFeed +
						'WHEN NOT MATCHED BY TARGET THEN' + @LineFeed + 
						'    INSERT (ServerName,DbName,SchemaName,[Description],isActive,isGeneratedByCollection,LastCollectionDate)' + @LineFeed +
						'    VALUES (i.ServerName,i.DbName,i.SchemaName,''Created automatically by permission collector'',1,1,GETDATE())'  + @LineFeed +
/*
						'WHEN NOT MATCHED BY SOURCE THEN ' + @LineFeed + 
						'    UPDATE SET LastCollectionDate = NULL' + @LineFeed +
*/
						';'    


SET @tsql_schemas = 	@tsql_schemas + @LineFeed + 
						'GO' + @LineFeed;

DECLARE @tsql_RemoveOldData NVARCHAR(MAX) 

SET @tsql_RemoveOldData = 'update [security].[DatabaseSchemas]' + @LineFeed +
						  'set LastCollectionDate = NULL' + @LineFeed +
						  'where ServerName = ''' + @@SERVERNAME  + ''''

if @DatabaseToAnalyze is not null
BEGIN 
	SET @tsql_RemoveOldData += ' and DbName = ''' + @DatabaseToAnalyze + ''''
END


SELECT 'DATABASESCHEMAS',@tsql_RemoveOldData
UNION ALL 
SELECT 'DATABASESCHEMAS' , @tsql_schemas 
union all
SELECT null, 	'if (OBJECT_ID(''tempdb..#tmpDbSchemas'') is not null)' + @LineFeed +
				'BEGIN' + @LineFeed +
				'    DROP TABLE #tmpDbSchemas'  + @LineFeed +
				'END;' + @LineFeed +
				'GO' + @LineFeed 

SET @tsql = 
'if object_id(''tempdb..#insert_statements'') is not null' + @LineFeed +
'BEGIN' + @LineFeed +
'	DROP table #insert_statements' + @LineFeed +
'END'  ;

exec sp_executesql @tsql 