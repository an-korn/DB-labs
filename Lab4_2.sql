/*
  Variant #9
  group 651003
  Kornienko Anastasia
*/

USE AdventureWorks2012;
GO

--point a)
CREATE VIEW Sales.SpecialOfferWithProductView(
  SpecialOfferID,
  ProductID,
  Name,
  Description,
  DiscountPct,
  Type,
  Category,
  StartDate,
  EndDate,
  MinQty,
  MaxQty,
  OfferRowguid,
  OfferProductRowguid,
  OfferModifiedDate,
  OfferProductModifiedDate
) 
  WITH SCHEMABINDING
  AS SELECT SpecialOffer.SpecialOfferID,
             OfferProduct.ProductID,
			 Product.Name,
			 SpecialOffer.Description,
			 SpecialOffer.DiscountPct,
			 SpecialOffer.Type,
			 SpecialOffer.Category,
			 SpecialOffer.StartDate,
			 SpecialOffer.EndDate,
			 SpecialOffer.MinQty,
			 SpecialOffer.MaxQty,
			 SpecialOffer.rowguid,
			 OfferProduct.rowguid,
			 SpecialOffer.ModifiedDate,
			 OfferProduct.ModifiedDate
  FROM Sales.SpecialOffer SpecialOffer
  JOIN Sales.SpecialOfferProduct OfferProduct
    ON SpecialOffer.SpecialOfferID = OfferProduct.SpecialOfferID
  JOIN Production.Product Product
    ON Product.ProductID = OfferProduct.ProductID;

SELECT * FROM Sales.SpecialOfferWithProductView;
GO

CREATE UNIQUE CLUSTERED INDEX I_SpecialOfferWithProductView_SpecialOfferID_ProductID
  ON Sales.SpecialOfferWithProductView (
    SpecialOfferID,
	ProductID
  )
GO

--point b)
CREATE TRIGGER Sales.SpecialOfferWithProductViewCommonTrigger
  ON Sales.SpecialOfferWithProductView
  INSTEAD OF INSERT, UPDATE, DELETE AS
  BEGIN
    --a new record or the record for updating should be located in the inserted temporary table
    IF EXISTS(SELECT * FROM inserted)
	BEGIN
	  /*
	    When update the record the record with the old data will be inserted into the "deleted" table
	    and the record with a new data for replacing will be inserted into the "inserted" table.
	    So for indicating what the action is happening now, there should be one more check:
		  - for the new record - it should not be in the deleted table
		  - for the updated record - there should be the one with the replaced data.
	  */ 
	  IF NOT EXISTS(SELECT * FROM deleted) -- for a new record
	  BEGIN
	    INSERT INTO Sales.SpecialOffer(
		   Description,
	       DiscountPct,
	       Type,
	       Category,
	       StartDate,
	       EndDate,
		   MinQty,
		   MaxQty,
		   rowguid,
	       ModifiedDate
		)
		SELECT
		   inserted.Description,
		   inserted.DiscountPct,
	       inserted.Type,
	       inserted.Category,
	       inserted.StartDate,
	       inserted.EndDate,
		   inserted.MinQty,
		   inserted.MaxQty,
		   inserted.OfferRowguid,
		   GETDATE()
		FROM inserted
        INSERT INTO Sales.SpecialOfferProduct (
		   SpecialOfferID,
		   ProductID,
		   rowguid,
		   ModifiedDate
		)
		SELECT
		   SpecialOffer.SpecialOfferID,
		   Product.ProductID,
		   inserted.OfferProductRowguid,
		   GETDATE()
		FROM inserted
		JOIN Production.Product Product
		  ON Product.Name = inserted.Name
		JOIN Sales.SpecialOffer SpecialOffer
		  ON SpecialOffer.rowguid = inserted.OfferRowguid
	  END
	  ELSE
	  BEGIN
	    UPDATE Sales.SpecialOffer
		SET 
		   Category = inserted.Category,
		   Description = inserted.Description,
		   DiscountPct = inserted.DiscountPct,
		   Type = inserted.Type,
		   StartDate = inserted.StartDate,
	       EndDate = inserted.EndDate,
		   MinQty = inserted.MinQty,
		   MaxQty = inserted.MaxQty,
		   ModifiedDate = GETDATE() 
		FROM inserted, deleted
		WHERE Sales.SpecialOffer.SpecialOfferID = deleted.SpecialOfferID
	  END
	END
	ELSE
	BEGIN
	  ALTER TABLE Sales.SpecialOfferProduct NOCHECK CONSTRAINT FK_SpecialOfferProduct_SpecialOffer_SpecialOfferID
	  DELETE FROM Sales.SpecialOfferProduct
	  WHERE SpecialOfferID IN (SELECT SpecialOfferID FROM deleted)
	    AND ProductID IN (SELECT ProductID FROM deleted)
	  
	  DELETE FROM Sales.SpecialOffer
	  WHERE SpecialOfferID IN (SELECT SpecialOfferID FROM deleted)
	END
  END;
GO

--point c)
INSERT INTO Sales.SpecialOfferWithProductView (
  Description,
  DiscountPct,
  Type,
  Category,
  StartDate,
  EndDate,
  MinQty,
  MaxQty,
  Name,
  OfferProductRowguid,
  OfferRowguid
)
  VALUES (
    'Description',
	0.15,
	'Seasonal Discount',
	'Reseller',
	GETDATE(),
	GETDATE(),
	11,
	18,
	'Adjustable Race',
	NEWID(),
	NEWID()
  );

SELECT * FROM Sales.SpecialOffer;
SELECT * FROM Sales.SpecialOfferProduct;
SELECT * FROM Sales.SpecialOfferWithProductView;


UPDATE Sales.SpecialOfferWithProductView
  SET Category = 'Customer',
      Description = 'Description2',
	  DiscountPct = 0.20,
      Type = 'Volume Discount',
	  NAME = 'LL Fork'
  WHERE Name = 'Adjustable Race';

SELECT * FROM Sales.SpecialOffer;
SELECT * FROM Sales.SpecialOfferProduct;
SELECT * FROM Sales.SpecialOfferWithProductView;

DELETE Sales.SpecialOfferWithProductView
  WHERE Name = 'Adjustable Race';

SELECT * FROM Sales.SpecialOffer;
SELECT * FROM Sales.SpecialOfferProduct;
SELECT * FROM Sales.SpecialOfferWithProductView;
