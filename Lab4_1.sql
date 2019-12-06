/*
  Variant #9
  group 651003
  Kornienko Anastasia
*/

USE AdventureWorks2012;
GO

--point a)
-- char(6) for action because the maximum word length in data set is 6.
CREATE TABLE Sales.SpecialOfferHst (
  ID INT IDENTITY(1, 1) PRIMARY KEY,
  Action CHAR(6) NOT NULL CHECK(Action IN('insert', 'update', 'delete')),
  ModifiedDate DATETIME NOT NULL,
  SourceID INT NOT NULL,
  UserName VARCHAR(50) NOT NULL
);

SELECT * FROM Sales.SpecialOfferHst
GO

--point b)
CREATE TRIGGER Sales.[SpecialOffer.InsertTrigger]
  ON Sales.SpecialOffer
  AFTER INSERT AS
    INSERT INTO Sales.SpecialOfferHst(
	  Action,
	  ModifiedDate,
	  SourceID,
	  UserName
	)
	SELECT 'insert',
	       GETDATE(),
		   inserted.SpecialOfferID,
		   USER_NAME()
	FROM inserted;
GO

CREATE TRIGGER Sales.[SpecialOffer.UpdateTrigger]
  ON Sales.SpecialOffer
  AFTER UPDATE AS
    INSERT INTO Sales.SpecialOfferHst(
	  Action,
	  ModifiedDate,
	  SourceID,
	  UserName
	)
	SELECT 'update',
	       GETDATE(),
		   inserted.SpecialOfferID,
		   USER_NAME()
	FROM inserted;
GO

CREATE TRIGGER Sales.[SpecialOffer.DeleteTrigger]
  ON Sales.SpecialOffer
  AFTER DELETE AS
    INSERT INTO Sales.SpecialOfferHst(
	  Action,
	  ModifiedDate,
	  SourceID,
	  UserName
	)
	SELECT 'delete',
	       GETDATE(),
		   deleted.SpecialOfferID,
		   USER_NAME()
	FROM deleted;
GO

--pont c)
CREATE VIEW Sales.SpecialOfferView
  WITH ENCRYPTION
  AS SELECT * FROM Sales.SpecialOffer;
GO

SELECT * from Sales.SpecialOffer;
SELECT * from Sales.SpecialOfferView;

--point d)
INSERT INTO Sales.SpecialOfferView (
  Description,
  DiscountPct,
  Type,
  Category,
  StartDate,
  EndDate
)
  VALUES (
    'Description',
	0.15,
	'Seasonal Discount',
	'Reseller',
	GETDATE(),
	GETDATE()
  );

UPDATE Sales.SpecialOfferView
  SET Category = 'Customer'
  WHERE SpecialOfferID = (
    SELECT MAX(SpecialOfferID) FROM Sales.SpecialOfferView
  );

DELETE Sales.SpecialOfferView
  WHERE SpecialOfferID = (
    SELECT MAX(SpecialOfferID) FROM Sales.SpecialOfferView
  );


SELECT * FROM Sales.SpecialOfferHst;
GO
