/*
  Variant #9
  group 651003
  Kornienko Anastasia
*/

CREATE DATABASE NewDatabase;

USE NewDatabase;
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

CREATE TABLE sales.Oders(OrderNum INT NULL);
GO

USE master;
GO

EXEC sp_addumpdevice 'disk', 'NewData',
'E:\Учёба\4 курс\БД\NewData.bak';
GO

BACKUP DATABASE NewDatabase
  TO NewData;
GO

DROP DATABASE NewDatabase;
GO

RESTORE DATABASE NewDatabase
  FROM NewData;
GO