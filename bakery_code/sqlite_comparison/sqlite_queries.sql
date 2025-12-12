SQLite Queries: 

-- ===========================================
-- Bakery Database: Feature Queries (ECE 401 Final Project)
-- Author: Bryn Neal, Joseph Corella, Miguel Sena
-- ===========================================

-- Feature 1: View all sales with product and employee info
-- Shows each sale with product name, employee who handled it, and customer name.
SELECT s.sale_id, s.date, p.name AS product, p.price, 
       e.name AS employee, c.name AS customer
FROM sales s
JOIN product p ON s.product_id = p.product_id
JOIN employee e ON s.handled_by = e.employee_id
JOIN customer c ON s.customer_id = c.customer_id
ORDER BY s.date DESC
LIMIT 10;

-- ===========================================

-- Feature 2: Top 10 best-selling products
-- Finds the most frequently sold products and their total revenue.
SELECT p.name AS product, COUNT(s.sale_id) AS times_sold, 
       ROUND(SUM(s.total_cost), 2) AS total_revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY p.product_id
ORDER BY times_sold DESC
LIMIT 10;

-- ===========================================

-- Feature 3: Total daily revenue
-- Calculates the total daily revenue and total number of sales per date.
SELECT s.date, 
       ROUND(SUM(s.total_cost), 2) AS daily_revenue, 
       COUNT(s.sale_id) AS total_sales
FROM sales s
GROUP BY s.date
ORDER BY s.date ASC;

-- ===========================================

-- Feature 4: Most valuable customers
-- Lists the top customers by total amount spent and number of purchases.
SELECT c.name AS customer, 
       ROUND(SUM(s.total_cost), 2) AS total_spent,
       COUNT(s.sale_id) AS purchases
FROM sales s
JOIN customer c ON s.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 5;

-- ===========================================

-- Feature 5: Employee sales performance
-- Displays each employee’s total sales and total revenue generated.
SELECT e.name AS employee, 
       COUNT(s.sale_id) AS total_sales, 
       ROUND(SUM(s.total_cost), 2) AS total_revenue
FROM sales s
JOIN employee e ON s.handled_by = e.employee_id
GROUP BY e.employee_id
ORDER BY total_revenue DESC;

-- ===========================================

-- Feature 6: Average order value
-- Computes the average sale value across all transactions.
SELECT ROUND(AVG(total_cost), 2) AS avg_sale_value
FROM sales;

-- ===========================================

-- Feature 7: Busiest day of the week
-- Determines which weekday has the highest number of total sales (0 = Sunday, 6 = Saturday).
SELECT STRFTIME('%w', date) AS weekday, 
       COUNT(*) AS total_sales
FROM sales
GROUP BY weekday
ORDER BY total_sales DESC;

-- ===========================================

-- Feature 8: Employee attendance summary
-- Shows the number of days and average hours each employee worked.
SELECT e.name AS employee, 
       COUNT(DISTINCT w.date) AS days_worked, 
       ROUND(AVG(w.hours_worked), 2) AS avg_hours
FROM worked_on w
JOIN employee e ON w.employee_id = e.employee_id
GROUP BY e.employee_id
ORDER BY days_worked DESC;

-- ===========================================

-- Feature 9: Products generating the most revenue
-- Lists the top products by total revenue earned from all sales.
SELECT p.name AS product, 
       ROUND(SUM(s.total_cost), 2) AS total_revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_revenue DESC
LIMIT 10;

-- ===========================================

-- Feature 10: Daily employee sales summary
-- Shows how much each employee sold per day, ordered by date.
SELECT s.date, e.name AS employee, 
       ROUND(SUM(s.total_cost), 2) AS total_sales
FROM sales s
JOIN employee e ON s.handled_by = e.employee_id
GROUP BY s.date, e.employee_id
ORDER BY s.date ASC, total_sales DESC;


