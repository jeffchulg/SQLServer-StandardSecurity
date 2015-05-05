/*requires main.sql */

PRINT 'Creating temporary table in which created Contacts will be stored' ;

CREATE TABLE #testContacts (
    SQLLogin VARCHAR(512) NOT NULL 
) ;

