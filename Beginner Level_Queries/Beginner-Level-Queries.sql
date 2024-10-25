-- *****************************************************************************************
-- *****************************************************************************************
-- -----------------------------------BEGINNER LEVEL QUERIES--------------------------------
-- *****************************************************************************************
-- *****************************************************************************************
-- 1> Select all campaigns that are currently active.
	select * from tbl_campaign where start_date < current_date and end_date >=current_date;


-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- 2> Select all customers who joined after January 1, 2023.
	select * from tbl_campaign where start_date>='2023-01-01';

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 3> Select the total amount spent by each customer, ordered by amount in descending order.
    select name,total_spent from tbl_customer order by total_spent desc;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 4> Select the products with a price greater than $50.
	select * from tbl_product where price > 50;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 5> Select the number of orders placed in the last 30 days
	select count(*) from tbl_order where order_date >= current_date - interval '30 days';

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 6> Order the products by price in ascending order and limit the results to the top 5 most affordable products.
    select * from tbl_product order by price limit 5;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 7> Select the campaign names and their budgets.
	select campaign_name,budget from tbl_campaign;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 8> Select the total quantity sold for each product, ordered by quantity sold in descending order.
	select product_id, sum(quantity) from tbl_order_item group by product_id order by sum(quantity) desc;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 9> Select the details of orders that have a total amount greater than $100.
	select * from tbl_order_item where price>100;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 10> Find the total number of customers who have made at least one purchase.
	select count(distinct customer_id) from tbl_order;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 11> Select the top 3 campaigns with the highest budgets.
	select * from tbl_campaign order by budget desc limit 3;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 12> Select the top 5 customers with the highest total amount spent.
	select * from tbl_customer order by total_spent desc limit 5;

-- *****************************************************************************************
