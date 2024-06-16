# Danny's Dinner Case Study 1

## Introduction
Welcome to the Danny's Dinner Case Study 1 repository. This project explores the scenario of Danny's Dinner, a fictional restaurant chain aiming to optimize its operations using data-driven insights. In this case study, we analyze their current setup, identify challenges, and propose solutions to enhance efficiency and customer satisfaction.

## Problem Statement
Danny's Dinner faces several operational challenges that hinder its performance and customer experience:

- **Inventory Management:** Inefficient tracking leading to overstocking or understocking of ingredients.
- **Customer Satisfaction:** Issues with order accuracy and timely service.
- **Employee Management:** Difficulty in scheduling shifts and optimizing staffing levels.

## Entity Relational Diagram (ERD)
The Entity Relational Diagram (ERD) below illustrates the key entities and their relationships within the Danny's Dinner database:

![image](https://github.com/shreyanshi1605/Danny-s-Dinner/assets/145632760/4ffec918-8bd3-4792-9ff2-1b63f0be1d55)

## Case Study Questions

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

## Solution

Before addressing the questions and providing answers, I've comprehensively reviewed the Entity Relationship Diagram (ERD) to grasp the logical organization of the tables. Danny has supplied us with sample data that safeguards customer privacy, and this schema can be readily executed on your local system.

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

1. What is the total amount each customer spent at the restaurant?

The SQL query calculates the total amount spent by each customer at Danny’s Diner. It joins the sales table with the menu table on the product_id to associate each sale with its menu item price. The SUM function adds up the prices for each customer, and the GROUP BY clause ensures that the sum is calculated separately for each customer_id.

SELECT s.customer_id, SUM(m.price) AS "Total Amount Spent" 
FROM menu m 
INNER JOIN sales s 
ON m.product_id = s.product_id 
GROUP BY customer_id;

![image](https://github.com/shreyanshi1605/Danny-s-Dinner/assets/145632760/4b3a8b9e-8625-411e-b52f-aac614ab8e11)

The output is a table with two columns: customer_id and Total Amount Spent, showing the total spent by customers A, B, and C as 76, 74, and 36 respectively

2. How many days has each customer visited the restaurant?

The SQL query aims to determine the number of distinct days each customer has visited Danny’s Diner. It selects the customer_id from the sales table and counts the unique order_date entries for each customer. The COUNT(distinct order_date) function ensures that only unique visit dates are counted, even if multiple orders were placed on the same day. The GROUP BY customer_id clause groups the results by customer, providing a count of visited days for each one.

SELECT customer_id, COUNT(distinct order_date) AS "Number of Days Visited" 
FROM sales 
GROUP BY customer_id;

![image](https://github.com/shreyanshi1605/Danny-s-Dinner/assets/145632760/8e3f6665-79c9-42a2-a4e9-49823e0c9446)

The output shows that customer A visited on 4 different days, B on 6, and C on 2.

3. What was the first item from the menu purchased by each customer?

The SQL query joins the sales table with the menu table based on matching product_ids. The query then filters for the earliest order_date for each customer_id. The result is a list of customers along with the first item they purchased and the date of purchase. The results are ordered by customer_id.

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

![image](https://github.com/shreyanshi1605/Danny-s-Dinner/assets/145632760/6f69b963-4f9b-4a1f-b08b-e0bb57825f6e)

The result gives us a list with customer IDs, associated product names, and the respective order dates for their first purchases.

4. What is the most purchased item on the menu and how many times was it purchased by all customers?

The SQL query identifies the most purchased item on the menu by counting the number of times each item was sold, grouping the results by product name, and ordering them in descending order. The SELECT TOP 1 ensures that only the item with the highest count is returned. However, the ORDER BY clause should be COUNT(s.product_id) DESC to get the correct most purchased item.

SELECT top 1 COUNT(s.product_id) AS "Most PurchASed Item" , m.product_name 
FROM menu m INNER JOIN sales s 
ON m.product_id = s.product_id 
GROUP BY m.product_name 
ORDER BY max(s.product_id) DESC;

![image](https://github.com/shreyanshi1605/Danny-s-Dinner/assets/145632760/2dc32e5b-1fa3-47d5-8215-15f3b0f71ff3)

The output shows that ‘ramen’ is the most purchased item, having been bought 8 times by all customers. 

5. Which item was the most popular for each customer?

The SQL query uses a Common Table Expression (CTE) named item_COUNT to count the number of times each menu item was ordered by each customer. It then ranks these items within each customer group based on the order count. The main query selects the top-ranked (most ordered) item for each customer from the CTE.

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

![image](https://github.com/shreyanshi1605/Danny-s-Dinner/assets/145632760/bb279c55-5269-4bec-9518-fde7926f8cfc)

The output shows each customer’s most frequently ordered item. For example, if customer A most frequently ordered ‘ramen’, and customer B most frequently ordered ‘sushi’, these would be listed in the output

6. Which item was purchased first by the customer after they became a member?

The SQL query creates a ranked list of menu items purchased by each customer after their membership join date, using a Common Table Expression (CTE). It then selects the first item each customer bought post-membership. The DENSE_RANK() function is used to rank the items based on the order date for each customer.

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

![image](https://github.com/shreyanshi1605/Danny-s-Dinner/assets/145632760/0f7139dc-b0d7-476e-82c3-78ccc98dc84f)

Customer A: First purchased item post-membership is ‘ramen’.
Customer B: First purchased item post-membership is ‘sushi’.

7. Which item was purchased just before the customer became a member?

The SQL query determines the last item purchased by each customer before they became members. It uses a Common Table Expression (CTE) to rank the purchases made before the join date and selects the most recent purchase (ranking = 1) for each customer. The final output lists the customer_id and the product_name of that last pre-membership purchase.

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

![image](https://github.com/shreyanshi1605/Danny-s-Dinner/assets/145632760/564e740f-374d-43d3-aaec-6e8ad36c94c1)

Customer A: Last purchased item before membership was ‘sushi’.
Customer B: Last purchased item before membership was also ‘sushi’

8. What is the total items and amount spent for each member before they became a member?

The SQL query is designed to calculate the total number of items purchased and the total amount spent by customers on orders made before they became members. It first identifies pre-membership purchases by joining the members and sales tables, then aggregates this data with the menu table to sum up the items and costs.

with purchase_before_members AS (
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

![image](https://github.com/shreyanshi1605/Danny-s-Dinner/assets/145632760/1115cced-f7e3-40a9-b65a-c647d5f59bdf)

The output of the SQL query is a table with three columns: customer_id, Total Items, and Amount Spent. It shows the total number of items each customer purchased and the total amount they spent on those items before they became members

9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

The SQL query is creating a points system for products sold, where each product contributes points based on its price and product_id. If the product_id is 1, it contributes 20 times its price in points, otherwise, it contributes 10 times its price. This is done using a Common Table Expression (CTE) named points_CTE.

The query then joins the sales table with this CTE based on the product_id and calculates the total points for each customer. The results are grouped by customer_id and ordered by customer_id.

WITH points_CTE AS (
  SELECT 
    product_id, 
    CASE
      WHEN product_id = 1 THEN price * 20
      ELSE price * 10
    END AS points
  FROM menu
) SELECT 
  s.customer_id, 
  SUM(points_CTE.points) AS total_points
FROM sales s
JOIN points_CTE 
  ON s.product_id = points_CTE.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

![image](https://github.com/shreyanshi1605/Danny-s-Dinner/assets/145632760/1a0fc6c6-dce9-426d-a489-3c5a97a717c5)

The output of this query is a table with two columns: customer_id and total_points. Each row represents a customer and shows the total points they have accumulated based on their purchases. This can be used to understand the rewards or loyalty points each customer has earned

10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi

The SQL query utilizes a Common Table Expression (CTE) to calculate points for customer purchases. Points are normally 10 times the price, but purchases made within a week of joining or of ‘sushi’ earn double points. The CTE includes customer ID, product name, price, and dates.

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

The output summarizes the total points for each customer, reflecting their purchasing activity and any bonus points earned for timely or specific product purchases, such as ‘sushi’. This helps in loyalty or rewards program analysis.

![image](https://github.com/shreyanshi1605/Danny-s-Dinner/assets/145632760/1d04431d-0b05-4419-99ef-d5c544953c69)

## Suggestions
Based on the analysis, here are some suggestions to address the identified challenges:

- **Implement Inventory Management System:** Integrate a robust inventory management system to track ingredient usage, predict demand, and automate ordering processes.
- **Enhance Order Management:** Develop a streamlined order processing system to minimize errors and improve order fulfillment times.
- **Optimize Employee Scheduling:** Utilize scheduling software to optimize shifts based on historical data and demand forecasts.

## Conclusion
In conclusion, addressing the operational challenges at Danny's Dinner requires a combination of improved systems and processes. By implementing the suggestions outlined above, the restaurant can enhance efficiency, reduce costs, and ultimately provide a better experience for its customers and employees.
