--- $Id: create-tables.sql,v 1.1 2014/07/01 14:15:13 condor Exp condor $
---
---Copyright 2014 Gymnogyps Californianus
---
--- File     : create_tables.sql
--- Purpose  : SQL statement to create the datebase tables
---          : for the mysql_rocket.sh utility.
--- Date     : 11/07/13
--- Author   : condor
--- 
--- GUFI: 527c17e35fbb04.54787666:527c17e3bae180.98325757:110713:174451EST
---       5283a5ec981d31.63309163:5283a5ed0f58a5.63265393:111213:111644EST
---       528bdaf286bbf7.29235535:528bdaf2e3e658.34779837:111913:164106EST

CREATE TABLE directory ( 
	directory 		STRING NOT NULL, 
	logMessage		STRING,
	directoryId		INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL 
);


--- INSERT INTO Directory VALUES ("/home/condor", "", 1);
--- INSERT INTO Directory VALUES ("/home/condor/devel", "", 2 );
--- INSERT INTO Directory VALUES ("/home/condor/.cfs", "", 3);

--- 
--- CREATE TABLE Identity (
--- title			CHAR (30),
--- firstName		CHAR (30),
--- middleName		CHAR (30),
--- lastName		CHAR (30),
--- creationDate		DATE,
--- addressId		INTEGER,
--- securityId		INTEGER,
--- identityId		INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
--- 
--- FOREIGN KEY (addressId)  REFERENCES Address(addressId),
--- FOREIGN KEY (securityId) REFERENCES Security(securityId)  
--- );
--- 
--- CREATE TABLE Owner (
--- identityId		INTEGER,
--- directoryId		INTEGER,
--- ownerId			INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
--- FOREIGN KEY (identityId)  REFERENCES Identity(identityId),
--- FOREIGN KEY (directoryId) REFERENCES Directory(directoryId)  
--- );
--- 
--- CREATE TABLE Address (
--- address1		CHAR (30),
--- address2		CHAR (30),
--- city			CHAR (25),
--- state			CHAR (2),
--- postalCode		CHAR (10),
--- addressId		INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
--- );
--- 
--- 
--- CREATE TABLE Security (
--- passphrase		CHAR (30),
--- riskQuestion1		CHAR (30),
--- riskQuestion2		CHAR (30),
--- riskAnswer1		CHAR (30),
--- riskAnswer2		CHAR (30),
--- creationDate		DATE,
--- securityId		INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
--- );

--- CREATE TABLE Admin (
--- variety			CHAR (30),
--- creationDate		DATE
--- );

--- INSERT INTO Admin VALUES ("rose", "11-20-13" );
--- $Log: create-tables.sql,v $
--- Revision 1.1  2014/07/01 14:15:13  condor
--- Initial revision
---
--- Revision 1.1  2014/05/27 19:26:16  root
--- Initial revision
---
---
