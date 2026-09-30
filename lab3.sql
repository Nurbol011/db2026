CREATE TABLE departments (
                             dept_id SERIAL PRIMARY KEY,
                             dept_name VARCHAR(100) NOT NULL,
                             budget INTEGER,
                             manager_id INTEGER
);

CREATE TABLE employees (
                           emp_id SERIAL PRIMARY KEY,
                           first_name VARCHAR(50),
                           last_name VARCHAR(50),
                           department VARCHAR(50),
                           salary INTEGER,
                           hire_date DATE,
                           status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE projects (
                          project_id SERIAL PRIMARY KEY,
                          project_name VARCHAR(100),
                          dept_id INTEGER REFERENCES departments(dept_id),
                          start_date DATE,
                          end_date DATE,
                          budget INTEGER
);

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'John', 'Doe', 'IT');

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Jane', 'Smith', 'HR', DEFAULT, '2023-05-15', DEFAULT);

INSERT INTO departments (dept_name, budget, manager_id) VALUES
                                                            ('IT', 150000, 101),
                                                            ('HR', 80000, 102),
                                                            ('Sales', 200000, 103);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Alice', 'Johnson', 'IT', 50000 * 1.1, CURRENT_DATE, DEFAULT);

CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

UPDATE employees
SET salary = salary * 1.1;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
                     WHEN salary > 80000 THEN 'Management'
                     WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
                     ELSE 'Junior'
    END;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = (
    SELECT CAST(AVG(e.salary) * 1.2 AS INTEGER)
    FROM employees e
    WHERE e.department = d.dept_name
);

UPDATE employees
SET salary = CAST(salary * 1.15 AS INTEGER), status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
    RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Bob', 'Marley', NULL, NULL, '2022-01-01', 'Active');

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Michael', 'Scofield', 'Engineering', 75000, '2021-10-10')
    RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
    RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
    RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Sarah', 'Connor', 'Security', 65000, '2024-01-10'
    WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'Sarah' AND last_name = 'Connor'
);

UPDATE employees e
SET salary = CASE
                 WHEN (SELECT d.budget FROM departments d WHERE d.dept_name = e.department) > 100000
                     THEN CAST(e.salary * 1.1 AS INTEGER)
                 ELSE CAST(e.salary * 1.05 AS INTEGER)
    END
WHERE EXISTS (
    SELECT 1 FROM departments d WHERE d.dept_name = e.department
);

INSERT INTO employees (first_name, last_name, department, salary, hire_date) VALUES
                                                                                 ('User1', 'Test', 'IT', 40000, '2026-01-01'),
                                                                                 ('User2', 'Test', 'IT', 42000, '2026-01-01'),
                                                                                 ('User3', 'Test', 'HR', 38000, '2026-01-01'),
                                                                                 ('User4', 'Test', 'Sales', 45000, '2026-01-01'),
                                                                                 ('User5', 'Test', 'Sales', 47000, '2026-01-01');

UPDATE employees
SET salary = CAST(salary * 1.1 AS INTEGER)
WHERE last_name = 'Test';

CREATE TABLE IF NOT EXISTS employee_archive (
                                                LIKE employees INCLUDING ALL
);

WITH moved AS (
DELETE FROM employees
WHERE status = 'Inactive'
    RETURNING *
)
INSERT INTO employee_archive
SELECT * FROM moved;

UPDATE projects p
SET end_date = p.end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
    SELECT COUNT(*)
    FROM employees e
    WHERE e.department = (SELECT d.dept_name FROM departments d WHERE d.dept_id = p.dept_id)
    ) > 3;