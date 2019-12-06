/*
  Variant #9
  group 651003
  Kornienko Anastasia
*/

USE AdventureWorks2012;
GO

--pont a)
ALTER TABLE dbo.StateProvince ADD AddressType NVARCHAR(50);

SELECT * FROM dbo.StateProvince;
GO

-- point b)
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AddressType' AND TABLE_SCHEMA = 'Person';
GO

CREATE TYPE StateProvinceType
  AS TABLE(
    StateProvinceID INT,
	StateProvinceCode NCHAR(3),
	CountryRegionCode NVARCHAR(3),
	IsOnlyStateProvinceFlag SMALLINT,
	Name NVARCHAR(50),
	TerritoryID INT,
	ModifiedDate DATETIME,
	AddressType NVARCHAR(50),
	PRIMARY KEY (StateProvinceID)
  );

-- GO is default batch separator
-- table variables are scoped to the batches(also to the stored procedures or user-defined functions)
DECLARE @StateProvinceDublicate AS StateProvinceType;

/*
  There is nothing said about what to do in the case when the StateProvince may have
  several Address Types, so I decided to join them with ',' into the one value
  I'm using the version of 2012 so I'm not able to use the STRING_AGG here unfortunately.
  That's why I'm using this "standart" solution here.
*/
INSERT INTO @StateProvinceDublicate
  (
    StateProvinceID,
	StateProvinceCode,
	CountryRegionCode,
	IsOnlyStateProvinceFlag,
	Name,
	TerritoryID,
	ModifiedDate,
	AddressType
  )
  SELECT DISTINCT StateProvince.StateProvinceID,
         StateProvince.StateProvinceCode,
		 StateProvince.CountryRegionCode,
		 StateProvince.IsOnlyStateProvinceFlag,
		 StateProvince.Name,
		 StateProvince.TerritoryID,
		 StateProvince.ModifiedDate,
         STUFF((
		   SELECT DISTINCT ', ' + AddressType.Name
		   FROM Person.Address Address
		   JOIN Person.BusinessEntityAddress BEAddress
		   ON BEAddress.AddressID = Address.AddressID
		   JOIN Person.AddressType AddressType
		   ON AddressType.AddressTypeID = BEAddress.AddressTypeID
		   WHERE Address.StateProvinceID = StateProvince.StateProvinceID
		   FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 2, '') AddressType
  FROM dbo.StateProvince StateProvince
  JOIN Person.Address Address
    ON StateProvince.StateProvinceID = Address.StateProvinceID
  JOIN Person.BusinessEntityAddress BEAddress
    ON BEAddress.AddressID = Address.AddressID
  JOIN Person.AddressType AddressType
    ON AddressType.AddressTypeID = BEAddress.AddressTypeID;

SELECT StateProvinceDup.AddressType,  CountryRegion.Name + ' ' + StateProvinceDup.Name  FROM  @StateProvinceDublicate StateProvinceDup
  JOIN Person.CountryRegion CountryRegion
    ON StateProvinceDup.CountryRegionCode = CountryRegion.CountryRegionCode
;


--point c)
SELECT * FROM Person.CountryRegion;

UPDATE dbo.StateProvince
  SET AddressType = StateProvinceDup.AddressType,
      Name = CountryRegion.Name + ' ' + StateProvinceDup.Name
  FROM @StateProvinceDublicate StateProvinceDup
  JOIN Person.CountryRegion CountryRegion
    ON StateProvinceDup.CountryRegionCode = CountryRegion.CountryRegionCode
  WHERE dbo.StateProvince.StateProvinceID = StateProvinceDup.StateProvinceID;

SELECT * FROM dbo.StateProvince;
GO

--point d)
DELETE StateProvince
  FROM dbo.StateProvince
  WHERE StateProvinceID not in (
    SELECT MAX(StateProvinceID) OVER(PARTITION BY AddressType)
	FROM dbo.StateProvince
  );

SELECT * FROM dbo.StateProvince;
GO

--point e)
SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
  WHERE TABLE_NAME = 'StateProvince' AND TABLE_SCHEMA = 'dbo';
GO

ALTER TABLE dbo.StateProvince DROP COLUMN AddressType;
ALTER TABLE dbo.StateProvince DROP CONSTRAINT territory_even;

SELECT def.name
  FROM sys.all_columns c
  JOIN sys.tables t
    ON t.object_id = c.object_id
  JOIN sys.schemas sch
    ON sch.schema_id = t.schema_id
  JOIN sys.default_constraints def
    ON c.default_object_id = def.object_id
  WHERE sch.name = 'dbo' AND t.name = 'StateProvince';
GO

IF EXISTS (
  SELECT name FROM sys.objects
    WHERE name = 'territory_def_value'
	  AND type = 'D'
)
 ALTER TABLE dbo.StateProvince DROP CONSTRAINT territory_def_value;
GO

--point f)
DROP TABLE dbo.StateProvince;
GO