CREATE DATABASE EMS_Project;
USE EMS_Project;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    JobID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    Name VARCHAR(100),
    Description TEXT,
    SalaryRange VARCHAR(50)
);

SELECT * FROM JobDepartment;

-- Table 2: Salary/Bonus 
CREATE TABLE SalaryBonus (
    SalaryID INT PRIMARY KEY,
    JobID INT,
    Amount DECIMAL(10,2),
    Annual DECIMAL(10,2),
    Bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (jobID) REFERENCES JobDepartment(JobID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

SELECT * FROM SalaryBonus;

-- Table 3: Employee 
CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    Firstname VARCHAR(50),
    Lastname VARCHAR(50),
    Gender VARCHAR(10),
    Age INT,
    contactAddress VARCHAR(100),
    EmpEmail VARCHAR(100) UNIQUE,
    Emppass VARCHAR(50),
    JobID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (JobID)
        REFERENCES JobDepartment(JobID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

SELECT * FROM Employee;

-- Table 4: Qualification  
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    EmpID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (EmpID)
        REFERENCES Employee(EmpID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

SELECT * FROM Qualification;

-- Table 5: Leaves  
CREATE TABLE Leaves (
    LeaveID INT PRIMARY KEY,
    EmpID INT,
    Date DATE,
    Reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (EmpID) REFERENCES Employee(EmpID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

SELECT * FROM Leaves;

-- Table 6: Payroll PayrollID	EmpID	JobID	SalaryID	LeaveID	Date	Report	TotalAmount
CREATE TABLE Payroll (
    PayrollID INT PRIMARY KEY,
    EmpID INT,
    JobID INT,
    SalaryID INT,
    LeaveID INT,
    Date DATE,
    Report TEXT,
    TotalAmount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (EmpID) REFERENCES Employee(EmpID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (JobID) REFERENCES JobDepartment(JobID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (SalaryID) REFERENCES SalaryBonus(SalaryID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (LeaveID) REFERENCES Leaves(LeaveID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

SELECT * FROM payroll;

-- EMPLOYEE INSIGHTS 
-- How many unique employees are currently in the system?
SELECT COUNT(DISTINCT EmpID) AS total_employees
FROM Employee;

-- Which departments have the highest number of employees?
SELECT jd.jobdept, COUNT(e.EmpID) AS employee_count
FROM Employee e
JOIN JobDepartment jd ON e.JobID = jd.JobID
GROUP BY jd.jobdept
ORDER BY employee_count DESC;

-- is the average salary per department? 
SELECT jd.jobdept, AVG(sb.amount) AS avg_salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.JobID = jd.JobID
GROUP BY jd.jobdept;

-- Who are the top 5 highest-paid employees?
SELECT e.Firstname, e.Lastname, sb.amount AS salary
FROM Employee e
JOIN SalaryBonus sb ON e.JobID = sb.JobID
ORDER BY sb.amount DESC
LIMIT 5;

-- What is the total salary expenditure across the company?
SELECT SUM(amount) AS total_salary_expenditure
FROM SalaryBonus;

-- JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
SELECT jobdept, COUNT(DISTINCT name) AS total_job_roles
FROM JobDepartment
GROUP BY jobdept;

-- What is the average salary range per department?
SELECT jd.jobdept, AVG(sb.amount) AS avg_salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.JobID = jd.JobID
GROUP BY jd.jobdept;

-- Which job roles offer the highest salary?
SELECT jd.name AS job_role, sb.amount AS highest_salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.JobID = jd.JobID
ORDER BY sb.amount DESC;

-- Which departments have the highest total salary allocation?
SELECT jd.jobdept, SUM(sb.amount) AS total_salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.JobID = jd.JobID
GROUP BY jd.jobdept
ORDER BY total_salary DESC;

--  QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT EmpID) AS employees_with_qualifications
FROM Qualification;

-- Which positions require the most qualifications?
SELECT Position, COUNT(*) AS qualification_count
FROM Qualification
GROUP BY Position
ORDER BY qualification_count DESC;

-- Which employees have the highest number of qualifications?
SELECT EmpID, COUNT(*) AS total_qualifications
FROM Qualification
GROUP BY EmpID
ORDER BY total_qualifications DESC;

-- LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?
SELECT YEAR(Date) AS year, COUNT(DISTINCT EmpID) AS employees_on_leave
FROM Leaves
GROUP BY YEAR(Date)
ORDER BY employees_on_leave DESC;

-- Average number of leave days taken per department?
SELECT jd.jobdept, COUNT(l.LeaveID) / COUNT(DISTINCT e.EmpID) AS avg_leave_days
FROM Leaves l
JOIN Employee e ON l.EmpID = e.EmpID
JOIN JobDepartment jd ON e.JobID = jd.JobID
GROUP BY jd.jobdept;

-- Which employees have taken the most leaves?
SELECT EmpID, COUNT(*) AS total_leaves
FROM Leaves
GROUP BY EmpID
ORDER BY total_leaves DESC;

-- Total number of leave days taken company-wide?
SELECT COUNT(*) AS total_leave_days
FROM Leaves;

-- How do leave days correlate with payroll amounts?
SELECT e.EmpID, COUNT(l.LeaveID) AS leave_days, AVG(p.TotalAmount) AS avg_payroll
FROM Employee e
LEFT JOIN Leaves l ON e.EmpID = l.EmpID
LEFT JOIN Payroll p ON e.EmpID = p.EmpID
GROUP BY e.EmpID;

-- PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
SELECT DATE_FORMAT(Date, '%Y-%m') AS month, SUM(TotalAmount) AS total_payroll
FROM Payroll
GROUP BY DATE_FORMAT(Date, '%Y-%m');

-- What is the average bonus given per department?
SELECT jd.jobdept, AVG(sb.bonus) AS avg_bonus
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.JobID = jd.JobID
GROUP BY jd.jobdept;

-- Which department receives the highest total bonuses?
SELECT jd.jobdept, SUM(sb.bonus) AS total_bonus
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.JobID = jd.JobID
GROUP BY jd.jobdept
ORDER BY total_bonus DESC;
 
 
--  What is the average value of TotalAmount after leave deductions?
SELECT AVG(TotalAmount) AS avg_net_payroll
FROM Payroll;



