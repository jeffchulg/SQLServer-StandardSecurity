/*requires Schema.SecurityHelpers.sql*/
/*requires Schema.Security.sql*/
/*requires Table.security.Contacts.sql*/
/*requires Table.security.SQLMappings.sql*/
/*requires Table.security.DatabaseRoles.sql*/
/*requires Table.security.DatabaseRoleMembers.sql*/
/*requires Procedure.security.setDatabaseAccess.sql*/


PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [SecurityHelpers].[setSQLAgentUserPermission] Creation'

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[SecurityHelpers].[setSQLAgentUserPermission]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [SecurityHelpers].[setSQLAgentUserPermission] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName    	 varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
	PRINT '    Procedure created.'
END
GO

ALTER PROCEDURE [SecurityHelpers].[setSQLAgentUserPermission] (
    @ServerName  		        VARCHAR(512) = @@ServerName,    
    @GranteeRoleName            VARCHAR(128) = NULL, -- if set, no contact lookup 
    @ContactDepartment          VARCHAR(512) = NULL,
    @ContactsJob                VARCHAR(256) = NULL,
    @ContactName                VARCHAR(256) = NULL,
    @ContactLogin               VARCHAR(128) = NULL,        
    @withDatabaseAccessCreation BIT          = 1,
    @exactMatch                 BIT          = 1,
    @GrantedLevel               VARCHAR(16)  = 'USER', -- other : 'READER','OPERATOR'
    @isAllow                    BIT          = 1,
    @isActive                   BIT          = 1,
    @_noTmpTblDrop              BIT          = 0,
	@Debug		 		        BIT		  	 = 0
)
AS
BEGIN 

    SET NOCOUNT ON;
    DECLARE @DbName             VARCHAR(128);
    DECLARE @tsql             	nvarchar(max);
    DECLARE @LineFeed 		    VARCHAR(10);    
    DECLARE @LookupOperator     VARCHAR(4) ;
    DECLARE @SQLAgentRoleName   VARCHAR(128);
    DECLARE @PermissionLevel    VARCHAR(16);
    

    SET @LookupOperator  = '=';
    SET @PermissionLevel = 'GRANT'
    
    if @exactMatch = 0
        SET @LookupOperator = 'like';
    
    /* 
     * Sanitize input
     */
    
    SELECT 
		@LineFeed 			= CHAR(13) + CHAR(10),
        @exactMatch         = isnull(@exactMatch,1),
        @ServerName         = case when len(@ServerName)        = 0 THEN NULL else @ServerName END ,
        @DbName             = 'msdb' ,
        @ContactDepartment  = case when len(@ContactDepartment) = 0 THEN NULL else @ContactDepartment END ,
        @ContactsJob        = case when len(@ContactsJob)       = 0 THEN NULL else @ContactsJob END ,
        @ContactName        = case when len(@ContactName)       = 0 THEN NULL else @ContactName END ,
        @ContactLogin       = case when len(@ContactLogin)      = 0 THEN NULL else @ContactLogin END ,
        @GranteeRoleName    = case when len(@GranteeRoleName)   = 0 THEN NULL else @GranteeRoleName END 
    
    if @GranteeRoleName is not null 
    BEGIN 
        if(@Debug = 1) 
        BEGIN 
            PRINT '-- Parameter @GranteeRoleName is not empty => ignoring any information related to Contact'
        END 
        
        SET @ContactDepartment = NULL;
        SET @ContactLogin       = NULL;
        SET @ContactName        = NULL;
        SET @ContactsJob        = NULL ;
    END 
    
    if @isAllow = 0
        SET @PermissionLevel = 'REVOKE'
    
	/*
		Checking parameters
	*/
	
	if(@ServerName is null)
	BEGIN
		RAISERROR('No value set for @ServerName !',12,1);
        RETURN;
	END			        
    
    if(@ContactLogin is null and @ContactDepartment is null and @ContactsJob is null and @ContactName is null and @GranteeRoleName is null )
	BEGIN
		RAISERROR('No way to process : no parameter isn''t null !',12,1);
        RETURN;
	END		
    
    if(@GrantedLevel = 'USER')
    BEGIN
        SET @SQLAgentRoleName = 'SQLAgentUserRole';
    END 
    ELSE IF(@GrantedLevel = 'READER')
    BEGIN
        SET @SQLAgentRoleName = 'SQLAgentReaderRole';
    END ELSE IF(@GrantedLevel = 'OPERATOR')
    BEGIN
        SET @SQLAgentRoleName = 'SQLAgentOperatorRole';
    END 
    ELSE
    BEGIN
        RAISERROR('Unexpected value for parameter @GrantedLevel (%s)',12,1,@GrantedLevel);
        RETURN;
    END 
     
    BEGIN TRY
    
        if @withDatabaseAccessCreation = 1 and @GranteeRoleName is null 
        BEGIN     
            if @Debug = 1
            BEGIN 
                PRINT '-- set database access to msdb'
            END            
            exec [security].[setDatabaseAccess] 
                @ServerName         = @ServerName,
                @DbName             = 'msdb',
                @ContactLogin       = @ContactLogin,
                @ContactDepartment  = @ContactDepartment,
                @ContactsJob        = @ContactsJob ,
                @ContactName        = @ContactName,
                @exactMatch         = @exactMatch,
                @DefaultSchema      = 'dbo',
                @isDefaultDb        = 0,
                @withServerAccessCreation = 1,
                @_noTmpTblDrop      = @_noTmpTblDrop,
                @Reason             = 'Created to allow this login to use SQL Agent',
                @Debug              = @Debug ;               
        END 
        
        if @Debug = 1
        BEGIN 
            PRINT '-- set Creating #grantees table'
        END   
        -- create the table #grantees
        CREATE table #grantees ( GranteeName varchar(512), isRole BIT, isActive BIT) ;
        
        if @GranteeRoleName is not null 
        BEGIN
            /* this is just a story of role memberships */
            if @Debug = 1
            BEGIN 
                PRINT '-- Role membership settings'
            END 
            -- check the grantee role exists.
            IF(NOT EXISTS (SELECT 1 FROM [security].[DatabaseRoles] where ServerName = @ServerName and DbName = @DbName and RoleName = @GranteeRoleName))
            BEGIN 
                RAISERROR('Unknown database role %s on Server %s in database %s',12,1,@GranteeRoleName,@ServerName,@DbName);
                RETURN;
            END 
            
            SET @tsql = 'insert into #grantees' + @LineFeed + 
                        '    SELECT [RoleName], 1, [isActive]' + @LineFeed +
                        '    from [security].[DatabaseRoles]' + @LineFeed +
                        '    where ' + @LineFeed +
                        '        [ServerName] = @ServerName' + @LineFeed +
                        '    and [DbName]     = ''msdb''' + @LineFeed +
                        '    and [RoleName]   ' + @LookupOperator + ' isnull(@Grantee,[RoleName])' + @LineFeed 
        END 
        ELSE
        BEGIN 
            if @Debug = 1
            BEGIN 
                PRINT '-- user membership settings'
            END 
            SET @tsql = 'insert into #grantees' + @LineFeed + 
                        '    SELECT m.DbUserName , 1, c.isActive' + @LineFeed +
                        '    FROM [security].[SQLMappings] m'+ @LineFeed +
                        '    INNER JOIN [security].[Contacts] c' + @LineFeed +
                        '    ON m.SQLLogin = c.SQLLogin' + @LineFeed +
                        '    WHERE' + @LineFeed +
                        '        [ServerName] = @ServerName' + @LineFeed +
                        '    AND [DbName]     = ''msdb''' + @LineFeed +
                        '    AND c.[SQLLogin]   ' + @LookupOperator + ' isnull(@curLogin,c.[SQLLogin])' + @LineFeed +
                        '    and c.[Department] ' + @LookupOperator + ' isnull(@curDep,c.[Department])' + @LineFeed +
                        '    and c.[Job]        ' + @LookupOperator + ' isnull(@curJob,c.[Job])' + @LineFeed +
                        '    and c.[Name]       ' + @LookupOperator + ' isnull(@curName,c.[Name])' + @LineFeed 
        END 
        
        exec sp_executesql  @tsql , 
                            N'@ServerName varchar(512),@curLogin VARCHAR(128) = NULL,@curDep VARCHAR(512),@CurJob VARCHAR(256),@CurName VARCHAR(256),@Grantee VARCHAR(128)',
                            @Grantee = @GranteeRoleName,
                            @ServerName = @ServerName , 
                            @curLogin = @ContactLogin,
                            @CurDep = @ContactDepartment, 
                            @CurJob = @ContactsJob , 
                            @CurName = @ContactName

        if @Debug = 1
        BEGIN 
            PRINT '-- Creating SQL Agent dedicated roles (which are already created by default)'
        END 
        
        
        MERGE [security].[DatabaseRoles] m
        using (
            select @ServerName as ServerName, 'msdb' as DbName,'SQLAgentUserRole' as RoleName, 0 as isStandard,'SQL Server Core Role - Allow user to access SQL Agent and CRUD his own jobs' as Reason,@isActive as isActive
            union all 
            select @ServerName, 'msdb','SQLAgentReaderRole', 0,'SQL Server Core Role - Allow user to see all SQL Agent jobs',@isActive
            union all 
            select @ServerName, 'msdb','SQLAgentOperatorRole', 0,'SQL Server Core Role - Allow user to operate on any SQL Agent Job. It won''t be able to drop a job which he doesn''t own.',@isActive
        ) i
        on 
            m.[ServerName]  = i.[ServerName]
        and m.[DbName]      = i.[DbName]
        and m.[RoleName]    = i.[RoleName]
        WHEN NOT MATCHED THEN 
            insert (
                ServerName, DbName,RoleName , isStandard,Reason,isActive
            )
            values (
                i.ServerName, i.DbName,i.RoleName , i.isStandard,i.Reason,i.isActive
            )
        ;
        
        
         
        MERGE [security].[DatabaseRoleMembers] m
        using (
            select @ServerName as ServerName, 'msdb' as DbName, @SQLAgentRoleName as RoleName, g.GranteeName as MemberName, g.isRole as MemberIsRole, @PermissionLevel as PermissionLevel, g.isActive as isActive
            FROM #grantees g
        ) i
        on 
            m.ServerName = i.ServerName
        and m.DbName     = i.DbName
        and m.RoleName   = i.RoleName
        and m.MemberName = i.MemberName
        WHEN MATCHED THEN 
            update set PermissionLevel = i.PermissionLevel, isActive = i.isActive
        WHEN NOT MATCHED THEN 
            insert ( 
                ServerName,DbName,RoleName,MemberName,MemberIsRole,PermissionLevel,isActive
            )
            values (
                i.ServerName,i.DbName,i.RoleName,i.MemberName,i.MemberIsRole,i.PermissionLevel,i.isActive
            )
        ;
            
        --select * from #grantees
        if @_noTmpTblDrop = 0 and OBJECT_ID('#logins' ) is not null
            DROP TABLE #logins ;
        
        if @_noTmpTblDrop = 0 and OBJECT_ID('#grantees' ) is not null
            DROP TABLE #grantees ;
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
            
        if @_noTmpTblDrop = 0 and OBJECT_ID('#grantees' ) is not null
            DROP TABLE #grantees ;            
       
    END CATCH 
END 
GO

PRINT '    Procedure altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 	
