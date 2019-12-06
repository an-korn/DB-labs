/*
  Variant #9
  group 651003
  Kornienko Anastasia
*/

USE AdventureWorks2012;
GO

SELECT Employee.BusinessEntityID, JobTitle, SUM(Rate) AS AvarageRate FROM HumanResources.Employee AS Employee
  INNER JOIN HumanResources.EmployeePayHistory AS EmployeePayHistory
    ON Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID
  GROUP BY Employee.BusinessEntityID, JobTitle;
GO

SELECT Employee.BusinessEntityID, JobTitle, Rate,
  CASE WHEN Rate < 51 THEN 'Less or equal 50'
       WHEN Rate > 100 THEN 'More than 100'
	   ELSE 'More than 50 but less or equal 100' END AS RateReport
  FROM HumanResources.Employee AS Employee
  INNER JOIN HumanResources.EmployeePayHistory AS EmployeePayHistory
    ON Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID
GO

SELECT Name, MAX(Rate) AS MaxRate FROM HumanResources.Employee AS Employee
  INNER JOIN HumanResources.EmployeePayHistory AS EmployeePayHistory
    ON Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID
  INNER JOIN (SELECT BusinessEntityID, Name FROM HumanResources.Department AS Department
              INNER JOIN HumanResources.EmployeeDepartmentHistory AS EmployeeDepartmentHistory
			  ON EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID)
	AS Department ON Employee.BusinessEntityID = Department.BusinessEntityID
  GROUP BY Name
  ORDER BY MaxRate;
GO