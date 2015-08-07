/*requires Schema.Security.sql*/
/*requires Table.security.DatabasePermissions.sql*/
/*requires Function.validator.isValidPermissionDescription.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Procedure [security].[ManagePermission] Creation'

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[ManagePermission]') AND type in (N'P'))
BEGIN
    EXECUTE ('CREATE PROCEDURE [security].[ManagePermission] ( ' +
            ' @ServerName    varchar(512), ' +
            ' @DbName        varchar(64) ' +
            ') ' +
            'AS ' +
            'BEGIN ' +
            '   RETURN ''Not implemented'' ' +
            'END')
    PRINT '    Procedure created.'
END
GO



ALTER PROCEDURE [security].[ManagePermission] (
    @ActionType     VARCHAR(128) = 'CREATE', -- other : 'LIST', 'OVERWRITE','DELETE'
    @ServerName     varchar(512) = @@SERVERNAME,
    @DbName         varchar(64)  = null ,
    @Grantee        varchar(64)  = null ,
    @GranteeIsUser  BIT      = null ,
    @ObjectClass    VARCHAR(128) = null ,
    @ObjectType     VARCHAR(128) = null ,
    @PermissionLevel VARCHAR(6)  = 'GRANT' ,
    @PermissionName  VARCHAR(128) = null ,
    @SchemaName      VARCHAR(64)= null ,
    @ObjectName      VARCHAR(128)= null ,
    @SubObjectName   VARCHAR(128)= null ,
    @isWithGrantOption BIT= 0 , 
    @Reason          VARCHAR(MAX) = NULL,
    @isActive        BIT = 0 ,    
    @Debug          BIT          = 0
)
AS
BEGIN

    --SET NOCOUNT ON;
    DECLARE @tsql               nvarchar(max);
    DECLARE @tsql_declaration   nvarchar(max);
    DECLARE @LineFeed           VARCHAR(6) ;
    DECLARE @CurServerName      varchar(512)
    DECLARE @CurDbName          varchar(64)
    DECLARE @tmpCnt             BIGINT;
    
    SET @LineFeed = CHAR(13) + CHAR(10) ;
    SET @tsql = '';
    SET @tsql_declaration = '';
    SET @tmpCnt = 0;
    
    -- Validate parameters 
    
    if(@ActionType not in ('CREATE','LIST','OVERWRITE','DELETE'))
    BEGIN 
        RAISERROR('Provided parameter @ActionType is unknown %s',10,1,@ActionType);
        RETURN;
    END 
    
    if(@Debug = 1)
    BEGIN 
        PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -  Action Type : ' + @ActionType + @LineFeed 
    END 
    
    
    if(@ActionType not in ('LIST'))
    BEGIN 
        if(@Debug = 1)
        BEGIN 
            PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -  Validating procedure parameters ' + @LineFeed
        END 

        /*
        The provided parameters should lead to completely identify ONE single row and
        contain all the mandatory informations to set a permission.
        */
        
        if(Validator.isValidPermissionDescription(@ServerName,@DbName,@Grantee,@GranteeIsUser,@ObjectClass,@ObjectType ,@PermissionLevel,@PermissionName,@SchemaName,@ObjectName,@SubObjectName,@isWithGrantOption,@Reason,@isActive) != 1)
        BEGIN 
            RAISERROR('Invalid permission description provided !',10,1);
            return;
        END        
    END 
    
    -- Building query
    
    
    if(OBJECT_ID(N'tempdb..##tmpManagePermission') is not null)
    BEGIN 
        exec sp_executesql N'DROP TABLE ##tmpManagePermission';
    END 
    
    SET @tsql_declaration =  @tsql_declaration + '@ServerName VARCHAR(256)' + ',@DbName VARCHAR(256)' + ',@Grantee VARCHAR(256)' +',@ObjectClass    VARCHAR(128)'+
                                ',@ObjectType VARCHAR(128)'+',@PermissionLevel VARCHAR(6)'+', @PermissionName  VARCHAR(128)'+',@SchemaName VARCHAR(64)' +
                                ',@ObjectName      VARCHAR(128)' + ',@SubObjectName   VARCHAR(128)'
    SET @tsql = 'SELECT *' + @LineFeed  +
                'INTO ##tmpManagePermission' + @LineFeed +
                'FROM [security].[DatabasePermissions]' + @LineFeed +
                'where 1 = 1 ' + @LineFeed 
    if(@ServerName is not null)
    BEGIN 
        SET @tsql = @tsql +
                    'and ServerName = @ServerName' + @LineFeed ;
    END 
    if(@DbName is not null)
    BEGIN 
        SET @tsql = @tsql +
                    'and DbName = @DbName' + @LineFeed ;
    END  
    if(@Grantee is not null)
    BEGIN 
        SET @tsql = @tsql +
                    'and Grantee = @Grantee' + @LineFeed ;
    END 
    if(@ObjectClass is not null)
    BEGIN 
        SET @tsql = @tsql +
                    'and ObjectClass = @ObjectClass' + @LineFeed ;
    END 
    if(@ObjectType is not null)
    BEGIN 
        SET @tsql = @tsql +
                    'and ObjectType = @ObjectType' + @LineFeed ;
    END 
    if(@ObjectType is not null)
    BEGIN 
        SET @tsql = @tsql +
                    'and ObjectType = @ObjectType' + @LineFeed ;
    END 
    if(@PermissionName is not null)
    BEGIN 
        SET @tsql = @tsql +
                    'and PermissionName = @PermissionName' + @LineFeed ;
    END 
    if(@SchemaName is not null)
    BEGIN 
        SET @tsql = @tsql +
                    'and SchemaName = @SchemaName' + @LineFeed ;
    END 
    if(@ObjectName is not null)
    BEGIN 
        SET @tsql = @tsql +
                    'and ObjectName = @ObjectName' + @LineFeed ;
    END 
    if(@SubObjectName is not null)
    BEGIN 
        SET @tsql = @tsql +
                    'and SubObjectName = @SubObjectName' + @LineFeed ;
    END 

    -- no permission level here ... it won't help in identifying whether there is already a row or not     
    
    if(@Debug = 1)
    BEGIN 
        PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Generated Query : ' + @LineFeed + @tsql 
    END 
    
    exec sp_executesql @tsql , @tsql_declaration, @ServerName = @ServerName , @DbName = @DbName, @Grantee = @Grantee,
                        @ObjectClass =@ObjectClass ,@ObjectType=@ObjectType,@PermissionLevel=@PermissionLevel,@PermissionName=@PermissionName,
                        @SchemaName=@SchemaName,@ObjectName=@ObjectName,@SubObjectName=@SubObjectName;

    
    
    if(@ActionType COLLATE French_CI_AI = 'LIST' COLLATE French_CI_AI)
    BEGIN 
        exec sp_executesql N'SELECT * FROM ##tmpManagePermission';
    END 
    ELSE if(@ActionType COLLATE French_CI_AI = 'DELETE' COLLATE French_CI_AI)
    BEGIN 
        RAISERROR('Not yet implemented.',10,1);
        RETURN;
    END 
    ELSE 
    BEGIN 
        DECLARE @rowCnt BIGINT ;
        
        SET @tsql = N'SELECT @rowCnt = COUNT(*) FROM ##tmpManagePermission' ;
        exec sp_executesql @tsql, N'@rowCnt BIGINT OUTPUT', @rowCnt = @rowCnt OUTPUT ;
        
        if(@rowCnt <= 0)
        BEGIN 
            -- no record found.
            insert into [security].[DatabasePermissions]  (
                ServerName,DbName,Grantee,isUser,ObjectClass,ObjectType ,PermissionLevel,PermissionName,SchemaName,ObjectName,SubObjectName,isWithGrantOption,Reason,isActive
            )
            values (
                @ServerName,@DbName,@Grantee,@GranteeIsUser,@ObjectClass,@ObjectType ,@PermissionLevel,@PermissionName,@SchemaName,@ObjectName,@SubObjectName,@isWithGrantOption,@Reason,@isActive
            )
            if(@Debug = 1)
            BEGIN 
                PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG -  New line added to [security].[DatabasePermissions] table' + @LineFeed
            END 
        END 
        ELSE IF(@rowCnt = 1)
        BEGIN             
            DECLARE @currentPermissionLevel         VARCHAR(128);
            DECLARE @currentIsWithGrantOption       BIT;
            DECLARE @currentReason                  VARCHAR(MAX);
            DECLARE @currentisActive                BIT;
            
            exec sp_executesql N'select @permlvl = PermissionLevel,@iswithgrant = isWithGrantOption , @reason = reason , @isActive = isActive from ##tmpManagePermission',
                               N'@permlvl VARCHAR(128) OUTPUT,@iswithgrant BIT OUTPUT, @reason VARCHAR(MAX) OUTPUT, @isActive BIT OUTPUT',
                               @permlvl = @currentPermissionLevel OUTPUT ,
                               @iswithgrant = @currentIsWithGrantOption OUTPUT,
                               @reason = @currentReason OUTPUT,
                               @isActive = @isActive OUTPUT ;
            
            if(@currentPermissionLevel <> @PermissionLevel)
            BEGIN 
                if(@ActionType = 'CREATE')
                BEGIN 
                    PRINT 'Warning : permission level not changed from ' + @currentPermissionLevel + ' to ' + @PermissionLevel;
                END 
                ELSE IF (@ActionType = 'OVERWRITE')
                BEGIN 
                    update [security].[DatabasePermissions] 
                        set PermissionLevel = @PermissionLevel
                    where 
                        ServerName = @ServerName 
                    and isnull(DbName,'<null>') = isnull(@DbName,'<null>')
                    and Grantee = @Grantee
                    and ObjectClass = @ObjectClass
                    and isnull(ObjectType,'<null>') = isnull(@ObjectType,'<null>')
                    and PermissionName = @PermissionName
                    and isnull(SchemaName,'<null>') = isnull(@SchemaName,'<null>')
                    and ObjectName = @ObjectName
                    and isnull(SubObjectName,'<null>') = isnull(@SubObjectName,'<null>')
                END 
            END 
            
            if(@currentIsWithGrantOption <> @isWithGrantOption)
            BEGIN 
                if(@ActionType = 'CREATE')
                BEGIN 
                    PRINT 'Warning : grant option not changed from ' + CONVERT(VARCHAR,@currentIsWithGrantOption) + ' to ' + CONVERT(VARCHAR,@isWithGrantOption);
                END 
                ELSE IF (@ActionType = 'OVERWRITE')
                BEGIN 
                    update [security].[DatabasePermissions] 
                        set isWithGrantOption = @isWithGrantOption
                    where 
                        ServerName = @ServerName 
                    and isnull(DbName,'<null>') = isnull(@DbName,'<null>')
                    and Grantee = @Grantee
                    and ObjectClass = @ObjectClass
                    and isnull(ObjectType,'<null>') = isnull(@ObjectType,'<null>')
                    and PermissionName = @PermissionName
                    and isnull(SchemaName,'<null>') = isnull(@SchemaName,'<null>')
                    and ObjectName = @ObjectName
                    and isnull(SubObjectName,'<null>') = isnull(@SubObjectName,'<null>')
                END 
            END     
            
            if(@currentReason <> @Reason)
            BEGIN 
                if(@ActionType = 'CREATE' and @currentReason is not null and (@currentReason <> @Reason or @Reason is null))
                BEGIN 
                    PRINT 'Warning : reason not changed from ' + isnull(@currentReason,'<null>') + ' to ' +  isnull(@Reason,'<null>');
                END 
                ELSE
                BEGIN 
                    update [security].[DatabasePermissions] 
                        set Reason = @Reason
                    where 
                        ServerName = @ServerName 
                    and isnull(DbName,'<null>') = isnull(@DbName,'<null>')
                    and Grantee = @Grantee
                    and ObjectClass = @ObjectClass
                    and isnull(ObjectType,'<null>') = isnull(@ObjectType,'<null>')
                    and PermissionName = @PermissionName
                    and isnull(SchemaName,'<null>') = isnull(@SchemaName,'<null>')
                    and ObjectName = @ObjectName
                    and isnull(SubObjectName,'<null>') = isnull(@SubObjectName,'<null>')
                END 
            END             
            if(@currentisActive <> @isActive)
            BEGIN 
                if(@ActionType = 'CREATE')
                BEGIN 
                    PRINT 'Warning : isActive not changed from ' + CONVERT(VARCHAR,@currentisActive) + ' to ' + CONVERT(VARCHAR,@isActive);
                END 
                ELSE IF (@ActionType = 'OVERWRITE')
                BEGIN 
                    update [security].[DatabasePermissions] 
                        set isActive = @isActive
                    where 
                        ServerName = @ServerName 
                    and isnull(DbName,'<null>') = isnull(@DbName,'<null>')
                    and Grantee = @Grantee
                    and ObjectClass = @ObjectClass
                    and isnull(ObjectType,'<null>') = isnull(@ObjectType,'<null>')
                    and PermissionName = @PermissionName
                    and isnull(SchemaName,'<null>') = isnull(@SchemaName,'<null>')
                    and ObjectName = @ObjectName
                    and isnull(SubObjectName,'<null>') = isnull(@SubObjectName,'<null>')
                END 
            END               
        END 
        ELSE 
        BEGIN 
            RAISERROR('Unexpected number of rows matching the given criteria',10,1);
            RETURN ;
        END 
    END 
    

END
GO


PRINT '    Procedure altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''        