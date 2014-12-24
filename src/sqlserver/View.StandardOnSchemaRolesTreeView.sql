/*requires Schema.Security.sql*/
/*requires Table.StandardOnSchemaRoles.sql*/
/*requires Table.StandardOnSchemaRolesSecurity.sql*/

/**
  ==================================================================================
    DESCRIPTION
		Creation of the [security].[StandardOnSchemaRolesTreeView] view.
        This view intends to display a hierarchical display for standard on schema 
        database roles.

	==================================================================================
  BUGS:
 
    BUGID       Fixed   Description
    ==========  =====   ==========================================================
    ----------------------------------------------------------------------------------
  ==================================================================================
  Notes :
 
        Exemples :
        -------
 
  ==================================================================================
  Revision history
 
    Date        Name                Description
    ==========  ================    ================================================
    24/12/2014  Jefferson Elias     Version 0.1.0
    --------------------------------------------------------------------------------	
  ==================================================================================
*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'View [security].[logins] Creation'

DECLARE @SQL VARCHAR(MAX)
IF  NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[security].[StandardOnSchemaRolesTreeView]'))
BEGIN
    SET @SQL =  'CREATE view [security].[StandardOnSchemaRolesTreeView]
                AS
                select ''Not implemented'' as Col1'
    EXEC (@SQL)
	PRINT '    View [security].[StandardOnSchemaRolesTreeView] created.'
END

SET @SQL = 'ALTER view [security].[StandardOnSchemaRolesTreeView]
                AS
                    with TreeView ([RoleName],ParentRole,[Level])
                    as (
                        select RoleName, CAST('''' as VARCHAR(64)) as ParentRole,0 
                        from security.StandardOnSchemaRoles
                        where RoleName not in (
                            select RoleName
                            from security.StandardOnSchemaRolesSecurity
                            where isRoleMembership = 1 and PermissionLevel = ''GRANT''
                        )
                        union all
                        select r.RoleName,CAST(r.PrivName AS varchar(64)),[Level]+1
                        from security.StandardOnSchemaRolesSecurity r	
                        INNER JOIN TreeView p ON r.PrivName = p.RoleName
                        where isRoleMembership = 1 and PermissionLevel = ''GRANT''
                    )
                    select tv.[Level],r.RoleName,r.isActive,r.Description,r.CreationDate,r.lastModified                 
                    from (
                        select max(tv1.[Level]) as [Level],tv1.RoleName
                        from 
                            TreeView tv1
                        group by RoleName
                    ) tv
                    inner join security.StandardOnSchemaRoles r
                    on
                        tv.RoleName = r.RoleName
                    '
EXEC (@SQL)
PRINT '    View [security].[StandardOnSchemaRolesTreeView] altered.'
GO

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT '' 