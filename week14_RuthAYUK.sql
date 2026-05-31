--Table 1 Query:
Create Table EmployeeDemographics 
(EmployeeID int, 
FirstName varchar(50), 
LastName varchar(50), 
Age int, 
Gender varchar(50)
)

--Table 2 Query:
Create Table EmployeeSalary 
(EmployeeID int, 
JobTitle varchar(50), 
Salary int
)

--Table 1 Insert:
Insert into EmployeeDemographics VALUES
(1001, 'Jim', 'Halpert', 30, 'Male'),
(1002, 'Pam', 'Beasley', 30, 'Female'),
(1003, 'Dwight', 'Schrute', 29, 'Male'),
(1004, 'Angela', 'Martin', 31, 'Female'),
(1005, 'Toby', 'Flenderson', 32, 'Male'),
(1006, 'Michael', 'Scott', 35, 'Male'),
(1007, 'Meredith', 'Palmer', 32, 'Female'),
(1008, 'Stanley', 'Hudson', 38, 'Male'),
(1009, 'Kevin', 'Malone', 31, 'Male'),
(1011, 'Ryan', 'Howard',26, 'Male'),
(NULL, 'Holly', 'Flax',NULL,NULL),
(1013,'Darryl', 'Philbin',NULL, 'Male')

--Table 2 Insert:
Insert Into EmployeeSalary VALUES
(1001, 'Salesman', 45000),
(1002, 'Receptionist', 36000),
(1003, 'Salesman', 63000),
(1004, 'Accountant', 47000),
(1005, 'HR', 50000),
(1006, 'Regional Manager', 65000),
(1007, 'Supplier Relations', 41000),
(1008, 'Salesman', 48000),
(1009, 'Accountant', 42000),
(1010,NULL, 47000),
(NULL,'Salesman',43000)

/* 
inner joins ,left join ,right join,full outer join
*/
SELECT  * 
FROM SQLTutorial.dbo.EmployeeDemographics AS ed

SELECT  *
FROM SQLTutorial.dbo.EmployeeSalary AS es

SELECT * 
FROM SQLTutorial.dbo.EmployeeDemographics AS ed
INNER JOIN SQLTutorial.dbo.EmployeeSalary AS es
	ON ed.EmployeeID = es.EmployeeID

-- full outer join is used to combine rows from two or more tables based on a related column between them.


SELECT * 
FROM SQLTutorial.dbo.EmployeeDemographics AS ed
FULL OUTER JOIN SQLTutorial.dbo.EmployeeSalary AS es
	ON ed.EmployeeID = es.EmployeeID

--LEFT JOIN is used to combine rows from two or more tables based on a related column between them.

SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics AS ed
LEFT JOIN SQLTutorial.dbo.EmployeeSalary AS es
	ON ed.EmployeeID = es.EmployeeID


SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics AS ed
RIGHT JOIN SQLTutorial.dbo.EmployeeSalary AS es
	ON ed.EmployeeID = es.EmployeeID

-- Selecting specific columns from the tables using inner join using alias
SELECT ed.EmployeeID, ed.FirstName, ed.LastName, es.JobTitle, es.Salary
FROM SQLTutorial.dbo.EmployeeDemographics 
INNER JOIN SQLTutorial.dbo.EmployeeSalary 
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

-- Selecting specific columns from the tables using right join using alias
SELECT ed.EmployeeID, ed.FirstName, ed.LastName, es.JobTitle, es.Salary
FROM SQLTutorial.dbo.EmployeeDemographics 
RIGHT JOIN SQLTutorial.dbo.EmployeeSalary 
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

-- Business logic : to find the employee who has the highest salary in the company and also find the employee who has the lowest salary in the company.
SELECT ed.EmployeeID, ed.FirstName, ed.LastName, es.JobTitle, es.Salary
FROM SQLTutorial.dbo.EmployeeDemographics AS ed
INNER JOIN SQLTutorial.dbo.EmployeeSalary AS es
	ON ed.EmployeeID = es.EmployeeID
WHERE es.Salary = (SELECT MAX(Salary) FROM SQLTutorial.dbo.EmployeeSalary)
OR  es.Salary = (SELECT MIN(Salary) FROM SQLTutorial.dbo.EmployeeSalary)
			
-- Business logic : to find every  employee salary except michael scott
SELECT ed.EmployeeID, ed.FirstName, ed.LastName, es.JobTitle, es.Salary
FROM SQLTutorial.dbo.EmployeeDemographics AS ed
INNER JOIN SQLTutorial.dbo.EmployeeSalary AS es
	ON ed.EmployeeID = es.EmployeeID
WHERE ed.FirstName != 'Michael' AND ed.LastName != 'Scott'
ORDER BY Salary DESC;

-- alternatively we can also use NOT IN operator to find every employee salary except michael scott
SELECT ed.EmployeeID, ed.FirstName, ed.LastName, es.JobTitle, es.Salary
FROM SQLTutorial.dbo.EmployeeDemographics AS ed
INNER JOIN SQLTutorial.dbo.EmployeeSalary AS es
	ON ed.EmployeeID = es.EmployeeID
WHERE ed.EmployeeID NOT IN (SELECT EmployeeID FROM SQLTutorial.dbo.EmployeeDemographics WHERE FirstName = 'Michael' AND LastName = 'Scott')
ORDER BY Salary DESC;

-- alterntively we can also use <> operator to find every employee salary except michael scott
SELECT ed.EmployeeID, ed.FirstName, ed.LastName, es.JobTitle, es.Salary
FROM SQLTutorial.dbo.EmployeeDemographics AS ed
INNER JOIN SQLTutorial.dbo.EmployeeSalary AS es
	ON ed.EmployeeID = es.EmployeeID
WHERE ed.FirstName <> 'Michael' AND ed.LastName <> 'Scott'
ORDER BY Salary DESC;

-- average salary of the employees in the company group by job title where jobtitle is salesman
SELECT es.JobTitle, AVG(es.Salary) AS AverageSalary
FROM SQLTutorial.dbo.EmployeeSalary AS es
INNER JOIN SQLTutorial.dbo.EmployeeDemographics AS ed
	ON es.EmployeeID = ed.EmployeeID
WHERE es.JobTitle = 'Salesman'
GROUP BY es.JobTitle;

-- average salary of the employees in the company group by job title where jobtitle is not salesman
SELECT es.JobTitle, AVG(es.Salary) AS AverageSalary
FROM SQLTutorial.dbo.EmployeeSalary AS es
INNER JOIN SQLTutorial.dbo.EmployeeDemographics AS ed
	ON es.EmployeeID = ed.EmployeeID
WHERE es.JobTitle <> 'Salesman'
GROUP BY es.JobTitle;


--Table 3 Query:
DROP TABLE IF EXISTS WareHouseEmployeeDemographics;

Create Table WareHouseEmployeeDemographics 
(EmployeeID int, 
FirstName varchar(50), 
LastName varchar(50), 
Age int, 
Gender varchar(50)
)

INSERT INTO WareHouseEmployeeDemographics VALUES
(1050, 'Roy','Anderson',31,'Male'),
(1051,'Hidetoshi','Hasagawa',40,'Male'),
(1052,'Val','Johnson',31,'Female'),
(1013,'Darryl','Philbin',NULL,'Male')

SELECT * FROM WareHouseEmployeeDemographics;

/* Union, Union All*/


SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics AS ed
UNION 
SELECT *
FROM SQLTutorial.dbo.WareHouseEmployeeDemographics AS wed

-- Union All is used to combine the result set of two or more SELECT statements.
-- unlike union, Union All does not remove duplicate rows between the various SELECT statements.

SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics AS ed
UNION ALL
SELECT *
FROM SQLTutorial.dbo.WareHouseEmployeeDemographics AS wed
ORDER BY EmployeeID

/*Case Statement*/
-- Example 0:
SELECT EmployeeID, FirstName, LastName, Age,
CASE 
	WHEN Age < 30 THEN 'Young'
	WHEN Age >= 30 AND Age < 40 THEN 'Middle-aged'
	WHEN Age >= 40 THEN 'Senior'
	ELSE 'Unknown'
END AS AgeGroup
FROM SQLTutorial.dbo.EmployeeDemographics

-- EXAMPLE 1:
SELECT FirstName, LastName,Age,
CASE 
	WHEN Age > 38 THEN 'Stanley'
	WHEN Age > 30 THEN 'Old'
	ELSE 'Baby'
END AS Agegroup
FROM SQLTutorial.dbo.EmployeeDemographics
WHERE Age IS NOT NULL
ORDER BY Age

-- Example 3:
SELECT FirstName, LastName, JobTitle, Salary,
CASE
	WHEN JobTitle = 'Salesman' THEN Salary + (Salary * .10)
	WHEN JobTitle = 'Accountant' THEN Salary + (Salary * .05)
	WHEN JobTitle = 'HR'THEN  Salary + (Salary * .000001)
	ELSE Salary + (Salary * .03)
END AS SalaryAfterRaise
FROM SQLTutorial.dbo.EmployeeDemographics
JOIN SQLTutorial.dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

-- updating SalaryAfterRaise column to 2 decimal places
SELECT FirstName, LastName, JobTitle, Salary,
       CAST(
           CASE
               WHEN JobTitle = 'Salesman' THEN Salary + (Salary * .10)
               WHEN JobTitle = 'Accountant' THEN Salary + (Salary * .05)
               WHEN JobTitle = 'HR' THEN Salary + (Salary * .000001)
               ELSE Salary + (Salary * .03)
           END 
       AS DECIMAL(18, 2)) AS SalaryAfterRaise
FROM SQLTutorial.dbo.EmployeeDemographics
JOIN SQLTutorial.dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

/*Updating/Deleting Records*/
SELECT * FROM SQLTutorial.dbo.EmployeeDemographics
-- updating the employee id of holly flax to 1012
UPDATE SQLTutorial.dbo.EmployeeDemographics
SET EmployeeID = 1012
WHERE FirstName = 'Holly' AND LastName = 'Flax';

--UPDATE SQLTutorial.dbo.EmployeeDemographics

UPDATE SQLTutorial.dbo.EmployeeDemographics
SET Age = 31, Gender = 'Female'
WHERE FirstName = 'Holly';

--Deleting record refers to removing existing data from a table.

delete from SQLTutorial.dbo.EmployeeDemographics
WHERE FirstName = 'Toby' AND LastName = 'Flenderson';

--we can delete multiple records from the EmployeeDemographics table where the age is greater than 35.
delete from SQLTutorial.dbo.EmployeeDemographics
WHERE Age < 25;