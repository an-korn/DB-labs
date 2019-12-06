/*
  Variant #9
  group 651003
  Kornienko Anastasia
*/

USE AdventureWorks2012;
GO

SELECT BusinessEntityID, JobTitle, BirthDate, HireDate FROM HumanResources.Employee
  WHERE BirthDate > '1980-12-31' AND HireDate > '1983-04-01';
GO

SELECT SUM(VacationHours) AS SumVacationHours, SUM(SickLeaveHours) AS SumSickLeaveHours
  FROM HumanResources.Employee;
GO

SELECT TOP 3 BusinessEntityID, JobTitle, Gender, BirthDate, HireDate FROM HumanResources.Employee
  ORDER BY HireDate;
GO