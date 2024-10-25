-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- *****************************************************************************************
-- -----------------------------------SQL ASSIGNMENT----------------------------------------
-- *****************************************************************************************
-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
create table tbl_campaign(
	campaign_id int primary key,
	campaign_name varchar(255),
	start_date date,
	end_date date,
	budget decimal(10,2),
	region varchar(255)
);
-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
create table tbl_customer(
	customer_id int primary key,
	name varchar(255),
	email varchar(255),
	join_date date,
	total_spent decimal(10,2)
);
-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
create table tbl_order(
	order_id int primary key,
	customer_id int references tbl_customer(customer_id),
	order_date date,
	campaign_id int references tbl_campaign(campaign_id),
	total_amount decimal(10,2)
);
-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
create table tbl_order_item(
order_item_id int primary key,
order_id int references tbl_order(order_id),
product_id int,
quantity int,
price decimal(10,2)
);
-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
create table tbl_product(
	product_id int primary key,
	product_name varchar(255),
	category varchar(255),
	price decimal
);
-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
create table tbl_inventory(
	inventory_id int primary key,
	product_id int references tbl_product(product_id),
	stock_quantity int
);
