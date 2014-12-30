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
DECLARE @Debug		BIT				 	  = '<DEBUG>'

-- handling global variable NULL value
if @Debug is null
BEGIN
	SET @Debug = 0
END

if @InventoryServerName is null
BEGIN
	SET @InventoryServerName = @@SERVERNAME
	IF @Debug = 1
	BEGIN
		PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Server name set to ' + @InventoryServerName  
	END
END

if @Debug = 1
BEGIN
	PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Preparing the extraction'
END

-- now, let's get logins defined on @InventoryServerName

DECLARE getlogins CURSOR LOCAL FOR
	select 
		name	as [SQLLogin] ,
		'N/A'	as [Name],
		'N/A'	as [Job],
		case 
			when is_disabled = 1 then 0 
			when is_disabled = 0 then 1 
		end		as [isActive],
		'N/A'   as [Department],
		Case	
			when type = 'S' then 'SQLSRVR'	
			when type = 'U' then 'WINDOWS'
		end     as [AuthMode]
	from sys.server_principals
	where type in ('S','U');

-- will containt MERGE statement for [security].[Contacts] table provisionning 
DECLARE @tsql_contacts  VARCHAR(MAX) ;
-- will containt MERGE statement for [security].[SQLLogins] table provisionning 
DECLARE @tsql_sqllogins VARCHAR(MAX) ;
DECLARE @LineFeed		VARCHAR(10);


-- initializing
SELECT 
	@LineFeed = CHAR(13) + CHAR(10)


-- now the miscellaneous variables used for MERGE statement generation
DECLARE @LoginName  VARCHAR(128)
DECLARE @Name		VARCHAR(256)
DECLARE @Job		VARCHAR(256)
DECLARE @Department VARCHAR(512)
DECLARE @isActive   BIT 
DECLARE @AuthMode   VARCHAR(8)

SET @tsql_contacts  = 'WITH cte_logins AS (' + @LineFeed 
SET @tsql_sqllogins = @tsql_contacts


DECLARE @iterNb BIGINT = 0
open  getlogins

fetch getlogins
into @LoginName, @Name,@Job,@isActive,@Department,@AuthMode

while @@FETCH_STATUS = 0
BEGIN
	SET @iterNb = @iterNb + 1
	if @iterNb > 1 
	BEGIN 
		SET @tsql_contacts  += 'UNION ALL ' 
		SET @tsql_sqllogins += 'UNION ALL ' 
	END 
	
	SET @tsql_contacts += 'SELECT' + @LineFeed + 
						  '    ''' + @LoginName + ''' as SQLLogin,' + @LineFeed + 
						  '    ''' + @Name + ''' as [Name],' + @LineFeed +
						  '    ''' + @Department + ''' as [Department],' + @LineFeed +
						  '    ''' + @Job + ''' as [Job],' + @LineFeed +					
						  '    ''' + @AuthMode + ''' as [AuthMode]' + @LineFeed 
						  
	SET @tsql_sqllogins +=  'SELECT' + @LineFeed +
							'    ''' + @LoginName + ''' as SQLLogin,' + @LineFeed +
							'    @@SERVERNAME as ServerName,' + @LineFeed + 
							CAST(@isActive AS VARCHAR) + ' as [isActive],' + @LineFeed
	-- carry on
	fetch getlogins
	into @LoginName, @Name,@Job,@isActive,@Department,@AuthMode
END 
CLOSE getLogins;
DEALLOCATE getLogins;

if @iterNb = 0
BEGIN
	RAISERROR('No logins defined. There could be a design error in this procedure...',16,0);
	return;
END

SET @tsql_contacts +=   ')' + @LineFeed +
                        'MERGE [security].[contacts] d' + @LineFeed +
						'USING cte_logins i' + @LineFeed +
						'ON' + @LineFeed +
						'    d.SqlLogin = i.SQLLogin' + @LineFeed +
						'WHEN MATCHED THEN' + @LineFeed + 
						'    UPDATE SET LastCollectionDate = GETDATE()' + @LineFeed +
						'WHEN NOT MATCHED BY TARGET THEN' + @LineFeed + 
						'    INSERT (SQLLogin,Name,Job,isActive,Department,AuthMode,isGeneratedByCollection,LastCollectionDate)' + @LineFeed +
						'    VALUES (i.SQLLogin,i.Name,i.Job,1,i.Department, i.AuthMode,1,GETDATE())'  + @LineFeed +
						';'    

if @InventoryServerName = @@SERVERNAME and exists (SELECT OBJECT_ID('[security].[Contacts]')) and exists (SELECT OBJECT_ID('[security].[SQLLogins]'))
BEGIN 
	PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - INFO - Running commands as local server it is the security inventory '
	
	exec sp_executesql @tsql_contacts 
END 
ELSE
BEGIN 
	PRINT '-- ' + CONVERT(VARCHAR,GETDATE()) + ' - INFO - Those commands are expected to be run on server : ' + @InventoryServerName
	PRINT ''
	PRINT '-- ------ Contact MERGE Statement -------'
	PRINT '-- --------------------------------------'
	SELECT @tsql_contacts
	
	PRINT '-- ------ SQLLogins MERGE Statement -----'
	PRINT '-- --------------------------------------'
	SELECT @tsql_sqllogins
END 
