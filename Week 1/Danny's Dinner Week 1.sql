CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);
 
CREATE TABLE menu (
  product_id INTEGER PRIMARY KEY,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);
 
CREATE TABLE members (
  customer_id VARCHAR(1) PRIMARY KEY,
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT * FROM members;
SELECT * FROM menu;
SELECT * FROM sales;

-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) AS "Total Amount Spent" 
FROM menu m 
INNER JOIN sales s 
ON m.product_id = s.product_id 
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(distinct order_date) AS "Number of Days Visited" 
FROM sales 
GROUP BY customer_id;

-- 3. What was the first item FROM the menu purchASed by each customer?
SELECT
    s.customer_id,
    m.product_name AS "First item Purchased",
    s.order_date AS "Purchased ON"
FROM
    sales s
INNER JOIN menu m ON s.product_id = m.product_id
WHERE
    s.order_date = (
        SELECT MIN(sub.order_date)
        FROM sales sub
        WHERE sub.customer_id = s.customer_id
    )
GROUP BY s.customer_id, m.product_name, s.order_date
ORDER BY
    s.customer_id;

-- 4. What is the most purchASed item ON the menu and how many times was it purchASed by all customers?
SELECT top 1 COUNT(s.product_id) AS "Most PurchASed Item" , m.product_name 
FROM menu m INNER JOIN sales s 
ON m.product_id = s.product_id 
GROUP BY m.product_name 
ORDER BY max(s.product_id) DESC;

-- 5. Which item was the most popular for each customer?
with item_COUNT AS(
	SELECT s.customer_id, m.product_name, COUNT(*) AS "order COUNT", 
	Dense_rank() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS ranking
	FROM menu m INNER JOIN sales s 
	ON m.product_id = s.product_id
	GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name
FROM item_COUNT
WHERE ranking = 1

-- 6. Which item was purchASed first by the customer after they became a members?
with joined_AS_members AS (
	SELECT mb.customer_id, mb.join_date, s.product_id, s.order_date, 
	Dense_rank() OVER(PARTITION BY mb.customer_id ORDER BY s.order_date) AS ranking
	FROM members mb
	INNER JOIN sales s
	ON mb.customer_id = s.customer_id
	WHERE s.order_date > mb.join_date
)
SELECT j.customer_id, m.product_name
FROM menu m
INNER JOIN joined_AS_members j
ON j.product_id = m.product_id
WHERE ranking = 1
GROUP BY j.customer_id, m.product_name;

-- 7. Which item was purchASed just before the customer became a members?
with purchASe_before_members AS (
	SELECT mb.customer_id, mb.join_date, s.product_id, s.order_date, 
	row_number() OVER(PARTITION BY mb.customer_id ORDER BY s.order_date DESC) AS ranking
	FROM members mb
	INNER JOIN sales s
	ON mb.customer_id = s.customer_id
	WHERE s.order_date < mb.join_date
)
SELECT p.customer_id, m.product_name
FROM menu m
INNER JOIN purchASe_before_members p
ON p.product_id = m.product_id
WHERE ranking = 1
GROUP BY p.customer_id, m.product_name;

-- 8. What is the total items and amount spent for each members before they became a members?
with purchASe_before_members AS (
	SELECT mb.customer_id, mb.join_date, s.product_id, s.order_date
	FROM members mb
	INNER JOIN sales s
	ON mb.customer_id = s.customer_id
	WHERE s.order_date < mb.join_date
)
SELECT p.customer_id, COUNT(*) AS "Total Items", SUM(m.price) AS "Amount Spent"
FROM menu m
INNER JOIN purchASe_before_members p
ON p.product_id = m.product_id
GROUP BY p.customer_id;


-- 9. If each $1 spent equates to 10 points and sushi hAS a 2x points multiplier — how many points would each customer have?
WITH points_CTE AS (
  SELECT 
    product_id, 
    CASE
      WHEN product_id = 1 THEN price * 20
      ELSE price * 10
    END AS points
  FROM menu
)

SELECT 
  s.customer_id, 
  SUM(points_CTE.points) AS total_points
FROM sales s
JOIN points_CTE 
  ON s.product_id = points_CTE.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earanking 2x points ON all items, not just sushi — how many points do customer A and B have at the end of January?

with CTE AS 
(SELECT s.customer_id, m.product_name, m.price, order_date, join_date,
	CASE
		WHEN s.order_date BETWEEN mb.join_date AND DATEADD(day, 7, mb.join_date) THEN m.price*10*2
		WHEN m.product_name = 'sushi' THEN m.price*10*2
		ELSE m.price*10
		END AS points
	FROM sales s
	INNER JOIN menu m
	ON s.product_id = m.product_id
	INNER JOIN members mb
	ON mb.customer_id = s.customer_id
)
SELECT customer_id, SUM(points) AS total_points FROM CTE GROUP BY customer_id;

-- BONUS QUESTION
-- 11. Determine the name and price of the product ordered by each customer ON all order dates & all order dates & find out whether the customer was a members ON the order date or not
SELECT s.customer_id, order_date, m.product_name, m.price, 
CASE
     WHEN s.order_date >= mb.join_Date THEN 'Y'
	 ELSE 'N' 
	 END AS members
FROM sales s
	INNER JOIN menu m
	ON s.product_id = m.product_id
	LEFT JOIN members mb
	ON mb.customer_id = s.customer_id;

-- 12. Rank the previous output FROM Q.11 based on the order_date for each customer. Display NULL if customer was not a members when dish was ordered.
with CTE AS
(
	SELECT s.customer_id, order_date, m.product_name, m.price, 
	Dense_rank() OVER(PARTITION BY order_date ORDER BY order_date) AS rank,
	CASE
		 WHEN s.order_date >= mb.join_Date THEN 'Y'
		 ELSE 'N' 
		 END AS members_status
	FROM sales s
		INNER JOIN menu m
		ON s.product_id = m.product_id
		LEFT JOIN members mb
		ON mb.customer_id = s.customer_id
)
SELECT *,
CASE
    WHEN members_status = 'N' then NULL
    ELSE RANK () OVER(
      PARTITION BY customer_id, members_status
      ORDER BY order_date) END AS ranking
FROM CTE;