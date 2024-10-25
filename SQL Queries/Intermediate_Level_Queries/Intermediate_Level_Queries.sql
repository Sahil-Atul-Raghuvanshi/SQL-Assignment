-- *****************************************************************************************
-- *****************************************************************************************
-- -----------------------------------INTERMEDIATE LEVEL QUERIES----------------------------
-- *****************************************************************************************
-- *****************************************************************************************
-- 1> Select the number of orders per campaign and order by the number of orders in descending order.
	select c.campaign_name,
		   count(o.order_id) as no_of_orders
	from tbl_campaign c
	inner join tbl_order o
	on c.campaign_id = o.campaign_id
	group by c.campaign_name
	order by count(o.order_id) desc;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 2> Find the average order amount for each campaign.
	select c.campaign_name,
		   round(avg(o.total_amount),2) as average_order_amount
	from tbl_campaign c
	inner join tbl_order o
	on c.campaign_id = o.campaign_id
	group by c.campaign_name;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 3> Select the products that have been ordered more than 100 times in total.
	select p.product_name,count(p.product_name) as no_of_times_ordered
	from tbl_product p
	inner join tbl_order_item oi
	on p.product_id = oi.product_id
	group by p.product_name
	having count(p.product_name)>100;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 4> Find the total sales for each region and order by sales in descending order.
	select c.region,count(o.order_id) as no_of_orders
	from tbl_campaign c
	inner join tbl_order o
	on c.campaign_id = o.campaign_id
	group by c.region
	order by count(o.order_id) desc;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 5> Select the average amount spent per customer and order by this average in descending order.
	select c.customer_id,c.name,round(avg(total_amount),2) as average_amount_spent
	from tbl_customer c
	inner join tbl_order o
	on c.customer_id = o.customer_id
	group by c.customer_id,c.name
	order by average_amt_spent desc;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 6> Select the most popular product in each category.
	with cte1 as (
		select p.product_name as pn,p.category as pc,count(p.product_name) as no_of_times_ordered
		from tbl_product p
		inner join tbl_order_item oi
		on p.product_id = oi.product_id
		group by p.product_name,p.category
	),
	cte2 as (
		select pn,pc,no_of_times_ordered,
		max(no_of_times_ordered) over(partition by pc order by no_of_times_ordered desc) as max_item
		from cte1
	)
	select pn as product_name,pc as category,no_of_times_ordered from cte2 where no_of_times_ordered=max_item;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 7> Find the total budget of all campaigns that have ended.
	select campaign_id,campaign_name,sum(budget) as total_budget
	from tbl_campaign
	where end_date > current_date
	group by campaign_id,campaign_name;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 8> Get order details along with campaign names.
	select order_id, c.campaign_name,customer_id,order_date, total_amount 
	from tbl_campaign as c
	inner join 
	tbl_order as o
	on c.campaign_id = o.campaign_id;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 9> Get product details for each order item.
	select order_item_id,p.product_id,product_name,category,p.price,quantity,o.price as total_price
	from tbl_product as p
	inner join
	tbl_order_item as o
	on p.product_id=o.product_id;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*	

-- 10> Aggregate the total revenue per campaign.
	select tbl_campaign.campaign_id,tbl_campaign.campaign_name,sum(total_amount) as total_revenue
	from tbl_campaign
	inner join
	tbl_order
	on
	tbl_campaign.campaign_id = tbl_order.campaign_id
	group by tbl_campaign.campaign_id
	order by tbl_campaign.campaign_id;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	
-- 11> Find the total number of orders placed per region.
	select region, count(order_id) as total_no_of_orders
	from tbl_campaign
	inner join
	tbl_order
	on
	tbl_campaign.campaign_id = tbl_order.campaign_id
	group by region;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 12> Find the total amount spent by each customer on each campaign.
	select campaign_name,name as customer_name,sum(total_amount) 
	from tbl_campaign 
	inner join
	tbl_order
	on tbl_campaign.campaign_id = tbl_order.campaign_id
	inner join 
	tbl_customer
	on tbl_customer.customer_id=tbl_order.customer_id
	group by campaign_name,customer_name;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 13> Use Aggregate Functions to find the average budget of all campaigns and group by region.
	select region,round(avg(budget),2)  as average_budget
	from tbl_campaign 
	group by region;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 14> Filter campaigns with a total spending greater than their budget using a sub-query.
	select c.campaign_id,c.campaign_name,c.budget,t1.total_spending
	from tbl_campaign as c
	inner join 
	(
		select campaign_id,sum(total_amount) as total_spending
		from tbl_order
		group by campaign_id
	) as t1
	on c.campaign_id=t1.campaign_id
	where t1.total_spending>c.budget;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 15> Calculate the total quantity sold and average price per product.
	select p.product_id,product_name,sum(quantity) as total_qunatity_sold,round(avg(o.price),2)
	from tbl_product as p
	inner join
	tbl_order_item as o
	on p.product_id=o.product_id
	group by p.product_id,product_name
	order by total_qunatity_sold desc;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 16> Aggregate the total quantity sold per product.
	select p.product_id,product_name,sum(quantity) as total_quantity_sold
	from tbl_product as p
	inner join
	tbl_order_item as o
	on p.product_id=o.product_id
	group by p.product_id,product_name
	order by total_qunatity_sold desc;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 17> Find campaigns with an average order amount greater than $200.
	select  c.campaign_id,c.campaign_name,round(avg(total_amount),2) as average_amount
	from tbl_campaign as c
	inner join 
	tbl_order as o
	on c.campaign_id = o.campaign_id
	group by c.campaign_id,c.campaign_name
	having avg(total_amount)>200;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 18> Find the top 10 products with the highest total sales amount and order by sales in descending order.
	select p.product_id,product_name,sum(o.price*o.quantity) as total_sales
	from tbl_product as p
	inner join
	tbl_order_item as o
	on p.product_id=o.product_id
	group by p.product_id,product_name
	order by sum(o.price*o.quantity) desc;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 19> Find products with less than 20 units in stock and order it using stock quantity.
   select p.product_id,p.product_name,i.stock_quantity
   from tbl_product p
   inner join tbl_inventory i
   on p.product_id=i.product_id
   where i.stock_quantity<20
   order by i.stock_quantity;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 20> Find customers who spent more than the average amount spent per customer in the last 6 months.
	select c.customer_id,c.name,c.total_spent
	from tbl_customer c
	where c.total_spent>(
		select avg(total_amount) from tbl_order
		where order_date > CURRENT_DATE - INTERVAL '6 months'
	);

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
