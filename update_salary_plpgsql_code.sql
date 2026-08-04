-- =============================================
-- Employee Table
-- =============================================

CREATE TABLE employee (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100),
    department VARCHAR(50),
    basic_salary NUMERIC(12,2),
    bonus NUMERIC(12,2),
    tax_percent NUMERIC(5,2),
    net_salary NUMERIC(12,2),
    status VARCHAR(20),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- Salary Audit Table
-- =============================================

CREATE TABLE salary_audit (
    audit_id SERIAL PRIMARY KEY,
    emp_id INT,
    old_salary NUMERIC(12,2),
    new_salary NUMERIC(12,2),
    processed_by VARCHAR(100),
    processed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT
);

-- =============================================
-- Sample Data
-- =============================================

INSERT INTO employee
(emp_name, department, basic_salary, bonus, tax_percent, status)
VALUES
('Sudhakar', 'IT', 50000, 5000, 10, 'ACTIVE'),
('Ramesh', 'HR', 45000, 3000, 8, 'ACTIVE'),
('Suresh', 'Finance', 55000, 4000, 12, 'ACTIVE'),
('Mahesh', 'IT', 60000, 6000, 10, 'ACTIVE');

-- =============================================
-- Procedure: Process Employee Salary
-- =============================================

CREATE OR REPLACE PROCEDURE process_employee_salary(
    p_department VARCHAR,
    p_bonus_increment NUMERIC,
    p_processed_by VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;

    v_old_salary NUMERIC(12,2);
    v_bonus NUMERIC(12,2);
    v_gross_salary NUMERIC(12,2);
    v_tax NUMERIC(12,2);
    v_net_salary NUMERIC(12,2);

    v_processed_count INT := 0;

BEGIN

    RAISE NOTICE 'Salary processing started for department: %', p_department;

    -- Validate input

    IF p_bonus_increment < 0 THEN
        RAISE EXCEPTION 'Bonus increment cannot be negative';
    END IF;

    -- Loop through employees

    FOR rec IN
        SELECT *
        FROM employee
        WHERE department = p_department
        AND status = 'ACTIVE'
    LOOP

        BEGIN

            v_old_salary := rec.basic_salary;

            -- Calculate revised bonus

            v_bonus := rec.bonus + p_bonus_increment;

            -- Gross salary

            v_gross_salary := rec.basic_salary + v_bonus;

            -- Tax calculation

            v_tax := (v_gross_salary * rec.tax_percent) / 100;

            -- Net salary

            v_net_salary := v_gross_salary - v_tax;

            -- Update employee salary

            UPDATE employee
            SET
                bonus = v_bonus,
                net_salary = v_net_salary
            WHERE emp_id = rec.emp_id;

            -- Insert audit record

            INSERT INTO salary_audit(
                emp_id,
                old_salary,
                new_salary,
                processed_by,
                remarks
            )
            VALUES(
                rec.emp_id,
                v_old_salary,
                v_net_salary,
                p_processed_by,
                'Salary processed successfully'
            );

            v_processed_count := v_processed_count + 1;

            RAISE NOTICE
                'Processed Employee ID: %, Net Salary: %',
                rec.emp_id,
                v_net_salary;

        EXCEPTION

            WHEN OTHERS THEN

                INSERT INTO salary_audit(
                    emp_id,
                    old_salary,
                    new_salary,
                    processed_by,
                    remarks
                )
                VALUES(
                    rec.emp_id,
                    rec.basic_salary,
                    NULL,
                    p_processed_by,
                    SQLERRM
                );

                RAISE NOTICE
                    'Error processing employee ID %: %',
                    rec.emp_id,
                    SQLERRM;

        END;

    END LOOP;

    -- Final summary

    RAISE NOTICE 'Salary processing completed';
    RAISE NOTICE 'Department: %', p_department;
    RAISE NOTICE 'Total Employees Processed: %', v_processed_count;
    RAISE NOTICE 'Processed By: %', p_processed_by;

END;
$$;

-- =============================================
-- Execute Procedure
-- =============================================

CALL process_employee_salary(
    'IT',
    2000,
    'Admin_User'
);

-- =============================================
-- Check Employee Data
-- =============================================

SELECT *
FROM employee;

-- =============================================
-- Check Audit Data
-- =============================================

SELECT *
FROM salary_audit;