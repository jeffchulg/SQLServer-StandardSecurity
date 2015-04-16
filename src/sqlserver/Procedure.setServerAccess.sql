/*requires Schema.Security.sql*/
/*requires Table.Contacts.sql*/
/*requires Table.SQLlogins.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setServerAccess] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setServerAccess]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setServerAccess] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[setServerAccess] created.'
END
GO

ALTER PROCEDURE [security].[setServerAccess] (
    @ServerName  		varchar(512) = @@ServerName,    
    @ContactDepartment  VARCHAR(512) = NULL,
    @ContactsJob        VARCHAR(256) = NULL,
    @ContactName        VARCHAR(256) = NULL,    
    @ContactLogin       VARCHAR(128) = NULL,    
    @exactMatch         BIT          = 1,
    @isAllow            BIT          = 1,
    @isActive           BIT          = 1,
    @_noTmpTblDrop      BIT          = 0,
	@Debug		 		BIT		  	 = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
		Helper to set login access to a given server.
        It can (un)set for a set of contacts by department, job title, or just their name
  
   ARGUMENTS :
        @ServerName         name of the server from which the we want to work with
                            By default, it's the current server
        @ContactDepartment  name of the department for lookup
        @ContactsJob        job title for which we need to give access 
        @ContactName        name of the contact 
        @ContactLogin       login defined in the inventory for the contact 
        @exactMatch         If set to 1, use "=" for lookups
                            If set to 0, use "like" for lookups
        @isAllow            If set to 1, it adds the permission
                            TODO If set to 0, it marks the permission as to be revoked
        @isActive           If set to 1, the access is active
        
        @Debug              If set to 1, we are in debug mode
	 
  
    REQUIREMENTS:
  
	EXAMPLE USAGE :

    Exec [security].[setServerAccess] 
        @ServerName  		 = 'MyServer1',    
        @ContactDepartment   = 'MyCorp/IT Service',
        @ContactsJob         = NULL,
        @ContactName         = '%John%',    
        @exactMatch          = 0
    
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
    24/12/2014  Jefferson Elias     VERSION 0.1.0
    --------------------------------------------------------------------------------     
    26/12/2014  Jefferson Elias     Added parameter @ContactLogin for a lookup on 
                                    sql login in table Contacts 
                                    Added parameter for keeping #logins table
                                    for reuse
                                    Added parameter sanitization
                                    VERSION 0.1.1
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
        @exactMatch         = isnull(@exactMatch,1),
        @ServerName         = case when len(@ServerName)        = 0 THEN NULL else @ServerName END ,
        @ContactDepartment  = case when len(@ContactDepartment) = 0 THEN NULL else @ContactDepartment END ,
        @ContactsJob        = case when len(@ContactsJob)       = 0 THEN NULL else @ContactsJob END ,
        @ContactName        = case when len(@ContactName)       = 0 THEN NULL else @ContactName END ,
        @ContactLogin       = case when len(@ContactLogin)      = 0 THEN NULL else @ContactLogin END 
    
	/*
		Checking parameters
	*/
	
	if(@ServerName is null)
	BEGIN
		RAISERROR('No value set for @ServerName !',10,1)
	END		
	if(@ContactLogin is null and @ContactDepartment is null and @ContactsJob is null and @ContactName is null)
	BEGIN
		RAISERROR('No way to process : no parameter isn''t null !',10,1)
	END		
	              
	BEGIN TRY
        DECLARE @LookupOperator VARCHAR(4) = '='
    
        if @exactMatch = 0
            SET @LookupOperator = 'like'
        
        
        if OBJECT_ID('#logins' ) is not null
            DROP TABLE #logins ;
        
        CREATE table #logins ( ServerName varchar(512), name varchar(128), isActive BIT)
               
        SET @tsql = 'insert into #logins' + @LineFeed + 
                    '    SELECT @ServerName, [SQLLogin], [isActive]' + @LineFeed +
                    '    from [security].[Contacts]' + @LineFeed +
                    '    where ' + @LineFeed +
                    '        [SQLLogin]   ' + @LookupOperator + ' isnull(@curLogin,[SQLLogin])' + @LineFeed +
                    '    and [Department] ' + @LookupOperator + ' isnull(@curDep,[Department])' + @LineFeed +
                    '    and [Job]        ' + @LookupOperator + ' isnull(@curJob,[Job])' + @LineFeed +
                    '    and [Name]       ' + @LookupOperator + ' isnull(@curName,[Name])' + @LineFeed                 
        
        exec sp_executesql 
                @tsql ,
                N'@ServerName varchar(512),@curLogin VARCHAR(128) = NULL,@curDep VARCHAR(512),@CurJob VARCHAR(256),@CurName VARCHAR(256)', 
                @ServerName = @ServerName , 
                @curLogin = @ContactLogin,
                @CurDep = @ContactDepartment, 
                @CurJob = @ContactsJob , 
                @CurName = @ContactName
        
        DECLARE @PermissionLevel VARCHAR(6) = 'GRANT' ;
        if @isAllow <> 1
        BEGIN 
            SET @PermissionLevel = 'DENY';
        END 
        
        
        MERGE 
            [security].[SQLLogins] l
        using   
            #logins i
        on 
            l.[ServerName] = i.[ServerName]
        and l.[SQLLogin] = i.Name 
        WHEN NOT MATCHED THEN 
            insert (
                ServerName,
                SqlLogin,
                isActive,
                PermissionLevel
            )
            values (
                i.ServerName,
                i.Name,
                i.isActive,
                @PermissionLevel
            )
        WHEN MATCHED and PermissionLevel <> @PermissionLevel THEN   
            update set PermissionLevel = @PermissionLevel
        ;
        
        if @_noTmpTblDrop = 0 and OBJECT_ID('#logins' ) is not null
            DROP TABLE #logins ;
	END TRY
	
	BEGIN CATCH
		SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
		
        if @_noTmpTblDrop = 0 and OBJECT_ID('#logins' ) is not null
            DROP TABLE #logins ;
       
	END CATCH
END
GO

PRINT '    Procedure [security].[setServerAccess] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 	