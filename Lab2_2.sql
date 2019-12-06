/*
  Variant #9
  group 651003
  Kornienko Anastasia
*/

USE AdventureWorks2012;
GO

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'StateProvince' AND DATA_TYPE != 'uniqueidentifier'
GO

-- point a)
-- "...Indexes, constraints, and triggers defind in the source table are not transferred to the new table, nor can they be specified in the SELECT...INTO ..."
SELECT TOP 0 province.StateProvinceID,
       province.StateProvinceCode,
       province.CountryRegionCode,
	   province.IsOnlyStateProvinceFlag,
	   province.Name, province.TerritoryID,
       province.ModifiedDate
  INTO dbo.StateProvince FROM Person.StateProvince AS province
GO

--point b)
ALTER TABLE dbo.StateProvince ADD PRIMARY KEY(StateProvinceID, StateProvinceCode)
GO

--point c)
ALTER TABLE dbo.StateProvince
  ADD CONSTRAINT territory_even
  CHECK (TerritoryID % 2 = 0);
GO

--point d)
ALTER TABLE dbo.StateProvince
  ADD CONSTRAINT territory_def_value
  DEFAULT 2 FOR TerritoryID;
GO

--point e)
SET IDENTITY_INSERT dbo.StateProvince ON
INSERT INTO dbo.StateProvince
  (StateProvinceID,
   StateProvinceCode,
   CountryRegionCode,
   IsOnlyStateProvinceFlag,
   Name, ModifiedDate)
  SELECT province.StateProvinceID,
         province.StateProvinceCode,
		 province.CountryRegionCode,
		 province.IsOnlyStateProvinceFlag,
		 province.Name, province.ModifiedDate
    FROM (
      SELECT *,
	         MAX(AddressID) OVER(
			   PARTITION BY StateProvince.StateProvinceID, StateProvince.StateProvinceCode
			 ) maxAddressID
	    FROM Person.StateProvince AS StateProvince
	    INNER JOIN (
	      SELECT addr.AddressID,
		         addr.StateProvinceID StID
		    FROM Person.Address AS addr
		    INNER JOIN Person.BusinessEntityAddress AS entaddress
		      ON entaddress.AddressID = addr.AddressID
		    INNER JOIN Person.AddressType as addrtype
		      ON addrtype.AddressTypeID = entaddress.AddressTypeID
		    WHERE addrtype.Name = 'Shipping'
	    ) AS addrbase
	      ON addrbase.StID = StateProvince.StateProvinceID
	) AS province WHERE province.AddressID = province.maxAddressID
SET IDENTITY_INSERT dbo.StateProvince OFF
GO

SELECT * FROM dbo.StateProvince
GO

--point f)
ALTER TABLE dbo.StateProvince
  ALTER COLUMN IsOnlyStateProvinceFlag smallint NULL
GO

