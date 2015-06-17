/*requires ..\main.sql*/
PRINT 'Creating temporary table in which created Contacts will be stored' ;

IF(OBJECT_ID('$(TestingSchema).testContacts') is not null)
	DROP TABLE $(TestingSchema).testContacts

CREATE TABLE $(TestingSchema).testContacts (
    SQLLogin VARCHAR(512) NOT NULL ,
    DbUserName VARCHAR(512) 
) ;

