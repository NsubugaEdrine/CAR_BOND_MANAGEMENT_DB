CREATE DATABASE alpha_motors
    DEFAULT CHARACTER SET = 'utf8mb4';

USE alpha_motors;

-- =============================================
-- TABLE CREATION
-- =============================================

-- 1. EMPLOYEE TABLE
CREATE TABLE EMPLOYEE (
    employee_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(80) NOT NULL,
    last_name       VARCHAR(80) NOT NULL,
    role            VARCHAR(60) NOT NULL,
    phone           VARCHAR(30),
    email           VARCHAR(150)
);

-- 2. CUSTOMER TABLE (Supertype)
CREATE TABLE CUSTOMER (
    customer_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(80) NOT NULL,
    last_name       VARCHAR(80),
    phone           VARCHAR(30),
    email           VARCHAR(150),
    address         VARCHAR(255),
    id_number       VARCHAR(50) NOT NULL,
    customer_type   ENUM('Individual', 'Corporate', 'Reseller') NOT NULL,
    UNIQUE KEY uq_customer_id_number (id_number)
);

-- 4. INDIVIDUAL_CUSTOMER TABLE (Subtype)
CREATE TABLE INDIVIDUAL_CUSTOMER (
    customer_id     INT UNSIGNED PRIMARY KEY,
    date_of_birth   DATE,
    occupation      VARCHAR(100),
    CONSTRAINT fk_indiv_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 5. CORPORATE_CUSTOMER TABLE (Subtype)
CREATE TABLE CORPORATE_CUSTOMER (
    customer_id         INT UNSIGNED PRIMARY KEY,
    company_name        VARCHAR(150) NOT NULL,
    tax_id               VARCHAR(50),
    company_reg_number  VARCHAR(50),
    CONSTRAINT fk_corp_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 6. RESELLER_CUSTOMER TABLE (Subtype)
CREATE TABLE RESELLER_CUSTOMER (
    customer_id         INT UNSIGNED PRIMARY KEY,
    business_license_no VARCHAR(50),
    resale_permit_no    VARCHAR(50),
    CONSTRAINT fk_reseller_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 7. AGENCY TABLE
CREATE TABLE AGENCY (
    agency_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    type            ENUM('URA', 'MinistryOfWorksAndTransport', 'PoliceInterpol', 'Bank', 'Other') NOT NULL,
    contact_info    VARCHAR(255)
);

-- 8. SUPPLIER TABLE
CREATE TABLE SUPPLIER (
    supplier_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    contact_person  VARCHAR(150),
    phone           VARCHAR(30),
    email           VARCHAR(150),
    address         VARCHAR(255),
    country         VARCHAR(100)
);

-- 9. VEHICLE TABLE (Supertype)
CREATE TABLE VEHICLE (
    vehicle_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    vin             VARCHAR(17) NOT NULL,
    make            VARCHAR(60) NOT NULL,
    model           VARCHAR(60) NOT NULL,
    year            SMALLINT UNSIGNED NOT NULL,
    color           VARCHAR(40),
    cost_price      DECIMAL(14,2) NOT NULL,
    selling_price   DECIMAL(14,2) NOT NULL,
    status          ENUM('Available', 'Reserved', 'Sold', 'InTransit') NOT NULL DEFAULT 'InTransit',
    date_received   DATE NOT NULL,
    supplier_id     INT UNSIGNED NOT NULL,
    -- discriminator: enforced disjoint/total by trg_vehicle_* triggers below
    vehicle_type    ENUM('New', 'Used') NOT NULL,
    UNIQUE KEY uq_vehicle_vin (vin),
    CONSTRAINT fk_vehicle_supplier
        FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
        ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE INDEX idx_vehicle_supplier ON vehicle(supplier_id);
CREATE INDEX idx_vehicle_status   ON vehicle(status);

-- 10. NEW_VEHICLE TABLE (Subtype)
CREATE TABLE NEW_VEHICLE (
    vehicle_id       INT UNSIGNED PRIMARY KEY,
    warranty_period  VARCHAR(50),
    dealer_invoice_no VARCHAR(50),
    CONSTRAINT fk_new_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 11. USED_VEHICLE TABLE (Subtype)
CREATE TABLE USED_VEHICLE (
    vehicle_id       INT UNSIGNED PRIMARY KEY,
    mileage          INT UNSIGNED,
    previous_owners  TINYINT UNSIGNED,
    condition_grade  VARCHAR(20),
    CONSTRAINT fk_used_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 12. SALE TABLE
CREATE TABLE SALE (
    sale_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_date       DATE NOT NULL,
    total_price     DECIMAL(14,2) NOT NULL,
    payment_terms   ENUM('FullCash', 'Instalment', 'BankLoan') NOT NULL,
    status          ENUM('Pending', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Pending',
    vehicle_id      INT UNSIGNED NOT NULL,
    customer_id     INT UNSIGNED NOT NULL,
    employee_id     INT UNSIGNED NOT NULL,
    CONSTRAINT fk_sale_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_sale_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_sale_employee
        FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_sale_vehicle  ON sale(vehicle_id);
CREATE INDEX idx_sale_customer ON sale(customer_id);
CREATE INDEX idx_sale_employee ON sale(employee_id);
CREATE INDEX idx_sale_status   ON sale(status);

-- 13. PAYMENT TABLE
CREATE TABLE PAYMENT (
    payment_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payment_date     DATE NOT NULL,
    amount           DECIMAL(14,2) NOT NULL,
    method           ENUM('Cash', 'BankTransfer', 'MobileMoney', 'Cheque', 'LoanDisbursement') NOT NULL,
    reference_number VARCHAR(60),
    sale_id          INT UNSIGNED NOT NULL,
    CONSTRAINT fk_payment_sale
        FOREIGN KEY (sale_id) REFERENCES sale(sale_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE INDEX idx_payment_sale ON payment(sale_id);

-- 14. COMPLIANCE_CHECK TABLE
CREATE TABLE COMPLIANCE_CHECK (
    check_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    check_date      DATE NOT NULL,
    check_type      ENUM('TaxAssessment', 'PoliceInterpolVerification', 'Registration') NOT NULL,
    result          ENUM('Pending', 'Cleared', 'Failed') NOT NULL DEFAULT 'Pending',
    remarks         VARCHAR(255),
    vehicle_id      INT UNSIGNED NOT NULL,
    agency_id       INT UNSIGNED NOT NULL,
    CONSTRAINT fk_compliance_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_compliance_agency
        FOREIGN KEY (agency_id) REFERENCES agency(agency_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_compliance_vehicle ON compliance_check(vehicle_id);
CREATE INDEX idx_compliance_agency  ON compliance_check(agency_id);

-- 15. EMPLOYEE_AUDIT TABLE
-- Audit/history table. It is never inserted into by hand: the
-- trg_employee_* triggers (AFTER INSERT / AFTER UPDATE / AFTER DELETE)
-- write to it automatically every time an employee row changes.
CREATE TABLE EMPLOYEE_AUDIT (
    audit_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id    INT UNSIGNED,
    action_type    ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_first_name VARCHAR(80),
    old_last_name  VARCHAR(80),
    old_role       VARCHAR(60),
    old_phone      VARCHAR(30),
    old_email      VARCHAR(150),
    new_first_name VARCHAR(80),
    new_last_name  VARCHAR(80),
    new_role       VARCHAR(60),
    new_phone      VARCHAR(30),
    new_email      VARCHAR(150),
    changed_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_employee_audit_emp ON employee_audit(employee_id);

-- =============================================
-- SAMPLE DATA INSERTION
-- =============================================

-- EMPLOYEE
INSERT INTO employee (first_name, last_name, role, phone, email) VALUES
('Alveen',   'Mutebi',    'Sales Executive',      '+256772000001', 'alveen.mutebi@alphamotors.co.ug'),
('Joan',     'Asango',    'Sales Executive',      '+256772000002', 'joan.asango@alphamotors.co.ug'),
('Stephen',  'Piramoe',   'Yard Manager',         '+256772000003', 'stephen.piramoe@alphamotors.co.ug'),
('Lawrence', 'Kideganono','Compliance Officer',   '+256772000004', 'lawrence.k@alphamotors.co.ug'),
('Edrine',   'Nsubuga',   'Accountant',           '+256772000005', 'edrine.nsubuga@alphamotors.co.ug'),
('Diana',    'Atugonza',  'Sales Executive',      '+256772000006', 'diana.atugonza@alphamotors.co.ug'),
('Caleb',    'Kironde',   'Yard Attendant',       '+256772000007', 'caleb.kironde@alphamotors.co.ug'),
('Ernest',   'Ntare',     'Sales Manager',        '+256772000008', 'ernest.ntare@alphamotors.co.ug'),
('Arnold',   'Mulembeke', 'Compliance Officer',   '+256772000009', 'arnold.mulembeke@alphamotors.co.ug'),
('Grace',    'Achieng',   'Accountant',           '+256772000010', 'grace.achieng@alphamotors.co.ug');

-- CUSTOMER
INSERT INTO customer (first_name, last_name, phone, email, address, id_number, customer_type) VALUES
('Samuel',  'Kaggwa',   '+256782100001', 'samuel.kaggwa@gmail.com',   'Ntinda, Kampala',       'CM88012345AB1A', 'Individual'),
('Patricia','Nabirye',  '+256782100002', 'patricia.nab@gmail.com',    'Kansanga, Kampala',     'CF90034567CD2B', 'Individual'),
('Moses',   'Okello',   '+256782100003', 'moses.okello@yahoo.com',    'Jinja Road, Jinja',     'CM85076543EF3C', 'Individual'),
('Sarah',   'Nakato',   '+256782100004', 'sarah.nakato@gmail.com',    'Mbarara Town',          'CF93021987GH4D', 'Individual'),
('Kampala Logistics Ltd',   NULL, '+256414200005', 'procurement@kampalalogistics.co.ug', 'Industrial Area, Kampala', 'CORP-REG-00123', 'Corporate'),
('Nile Breweries Fleet',    NULL, '+256414200006', 'fleet@nilebreweries.co.ug',           'Jinja Industrial Zone',    'CORP-REG-00456', 'Corporate'),
('Mbarara Farmers SACCO',   NULL, '+256485200007', 'admin@mbarararsacco.co.ug',           'Mbarara Town Centre',      'CORP-REG-00789', 'Corporate'),
('Deo',     'Ssemakula','+256782100008', 'deo.ssemakula@gmail.com',   'Kikuubo, Kampala',      'CM87098765IJ5E', 'Reseller'),
('Winnie',  'Auma',     '+256782100009', 'winnie.auma@gmail.com',     'Gulu Town',             'CF91045678KL6F', 'Reseller'),
('Hassan',  'Mubiru',   '+256782100010', 'hassan.mubiru@gmail.com',   'Kibuye, Kampala',       'CM89056789MN7G', 'Reseller');
 
-- INDIVIDUAL_CUSTOMER
INSERT INTO individual_customer (customer_id, date_of_birth, occupation) VALUES
(1, '1988-01-15', 'Civil Engineer'),
(2, '1990-03-22', 'Bank Teller'),
(3, '1985-07-08', 'Teacher'),
(4, '1993-02-19', 'Nurse');

-- CORPORATE_CUSTOMER
INSERT INTO corporate_customer (customer_id, company_name, tax_id, company_reg_number) VALUES
(5, 'Kampala Logistics Ltd',  'TIN1000123456', 'CORP-REG-00123'),
(6, 'Nile Breweries Fleet',   'TIN1000456789', 'CORP-REG-00456'),
(7, 'Mbarara Farmers SACCO',  'TIN1000789012', 'CORP-REG-00789');
 
-- RESELLER_CUSTOMER
INSERT INTO reseller_customer (customer_id, business_license_no, resale_permit_no) VALUES
(8,  'BL-KLA-004521', 'RP-2026-0088'),
(9,  'BL-GLU-002210', 'RP-2026-0091'),
(10, 'BL-KLA-004977', 'RP-2026-0104');
 
-- AGENCY
INSERT INTO agency (name, type, contact_info) VALUES
('Uganda Revenue Authority - Nakawa',        'URA',                         'nakawa@ura.go.ug'),
('Uganda Revenue Authority - Malaba',        'URA',                         'malaba@ura.go.ug'),
('Ministry of Works and Transport - Kampala','MinistryOfWorksAndTransport', 'kampala@works.go.ug'),
('Ministry of Works and Transport - Mukono', 'MinistryOfWorksAndTransport', 'mukono@works.go.ug'),
('Uganda Police - CIID Vehicle Theft Unit',  'PoliceInterpol',              'ciid@upf.go.ug'),
('INTERPOL National Central Bureau Kampala', 'PoliceInterpol',              'ncb@interpol.go.ug'),
('Stanbic Bank Uganda - Asset Finance',      'Bank',                        'assetfinance@stanbic.co.ug'),
('DFCU Bank - Motor Loans Desk',             'Bank',                        'motorloans@dfcugroup.com'),
('UAP Old Mutual Insurance',                 'Other',                       'motor@uap-oldmutual.co.ug'),
('Uganda Bureau of Standards',               'Other',                      'info@unbs.go.ug');

-- SUPPLIER
INSERT INTO supplier (name, contact_person, phone, email, address, country) VALUES
('Bex Auto Traders',        'Kenji Watanabe',  '+256701000001', 'kenji@bexauto.co.jp',      'Yokohama Port Yard 4',        'Japan'),
('IBC Japan Motors',        'Haruto Sato',      '+256701000002', 'haruto@ibcjapan.com',      'Nagoya Export Terminal',      'Japan'),
('Southern Cross Imports',  'Michael Turner',   '+256701000003', 'mturner@southerncross.co.za', 'Durban Harbour Rd 12',    'South Africa'),
('Kampala Motors Direct',   'Ronald Kato',      '+256701000004', 'ronald@kmdirect.co.ug',    'Nakawa Industrial Area',      'Uganda'),
('Dubai Auto Auctions FZE', 'Ahmed Al-Farsi',   '+971501000005', 'ahmed@dubaiauto.ae',       'Jebel Ali Free Zone',         'UAE'),
('Osaka Fair Deal Motors',  'Yuki Tanaka',      '+256701000006', 'yuki@osakafairdeal.jp',    'Osaka Bay Terminal 2',        'Japan'),
('Thika Road Auto Ltd',     'Peter Njoroge',    '+256701000007', 'peter@thikaroadauto.co.ke', 'Thika Road Depot',           'Kenya'),
('Nagano Vehicle Exports',  'Sota Yamamoto',    '+256701000008', 'sota@naganoexports.jp',    'Nagano Prefecture Depot',     'Japan'),
('Mombasa Freight Motors',  'James Otieno',     '+256701000009', 'james@mombasafreight.co.ke', 'Mombasa Port Warehouse 7',  'Kenya'),
('Local Trade-In Sellers',  'Grace Namuli',     '+256701000010', 'grace@localtrade.co.ug',   'Bakuli Yard Office',          'Uganda');

-- VEHICLE
INSERT INTO vehicle (vin, make, model, year, color, cost_price, selling_price, status, date_received, supplier_id, vehicle_type) VALUES
('JT2BF22K1W0123451', 'Toyota',    'Hilux',       2026, 'White',  95000000.00, 118000000.00, 'InTransit', '2026-06-01', 4, 'New'),
('JHMFA1F5XCS123452', 'Honda',     'CR-V',        2025, 'Silver', 78000000.00, 96000000.00,  'InTransit', '2026-06-05', 1, 'New'),
('KMHDU46D08U123453', 'Hyundai',   'Tucson',      2026, 'Black',  70000000.00, 88000000.00,  'InTransit', '2026-06-10', 5, 'New'),
('JN1TANT31U0123454', 'Nissan',    'X-Trail',     2025, 'Blue',   65000000.00, 82000000.00,  'Available', '2026-06-12', 2, 'New'),
('WVWZZZ1KZAW123455', 'Volkswagen','Tiguan',      2026, 'Grey',   88000000.00, 109000000.00, 'Available', '2026-06-15', 3, 'New'),
('JTMBK31V486123456', 'Toyota',    'RAV4',        2018, 'Pearl',  38000000.00, 52000000.00,  'Available', '2026-05-01', 6, 'Used'),
('JHMCM82633C123457', 'Honda',     'Fit',         2016, 'Red',    18000000.00, 27000000.00,  'Available', '2026-05-04', 7, 'Used'),
('JN1BJ1CV5AT123458', 'Nissan',    'Note',        2017, 'White',  16000000.00, 24000000.00,  'Available', '2026-05-09', 8, 'Used'),
('KNAFU4A25A5123459', 'Kia',       'Sportage',    2015, 'Black',  25000000.00, 36000000.00,  'Available', '2026-05-14', 9, 'Used'),
('JTEBU14R170123460', 'Toyota',    'Land Cruiser Prado', 2014, 'Silver', 55000000.00, 72000000.00, 'Available', '2026-05-20', 10, 'Used');
-- NEW_VEHICLE
INSERT INTO new_vehicle (vehicle_id, warranty_period, dealer_invoice_no) VALUES
(1, '3 years / 100,000 km', 'INV-JP-889011'),
(2, '3 years / 100,000 km', 'INV-JP-889012'),
(3, '5 years / 150,000 km', 'INV-AE-889013'),
(4, '3 years / 100,000 km', 'INV-JP-889014'),
(5, '4 years / 120,000 km', 'INV-ZA-889015');
 

-- USED_VEHICLE
INSERT INTO used_vehicle (vehicle_id, mileage, previous_owners, condition_grade) VALUES
(6,  62000, 1, 'A'),
(7,  91000, 2, 'B'),
(8,  74000, 1, 'A'),
(9,  108000, 2, 'B'),
(10, 130000, 3, 'C');
 
-- SALE
INSERT INTO sale (sale_date, total_price, payment_terms, status, vehicle_id, customer_id, employee_id) VALUES
('2026-07-01', 118000000.00, 'FullCash',   'Completed', 1,  1, 1),
('2026-07-03', 96000000.00,  'BankLoan',   'Completed', 2,  5, 2),
('2026-07-05', 88000000.00,  'FullCash',   'Completed', 3,  8, 1),
('2026-07-08', 82000000.00,  'Instalment', 'Pending',   4,  2, 6),
('2026-07-10', 109000000.00, 'BankLoan',   'Pending',   5,  6, 8),
('2026-07-12', 52000000.00,  'Instalment', 'Pending',   6,  3, 2),
('2026-07-14', 27000000.00,  'FullCash',   'Pending',   7,  9, 6),
('2026-07-16', 24000000.00,  'Instalment', 'Pending',   8,  4, 1),
('2026-07-18', 36000000.00,  'FullCash',   'Cancelled', 9,  10, 8),
('2026-07-20', 72000000.00,  'Instalment', 'Pending',   10, 7, 2);
 
-- PAYMENT
INSERT INTO payment (payment_date, amount, method, reference_number, sale_id) VALUES
('2026-07-01', 118000000.00, 'Cash',             'PMT-000001', 1),
('2026-07-03', 96000000.00,  'LoanDisbursement', 'PMT-000002', 2),
('2026-07-05', 88000000.00,  'BankTransfer',     'PMT-000003', 3),
('2026-07-08', 20000000.00,  'MobileMoney',      'PMT-000004', 4),
('2026-07-22', 20000000.00,  'MobileMoney',      'PMT-000005', 4),
('2026-07-12', 15000000.00,  'Cash',             'PMT-000006', 6),
('2026-07-26', 10000000.00,  'BankTransfer',     'PMT-000007', 6),
('2026-07-16', 6000000.00,   'MobileMoney',      'PMT-000008', 8),
('2026-07-20', 25000000.00,  'Cash',             'PMT-000009', 10),
('2026-08-03', 15000000.00,  'MobileMoney',      'PMT-000010', 10);
 
-- COMPLIANCE_CHECK
INSERT INTO compliance_check (check_date, check_type, result, remarks, vehicle_id, agency_id) VALUES
('2026-06-20', 'TaxAssessment',              'Cleared', 'Import duty and VAT fully paid',        1, 1),
('2026-06-21', 'PoliceInterpolVerification', 'Cleared', 'Chassis number verified, no flags',      1, 5),
('2026-06-22', 'Registration',               'Cleared', 'Number plates issued: UBH 001A',         1, 3),
('2026-06-23', 'TaxAssessment',              'Cleared', 'Import duty and VAT fully paid',        2, 2),
('2026-06-24', 'PoliceInterpolVerification', 'Cleared', 'Chassis number verified, no flags',      2, 6),
('2026-06-25', 'Registration',               'Cleared', 'Number plates issued: UBH 002B',         2, 4),
('2026-06-26', 'TaxAssessment',              'Cleared', 'Import duty and VAT fully paid',        3, 1),
('2026-06-27', 'PoliceInterpolVerification', 'Cleared', 'Chassis number verified, no flags',      3, 5),
('2026-06-28', 'Registration',               'Cleared', 'Number plates issued: UBH 003C',         3, 3),
('2026-06-29', 'TaxAssessment',              'Pending', 'Awaiting URA assessment appointment',    4, 2);



--TRIGGERS
-- =============================================
-- TRIGGERS ON TABLE EMPLOYEE
-- =============================================
-- A trigger is a named block of SQL attached to a table. It fires
-- automatically whenever that table is INSERTed into, UPDATEd or DELETEd from.
--
-- The 6 combinations used here (all possible timing/event pairs):
--   trg_employee_before_insert   -> cleans and validates NEW data
--   trg_employee_after_insert    -> writes the history row
--   trg_employee_before_update   -> guards and re-validates a change
--   trg_employee_after_update    -> writes the history row (old + new)
--   trg_employee_before_delete   -> stops illegal removals
--   trg_employee_after_delete    -> writes the history row
--
-- BEFORE triggers may change NEW.* (or read OLD.*) to modify/block the row.
-- AFTER triggers cannot change the row - they only react to what happened.

DROP TRIGGER IF EXISTS trg_employee_before_insert;
DROP TRIGGER IF EXISTS trg_employee_after_insert;
DROP TRIGGER IF EXISTS trg_employee_before_update;
DROP TRIGGER IF EXISTS trg_employee_after_update;
DROP TRIGGER IF EXISTS trg_employee_before_delete;
DROP TRIGGER IF EXISTS trg_employee_after_delete;

DELIMITER //

-- ---------------------------------------------------------------------
-- 1. BEFORE INSERT ON EMPLOYEE
-- Real life: HR receives "  kimani  okello ", phone "+256 77 200 0011" and a
--            wrong role "Cashier". Nothing is stored until it is tidy and legal.
-- Goal: clean the incoming data, then reject the row with our own message.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_employee_before_insert
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
    -- TIDY UP: remove padding, standardise capitalisation and case
    SET NEW.first_name = TRIM(NEW.first_name),
        NEW.last_name  = TRIM(NEW.last_name),
        NEW.role       = CONCAT(UPPER(LEFT(TRIM(NEW.role), 1)),
                                SUBSTRING(TRIM(NEW.role), 2)),
        NEW.phone      = NULLIF(TRIM(NEW.phone), ''),
        NEW.email      = LOWER(NULLIF(TRIM(NEW.email), ''));

    -- RULE 1: a real name is mandatory
    IF NEW.first_name = '' OR NEW.last_name = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: first_name and last_name are required.';
    END IF;

    -- RULE 2: only approved job roles may be stored
    IF NEW.role NOT IN ('Sales Executive', 'Sales Manager', 'Yard Manager',
                        'Yard Attendant', 'Compliance Officer', 'Accountant') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: role must be Sales Executive, Sales Manager, Yard Manager, Yard Attendant, Compliance Officer or Accountant.';
    END IF;

    -- RULE 3: email must look like an email address
    IF NEW.email IS NOT NULL AND NEW.email NOT LIKE '_%@_%._%' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: email is not a valid address.';
    END IF;

    -- RULE 4: work email must be on the company domain
    IF NEW.email IS NOT NULL AND NEW.email NOT LIKE '%@alphamotors.co.ug' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: work email must end with @alphamotors.co.ug.';
    END IF;

    -- RULE 5: phone must be in international format, e.g. +256772000001
    IF NEW.phone IS NOT NULL AND NEW.phone NOT REGEXP '^[+][0-9]{7,15}$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: phone must be in international format, e.g. +256772000001.';
    END IF;

    -- RULE 6: one employee, one email address
    IF NEW.email IS NOT NULL
       AND EXISTS (SELECT 1 FROM employee WHERE email = NEW.email) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: that email is already used by another employee.';
    END IF;
END//

-- ---------------------------------------------------------------------
-- 2. AFTER INSERT ON EMPLOYEE
-- Real life: the staff list is not just "who exists now" - HR must be able
--            to prove who was hired and when.
-- Goal: record the new employee in the audit trail.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_employee_after_insert
AFTER INSERT ON employee
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit
        (employee_id, action_type,
         new_first_name, new_last_name, new_role, new_phone, new_email)
    VALUES
        (NEW.employee_id, 'INSERT',
         NEW.first_name, NEW.last_name, NEW.role, NEW.phone, NEW.email);
END//

-- ---------------------------------------------------------------------
-- 3. BEFORE UPDATE ON EMPLOYEE
-- Real life: a clerk "helpfully" renumbers an employee, or two staff end up
--            sharing one mailbox, or the only Sales Manager is demployed.
-- Goal: freeze the identity, re-run the validation rules, block illegal moves.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_employee_before_update
BEFORE UPDATE ON employee
FOR EACH ROW
BEGIN
    -- RULE 1: the employee number is permanent
    IF NEW.employee_id <> OLD.employee_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: employee_id cannot be changed once assigned.';
    END IF;

    -- TIDY UP: the same normalisation as on insert
    SET NEW.first_name = TRIM(NEW.first_name),
        NEW.last_name  = TRIM(NEW.last_name),
        NEW.role       = CONCAT(UPPER(LEFT(TRIM(NEW.role), 1)),
                                SUBSTRING(TRIM(NEW.role), 2)),
        NEW.phone      = NULLIF(TRIM(NEW.phone), ''),
        NEW.email      = LOWER(NULLIF(TRIM(NEW.email), ''));

    -- RULE 2: role must still be one of the approved roles
    IF NEW.role NOT IN ('Sales Executive', 'Sales Manager', 'Yard Manager',
                        'Yard Attendant', 'Compliance Officer', 'Accountant') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: role must be Sales Executive, Sales Manager, Yard Manager, Yard Attendant, Compliance Officer or Accountant.';
    END IF;

    -- RULE 3: email must still be a valid company address
    IF NEW.email IS NOT NULL
       AND (NEW.email NOT LIKE '_%@_%._%' OR NEW.email NOT LIKE '%@alphamotors.co.ug') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: work email must be a valid address ending with @alphamotors.co.ug.';
    END IF;

    -- RULE 4: phone must still be in international format
    IF NEW.phone IS NOT NULL AND NEW.phone NOT REGEXP '^[+][0-9]{7,15}$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: phone must be in international format, e.g. +256772000001.';
    END IF;

    -- RULE 5: the new email must not already belong to a colleague
    IF NEW.email IS NOT NULL
       AND EXISTS (SELECT 1 FROM employee
                    WHERE email = NEW.email
                      AND employee_id <> OLD.employee_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: that email is already used by another employee.';
    END IF;

    -- RULE 6: the yard must always keep at least one Sales Manager
    IF OLD.role = 'Sales Manager' AND NEW.role <> 'Sales Manager'
       AND (SELECT COUNT(*) FROM employee WHERE role = 'Sales Manager') <= 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: the last Sales Manager cannot be demoted.';
    END IF;
END//

-- ---------------------------------------------------------------------
-- 4. AFTER UPDATE ON EMPLOYEE
-- Real life: a payslip reprint must show what the record used to say.
-- Goal: store a full before/after snapshot of every real change.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_employee_after_update
AFTER UPDATE ON employee
FOR EACH ROW
BEGIN
    -- only log when something actually changed (so a no-op UPDATE is ignored).
    -- BINARY is used because utf8mb4_0900_ai_ci compares case-insensitively,
    -- which would hide a real change such as 'Stephen' -> 'STEPHEN'.
    IF NOT (BINARY OLD.first_name <=> BINARY NEW.first_name
       AND BINARY OLD.last_name  <=> BINARY NEW.last_name
       AND BINARY OLD.role       <=> BINARY NEW.role
       AND BINARY OLD.phone      <=> BINARY NEW.phone
       AND BINARY OLD.email      <=> BINARY NEW.email) THEN

        INSERT INTO employee_audit
            (employee_id, action_type,
             old_first_name, old_last_name, old_role, old_phone, old_email,
             new_first_name, new_last_name, new_role, new_phone, new_email)
        VALUES
            (OLD.employee_id, 'UPDATE',
             OLD.first_name, OLD.last_name, OLD.role, OLD.phone, OLD.email,
             NEW.first_name, NEW.last_name, NEW.role, NEW.phone, NEW.email);
    END IF;
END//

-- ---------------------------------------------------------------------
-- 5. BEFORE DELETE ON EMPLOYEE
-- Real life: you cannot sack the salesman who closed the three biggest
--            deals of the year - his sales history must stay attributable.
-- Goal: block the DELETE and explain why, instead of an FK error.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_employee_before_delete
BEFORE DELETE ON employee
FOR EACH ROW
BEGIN
    -- RULE 1: nobody who appears on a sale may be removed
    IF EXISTS (SELECT 1 FROM sale WHERE employee_id = OLD.employee_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: cannot delete an employee who is linked to one or more sales.';
    END IF;

    -- RULE 2: the yard must always keep at least one Sales Manager
    IF OLD.role = 'Sales Manager'
       AND (SELECT COUNT(*) FROM employee WHERE role = 'Sales Manager') <= 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'EMPLOYEE ERROR: the last Sales Manager cannot be deleted.';
    END IF;
END//

-- ---------------------------------------------------------------------
-- 6. AFTER DELETE ON EMPLOYEE
-- Real life: ex-staff records are archived, not erased.
-- Goal: keep the removed row in the audit trail.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_employee_after_delete
AFTER DELETE ON employee
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit
        (employee_id, action_type,
         old_first_name, old_last_name, old_role, old_phone, old_email)
    VALUES
        (OLD.employee_id, 'DELETE',
         OLD.first_name, OLD.last_name, OLD.role, OLD.phone, OLD.email);
END//

DELIMITER ;

-- =============================================
-- CHECKING THE TRIGGERS
-- =============================================

-- T1: tidy + valid -> stored, audit row written
INSERT INTO employee (first_name, last_name, role, phone, email)
VALUES ('  grace ', ' NABBIRA ', 'accountant', '+256772000011', 'GRACE.Nabbira@AlphaMotors.co.ug');

-- T2: bad role -> refused by trg_employee_before_insert
INSERT INTO employee (first_name, last_name, role, phone, email)
VALUES ('Peter', 'Odeke', 'Cashier', '+256772000012', 'peter.odeke@alphamotors.co.ug');

-- T3: duplicate email -> refused
INSERT INTO employee (first_name, last_name, role, phone, email)
VALUES ('John', 'Sseba', 'Accountant', '+256772000013', 'alveen.mutebi@alphamotors.co.ug');

-- T4: employee with sales cannot be deleted -> refused
DELETE FROM employee WHERE employee_id = 1;

-- T5: free-text phone -> refused
INSERT INTO employee (first_name, last_name, role, phone, email)
VALUES ('Ruth', 'Ayikoi', 'Yard Attendant', '0772000014', 'ruth.ayikoi@alphamotors.co.ug');

-- T6: a clean change -> before/after snapshot logged
UPDATE employee SET phone = '+256772000015' WHERE employee_id = 11;

-- T7: an employee with no sales can be deleted -> archive row logged
DELETE FROM employee WHERE employee_id = 11;

SELECT * FROM employee;

SELECT * FROM employee_audit;

SHOW TRIGGERS LIKE 'employee';

SELECT trigger_name, action_timing, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'alpha_motors'
ORDER BY trigger_name;


-- JOINS



-- STORED PROCEDURES
DROP PROCEDURE IF EXISTS sales_made;
DELIMITER //
CREATE PROCEDURE sales_made(IN p_employee_id INT UNSIGNED)
BEGIN
    SELECT
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
        COALESCE(SUM(s.total_price), 0.00) AS total_sales
    FROM employee AS e
    LEFT JOIN sale AS s
        ON s.employee_id = e.employee_id
       AND s.status = 'Completed'
    WHERE e.employee_id = p_employee_id
    GROUP BY e.employee_id, e.first_name, e.last_name;
END//
DELIMITER ;


CALL sales_made(2);

CREATE PROCEDURE ADD_NEW_EMPLOYEE(
    IN p_first_name VARCHAR(80),
    IN p_last_name  VARCHAR(80),
    IN p_role       VARCHAR(60),
    IN p_phone      VARCHAR(30),
    IN p_email      VARCHAR(150)
)
BEGIN
    INSERT INTO employee (first_name, last_name, role, phone, email)
    VALUES (p_first_name, p_last_name, p_role, p_phone, p_email);
END//

CALL ADD_NEW_EMPLOYEE('Alice', 'Kizza', 'Sales Executive', '+256772000016', 'alice.kizza@alphamotors.co.ug');

DELIMITER //
CREATE PROCEDURE PROMOTE_EMPLOYEE(
    IN p_employee_id INT UNSIGNED,
    IN p_new_role     VARCHAR(60)
)
BEGIN
    UPDATE employee
    SET ROLE = 'P_NEW.ROLE'
    WHERE EMPLOYEE_id =p_EMPLOYEE_ID;
    END //
    DELIMITER ;
    CALL PROMOTE_EMPLOYEE(3, "Sales Manager");
    SELECT * FROM EMPLOYEE ;
    drop procedure if exists promote_employee;
    DELIMITER //
CREATE PROCEDURE PROMOTE_EMPLOYEE(
    IN p_employee_id INT UNSIGNED,
    IN p_new_role     VARCHAR(60)
)
BEGIN
    UPDATE employee
    SET ROLE = 'P_NEW.ROLE'
    WHERE EMPLOYEE_id =p_EMPLOYEE_ID;
    END //
    DELIMITER ;
    CALL PROMOTE_EMPLOYEE(3, "Sales Manager");



DELIMITER //

CREATE PROCEDURE unpaid_balance(IN p_customer_id INT UNSIGNED)
BEGIN
    -- 1. DECLARE the variables (The scratchpads)
    DECLARE v_total_cost DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_total_paid DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_unpaid_balance DECIMAL(10,2) DEFAULT 0.00;

    -- 2. SET the total cost using the FIXED price from the vehicle table
    -- Note: Change "v.price" to whatever your actual price column is called!
    SELECT IFNULL(SUM(v.selling_price), 0.00) 
    INTO v_total_cost
    FROM sale s
    JOIN vehicle v ON s.vehicle_id = v.vehicle_id
    WHERE s.customer_id = p_customer_id AND s.status <> 'Cancelled';

    -- 3. SET the total paid using the payment table
    SELECT IFNULL(SUM(p.amount), 0.00) 
    INTO v_total_paid
    FROM payment p
    JOIN sale s ON p.sale_id = s.sale_id
    WHERE s.customer_id = p_customer_id AND s.status <> 'Cancelled';

    -- 4. Calculate the final balance
    SET v_unpaid_balance = v_total_cost - v_total_paid;

    -- 5. Display the result
    SELECT v_total_cost AS total_cost, 
           v_total_paid AS amount_paid, 
           v_unpaid_balance AS unpaid_balance;

END //

call unpaid_balance(5);
DELIMITER ;
   
drop procedure if exists unpaid_balance;

call unpaid_balance(5);

call sales_made(2);




--CONSTRAINTS
