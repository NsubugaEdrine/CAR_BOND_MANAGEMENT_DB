CREATE DATABASE ALPHA_MOTORS;

USE ALPHA_MOTORS;

-- =============================================
-- TABLE CREATION
-- =============================================

-- 1. EMPLOYEE TABLE
CREATE TABLE EMPLOYEE (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- 2. CUSTOMER TABLE (Supertype)
CREATE TABLE CUSTOMER (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    address TEXT,
    id_number VARCHAR(50)
);

-- 3. ADDRESS TABLE
CREATE TABLE ADDRESS (
    address_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    street VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
);

-- 4. INDIVIDUAL_CUSTOMER TABLE (Subtype)
CREATE TABLE INDIVIDUAL_CUSTOMER (
    customer_id INT PRIMARY KEY,
    date_of_birth DATE NOT NULL,
    occupation VARCHAR(50),
    CONSTRAINT fk_ind_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
);

-- 5. CORPORATE_CUSTOMER TABLE (Subtype)
CREATE TABLE CORPORATE_CUSTOMER (
    customer_id INT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    tax_id VARCHAR(50) NOT NULL,
    company_reg_number VARCHAR(50) NOT NULL,
    CONSTRAINT fk_corp_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
);

-- 6. RESELLER_CUSTOMER TABLE (Subtype)
CREATE TABLE RESELLER_CUSTOMER (
    customer_id INT PRIMARY KEY,
    business_license_no VARCHAR(50) NOT NULL,
    resale_permit_no VARCHAR(50) NOT NULL,
    CONSTRAINT fk_reseller_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id)
);

-- 7. AGENCY TABLE
CREATE TABLE AGENCY (
    agency_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    contact_info TEXT NOT NULL
);

-- 8. SUPPLIER TABLE
CREATE TABLE SUPPLIER (
    supplier_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- 9. VEHICLE TABLE (Supertype)
CREATE TABLE VEHICLE (
    vehicle_id INT PRIMARY KEY,
    vin VARCHAR(50) NOT NULL,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    vehicle_year INT NOT NULL,
    cost_price DECIMAL(12, 2) NOT NULL,
    selling_price DECIMAL(12, 2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    supplier_id INT NOT NULL,
    CONSTRAINT fk_vehicle_supplier FOREIGN KEY (supplier_id) REFERENCES SUPPLIER(supplier_id)
);

-- 10. NEW_VEHICLE TABLE (Subtype)
CREATE TABLE NEW_VEHICLE (
    vehicle_id INT PRIMARY KEY,
    warranty_period VARCHAR(50) NOT NULL,
    dealer_invoice_no VARCHAR(50) NOT NULL,
    CONSTRAINT fk_new_vehicle FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id)
);

-- 11. USED_VEHICLE TABLE (Subtype)
CREATE TABLE USED_VEHICLE (
    vehicle_id INT PRIMARY KEY,
    mileage INT NOT NULL,
    previous_owners INT NOT NULL,
    condition_grade VARCHAR(20) NOT NULL,
    CONSTRAINT fk_used_vehicle FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id)
);

-- 12. SALE TABLE
CREATE TABLE SALE (
    sale_id INT PRIMARY KEY,
    sale_date DATE NOT NULL,
    total_price DECIMAL(12, 2) NOT NULL,
    payment_terms VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    vehicle_id INT NOT NULL,
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    CONSTRAINT fk_sale_vehicle FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id),
    CONSTRAINT fk_sale_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    CONSTRAINT fk_sale_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);

-- 13. PAYMENT TABLE
CREATE TABLE PAYMENT (
    payment_id INT PRIMARY KEY,
    payment_date DATE NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    method VARCHAR(50) NOT NULL,
    reference_number VARCHAR(50) NOT NULL,
    sale_id INT NOT NULL,
    CONSTRAINT fk_payment_sale FOREIGN KEY (sale_id) REFERENCES SALE(sale_id)
);

-- 14. COMPLIANCE_CHECK TABLE
CREATE TABLE COMPLIANCE_CHECK (
    check_id INT PRIMARY KEY,
    check_date DATE NOT NULL,
    check_type VARCHAR(50) NOT NULL,
    result VARCHAR(50) NOT NULL,
    remarks TEXT,
    vehicle_id INT NOT NULL,
    agency_id INT NOT NULL,
    CONSTRAINT fk_check_vehicle FOREIGN KEY (vehicle_id) REFERENCES VEHICLE(vehicle_id),
    CONSTRAINT fk_check_agency FOREIGN KEY (agency_id) REFERENCES AGENCY(agency_id)
);

-- =============================================
-- SAMPLE DATA INSERTION
-- =============================================

-- EMPLOYEE
INSERT INTO EMPLOYEE VALUES (1, 'John', 'Mwangi', 'Sales Manager', '0712345678', 'john.mwangi@alphamotors.co.ke');
INSERT INTO EMPLOYEE VALUES (2, 'Alice', 'Wanjiku', 'Sales Executive', '0723456789', 'alice.wanjiku@alphamotors.co.ke');
INSERT INTO EMPLOYEE VALUES (3, 'Peter', 'Otieno', 'Compliance Officer', '0734567890', 'peter.otieno@alphamotors.co.ke');
INSERT INTO EMPLOYEE VALUES (4, 'Grace', 'Njeri', 'Accountant', '0745678901', 'grace.njeri@alphamotors.co.ke');
INSERT INTO EMPLOYEE VALUES (5, 'David', 'Kamau', 'Mechanic', '0756789012', 'david.kamau@alphamotors.co.ke');

-- CUSTOMER
INSERT INTO CUSTOMER VALUES (1, 'Samuel', 'Kipchoge', '0710001111', 'samuel.k@gmail.com', '123 Nairobi Rd', 'ID001');
INSERT INTO CUSTOMER VALUES (2, 'Mary', 'Akinyi', '0720002222', 'mary.a@gmail.com', '456 Kisumu Ave', 'ID002');
INSERT INTO CUSTOMER VALUES (3, 'James', 'Mutua', '0730003333', 'james.m@corp.co.ke', '789 Mombasa St', 'ID003');
INSERT INTO CUSTOMER VALUES (4, 'Faith', 'Wambui', '0740004444', 'faith.w@reseller.co.ke', '321 Eldoret Ln', 'ID004');
INSERT INTO CUSTOMER VALUES (5, 'Brian', 'Ochieng', '0750005555', 'brian.o@gmail.com', '654 Nakuru Dr', 'ID005');

-- ADDRESS
INSERT INTO ADDRESS VALUES (1, 1, '123 Nairobi Rd', 'Nairobi', 'Nairobi', '00100');
INSERT INTO ADDRESS VALUES (2, 2, '456 Kisumu Ave', 'Kisumu', 'Kisumu', '40100');
INSERT INTO ADDRESS VALUES (3, 3, '789 Mombasa St', 'Mombasa', 'Mombasa', '80100');
INSERT INTO ADDRESS VALUES (4, 4, '321 Eldoret Ln', 'Eldoret', 'Uasin Gishu', '30100');
INSERT INTO ADDRESS VALUES (5, 5, '654 Nakuru Dr', 'Nakuru', 'Nakuru', '20100');

-- INDIVIDUAL_CUSTOMER
INSERT INTO INDIVIDUAL_CUSTOMER VALUES (1, '1990-05-15', 'Engineer');
INSERT INTO INDIVIDUAL_CUSTOMER VALUES (2, '1985-08-22', 'Doctor');
INSERT INTO INDIVIDUAL_CUSTOMER VALUES (5, '1992-11-30', 'Teacher');

-- CORPORATE_CUSTOMER
INSERT INTO CORPORATE_CUSTOMER VALUES (3, 'Mutua Enterprises Ltd', 'TAX123456', 'REG789012');

-- RESELLER_CUSTOMER
INSERT INTO RESELLER_CUSTOMER VALUES (4, 'BL987654', 'RP456789');

-- AGENCY
INSERT INTO AGENCY VALUES (1, 'NTSA', 'Government', '020-2223333');
INSERT INTO AGENCY VALUES (2, 'KEBS', 'Regulatory', '020-3334444');
INSERT INTO AGENCY VALUES (3, 'County Government', 'Local Authority', '020-4445555');

-- SUPPLIER
INSERT INTO SUPPLIER VALUES (1, 'Toyota Kenya', 'Joseph Maina', '0711111111', 'sales@toyotakenya.co.ke', 'Industrial Area, Nairobi', 'Kenya');
INSERT INTO SUPPLIER VALUES (2, 'Honda Japan', 'Takeshi Yamamoto', '+81-3-12345678', 'export@honda.co.jp', 'Tokyo, Minato', 'Japan');
INSERT INTO SUPPLIER VALUES (3, 'Ford USA', 'Michael Smith', '+1-555-1234567', 'fleet@ford.com', 'Dearborn, Michigan', 'USA');
INSERT INTO SUPPLIER VALUES (4, 'Mercedes Germany', 'Hans Mueller', '+49-30-9876543', 'sales@mercedes.de', 'Stuttgart', 'Germany');

-- VEHICLE
INSERT INTO VEHICLE VALUES (1, 'VIN001', 'Toyota', 'Corolla', 2024, 2500000.00, 3200000.00, 'Available', 1);
INSERT INTO VEHICLE VALUES (2, 'VIN002', 'Honda', 'Civic', 2023, 2800000.00, 3500000.00, 'Available', 2);
INSERT INTO VEHICLE VALUES (3, 'VIN003', 'Ford', 'Ranger', 2022, 3500000.00, 4200000.00, 'Sold', 3);
INSERT INTO VEHICLE VALUES (4, 'VIN004', 'Toyota', 'Land Cruiser', 2021, 8000000.00, 9500000.00, 'Sold', 1);
INSERT INTO VEHICLE VALUES (5, 'VIN005', 'Mercedes', 'C-Class', 2024, 6000000.00, 7200000.00, 'Available', 4);
INSERT INTO VEHICLE VALUES (6, 'VIN006', 'Honda', 'CR-V', 2020, 2200000.00, 2800000.00, 'Available', 2);
INSERT INTO VEHICLE VALUES (7, 'VIN007', 'Ford', 'Escape', 2019, 1800000.00, 2300000.00, 'Sold', 3);
INSERT INTO VEHICLE VALUES (8, 'VIN008', 'Toyota', 'Prado', 2023, 7500000.00, 8800000.00, 'Available', 1);

-- NEW_VEHICLE
INSERT INTO NEW_VEHICLE VALUES (1, '3 Years', 'DI2024001');
INSERT INTO NEW_VEHICLE VALUES (2, '3 Years', 'DI2023001');
INSERT INTO NEW_VEHICLE VALUES (5, '4 Years', 'DI2024002');
INSERT INTO NEW_VEHICLE VALUES (8, '3 Years', 'DI2023002');

-- USED_VEHICLE
INSERT INTO USED_VEHICLE VALUES (3, 45000, 2, 'A');
INSERT INTO USED_VEHICLE VALUES (4, 78000, 1, 'B+');
INSERT INTO USED_VEHICLE VALUES (6, 62000, 3, 'B');
INSERT INTO USED_VEHICLE VALUES (7, 95000, 2, 'C+');

-- SALE
INSERT INTO SALE VALUES (1, '2024-01-15', 3200000.00, 'Full Payment', 'Completed', 1, 1, 2);
INSERT INTO SALE VALUES (2, '2024-02-20', 4200000.00, 'Installment', 'Completed', 3, 3, 1);
INSERT INTO SALE VALUES (3, '2024-03-10', 9500000.00, 'Full Payment', 'Completed', 4, 3, 2);
INSERT INTO SALE VALUES (4, '2024-04-05', 2300000.00, 'Installment', 'Completed', 7, 5, 1);
INSERT INTO SALE VALUES (5, '2024-05-18', 3500000.00, 'Full Payment', 'Completed', 2, 2, 2);

-- PAYMENT
INSERT INTO PAYMENT VALUES (1, '2024-01-15', 3200000.00, 'Bank Transfer', 'REF001', 1);
INSERT INTO PAYMENT VALUES (2, '2024-02-20', 2100000.00, 'Bank Transfer', 'REF002', 2);
INSERT INTO PAYMENT VALUES (3, '2024-03-15', 2100000.00, 'Bank Transfer', 'REF003', 2);
INSERT INTO PAYMENT VALUES (4, '2024-03-10', 9500000.00, 'Cheque', 'REF004', 3);
INSERT INTO PAYMENT VALUES (5, '2024-04-05', 1150000.00, 'Cash', 'REF005', 4);
INSERT INTO PAYMENT VALUES (6, '2024-05-05', 1150000.00, 'Cash', 'REF006', 4);
INSERT INTO PAYMENT VALUES (7, '2024-05-18', 3500000.00, 'M-Pesa', 'REF007', 5);

-- COMPLIANCE_CHECK
INSERT INTO COMPLIANCE_CHECK VALUES (1, '2024-01-10', 'Inspection', 'Pass', 'Vehicle in good condition', 1, 1);
INSERT INTO COMPLIANCE_CHECK VALUES (2, '2024-02-15', 'Emissions Test', 'Pass', 'Within acceptable limits', 2, 2);
INSERT INTO COMPLIANCE_CHECK VALUES (3, '2024-02-18', 'Inspection', 'Pass', 'Minor scratches noted', 3, 1);
INSERT INTO COMPLIANCE_CHECK VALUES (4, '2024-03-05', 'Emissions Test', 'Fail', 'Exceeds emission standards', 6, 2);
INSERT INTO COMPLIANCE_CHECK VALUES (5, '2024-03-08', 'Inspection', 'Pass', 'Excellent condition', 4, 3);
INSERT INTO COMPLIANCE_CHECK VALUES (6, '2024-04-01', 'Registration', 'Pass', 'Documents verified', 7, 3);
INSERT INTO COMPLIANCE_CHECK VALUES (7, '2024-05-10', 'Inspection', 'Pass', 'New vehicle inspection cleared', 8, 1);

-- =============================================
-- DATA RETRIEVAL CONCEPTS
-- =============================================

-- 1. BASIC SELECT: Retrieve all employees
SELECT * FROM EMPLOYEE;

-- 2. SELECT with WHERE clause: Find vehicles that are available
SELECT vehicle_id, vin, make, model, vehicle_year, selling_price
FROM VEHICLE
WHERE status = 'Available';

-- 3. SELECT with ORDER BY: List vehicles sorted by selling price descending
SELECT vin, make, model, selling_price
FROM VEHICLE
ORDER BY selling_price DESC;

-- 4. SELECT with LIMIT: Get the top 3 most expensive vehicles
SELECT vin, make, model, selling_price
FROM VEHICLE
ORDER BY selling_price DESC
LIMIT 3;

-- 5. AGGREGATE FUNCTIONS: Count of vehicles by status
SELECT status, COUNT(*) AS total_vehicles
FROM VEHICLE
GROUP BY status;

-- 6. AGGREGATE FUNCTIONS: Average selling price per make
SELECT make, AVG(selling_price) AS avg_price, MIN(selling_price) AS min_price, MAX(selling_price) AS max_price
FROM VEHICLE
GROUP BY make;

-- 7. INNER JOIN: List all sales with customer and employee names
SELECT 
    s.sale_id,
    s.sale_date,
    s.total_price,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    s.payment_terms,
    s.status
FROM SALE s
INNER JOIN CUSTOMER c ON s.customer_id = c.customer_id
INNER JOIN EMPLOYEE e ON s.employee_id = e.employee_id;

-- 8. INNER JOIN: Show vehicles with their type (New or Used) and supplier
SELECT 
    v.vin,
    v.make,
    v.model,
    v.vehicle_year,
    v.selling_price,
    sp.name AS supplier_name,
    CASE 
        WHEN nv.vehicle_id IS NOT NULL THEN 'New'
        WHEN uv.vehicle_id IS NOT NULL THEN 'Used'
    END AS vehicle_type
FROM VEHICLE v
INNER JOIN SUPPLIER sp ON v.supplier_id = sp.supplier_id
LEFT JOIN NEW_VEHICLE nv ON v.vehicle_id = nv.vehicle_id
LEFT JOIN USED_VEHICLE uv ON v.vehicle_id = uv.vehicle_id;

-- 9. LEFT JOIN: Show all customers and their addresses (including those without addresses)
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    a.street,
    a.city,
    a.state,
    a.zip_code
FROM CUSTOMER c
LEFT JOIN ADDRESS a ON c.customer_id = a.customer_id;

-- 10. SUBQUERY: Find vehicles sold above the average selling price
SELECT vin, make, model, selling_price
FROM VEHICLE
WHERE selling_price > (SELECT AVG(selling_price) FROM VEHICLE);

-- 11. SUBQUERY: Customers who have made purchases
SELECT first_name, last_name, email
FROM CUSTOMER
WHERE customer_id IN (SELECT DISTINCT customer_id FROM SALE);

-- 12. SUBQUERY: Customers who have NOT made purchases
SELECT first_name, last_name, email
FROM CUSTOMER
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM SALE);

-- 13. AGGREGATE with HAVING: Suppliers supplying more than 1 vehicle
SELECT sp.name AS supplier_name, COUNT(v.vehicle_id) AS vehicle_count
FROM SUPPLIER sp
INNER JOIN VEHICLE v ON sp.supplier_id = v.supplier_id
GROUP BY sp.name
HAVING COUNT(v.vehicle_id) > 1;

-- 14. COMPLEX JOIN: Full sale details with payment info
SELECT 
    s.sale_id,
    s.sale_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    CONCAT(v.make, ' ', v.model) AS vehicle,
    v.vin,
    s.total_price,
    s.payment_terms,
    p.payment_date,
    p.amount AS payment_amount,
    p.method AS payment_method,
    p.reference_number
FROM SALE s
INNER JOIN CUSTOMER c ON s.customer_id = c.customer_id
INNER JOIN VEHICLE v ON s.vehicle_id = v.vehicle_id
INNER JOIN PAYMENT p ON s.sale_id = p.sale_id
ORDER BY s.sale_date;

-- 15. GROUP BY with multiple aggregates: Total revenue per employee
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(s.sale_id) AS total_sales,
    SUM(s.total_price) AS total_revenue,
    AVG(s.total_price) AS avg_sale_value
FROM EMPLOYEE e
INNER JOIN SALE s ON e.employee_id = s.employee_id
GROUP BY e.first_name, e.last_name;

-- 16. DATE FUNCTIONS: Sales made in 2024
SELECT sale_id, sale_date, total_price
FROM SALE
WHERE YEAR(sale_date) = 2024;

-- 17. COMPLIANCE CHECK results with vehicle and agency info
SELECT 
    cc.check_id,
    cc.check_date,
    cc.check_type,
    cc.result,
    cc.remarks,
    CONCAT(v.make, ' ', v.model) AS vehicle,
    v.vin,
    a.name AS agency_name
FROM COMPLIANCE_CHECK cc
INNER JOIN VEHICLE v ON cc.vehicle_id = v.vehicle_id
INNER JOIN AGENCY a ON cc.agency_id = a.agency_id
ORDER BY cc.check_date;

-- 18. SUBQUERY with aggregate: Vehicles priced above their make's average
SELECT vin, make, model, selling_price
FROM VEHICLE v1
WHERE selling_price > (
    SELECT AVG(selling_price) 
    FROM VEHICLE v2 
    WHERE v2.make = v1.make
);

-- 19. CONDITIONAL COUNT: Number of passed and failed compliance checks per check type
SELECT 
    check_type,
    SUM(CASE WHEN result = 'Pass' THEN 1 ELSE 0 END) AS passed,
    SUM(CASE WHEN result = 'Fail' THEN 1 ELSE 0 END) AS failed
FROM COMPLIANCE_CHECK
GROUP BY check_type;

-- 20. UNION: All customer names from both individual and corporate customers
SELECT CONCAT(c.first_name, ' ', c.last_name) AS full_name, 'Individual' AS customer_type
FROM CUSTOMER c
INNER JOIN INDIVIDUAL_CUSTOMER ic ON c.customer_id = ic.customer_id
UNION
SELECT CONCAT(c.first_name, ' ', c.last_name) AS full_name, 'Corporate' AS customer_type
FROM CUSTOMER c
INNER JOIN CORPORATE_CUSTOMER cc ON c.customer_id = cc.customer_id;
