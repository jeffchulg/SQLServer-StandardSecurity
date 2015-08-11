/*requires Schema.Security.sql*/
/*requires Table.security.Contacts.sql*/
/*requires Table.security.SQLLogins.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[PrepareAccessSettings] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[PrepareAccessSettings]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[PrepareAccessSettings] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[PrepareAccessSettings] created.'
END
GO

ALTER PROCEDURE [security].[PrepareAccessSettings] (
	@AccessLevel				VARCHAR(16)  = 'SERVER', -- Available 'SERVER','DATABASE','SCHEMA'
	@ServerName  		        VARCHAR(512) = @@ServerName,    
    @ContactDepartment          VARCHAR(512) = NULL,
    @ContactsJob                VARCHAR(256) = NULL,
    @ContactName                VARCHAR(256) = NULL,
    @ContactLogin               VARCHAR(128) = NULL,    
    @exactMatch                 BIT          = 1,    
    @withTmpTblDrop             BIT          = 0,    
	@Debug		 		        BIT		  	 = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:		
  
   ARGUMENTS :        	
		@ServerName         name of the server from which the we want to work with
                            By default, it's the current server
        @ContactDepartment  name of the department for lookup
        @ContactsJob        job title for which we need to give access 
        @ContactName        name of the contact 
        @ContactLogin       login defined in the inventory for the contact         
        @exactMatch         If set to 1, use "=" for lookups
                            If set to 0, use "like" for lookups
        @Debug              If set to 1, we are in debug mode
	 
  
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
   
    Date        Name                Description
    ==========  ================    ================================================
    11/08/2015  Jefferson Elias     Creation   	
    ----------------------------------------------------------------------------------	
  ===================================================================================
*/
BEGIN

	SET NOCOUNT ON;
    DECLARE @tsql             	nvarchar(max);
	DECLARE @LineFeed 		    VARCHAR(10);
	
	/* 
     * Sanitize input
     */
    
    SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10),
		@AccessLevel        = upper(@AccessLevel),
		@ServerName         = case when len(@ServerName)        = 0 THEN NULL else @ServerName END ,
		@exactMatch         = isnull(@exactMatch,1),        
        @ContactDepartment  = case when len(@ContactDepartment) = 0 THEN NULL else @ContactDepartment END ,
        @ContactsJob        = case when len(@ContactsJob)       = 0 THEN NULL else @ContactsJob END ,
        @ContactName        = case when len(@ContactName)       = 0 THEN NULL else @ContactName END ,
        @ContactLogin       = case when len(@ContactLogin)      = 0 THEN NULL else @ContactLogin END ;
	
	/*
		Checking parameters
	*/
	if(@ServerName is null)
	BEGIN
		RAISERROR('No value set for @ServerName !',10,1)
	END;
	
	if(@ContactLogin is null and @ContactDepartment is null and @ContactsJob is null and @ContactName is null)
	BEGIN
		RAISERROR('No way to process : no parameter isn''t null !',12,1);
	END	;	
	
	if(@AccessLevel not in ('SERVER','DATABASE','SCHEMA'))
	BEGIN
		RAISERROR('Unknown AccessLevel parameter',12,1);
	END	;
        
	if OBJECT_ID('##logins') is not null and @withTmpTblDrop = 1 
	BEGIN 
		if @Debug = 1
		BEGIN 
			PRINT '-- Dropping table ##logins';
		END  
		exec sp_executesql 'DROP TABLE ##logins' ;
	END 
	
	if OBJECT_ID('##logins' ) is null 
	BEGIN    

		if @Debug = 1
		BEGIN 
			PRINT '-- Performing lookup for contacts that correspond to criteria';
		END  ;
		
		DECLARE @LookupOperator VARCHAR(4) = '=';
	
		if @exactMatch = 0
			SET @LookupOperator = 'like';
			
		CREATE table ##logins ( ServerName varchar(512), name varchar(128), isActive BIT);
		
		if @AccessLevel = 'SERVER'
		BEGIN
			SET @tsql = 'insert into ##logins' + @LineFeed +
						'    SELECT @ServerName, [SQLLogin], [isActive]' + @LineFeed +
						'    from [security].[Contacts]' + @LineFeed +
						'    where ' + @LineFeed +
						'        [SQLLogin]   ' + @LookupOperator + ' isnull(@curLogin,[SQLLogin])' + @LineFeed +
						'    and [Department] ' + @LookupOperator + ' isnull(@curDep,[Department])' + @LineFeed +
						'    and [Job]        ' + @LookupOperator + ' isnull(@curJob,[Job])' + @LineFeed +
						'    and [Name]       ' + @LookupOperator + ' isnull(@curName,[Name])' + @LineFeed;
		END;
		
		IF @AccessLevel in ('DATABASE','SCHEMA')
		BEGIN 
			SET @tsql = 'insert into ##logins' + @LineFeed +
						'    SELECT ServerName, l.[SQLLogin], l.[isActive]' + @LineFeed +
						'    FROM [security].[SQLLogins] l' + @LineFeed +
						'    WHERE' + @LineFeed +
						'        l.ServerName = @ServerName' + @LineFeed +
						'    AND l.[SQLLogin] in (' + @LineFeed +
						'            SELECT [SQLLogin]' + @LineFeed +
						'            from [security].[Contacts] c' + @LineFeed +
						'            where ' + @LineFeed +
						'                c.[SQLLogin]   ' + @LookupOperator + ' isnull(@curLogin,[SQLLogin])' + @LineFeed +
						'            and c.[Department] ' + @LookupOperator + ' isnull(@curDep,[Department])' + @LineFeed +
						'            and c.[Job]        ' + @LookupOperator + ' isnull(@curJob,[Job])' + @LineFeed +
						'            and c.[Name]       ' + @LookupOperator + ' isnull(@curName,[Name])' + @LineFeed +
						'    )';
		END;

		
		if @Debug = 1
		BEGIN 
			PRINT '/* Query executed : ' + @tsql + '*/';
		END ;
		
		exec sp_executesql
				@tsql ,
				N'@ServerName varchar(512),@curLogin VARCHAR(128) = NULL,@curDep VARCHAR(512),@CurJob VARCHAR(256),@CurName VARCHAR(256)',
				@ServerName = @ServerName ,
				@curLogin = @ContactLogin,
				@CurDep = @ContactDepartment,
				@CurJob = @ContactsJob ,
				@CurName = @ContactName
	END ;
END
GO

PRINT '    Procedure [security].[PrepareAccessSettings] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''	