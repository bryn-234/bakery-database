BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "Bakery" (
	"Date"	TEXT,
	"Time"	TEXT,
	"Transaction"	INTEGER,
	"Item"	TEXT
);
CREATE TABLE IF NOT EXISTS customer (
    customer_id INTEGER PRIMARY KEY,
    name TEXT,
    phone_number TEXT
);
CREATE TABLE IF NOT EXISTS employee (
    employee_id INTEGER PRIMARY KEY,
    name TEXT,
    title TEXT,
    salary REAL,
    date_of_birth TEXT,
    address TEXT,
    phone_number TEXT
);
CREATE TABLE IF NOT EXISTS product (
    product_id INTEGER PRIMARY KEY,
    name TEXT,
    description TEXT,
    nutrition_facts TEXT,
    price REAL
);
CREATE TABLE IF NOT EXISTS sales (
    sale_id INTEGER PRIMARY KEY,
    date TEXT,
    quantity INTEGER,
    total_cost REAL,
    handled_by INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    FOREIGN KEY (handled_by) REFERENCES employee(employee_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);
CREATE TABLE IF NOT EXISTS schedule (
    schedule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT,
    employee_id INTEGER,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);
CREATE TABLE IF NOT EXISTS worked_on (
    work_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT,
    employee_id INTEGER,
    clock_in_time TEXT,
    hours_worked INTEGER,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);
CREATE VIEW products_sold as 
select distinct Item
from bakery;
COMMIT;
