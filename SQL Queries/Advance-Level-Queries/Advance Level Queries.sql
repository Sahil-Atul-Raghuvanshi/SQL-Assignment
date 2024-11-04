-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- *****************************************************************************************
-- -----------------------------------ADVANCE SQL QUERIES-----------------------------------
-- *****************************************************************************************
-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 1> Select the campaigns with the highest and lowest budgets.

	select 'Maximum Budget Campaign' as campaign_type,campaign_id,campaign_name,budget
	from tbl_campaign
	where budget = (select max(budget) from tbl_campaign)
	union
	select 'Minimum Budget Campaign' as campaign_type,campaign_id,campaign_name,budget
	from tbl_campaign
	where budget = (select min(budget) from tbl_campaign);

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 2> Find the average price of products across all categories.

	select category,round(avg(price),2) as average_price
	from tbl_product
	group by category;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 3> Rank products based on their total sales within each category.

	select p.product_id,p.product_name,p.category,sum(oi.price*oi.quantity) as total_sales,
	rank() over( partition by p.category order by sum(oi.price*oi.quantity) desc )
	from tbl_product p
	inner join tbl_order_item oi
	on p.product_id = oi.product_id
	group by p.product_id,p.product_name,p.category;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 4> Create a CTE to calculate the total revenue and average order amount for each campaign.
	with calculate as(
		select tbl_campaign.campaign_id,tbl_campaign.campaign_name,
		sum(total_amount) as total_revenue,
		round(avg(total_amount),2) as average_order_amount
		from tbl_campaign
		inner join
		tbl_order
		on
		tbl_campaign.campaign_id = tbl_order.campaign_id
		group by tbl_campaign.campaign_id,tbl_campaign.campaign_name
		order by tbl_campaign.campaign_id
	)
	select * from calculate;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- 5> Handle any missing stock quantities and provide a default value of 0 for products with no recorded inventory.


	select i.product_id,product_name,coalesce(stock_quantity,0) as stock_quantity
	from tbl_inventory i
	left join tbl_product p
	on i.product_id=p.product_id;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- 6> Analyse the total quantity and revenue generated from each product by customer.

	select c.customer_id,c.name,
	p.product_name,
	sum(oi.quantity) as total_quantity,
	sum(oi.quantity*oi.price) as total_revenue
	from tbl_customer c
	inner join tbl_order o
	on c.customer_id=o.customer_id
	inner join tbl_order_item oi
	on oi.order_id=o.order_id
	inner join tbl_product p
	on p.product_id=oi.product_id
	group by c.customer_id,c.name,
	p.product_name;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 7> Find campaigns that have a higher average order amount than the overall average.

	with input_data as (
		select tbl_campaign.campaign_id,tbl_campaign.campaign_name,round(avg(total_amount),2) as avg_per_campaign
		from tbl_campaign
		inner join
		tbl_order
		on
		tbl_campaign.campaign_id = tbl_order.campaign_id
		group by tbl_campaign.campaign_id
	),
	final_output as (
		select campaign_id,campaign_name,avg_per_campaign 
		from input_data
		where avg_per_campaign >
		(
			select avg(total_amount) from tbl_order
		)
	)
	select * from final_output;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 8> Analyse the rolling average of sales per campaign over the last 3 months.

	with monthly_sales as (
	    select campaign_id,
	           date_trunc('month', order_date) as sales_month,
	           sum(total_amount) as total_sales
	    from
	        tbl_order
	    where 
	        order_date >= current_date - interval '3 months'
	    group by 
	        campaign_id, sales_month
	),
	rolling_avg_sales as (
	    select campaign_id,
	           sales_month,
	           avg(total_sales) over (partition by campaign_id order by sales_month 
	           rows between 2 preceding and current row) as rolling_average_sales
	    from 
	        monthly_sales
	)
	select campaign_id,
	       sales_month,
		   to_char(sales_month, 'Month YYYY') as month_name,
	       rolling_average_sales,
	from 
	    rolling_avg_sales
	order by 
	    campaign_id, sales_month;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 9> Calculate the growth rate of sales for each campaign over time and rank them accordingly.

	-- Daily Growth Rate
 
	select c.campaign_name,order_date,sum(total_amount),
	((sum(total_amount)-lag(sum(total_amount)) over(order by order_date))/
	 lag(sum(total_amount)) over(order by order_date)*100) as growth_rate
	from tbl_campaign c
	inner join tbl_order o
	on c.campaign_id = o.campaign_id
	group by c.campaign_name,order_date
	order by o.order_date;
	
	-- Monthly Growth Rate

	with cte1 as (
	select c.campaign_name,date_trunc('month', o.order_date) AS month_start,sum(total_amount) as total_sales
	from tbl_campaign c
	inner join tbl_order o
	on c.campaign_id = o.campaign_id
	group by c.campaign_name,month_start
	),
	cte2 as(
		select campaign_name,to_char(month_start, 'Month YYYY') AS month_name,total_sales,
		(total_sales-lag(total_sales)over(partition by campaign_name order by month_start))/
	 lag(total_sales) over(partition by campaign_name order by month_start)*100 as growth_rate
		from cte1
	)
	select * from cte2;

	-- Weekly Growth Rate

	with cte1 as (
	select c.campaign_name,date_trunc('week', o.order_date) AS week_start,sum(total_amount) as total_sales
	from tbl_campaign c
	inner join tbl_order o
	on c.campaign_id = o.campaign_id
	group by c.campaign_name,week_start
	),
	cte2 as(
		select campaign_name,week_start,total_sales,
		(total_sales-lag(total_sales)over(partition by campaign_name order by week_start))/
	 lag(total_sales) over(partition by campaign_name order by week_start)*100 as growth_rate
		from cte1
	)
	select * from cte2;
	
-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- 10> Use CTEs and Window Functions to find the top 5 customers who have consistently spent above the 75th percentile of customer spending.


	with input_data as(
		select c.customer_id,c.name,c.total_spent 
		from tbl_customer c
	),
	filter_customers as(
		select * 
		from input_data 
		where total_spent > 
		(
			select
			percentile_cont(0.75) 
			within group(order by total_spent)
			from input_data
		)
	),
	rank_customers as(
		select customer_id,name,total_spent,
		rank() over(order by total_spent desc) as rank
		from filter_customers
	)
	select * from rank_customers where rank<=5;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- 11> Use Advanced Sub-Queries to find the correlation between campaign budgets and total revenue generated.

	with campaign_revenue as (
	    select 
	        c.campaign_id,
	        c.campaign_name,
	        c.budget,
	        coalesce(sum(o.total_amount), 0) as total_revenue
	    from 
	        tbl_campaign c
	    left join 
	        tbl_order o on c.campaign_id = o.campaign_id
	    group by 
	        c.campaign_id, c.campaign_name, c.budget
	),
	budget_ranges as (
	    select 
	        campaign_id,
	        campaign_name,
	        budget,
	        total_revenue,
	        case 
	            when budget between 10000 and 20000 then '10000-20000'
	            when budget between 20001 and 30000 then '20001-30000'
	            when budget between 30001 and 40000 then '30001-40000'
	            when budget between 40001 and 50000 then '40001-50000'
	            else '50001+'
	        end as budget_range
	    from 
	        campaign_revenue
	)
	select 
		campaign_name, total_revenue, budget_range
	from 
	    budget_ranges
	order by 
	    budget_range;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 12> Partition the sales data to compare the performance of different regions and identify any anomalies.

	with inputdata as(
	select  c.region,
			sum(o.total_amount) as total_sales,
			round(stddev(o.total_amount),2) as std,
			round(avg(o.total_amount),2) as avg
	from tbl_campaign c
	inner join tbl_order o
	on c.campaign_id=o.campaign_id
	group by c.region
	),
	Anomalies as (
		select c.region,total_sales,sm.avg ,sm.std,
		(case 
			when o.total_amount > (sm.avg + 1*sm.std) then 'High Anomaly'
			when o.total_amount < (sm.avg - 1*sm.std) then 'Low Anomaly'
			else 'Normal'
		end) as anomaly_status
		from tbl_order o
		inner join tbl_campaign c 
		on o.campaign_id = c.campaign_id
		inner join
		inputdata sm on sm.region = c.region	
	)
	select distinct * from Anomalies;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 13> Analyse the impact of product categories on campaign success.

	select c.campaign_id,c.campaign_name,p.category, sum(o.total_amount) as total_revenue,count(o.order_id) as total_orders
	from tbl_product p
	inner join tbl_order_item oi 
	on p.product_id = oi.product_id
	inner join tbl_order o 
	on oi.order_id = o.order_id
	inner join tbl_campaign c on o.campaign_id = c.campaign_id
	group by p.category,c.campaign_id,c.campaign_name;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 14> Compute the moving average of sales per region and analyze trends.

	select c.region,o.total_amount,
	avg(o.total_amount) over(partition by c.region order by o.total_amount rows between unbounded preceding and current row)
	from tbl_campaign c
	inner join tbl_order o
	on c.campaign_id=o.campaign_id;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 15> Evaluate the effectiveness of campaigns by comparing the pre-campaign and post-campaign average sales.

	with sales_data as (
	    select 
	        c.campaign_id,
	        c.campaign_name,
	        case 
	            when o.order_date < c.start_date then 'Pre Campaign'
	            when o.order_date > c.end_date then 'Post Campaign'
	        end as duration,
	        o.total_amount
	    from 
	        tbl_campaign c
	    inner join 
	        tbl_order o on c.campaign_id = o.campaign_id
	    where 
	        o.order_date < c.start_date or o.order_date > c.end_date
	),
	average_sales as (
	    select 
	        campaign_id,
	        campaign_name,
	        avg(case when duration = 'Pre Campaign' then total_amount end) as avg_pre_sales,
	        avg(case when duration = 'Post Campaign' then total_amount end) as avg_post_sales
	    from 
	        sales_data
	    group by 
	        campaign_id, campaign_name
	)
	select 
	    campaign_id,
	    campaign_name,
	    coalesce(avg_pre_sales, 0) as avg_pre_sales,
	    coalesce(avg_post_sales, 0) as avg_post_sales,  
	    (coalesce(avg_post_sales, 0) - coalesce(avg_pre_sales, 0)) as sales_difference,
	    case 
	        when coalesce(avg_pre_sales, 0) = 0 then null  
	        else (coalesce(avg_post_sales, 0) - coalesce(avg_pre_sales, 0)) / coalesce(avg_pre_sales, 0) * 100 
	    end as effectiveness_percentage
	from 
	    average_sales

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

