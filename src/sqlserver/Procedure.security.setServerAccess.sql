/*requires Schema.Security.sql*/
/*requires Table.security.Contacts.sql*/
/*requires Table.security.SQLLogins.sql*/
/*requires Procedure.security.PrepareAccessSettings.sql*/

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
                                    Added parameter for keeping ##logins table
                                    for reuse
                                    Added parameter sanitization
                                    VERSION 0.1.1
    --------------------------------------------------------------------------------
	07/08/2015  Jefferson Elias     Removed version number
	----------------------------------------------------------------------------------
	11/08/2015  Jefferson Elias		moved a part of the logic to security.PrepareAccessSettings
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
        @ServerName         = case when len(@ServerName)        = 0 THEN NULL else @ServerName END 

	/*
		Checking parameters
	*/

	if(@ServerName is null)
	BEGIN
		RAISERROR('No value set for @ServerName !',12,1)
	END

	BEGIN TRY
        exec [security].[PrepareAccessSettings]
						@AccessLevel		= 'SCHEMA',
						@ServerName			= @ServerName, 
						@ContactDepartment	= @ContactDepartment,
						@ContactsJob		= @ContactsJob,
						@ContactName		= @ContactName,
						@ContactLogin		= @ContactLogin,
						@exactMatch			= @exactMatch,
						@withTmpTblDrop		= 0,
						@Debug				= @Debug ;

        DECLARE @PermissionLevel VARCHAR(6) = 'GRANT' ;
        if @isAllow = 1
        BEGIN
            SET @PermissionLevel = 'DENY';
            MERGE
                [security].[SQLLogins] l
            using
                ##logins i
            on
                l.[ServerName] = i.[ServerName]
            and l.[SQLLogin] = i.Name
            WHEN NOT MATCHED THEN
                insert (
                    ServerName,
                    SqlLogin,
                    isActive
                )
                values (
                    i.ServerName,
                    i.Name,
                    i.isActive
                )
            ;
        END
        ELSE
            RAISERROR('Not yet implemented ! ',16,0)


        if @_noTmpTblDrop = 0 and OBJECT_ID('tempdb..#logins' ) is not null
            exec sp_executesql N'DROP TABLE ##logins' ;
	END TRY

	BEGIN CATCH
		SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;

        if @_noTmpTblDrop = 0 and OBJECT_ID('tempdb..#logins' ) is not null
            exec sp_executesql N'DROP TABLE ##logins' ;

	END CATCH
END
GO

PRINT '    Procedure [security].[setServerAccess] altered.'

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''