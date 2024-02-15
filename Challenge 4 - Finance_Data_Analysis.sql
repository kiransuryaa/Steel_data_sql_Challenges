USE finance_data;

-- Create the Customers table
CREATE TABLE Customers (
CustomerID INT PRIMARY KEY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
City VARCHAR(50) NOT NULL,
State VARCHAR(2) NOT NULL
);
--------------------
-- Populate the Customers table
INSERT INTO Customers (CustomerID, FirstName, LastName, City, State)
VALUES (1, 'John', 'Doe', 'New York', 'NY'),
(2, 'Jane', 'Doe', 'New York', 'NY'),
(3, 'Bob', 'Smith', 'San Francisco', 'CA'),
(4, 'Alice', 'Johnson', 'San Francisco', 'CA'),
(5, 'Michael', 'Lee', 'Los Angeles', 'CA'),
(6, 'Jennifer', 'Wang', 'Los Angeles', 'CA');
--------------------
-- Create the Branches table
CREATE TABLE Branches (
BranchID INT PRIMARY KEY,
BranchName VARCHAR(50) NOT NULL,
City VARCHAR(50) NOT NULL,
State VARCHAR(2) NOT NULL
);
--------------------
-- Populate the Branches table
INSERT INTO Branches (BranchID, BranchName, City, State)
VALUES (1, 'Main', 'New York', 'NY'),
(2, 'Downtown', 'San Francisco', 'CA'),
(3, 'West LA', 'Los Angeles', 'CA'),
(4, 'East LA', 'Los Angeles', 'CA'),
(5, 'Uptown', 'New York', 'NY'),
(6, 'Financial District', 'San Francisco', 'CA'),
(7, 'Midtown', 'New York', 'NY'),
(8, 'South Bay', 'San Francisco', 'CA'),
(9, 'Downtown', 'Los Angeles', 'CA'),
(10, 'Chinatown', 'New York', 'NY'),
(11, 'Marina', 'San Francisco', 'CA'),
(12, 'Beverly Hills', 'Los Angeles', 'CA'),
(13, 'Brooklyn', 'New York', 'NY'),
(14, 'North Beach', 'San Francisco', 'CA'),
(15, 'Pasadena', 'Los Angeles', 'CA');
--------------------
-- Create the Accounts table
CREATE TABLE Accounts (
AccountID INT PRIMARY KEY,
CustomerID INT NOT NULL,
BranchID INT NOT NULL,
AccountType VARCHAR(50) NOT NULL,
Balance DECIMAL(10, 2) NOT NULL,
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);
--------------------
-- Populate the Accounts table
INSERT INTO Accounts (AccountID, CustomerID, BranchID, AccountType, Balance)
VALUES (1, 1, 5, 'Checking', 1000.00),
(2, 1, 5, 'Savings', 5000.00),
(3, 2, 1, 'Checking', 2500.00),
(4, 2, 1, 'Savings', 10000.00),
(5, 3, 2, 'Checking', 7500.00),
(6, 3, 2, 'Savings', 15000.00),
(7, 4, 8, 'Checking', 5000.00),
(8, 4, 8, 'Savings', 20000.00),
(9, 5, 14, 'Checking', 10000.00),
(10, 5, 14, 'Savings', 50000.00),
(11, 6, 2, 'Checking', 5000.00),
(12, 6, 2, 'Savings', 10000.00),
(13, 1, 5, 'Credit Card', -500.00),
(14, 2, 1, 'Credit Card', -1000.00),
(15, 3, 2, 'Credit Card', -2000.00);
--------------------
-- Create the Transactions table
CREATE TABLE Transactions (
TransactionID INT PRIMARY KEY,
AccountID INT NOT NULL,
TransactionDate DATE NOT NULL,
Amount DECIMAL(10, 2) NOT NULL,
FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);
--------------------
-- Populate the Transactions table
INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount)
VALUES (1, 1, '2022-01-01', -500.00),
(2, 1, '2022-01-02', -250.00),
(3, 2, '2022-01-03', 1000.00),
(4, 3, '2022-01-04', -1000.00),
(5, 3, '2022-01-05', 500.00),
(6, 4, '2022-01-06', 1000.00),
(7, 4, '2022-01-07', -500.00),
(8, 5, '2022-01-08', -2500.00),
(9, 6, '2022-01-09', 500.00),
(10, 6, '2022-01-10', -1000.00),
(11, 7, '2022-01-11', -500.00),
(12, 7, '2022-01-12', -250.00),
(13, 8, '2022-01-13', 1000.00),
(14, 8, '2022-01-14', -1000.00),
(15, 9, '2022-01-15', 500.00);


-- Questions

-- 1. What are the names of all the customers who live in New York?
-- 2. What is the total number of accounts in the Accounts table?
-- 3. What is the total balance of all checking accounts?
-- 4. What is the total balance of all accounts associated with customers who live in Los Angeles?
-- 5. Which branch has the highest average account balance?
-- 6. Which customer has the highest current balance in their accounts?
-- 7. Which customer has made the most transactions in the Transactions table?
-- 8.Which branch has the highest total balance across all of its accounts?
-- 9. Which customer has the highest total balance across all of their accounts, including savings and checking accounts?
-- 10. Which branch has the highest number of transactions in the Transactions table?


-- 1. What are the names of all the customers who live in New York?
SELECT CustomerID, City, CONCAT(FirstName,' ',LastName) AS customer_name
FROM customers
WHERE City = 'New York';

-- 2. What is the total number of accounts in the Accounts table?
SELECT COUNT(DISTINCT(AccountID)) AS Total_number_of_account
FROM accounts;

-- 3. What is the total balance of all checking accounts?
SELECT AccountType, SUM(Balance) AS Total_balance
FROM accounts
WHERE AccountType = 'Checking';

-- 4. What is the total balance of all accounts associated with customers who live in Los Angeles?
SELECT c.City, SUM(Balance) AS total_balance
FROM accounts a
JOIN customers c USING(CustomerID) 
WHERE c.City = 'Los Angeles';

-- 5. Which branch has the highest average account balance?
SELECT BranchID, BranchName, ROUND(AVG(Balance), 2) AS Avg_balance
FROM accounts
JOIN branches USING(BranchID)
GROUP BY BranchID
ORDER BY Avg_balance DESC
LIMIT 1;

-- 6. Which customer has the highest current balance in their accounts?
SELECT CONCAT(c.FirstName,' ',c.LastName) AS customer_name,
	   MAX(a.Balance) AS highest_current_balance
FROM accounts a
JOIN customers c USING(CustomerID)
GROUP BY customer_name
ORDER BY highest_current_balance DESC
LIMIT 1 ;

-- 7. Which customer has made the most transactions in the Transactions table?
WITH customer_with_transaction AS(
	SELECT
		CONCAT(c.FirstName, ' ' , c.LastName) AS customer_name,
		COUNT(t.TransactionID) AS total_transaction,
		DENSE_RANK() OVER(ORDER BY COUNT(t.TransactionID) DESC ) rn
	FROM transactions t 
	JOIN accounts a ON t.AccountID = a.AccountID	
	JOIN customers c ON a.CustomerID = c.CustomerID
	GROUP BY customer_name
)
SELECT * FROM customer_with_transaction
WHERE rn = 1;

-- 8.Which branch has the highest total balance across all of its accounts?
SELECT b.BranchID, b.BranchName, SUM(Balance) AS Total_balance
FROM accounts a 
JOIN branches b USING(BranchID)
GROUP BY BranchID
ORDER BY Total_balance DESC
LIMIT 1;

-- 9. Which customer has the highest total balance across all of their accounts, including savings and checking accounts?
SELECT c.CustomerID, CONCAT(c.FirstName,' ', c.LastName) AS customer_name, 
	   SUM(a.Balance) AS total_balance
FROM customers c
JOIN accounts a ON c.CustomerID = a.CustomerID
WHERE a.AccountType IN ('Saving','Checking')
GROUP BY c.CustomerID, customer_name
ORDER BY total_balance DESC
LIMIT 1;

-- 10. Which branch has the highest number of transactions in the Transactions table?
WITH highest_transaction AS (
	SELECT  
		b.BranchName, 
		COUNT(t.TransactionID) AS number_of_transaction,
		DENSE_RANK() OVER(ORDER BY COUNT(t.TransactionID) DESC) rn
	FROM transactions t
	JOIN accounts a ON t.AccountID = a.AccountID
	JOIN branches b ON a.BranchID = b.BranchID
	GROUP BY b.BranchName
)
SELECT * 
FROM highest_transaction
WHERE rn = 1;

