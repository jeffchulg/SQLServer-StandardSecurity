/*requires Schema.Security.sql*/
/*requires Table.DatabaseRoles.sql*/
/*requires Table.DatabasePermissions.sql*/
/*requires Table.security.StandardOnDatabaseRoles.sql*/
/*requires Table.security.StandardOnDatabaseRolesSecurity.sql*/
/*requires Table.StandardExclusion.sql*/
/*requires Table.inventory.SQLDatabases.sql*/
/*requires Procedure.security.setStandardOnDatabaseRolePermissions.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
--PRINT 'Procedure [security].[setStandardOnDatabaseRole] Creation'
PRINT 'Procedure [security].[setStandardOnDatabaseRole] removal'

IF  /*NOT*/ EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[security].[setStandardOnDatabaseRole]') AND type in (N'P'))
BEGIN
	DROP PROCEDURE [security].[setStandardOnDatabaseRole]
    -- EXECUTE ('CREATE PROCEDURE [security].[setStandardOnDatabaseRole] ( ' +
            -- ' @ServerName    varchar(512), ' +
            -- ' @DbName        varchar(64) ' +
            -- ') ' +
            -- 'AS ' +
            -- 'BEGIN ' +
            -- '   RETURN ''Not implemented'' ' +
            -- 'END')
    -- PRINT '    Procedure created.'
END
GO

-- ALTER PROCEDURE [security].[setStandardOnDatabaseRole] (
    -- @ServerName  varchar(512) = @@SERVERNAME,
    -- @DbName      varchar(64)  = NULL,
    -- @StdRoleName varchar(64)  = NULL,
    -- @Debug       BIT          = 0
-- )
-- AS
-- /*
  -- ===================================================================================
   -- DESCRIPTION:
     -- This function takes care of the generation of Database Roles for "on database" access
     -- according to its parameter values.

   -- ARGUMENTS :
     -- @ServerName    name of the server on which the SQL Server instance we want to modify is running.
                    -- By default, it's the current server

     -- @DbName        name of the database to take care of.
                    -- A NULL value (which is the default value) means that this procedure
                    -- has to take care of all "on schema" roles for any database on the given server.

     -- @StdRoleName   name of the standard role for which execute this procedure
                    -- if NULL given, all standard roles are being taken into account

     -- @Debug         If set to 1, then we are in debug mode

   -- REQUIREMENTS:

    -- EXAMPLE USAGE :

        -- -- All standard security roles on all servers
        -- exec [security].[setStandardOnDatabaseRole] @ServerName = null

        -- -- All standard security roles on all servers for DBA database
        -- exec [security].[setStandardOnDatabaseRole] @ServerName = null, @DbName = 'DBA'

        -- -- All standard security roles on server 'SI-S-SERV308' for DBA database
        -- exec [security].[setStandardOnDatabaseRole] @ServerName = 'SI-S-SERV308', @DbName = 'DBA'

        -- -- All standard security roles on local server for all database (uses variable @@SERVERNAME)
        -- exec [security].[setStandardOnDatabaseRole]

        -- -- All standard security roles on local server for DBA database (uses variable @@SERVERNAME)
        -- exec [security].[setStandardOnDatabaseRole] @DbName = 'DBA'

   -- ==================================================================================
   -- BUGS:

     -- BUGID       Fixed   Description
     -- ==========  =====   ==========================================================
     -- ----------------------------------------------------------------------------------
   -- ==================================================================================
   -- NOTES:
   -- AUTHORS:
        -- .   VBO     Vincent Bouquette   (vincent.bouquette@chu.ulg.ac.be)
        -- .   BBO     Bernard Bozert      (bernard.bozet@chu.ulg.ac.be)
        -- .   JEL     Jefferson Elias     (jelias@chu.ulg.ac.be)

   -- COMPANY: CHU Liege
   -- ==================================================================================
   -- Revision History

    -- Date        Nom         Description
    -- ==========  =====       ==========================================================
    -- 11/05/2015  JEL         Version 0.0.1
    -- ----------------------------------------------------------------------------------
  -- ===================================================================================
-- */
-- BEGIN

    -- --SET NOCOUNT ON;
    -- DECLARE @versionNb          varchar(16) = '0.0.1';
    -- DECLARE @tsql               varchar(max);
    -- DECLARE @CurServerName      varchar(512)
    -- DECLARE @CurDbName          varchar(64)
    -- DECLARE @CurRoleName        varchar(64)
    -- DECLARE @CurDescription     varchar(2048)
    -- DECLARE @curIsActive        BIT


    -- SET @CurServerName = @ServerName
    -- SET @CurDbName     = @DbName

    -- BEGIN TRY
    -- --BEGIN TRANSACTION
        -- if(@CurServerName is null)
        -- BEGIN
            -- -- needs to loop on all servers defined in SQLMappings
            -- -- no parameterized cursor in MSSQL ... viva Oracle!

            -- if @Debug = 1
            -- BEGIN
                -- PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - No ServerName Given. Overall repository security update.'
            -- END

            -- DECLARE getServers CURSOR LOCAL FOR
                -- select distinct
                    -- ServerName
                -- from
                    -- security.SQLMappings
                -- order by 1

            -- open getServers
            -- FETCH NEXT
            -- FROM getServers INTO @CurServerName

            -- WHILE @@FETCH_STATUS = 0
            -- BEGIN
                -- EXEC [security].[setStandardOnDatabaseRole] @ServerName = @CurServerName, @DbName = @CurDbName,@Debug = @Debug
                -- -- carry on ...
                -- FETCH NEXT
                -- FROM getServers INTO @CurServerName
            -- END
            -- CLOSE getServers
            -- DEALLOCATE getServers
        -- END
        -- else if(@CurServerName is not null and @CurDbName is null)
        -- BEGIN
            -- if @Debug = 1
            -- BEGIN
                -- PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - No DbName Given. Overall server security update.'
            -- END
            -- -- needs to loop on all dbs defined in SQLMappings
            -- -- no parameterized cursor in MSSQL ... viva Oracle!
            -- DECLARE getServerDatabases CURSOR LOCAL FOR
                -- select distinct
                    -- DbName
                -- from inventory.SQLDatabases
                -- where
                    -- [ServerName] = @CurServerName
                -- and [DbName] not in (
                    -- select
                        -- ObjectName
                    -- from
                        -- security.StandardExclusion
                    -- where
                        -- ObjectType = 'DATABASE'
                    -- and isActive = 1
                -- )
                -- order by 1
            -- open getServerDatabases
            -- FETCH NEXT
            -- FROM getServerDatabases INTO @CurDbName

            -- WHILE @@FETCH_STATUS = 0
            -- BEGIN
                -- EXEC [security].[setStandardOnDatabaseRole] @ServerName = @CurServerName, @DbName = @CurDbName,@Debug = @Debug
                -- -- carry on ...
                -- FETCH NEXT
                -- FROM getServerDatabases INTO @CurDbName
            -- END
            -- CLOSE getServerDatabases
            -- DEALLOCATE getServerDatabases
        -- END
        -- else
        -- BEGIN
            -- if @Debug = 1
            -- BEGIN
                -- PRINT '--------------------------------------------------------------------------------------------------------------'
                -- PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of server ' + @CurServerName
                -- PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of Database ' + @CurDbName
            -- END

            -- -- make sure the database exists in our security inventory

            -- DECLARE @tmpCounter INT ;

            -- SELECT @tmpCounter = COUNT(*) from inventory.SQLDatabases where ServerName = @CurServerName and DbName = @CurDbName ;

            -- if(@tmpCounter = 0)
            -- BEGIN
                -- RAISERROR('No match found for given database %s on server %s',10,1,@CurDbName,@CurServerName);
                -- RETURN;
            -- END
            -- -- TODO : ensure that this dataset is ordered from no role dependency to roles with dependant roles created
            -- DECLARE GetStandardOnDbRoles CURSOR LOCAL FOR
                -- select RoleName, isActive, [Description]
                -- from security.StandardOnDatabaseRoles

            -- open GetStandardOnDbRoles;

            -- FETCH NEXT
            -- FROM GetStandardOnDbRoles INTO @CurRoleName,@curIsActive,@CurDescription

            -- WHILE @@FETCH_STATUS = 0
            -- BEGIN
                -- if @Debug = 1
                -- BEGIN
                    -- PRINT CONVERT(VARCHAR,GETDATE()) + ' - DEBUG - Taking care of Standard Database Role ' + @CurRoleName;
                -- END
                -- merge security.DatabaseRoles r
                -- using (
                    -- select
                        -- @CurServerName  as ServerName,
                        -- @CurDbName      as DbName,
                        -- @CurRoleName    as RoleName,
                        -- @curIsActive    as isActive,
                        -- @curDescription as Description
                -- ) i
                -- on
                    -- r.ServerName = i.ServerName
                -- and r.DbName     = i.DbName
                -- and r.RoleName   = i.RoleName
                -- WHEN MATCHED THEN
                    -- update set
                        -- isActive = i.isActive
                -- WHEN NOT MATCHED BY TARGET THEN
                    -- insert (
                        -- ServerName,
                        -- DbName,
                        -- RoleName,
                        -- isStandard,
                        -- Reason,
                        -- isActive
                    -- )
                    -- values (
                        -- i.ServerName,
                        -- i.DbName,
                        -- i.RoleName,
                        -- 1,
                        -- i.Description,
                        -- i.isActive
                    -- )
                -- /*
                -- WHEN NOT MATCHED BY SOURCE THEN
                    -- -- TODO make a procedure to undo the missing standard privilege
                -- */
                -- ;

                -- -- now the role is created, we can add its permissions
                -- EXEC [security].[setStandardOnDatabaseRolePermissions]
                    -- @ServerName  = @CurServerName,
                    -- @DbName      = @CurDbName,
                    -- @RoleName    = @CurRoleName,
                    -- @Debug       = @Debug

                -- -- carry on ...
                -- FETCH NEXT
                -- FROM GetStandardOnDbRoles INTO @CurRoleName,@curIsActive,@CurDescription
            -- END
            -- CLOSE GetStandardOnDbRoles
            -- DEALLOCATE GetStandardOnDbRoles
            -- if(@Debug = 1)
            -- BEGIN
                -- PRINT '--------------------------------------------------------------------------------------------------------------'
            -- END
        -- END
    -- --COMMIT
    -- END TRY
    -- BEGIN CATCH
        -- SELECT
        -- ERROR_NUMBER() AS ErrorNumber
        -- ,ERROR_SEVERITY() AS ErrorSeverity
        -- ,ERROR_STATE() AS ErrorState
        -- ,ERROR_PROCEDURE() AS ErrorProcedure
        -- ,ERROR_LINE() AS ErrorLine
        -- ,ERROR_MESSAGE() AS ErrorMessage;

        -- if CURSOR_STATUS('local','getServers') >= 0
        -- begin
            -- close getServers
            -- deallocate getServers
        -- end
        -- if CURSOR_STATUS('local','getServerDatabases') >= 0
        -- begin
            -- close getServerDatabases
            -- deallocate getServerDatabases
        -- end
        -- if CURSOR_STATUS('local','GetStandardOnDbRoles') >= 0
        -- begin
            -- close GetStandardOnDbRoles
            -- deallocate GetStandardOnDbRoles
        -- end
        -- IF @@TRANCOUNT > 0
            -- ROLLBACK
    -- END CATCH
-- END
-- GO


-- IF @@ERROR = 0
    -- PRINT '   PROCEDURE altered.'
-- ELSE
-- BEGIN
    -- PRINT '   Error while trying to alter procedure'
    -- RETURN
-- END

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT ''