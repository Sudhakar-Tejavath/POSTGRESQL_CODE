
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