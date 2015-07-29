/*requires Schema.Security.sql*/
/*requires Table.Contacts.sql*/
/*requires Table.SQLLogins.sql*/
/*requires Table.SQLMappings.sql*/
/*requires Table.DatabaseSchemas.sql*/
/*requires Table.DatabaseRoles.sql*/
/*requires Table.DatabaseRoleMembers.sql*/
/*requires Table.StandardOnSchemaRoles.sql*/
/*requires Procedure.setServerAccess.sql*/
/*requires Function.security.getStandardOnSchemaRoleName.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[setSchemaAccess] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setSchemaAccess]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[setSchemaAccess] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure [security].[setSchemaAccess] created.'
END
GO

ALTER PROCEDURE [security].[setSchemaAccess] (
    @ServerName  		        VARCHAR(512) = @@ServerName,    
    @DbName                     VARCHAR(128) = DB_NAME,
    @SchemaName                 VARCHAR(128) ,
    @StandardRoleName           VARCHAR(128) , 
    @ContactDepartment          VARCHAR(512) = NULL,
    @ContactsJob                VARCHAR(256) = NULL,
    @ContactName                VARCHAR(256) = NULL,
    @ContactLogin               VARCHAR(128) = NULL,
    @Reason                     VARCHAR(MAX) ,
    @exactMatch                 BIT          = 1,
    @isAllow                    BIT          = 1,
    @isActive                   BIT          = 1,
	@Debug		 		        BIT		  	 = 0
)
AS
/*
  ===================================================================================
   DESCRIPTION:
		Helper to give access to a given database schema.        
        It can (un)set for a set of contacts by department, job title, or just their name
        The database username that will be used is the same as the sql login
  
   ARGUMENTS :
        @ServerName         name of the server from which the we want to work with
                            By default, it's the current server
        @DbName             The name of the database to which give access 
                            By default, it's the current database name 
        @SchemaName         name of the schema in @DbName on which set a standard role
        @StandardRoleName   role to assign to contacts 
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
    16/04/2015  Jefferson Elias     VERSION 0.1.1
    --------------------------------------------------------------------------------  
  ===================================================================================
*/
BEGIN

    SET NOCOUNT ON;
    DECLARE @versionNb        	varchar(16) = '0.1.0';
    DECLARE @tsql             	nvarchar(max);
    DECLARE @LineFeed 		    VARCHAR(10);    
    
    /* 
     * Sanitize input
     */
    
    SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10),        
        @exactMatch         = isnull(@exactMatch,1),
        @ServerName         = case when len(@ServerName)        = 0 THEN NULL else @ServerName END ,
        @DbName             = case when len(@DbName)            = 0 THEN NULL else @DbName END ,
        @SchemaName         = case when len(@SchemaName)        = 0 THEN NULL else @SchemaName END ,
        @StandardRoleName   = case when len(@StandardRoleName)  = 0 THEN NULL else @StandardRoleName END ,
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
	if(@DbName is null)
	BEGIN
		RAISERROR('No value set for @DbName !',10,1)
	END	          
	if(@ContactLogin is null and @ContactDepartment is null and @ContactsJob is null and @ContactName is null)
	BEGIN
		RAISERROR('No way to process : no parameter isn''t null !',10,1)
	END	

    if(not EXISTS (select 1 from security.StandardOnSchemaRoles where RoleName = @StandardRoleName))
    BEGIN 
        RAISERROR('Parameter StandardRoleName is not a valid standard role',10,1)
    END 
    
    if( not EXISTS (select 1 from security.DatabaseSchemas where ServerName = @ServerName and DbName = @DbName and SchemaName = @SchemaName))
    BEGIN 
        RAISERROR('Provided schema does not exist',10,1)
    END     
    
    DECLARE @StandardOnSchemaRoleName VARCHAR(256) = security.getStandardOnSchemaRoleName(@SchemaName,@StandardRoleName);

    if( not EXISTS (select 1 from security.DatabaseRoles where ServerName = @ServerName and DbName = @DbName and RoleName = @StandardOnSchemaRoleName and isStandard = 1))
    BEGIN 
        RAISERROR('Generated Standard role for the provided schema does not exist',10,1)
    END 
	
    BEGIN TRY
        
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
                        '    SELECT l.ServerName, l.[SQLLogin], l.[isActive]' + @LineFeed +
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
             
        MERGE 
            [security].[DatabaseRoleMembers] m
            using   (
                select l.ServerName, @DbName as DbName , @StandardOnSchemaRoleName as RoleName, sm.DbUserName as MemberName, 0 as MemberIsRole
                from 
                    #logins l
                inner join 
                    [security].[SQLMappings] sm
                on  
                    sm.ServerName   = l.ServerName 
                and sm.DbName       = @DbName 
                and sm.SqlLogin     = l.Name
            ) i
            on 
                m.[ServerName]      = i.[ServerName]
            and m.[DbName]          = i.[DbName]
            and m.[RoleName]        = i.[RoleName]
            and m.[MemberName]      = i.[MemberName]
            and m.[MemberIsRole]    = i.[MemberIsRole]
            WHEN MATCHED THEN 
                update set 
                    PermissionLevel = CASE WHEN @isAllow = 1 THEN 'GRANT' ELSE 'REVOKE' END,
                    --CASE WHEN @Reason IS NULL THEN 'Added during setSchemaAccess call' ELSE @Reason
                    isActive = @isActive
            WHEN NOT MATCHED THEN 
                insert (
                    ServerName,
                    DbName,
                    RoleName,
                    MemberName,
                    MemberIsRole,
                    PermissionLevel,
                    Reason,
                    isActive
                )
                values (
                    i.ServerName,                        
                    i.DbName,
                    i.RoleName,
                    i.MemberName,
                    i.MemberIsRole,
                    CASE WHEN @isAllow = 1 THEN 'GRANT' ELSE 'REVOKE' END ,
                    CASE WHEN @Reason IS NULL THEN 'Added during setSchemaAccess call' ELSE @Reason END ,
                    @isActive
                )
            ;
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

PRINT '    Procedure [security].[setSchemaAccess] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 	