-- Topic: CTEs
USE SQLTutorial;
-- CTE is Common Table Expression, it is a temporary result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement.
-- CTE stores result as a temporary table that can be referenced within the main query. It is defined using the WITH keyword, followed by the CTE name and the query that generates the result set.
-- the query inside the CTE  is executed first, and the result is stored in a temporary table that can be referenced in the main query. This allows you to write more complex queries without having to repeat the same subquery multiple times.
-- here is an example of a CTE that calculates the average salary for each job title in the EmployeeSalary table:
-- CTE works likes a variable that holds the result of a query.
-- it can be called multiple times in the main query, which can help to improve performance by avoiding the need to repeat the same subquery multiple times.

WITH AverageSalary AS (
	SELECT JobTitle, AVG(Salary) AS AvgSalary
	FROM dbo.EmployeeSalary
	GROUP BY JobTitle
)

SELECT *
FROM AverageSalary;

-- partion by is used to divide the result set into partitions based on one or more columns. 
-- It is often used in conjunction with window functions to perform calculations across a set of rows that are related to the current row.
-- example of using PARTITION BY with a window function to calculate the average salary for each job title in the EmployeeSalary table:

WITH AverageSalary AS (
	SELECT JobTitle, Salary, AVG(Salary) OVER (PARTITION BY JobTitle) AS AvgSalary
	FROM dbo.EmployeeSalary
)
SELECT *
FROM AverageSalary;

--NOTE: The above query calculates the average salary for each job title and includes the original salary for each employee. 
--The PARTITION BY clause ensures that the average is calculated separately for each job title.

WITH EmployeeSummary AS (
SELECT FirstName, LastName,Gender,Salary,
COUNT(gender) OVER (PARTITION BY Gender) AS TotalGender,
AVG(Salary) OVER (PARTITION BY Gender) AS AvgSalary
FROM SQLTutorial.dbo.EmployeeDemographics AS emp
INNER JOIN SQLTutorial.dbo.EmployeeSalary AS sal
ON emp.EmployeeID = sal.EmployeeID
WHERE Salary > '45000'
)

SELECT FirstName,AvgSalary
FROM EmployeeSummary
WHERE TotalGender > 1;

/* Topic: Temp Tables*/
-- Temporary tables are used to store intermediate results that can be used in subsequent queries.
-- they differ from CTEs in that they are created and stored in the tempdb database, and they can be accessed by multiple queries within the same session.
-- Temporary tables are created using the CREATE TABLE statement, and they can be populated with data using the INSERT INTO statement.
-- example of creating a temporary table to store the average salary for each job title in the EmployeeSalary table:
CREATE TABLE #AverageSalary (
	JobTitle varchar(255),
	AvgSalary int
);
INSERT INTO #AverageSalary (JobTitle, AvgSalary)
VALUES ('Software Engineer', 80000),
('Data Analyst', 60000),
('Project Manager', 90000);

SELECT* FROM #AverageSalary;
--Note: Unlike CTEs, temp tables are peesistent and not like CTEs which are temporary and only exist during the execution of a single query.


-- The below query creates a temporary table called #temp_Employee, inserts a new record into it, and then populates it with data from the EmployeeSalary table.
-- Finally, it selects all records from the temporary table.
CREATE TABLE #temp_Employee (
EmployeeID int,
JobTitle varchar(100),
Salary int
);
INSERT INTO #temp_Employee (EmployeeID, JobTitle, Salary)
VALUES (1000, 'HR', 45000);

INSERT INTO #temp_Employee (EmployeeID, JobTitle, Salary)
SELECT * 
FROM SQLTutorial.dbo.EmployeeSalary;

SELECT * FROM #temp_Employee;

-- The below query creates a temporary table called #temp_Employee2, which stores the job title, number of employees per job, average age, and average salary for each job title.
CREATE TABLE #temp_Employee2 (
JobTitle varchar(100),
EmployeesPerJob int,
AvgAge int,
AvgSalary int
);
INSERT INTO #temp_Employee2 (JobTitle, EmployeesPerJob, AvgAge, AvgSalary)
SELECT JobTitle, COUNT(*) AS EmployeesPerJob, AVG(Age) AS AvgAge, AVG(Salary) AS AvgSalary
FROM  SQLTutorial.dbo.EmployeeDemographics AS emp
JOIN SQLTutorial.dbo.EmployeeSalary AS sal
	ON emp.EmployeeID = sal.EmployeeID
GROUP BY JobTitle;

SELECT * FROM #temp_Employee2;

/* Topic: Subqueries*/
-- A subquery is a query that is nested inside another query. 
-- It can be used to retrieve data that will be used in the main query.
-- Example below shows simple subquery that retrieves the average salary for each job title in the EmployeeSalary table and then selects all employees whose salary is above the average for their job title:
-- Below query uses a subquery to calculate the average salary for each job title and then selects all employees whose salary is above the average for their job title.
SELECT*
SELECT EmployeeID,Salary,AVG(Salary) OVER () AS AvgSalary
FROM SQLTutorial.dbo.EmployeeSalary
WHERE Salary > (SELECT AVG(Salary) FROM SQLTutorial.dbo.EmployeeSalary);

-- Outputs all employees whose salary is above the average salary for all employees in the EmployeeSalary table.
SELECT EmployeeID,JobTitle,Salary
FROM EmployeeSalary
WHERE EmployeeID IN (SELECT EmployeeID FROM EmployeeDemographics WHERE Age > 30);

--END

