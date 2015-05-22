/*requires main.sql*/

PRINT 'Creating temporary table in which created Contacts will be stored' ;

IF(OBJECT_ID('tempdb..#testContacts') is not null)
	DROP TABLE #testContacts

CREATE TABLE #testContacts (
    SQLLogin VARCHAR(512) NOT NULL ,
    DbUserName VARCHAR(512) 
) ;

