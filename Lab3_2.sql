/*
  Variant #9
  group 651003
  Kornienko Anastasia
*/

USE AdventureWorks2012;
GO

SELECT * FROM dbo.StateProvince;
GO

--pont a)
ALTER TABLE dbo.StateProvince
  ADD TaxRate SMALLMONEY,
      CurrencyCode NCHAR(3),
	  AvarageRate MONEY,
	  IntTaxRate AS CEILING(TaxRate);

SELECT * FROM dbo.StateProvince;
GO

--point b)
CREATE TABLE dbo.#StateProvince (
  StateProvinceID INT,
  StateProvinceCode NCHAR(3),
  CountryRegionCode NVARCHAR(3),
  IsOnlyStateProvinceFlag SMALLINT,
  Name NVARCHAR(50),
  TerritoryID INT,
  ModifiedDate DATETIME,
  TaxRate SMALLMONEY,
  CurrencyCode NCHAR(3),
  AvarageRate MONEY,
  PRIMARY KEY (StateProvinceID)
);

SELECT * FROM dbo.#StateProvince;
GO

--point c)
WITH RATE_CTE AS (
  SELECT MAX(CurrencyRate.AverageRate) MaxRate,
         ToCurrencyCode
  FROM Sales.CurrencyRate CurrencyRate
  GROUP BY ToCurrencyCode
)
INSERT INTO dbo.#StateProvince(
  StateProvinceID,
  StateProvinceCode,
  CountryRegionCode,
  IsOnlyStateProvinceFlag,
  Name,
  TerritoryID,
  ModifiedDate,
  TaxRate,
  CurrencyCode,
  AvarageRate
)
  SELECT StateProvince.StateProvinceID,
         StateProvinceCode,
         StateProvince.CountryRegionCode,
	     IsOnlyStateProvinceFlag,
	     StateProvince.Name,
	     TerritoryID,
	     StateProvince.ModifiedDate,
		 ISNULL(SalesTaxRate.TaxRate, 0),
	     Currency.CurrencyCode,
	     rate.MaxRate
  FROM dbo.StateProvince StateProvince
  JOIN Sales.CountryRegionCurrency CountryRegionCurrency
    ON CountryRegionCurrency.CountryRegionCode = StateProvince.CountryRegionCode
  JOIN Sales.Currency Currency
    ON Currency.CurrencyCode = CountryRegionCurrency.CurrencyCode
  JOIN RATE_CTE rate
    ON CountryRegionCurrency.CurrencyCode = rate.ToCurrencyCode
  LEFT JOIN Sales.SalesTaxRate SalesTaxRate
    ON SalesTaxRate.StateProvinceID = StateProvince.StateProvinceID
  WHERE SalesTaxRate.TaxType = 1 OR SalesTaxRate.TaxType IS NULL;
GO

SELECT * FROM dbo.#StateProvince;
SELECT * FROM dbo.StateProvince;

--point d)
DELETE FROM dbo.StateProvince WHERE CountryRegionCode = 'CA';

SELECT * FROM dbo.StateProvince;
SELECT * FROM dbo.#StateProvince;

--point e)
SET IDENTITY_INSERT dbo.StateProvince ON
MERGE INTO dbo.StateProvince targ
  USING dbo.#StateProvince src
  ON targ.StateProvinceID = src.StateProvinceID
WHEN MATCHED THEN UPDATE SET
  targ.TaxRate = src.TaxRate,
  targ.CurrencyCode = src.CurrencyCode,
  targ.AvarageRate = src.AvarageRate
WHEN NOT MATCHED BY TARGET THEN
  INSERT (
    StateProvinceID,
    StateProvinceCode,
    CountryRegionCode,
    IsOnlyStateProvinceFlag,
    Name,
    TerritoryID,
    ModifiedDate,
    TaxRate,
    CurrencyCode,
    AvarageRate
  )
  VALUES (
    src.StateProvinceID,
    src.StateProvinceCode,
    src.CountryRegionCode,
    src.IsOnlyStateProvinceFlag,
    src.Name,
    src.TerritoryID,
    src.ModifiedDate,
    src.TaxRate,
    src.CurrencyCode,
    src.AvarageRate
  )
WHEN NOT MATCHED BY SOURCE THEN DELETE;
SET IDENTITY_INSERT dbo.StateProvince OFF
GO

SELECT * FROM dbo.StateProvince;
SELECT * FROM dbo.#StateProvince;
GO