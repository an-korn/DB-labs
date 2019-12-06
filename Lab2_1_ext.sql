/*
  Variant #10
  group 651003
  Kornienko Anastasia
*/

USE AdventureWorks2012;
GO

SELECT Employee.BusinessEntityID,
       JobTitle,
	   ROUND(Rate, 0) AS RoundRate,
	   Rate
  FROM HumanResources.Employee AS Employee
  INNER JOIN HumanResources.EmployeePayHistory AS EmployeePayHistory
    ON Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID
  GROUP BY Employee.BusinessEntityID, JobTitle, Rate;
GO

SELECT Employee.BusinessEntityID,
       JobTitle,
	   Rate,
	   RANK() OVER
	   (PARTITION BY Employee.BusinessEntityID ORDER BY RateChangeDate) AS ChangeNumber
  FROM HumanResources.Employee AS Employee
  INNER JOIN HumanResources.EmployeePayHistory AS EmployeePayHistory
    ON Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID;
GO

SELECT Name, JobTitle, HireDate, BirthDate
  FROM HumanResources.EmployeeDepartmentHistory AS EmployeeDepartmentHistory
  INNER JOIN HumanResources.Department AS Department
    ON EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID
  INNER JOIN HumanResources.Employee AS Employee
    ON Employee.BusinessEntityID = EmployeeDepartmentHistory.BusinessEntityID
  GROUP BY Name, JobTitle, HireDate, BirthDate
  ORDER BY JobTitle ASC,
    CASE
	  WHEN LEN(JobTitle) - LEN(REPLACE(LTRIM(RTRIM(JobTitle)), ' ', '')) = 0 THEN HireDate
	  WHEN LEN(JobTitle) - LEN(REPLACE(LTRIM(RTRIM(JobTitle)), ' ', '')) > 0 THEN BirthDate
	END DESC;
GO
