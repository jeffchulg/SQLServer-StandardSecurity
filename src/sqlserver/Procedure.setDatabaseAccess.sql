/*requires Schema.Security.sql*/
/*requires Table.Contacts.sql*/
/*requires Table.SQLMappings.sql*/
/*requires Procedure.setServerAccess.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setDatabaseAccess] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setDatabaseAccess]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setDatabaseAccess] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[setDatabaseAccess] created.'
END
GO

ALTER PROCEDURE [security].[setDatabaseAccess] (
    @ServerName  		        VARCHAR(512) = @@ServerName,    
    @DbName                     VARCHAR(128) = DB_NAME,
    @ContactDepartment          VARCHAR(512) = NULL,
    @ContactsJob                VARCHAR(256) = NULL,
    @ContactName                VARCHAR(256) = NULL,
    @ContactLogin               VARCHAR(128) = NULL,        
    @DefaultSchema              VARCHAR(64)  = NULL,    
    @isDefaultDb                BIT          = 0,
    @withServerAccessCreation   BIT          = 0,
    @exactMatch                 BIT          = 1,
    @isAllow                    BIT          = 1,
    @isActive                   BIT          = 1,
	@Debug		 		        BIT		  	 = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
		Helper to give access to a given database.        
        It can (un)set for a set of contacts by department, job title, or just their name
        The database username that will be used is the same as the sql login
  
   ARGUMENTS :
        @ServerName         name of the server from which the we want to work with
                            By default, it's the current server
        @DbName             The name of the database to which give access 
                            By default, it's the current database name 
        @ContactDepartment  name of the department for lookup
        @ContactsJob        job title for which we need to give access 
        @ContactName        name of the contact 
        @ContactLogin       login defined in the inventory for the contact         
        @DefaultSchema      the default schema in @DbName which is assigned to the database user 
        @isDefaultDb        if set to 1, the given @DbName database will be set as default database 
                            for the logins on @ServerName server.
        @withServerAccessCreation 
                            if set to 1, this procedure will call [setServerAccess] to create the 
                            logins (if they don't exist) at the same time 
        @exactMatch         If set to 1, use "=" for lookups
                            If set to 0, use "like" for lookups
        @isAllow            If set to 1, it adds the permission
                            TODO If set to 0, it marks the permission as to be revoked
        @isActive           If set to 1, the access is active
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
    26/12/2014  Jefferson Elias     VERSION 0.1.1
    --------------------------------------------------------------------------------  
  ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    DECLARE @versionNb        	varchar(16) = '0.1.1';
    DECLARE @tsql             	nvarchar(max);
    DECLARE @LineFeed 		    VARCHAR(10);    
    
    /* 
     * Sanitize input
     */
    
    SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10),
        @isDefaultDb        = isnull(@isDefaultDb,0),
        @exactMatch         = isnull(@exactMatch,1),
        @ServerName         = case when len(@ServerName)        = 0 THEN NULL else @ServerName END ,
        @DbName             = case when len(@DbName)            = 0 THEN NULL else @DbName END ,
        @ContactDepartment  = case when len(@ContactDepartment) = 0 THEN NULL else @ContactDepartment END ,
        @ContactsJob        = case when len(@ContactsJob)       = 0 THEN NULL else @ContactsJob END ,
        @ContactName        = case when len(@ContactName)       = 0 THEN NULL else @ContactName END ,
        @ContactLogin       = case when len(@ContactLogin)      = 0 THEN NULL else @ContactLogin END ,
        @DefaultSchema      = case when len(@DefaultSchema)      = 0 THEN NULL else @DefaultSchema END 
        
    
	/*
		Checking parameters
	*/
	
	if(@ServerName is null)
	BEGIN
		RAISERROR('No value set for @ServerName !',10,1)
	END		
	if(@DbName is null)
	BEGIN
		RAISERROR('No value set for @DbName !',10,1)
	END	    
    if(@DefaultSchema is null)
	BEGIN
		RAISERROR('No value set for @DefaultSchema !',10,1)
	END	   
	if(@ContactLogin is null and @ContactDepartment is null and @ContactsJob is null and @ContactName is null)
	BEGIN
		RAISERROR('No way to process : no parameter isn''t null !',10,1)
	END		
	              
	BEGIN TRY
    
        if @withServerAccessCreation = 1 
        BEGIN     
            if @Debug = 1
            BEGIN 
                PRINT '-- set server access (to be sure that the server access is given'
            END            
            exec [security].[setServerAccess] 
                @ServerName         = @ServerName,
                @ContactLogin       = @ContactLogin,
                @ContactDepartment  = @ContactDepartment,
                @ContactsJob        = @ContactsJob ,
                @ContactName        = @ContactName,
                @exactMatch         = @exactMatch,
                @_noTmpTblDrop      = 1
        END 
        
        if OBJECT_ID('#logins' ) is null 
        -- there have been no setServerAccess call => we need to get a list of logins to use
        BEGIN    

            if @Debug = 1
            BEGIN 
                PRINT '-- Performing lookup for contacts that correspond to criteria'
            END  
        
            DECLARE @LookupOperator VARCHAR(4) = '='
        
            if @exactMatch = 0
                SET @LookupOperator = 'like'        
            CREATE table #logins ( ServerName varchar(512), name varchar(128), isActive BIT)
        
            SET @tsql = 'insert into #logins' + @LineFeed + 
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
                        '    )' 
            
            if @Debug = 1
            BEGIN 
                PRINT '/* Query executed : ' + @tsql + '*/'
            END 
            
            exec sp_executesql 
                    @tsql ,
                    N'@ServerName varchar(512),@curLogin VARCHAR(128) = NULL,@curDep VARCHAR(512),@CurJob VARCHAR(256),@CurName VARCHAR(256)', 
                    @ServerName = @ServerName , 
                    @curLogin = @ContactLogin,
                    @CurDep = @ContactDepartment, 
                    @CurJob = @ContactsJob , 
                    @CurName = @ContactName
        END
            
        if @isAllow = 1 
        BEGIN         
            --SELECT * from #logins
            if @Debug = 1
            BEGIN 
                PRINT '-- ALLOW mode - setups for 1) new mappings 2) default schema changes'
            END  
            MERGE 
                [security].[SQLMappings] m
            using   (
                select  ServerName, @DbName as DbName , Name as SQLLogin
                from #logins 
            ) i
            on 
                m.[ServerName]  = i.[ServerName]
            and m.[DbName]      = i.[DbName]
            and m.[SQLLogin]    = i.SQLLogin
            WHEN MATCHED THEN 
                update set 
                    DefaultSchema = @DefaultSchema
            WHEN NOT MATCHED THEN 
                insert (
                    ServerName,
                    SqlLogin,
                    DbName,
                    DbUserName,
                    DefaultSchema,
                    isDefaultDb
                )
                values (
                    i.ServerName,                        
                    i.SQLLogin,
                    i.DbName,
                    i.SQLLogin,
                    @DefaultSchema,
                    @isDefaultDb
                )
            ;
              
            if @Debug = 1
            BEGIN 
                PRINT '-- Default database management'
            END  
              
            /* one more thing to do is to consider @isDefaultDb
                when = 1 :
                    set isDefaultDb to 0 for those SQLMappings
                    that already have a default database set
                    It's considered as a change
                when = 0 : 
                    just set mappings to 0
            */
            
            DECLARE loginsToManage CURSOR LOCAL FOR 
                select Name as SQLLogin
                from #logins 
            ;

            DECLARE @CurLogin VARCHAR(128)
            
            OPEN loginsToManage;
                        
            FETCH NEXT 
            FROM loginsToManage into @CurLogin
            
            WHILE @@FETCH_STATUS = 0
            BEGIN                 
                if @isDefaultDb = 1
                BEGIN 
                    DECLARE @WrongDefaultDb VARCHAR(64)
                    select  
                        @WrongDefaultDb = DbName
                    from 
                        [security].[SQLMappings]
                    WHERE 
                        ServerName  = @ServerName
                    and SQLLogin    = @CurLogin
                    and isDefaultDb = 1
                    and DbName      <> @DbName                    
                    
                    -- unset the documented default db
                    if @WrongDefaultDb is not null 
                    BEGIN
                        if @Debug = 1
                        BEGIN 
                            PRINT '-- Database ' + QUOTENAME(@WrongDefaultDb) + ' is no longer the default database for user ' + QUOTENAME(@CurLogin)
                        END                      
                        update [security].[SQLMappings]
                        set 
                            isDefaultDb = 0
                        where 
                            ServerName  = @ServerName
                        and DbName      = @WrongDefaultDb
                        and SQLLogin    = @CurLogin                                    
                    END
                
                END    
                
                -- set the good default db
                update [security].[SQLMappings]
                set 
                    isDefaultDb = @isDefaultDb
                where 
                    ServerName  = @ServerName
                and DbName      = @DbName
                and SQLLogin    = @CurLogin            
                
                -- carry on
                FETCH NEXT 
                FROM loginsToManage into @CurLogin            
            END 
        END 
        ELSE 
            RAISERROR('Not yet implemented ! ',16,0)
	END TRY
	
	BEGIN CATCH
		SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
		
        if OBJECT_ID('#logins' ) is not null
            DROP TABLE #logins ;
        
		if CURSOR_STATUS('local','loginsToManage') >= 0 
		begin
			close loginsToManage
			deallocate loginsToManage 
		end
		
	END CATCH
END
GO

PRINT '    Procedure [security].[setDatabaseAccess] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 	