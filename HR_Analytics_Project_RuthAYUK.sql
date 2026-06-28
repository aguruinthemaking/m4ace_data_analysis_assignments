-- 1. Safely clear out any failed table attempts
IF OBJECT_ID('dbo.clean_hr_roster', 'U') IS NOT NULL 
    DROP TABLE dbo.clean_hr_roster;
GO

-- 2. Create the clean table with the exact correct column names
SELECT 
    TRIM(id) AS employee_id,
    CONCAT(TRIM(last_name), ', ', TRIM(first_name)) AS employee_name,
    gender,
    race,
    department,
    TRIM(jobtitle) AS job_title,
    location AS location_type,
    TRIM(location_city) AS city,
    TRIM(location_state) AS state,
    
 
    TRY_CAST(hire_date AS DATE) AS hire_date,
    
    CASE 
        WHEN termdate LIKE '%Present%' OR TRIM(termdate) = '' OR termdate IS NULL THEN NULL
        ELSE TRY_CAST(TRIM(termdate) AS DATE) 
    END AS term_date
INTO dbo.clean_hr_roster
FROM dbo.HR_Analytics_Project_RuthAYUK;
GO


-- 2. Clean termdate (Extract first 19 chars to drop ' UTC')
UPDATE [dbo].[HR_Analytics_Project_RuthAYUK]
SET termdate = TRY_CAST(LEFT(NULLIF(termdate, ''), 19) AS DATETIME)
WHERE termdate IS NOT NULL AND termdate != '';
GO

-- 3. Clean birthdate and fix future-year bugs
UPDATE [dbo].[HR_Analytics_Project_RuthAYUK]
SET birthdate = CASE
    -- If the parsed date is in the future, subtract 100 years
    WHEN TRY_CAST(birthdate AS DATE) > GETDATE() 
    THEN DATEADD(year, -100, TRY_CAST(birthdate AS DATE))
    ELSE TRY_CAST(birthdate AS DATE)
END;
GO

-- Safely clear out the old table to prevent name collisions
IF OBJECT_ID('dbo.clean_hr_roster', 'U') IS NOT NULL 
    DROP TABLE dbo.clean_hr_roster;
GO
    

-- Ensure the engine resets memory before starting the CTE with a semicolon
;WITH RetentionMetrics AS (
    SELECT 
        department,
        COUNT(employee_id) AS total_lifetime_hires,
        COUNT(term_date) AS total_exits,
        
        -- Safe SQL Server DATEDIFF for checking early exits under 90 days
        SUM(CASE WHEN term_date IS NOT NULL AND DATEDIFF(DAY, hire_date, term_date) <= 90 THEN 1 ELSE 0 END) AS early_90_day_exits,
        
        -- Lifespan analysis converted safely to years
        ROUND(AVG(CASE WHEN term_date IS NOT NULL THEN CAST(DATEDIFF(DAY, hire_date, term_date) AS DECIMAL(10,2)) / 365.25 END), 1) AS avg_years_before_exit,
        ROUND(AVG(CASE WHEN term_date IS NULL THEN CAST(DATEDIFF(DAY, hire_date, GETDATE()) AS DECIMAL(10,2)) / 365.25 END), 1) AS active_staff_avg_tenure
    FROM dbo.clean_hr_roster
    GROUP BY department
)
SELECT 
    department,
    total_lifetime_hires,
    total_exits,
    (total_lifetime_hires - total_exits) AS current_active_headcount,
    ROUND(100.0 * total_exits / total_lifetime_hires, 2) AS lifecycle_turnover_rate_pct,
    ROUND(100.0 * early_90_day_exits / total_lifetime_hires, 2) AS onboarding_failure_rate_pct,
    avg_years_before_exit,
    active_staff_avg_tenure
FROM RetentionMetrics
ORDER BY lifecycle_turnover_rate_pct DESC;
GO


SELECT name 
FROM sys.tables 
WHERE name LIKE '%RuthAYUK%';

SELECT 
    department,
    COUNT(*) AS total_lifetime_hires,
    COUNT(term_date) AS total_exits,
    -- Basic Turnover calculation: (Total Exits / Total Hires) * 100
    ROUND(100.0 * COUNT(term_date) / COUNT(*), 2) AS department_turnover_rate_pct
FROM dbo.clean_hr_roster
WHERE hire_date IS NOT NULL
GROUP BY department
ORDER BY department_turnover_rate_pct DESC; -- Places the biggest problem areas at the top
GO

SELECT 
    department,
    COUNT(*) AS total_hires,
    -- Count only people whose total stay was 90 days or less
    SUM(CASE WHEN term_date IS NOT NULL AND DATEDIFF(DAY, hire_date, term_date) <= 90 THEN 1 ELSE 0 END) AS early_90_day_exits,
    -- Calculate what percentage of total hires left immediately
    ROUND(100.0 * SUM(CASE WHEN term_date IS NOT NULL AND DATEDIFF(DAY, hire_date, term_date) <= 90 THEN 1 ELSE 0 END) / COUNT(*), 2) AS early_failure_rate_pct
FROM dbo.clean_hr_roster
WHERE hire_date IS NOT NULL
GROUP BY department
ORDER BY early_failure_rate_pct DESC;
GO

SELECT 
    department,
    -- Average years spent at the company for those who left
    ROUND(AVG(CASE WHEN term_date IS NOT NULL THEN CAST(DATEDIFF(DAY, hire_date, term_date) AS DECIMAL(10,2)) / 365.25 END), 1) AS avg_years_lasted_before_exit,
    -- Average years spent at the company for active workers who are still here
    ROUND(AVG(CASE WHEN term_date IS NULL THEN CAST(DATEDIFF(DAY, hire_date, GETDATE()) AS DECIMAL(10,2)) / 365.25 END), 1) AS active_workers_current_tenure_years
FROM dbo.clean_hr_roster
WHERE hire_date IS NOT NULL
GROUP BY department;
GO

SELECT COUNT(*) AS total_rows_inside_clean_table 
FROM dbo.clean_hr_roster;


-- Ensure SQL Server clears previous memory before launching the CTE
;WITH DepartmentalAverages AS (
    -- ========================================================
    -- 1. THE CTE: Calculate baseline stats for each department
    -- ========================================================
    SELECT 
        department,
        COUNT(employee_id) AS current_active_headcount,
        -- Calculate the overall average time people stay in this specific department
        AVG(CAST(DATEDIFF(DAY, hire_date, COALESCE(term_date, GETDATE())) AS DECIMAL(10,2)) / 365.25) AS dept_avg_tenure_years
    FROM dbo.clean_hr_roster
    WHERE hire_date IS NOT NULL
    GROUP BY department
)
SELECT 
    emp.employee_id,
    emp.employee_name,
    emp.department,
    emp.job_title,
    emp.state,
    
    -- Calculate this specific employee's current tenure in years
    ROUND(CAST(DATEDIFF(DAY, emp.hire_date, COALESCE(emp.term_date, GETDATE())) AS DECIMAL(10,2)) / 365.25, 1) AS employee_tenure_years,
    
    -- Pull the department baseline tenure straight from our CTE block above
    ROUND(base.dept_avg_tenure_years, 1) AS department_average_tenure,

    -- ========================================================
    -- 2. THE WINDOW FUNCTION: Rank employees by seniority within their department
    -- ========================================================
    DENSE_RANK() OVER (PARTITION BY emp.department ORDER BY emp.hire_date ASC) AS seniority_rank_in_dept,

    -- Dynamic Insight Flag comparing individual tenure against department average
    CASE 
        WHEN emp.term_date IS NULL AND (DATEDIFF(DAY, emp.hire_date, GETDATE()) / 365.25) > base.dept_avg_tenure_years THEN 'Loyal Veteran (Above Avg Tenure)'
        WHEN emp.term_date IS NULL AND (DATEDIFF(DAY, emp.hire_date, GETDATE()) / 365.25) <= 1.0 THEN 'New Hire (Under 1 Year)'
        WHEN emp.term_date IS NOT NULL THEN 'Exited Employee'
        ELSE 'Standard Active Employee'
    END AS employee_retention_status

FROM dbo.clean_hr_roster emp
-- ========================================================
-- 3. THE JOIN: Connect the individual records to the department averages
-- ========================================================
JOIN DepartmentalAverages base ON emp.department = base.department

-- Order the results neatly by department and seniority rank
ORDER BY emp.department, seniority_rank_in_dept ASC;
GO
