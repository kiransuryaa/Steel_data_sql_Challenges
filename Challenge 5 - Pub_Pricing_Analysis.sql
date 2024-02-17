-- QUESTIONS

-- 1. How many pubs are located in each country?
-- 2. What is the total sales amount for each pub, including the beverage price and quantity sold?
-- 3. Which pub has the highest average rating?
-- 4. What are the top 5 beverages by sales quantity across all pubs?
-- 5. How many sales transactions occurred on each date?
-- 6. Find the name of someone that had cocktails and which pub they had it in.
-- 7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?
-- 8. Which pubs have a rating higher than the average rating of all pubs?
-- 9. What is the running total of sales amount for each pub, ordered by the transaction date?
-- 10. For each country, what is the average price per unit of beverages in each category, and what is the overall average price per unit of beverages across all categories?
-- 11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, and what is the pub's overall sales amount?

-- 1. How many pubs are located in each country?
SELECT country, COUNT(*) AS number_of_pubs 
FROM pubs
GROUP BY country;

-- 2. What is the total sales amount for each pub, including the beverage price and quantity sold?
SELECT p.pub_name, SUM(b.price_per_unit * s.quantity) AS total_sales_amount
FROM pubs p
JOIN sales s USING(pub_id)
JOIN beverages b USING(beverage_id)
GROUP BY p.pub_name;

-- 3. Which pub has the highest average rating?
SELECT p.pub_id, p.pub_name, ROUND(AVG(rating), 2) AS Avg_rating
FROM ratings r
JOIN pubs p USING (pub_id)
GROUP BY p.pub_id
ORDER BY Avg_rating DESC
LIMIT 1;

-- 4. What are the top 5 beverages by sales quantity across all pubs?
SELECT b.beverage_id, b.beverage_name, SUM(s.quantity) AS total_quantity 
FROM sales s 
JOIN beverages b USING(beverage_id)
GROUP BY b.beverage_id
ORDER BY total_quantity DESC
LIMIT 5;

-- 5. How many sales transactions occurred on each date?
SELECT transaction_date, COUNT(sale_id) AS total_transactions
FROM sales
GROUP BY transaction_date
ORDER BY transaction_date;

-- 6. Find the name of someone that had cocktails and which pub they had it in.
SELECT p.pub_id, p.pub_name, r.customer_name, b.category 
FROM beverages b 
JOIN sales s USING (beverage_id)
JOIN ratings r USING (pub_id)
JOIN pubs p USING (pub_id)
WHERE b.category = 'Cocktail' 
ORDER BY p.pub_id;

-- 7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?
SELECT category, ROUND(AVG(price_per_unit)) AS avg_price_per_unit
FROM beverages
WHERE category NOT IN ('Spirit')
GROUP BY category;

-- 8. Which pubs have a rating higher than the average rating of all pubs?
SELECT p.pub_name, ROUND(AVG(r.rating),2) AS avg_rating
FROM pubs p
JOIN ratings r USING(pub_id)
GROUP BY p.pub_name
HAVING avg_rating > (SELECT AVG(rating)
FROM ratings);

-- 9. What is the running total of sales amount for each pub, ordered by the transaction date?
SELECT p.pub_name, s.transaction_date, sum(b.price_per_unit * s.quantity) AS total_amount,
SUM(SUM(b.price_per_unit * s.quantity)) OVER (PARTITION BY pub_name ORDER BY transaction_date ) AS running_total
FROM pubs p 
JOIN sales s USING (pub_id) 
JOIN beverages b USING (beverage_id)
GROUP BY p.pub_name, s.transaction_date;

-- 10. For each country, what is the average price per unit of beverages in each category, and what is the overall average price per unit of beverages across all categories?
WITH cte1 AS (
	SELECT 
		b.category, 
		p.country, 
		ROUND(AVG(b.price_per_unit),2) AS Avg_price_per_unit_each_category
	FROM beverages b
	JOIN sales s USING(beverage_id)
	JOIN pubs p USING(pub_id)
	GROUP BY b.category, p.country 
),
cte2 AS (
	SELECT 
		p.country, 
		ROUND(AVG(b.price_per_unit),2) AS avg_price_per_unit_overall_category
    FROM beverages b
	JOIN sales s USING(beverage_id)
	JOIN pubs p USING(pub_id)
    GROUP BY p.country
)
SELECT 
	cte1.country, 
	cte1.category, 
	cte1.Avg_price_per_unit_each_category,
	cte2.avg_price_per_unit_overall_category
FROM cte1
JOIN cte2 USING(country);

-- 11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, and what is the pub's overall sales amount?
SELECT * FROM beverages;
SELECT * FROM sales;
WITH temp1 AS(
	SELECT p.pub_name, b.category, SUM(b.price_per_unit*s.quantity) AS category_sales_amount
	FROM beverages b
	JOIN sales s USING(beverage_id)
	JOIN pubs p USING(pub_id)
	GROUP BY p.pub_name, b.category
),
temp2 AS(
	SELECT p.pub_name, SUM(b.price_per_unit*s.quantity) AS overall_sales_amount
	FROM beverages b
	JOIN sales s USING(beverage_id)
	JOIN pubs p USING(pub_id)
	GROUP BY p.pub_name
)
SELECT temp1.pub_name, temp2.overall_sales_amount, temp1.category, temp1.category_sales_amount, 
ROUND((temp1.category_sales_amount/temp2.overall_sales_amount)*100, 2) AS percent_contribution
FROM temp1
JOIN temp2 USING(pub_name);