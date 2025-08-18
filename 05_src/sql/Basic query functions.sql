--SELECT --

-- select everything from the customer TABLE
select * from customer;
-- use SQL as a calculator
select 1+1,10*5,pi();
-- add a static value 
select 2025 as this_year,'August' as this_month, customer_id
from customer;
-- add an order by and row limit 
select *
from customer
order by customer_first_name asc
limit 10;

-- WHERE --

select * from customer where customer_id = 1 
or customer_id = 2;
-- IN
select * from customer where customer_id in (3,4,5) 
or customer_postal_code in ('M4H','M1L');
-- like
select * from product where product_name like '%pepper%';
select * from customer where customer_last_name like 'a%';
-- NULLS and blanks
select * from product where product_size is NULL;
select * from product where product_size = '';
-- between another option
 select * from customer where customer_id between 1 and 20;
 
 
 -- CASE --
 
 select *
,case 
	when vendor_type = 'Fresh Focused' then 'Wednesday'
	when vendor_type = 'Prepared Foods' then 'Thursday'
	else 'Saturday'
	End as day_of_specialty
-- pie day, otherwise nothing
,case 
	when vendor_name = "Annie's Pie's"
	then 'annie is the best'
	end as annie_is_the_king
,case
	when vendor_name like '%pie%'
	then 'Wednesday'
	else 'Friday'
	end as pie_day
from vendor;


-- DISTINCT --

select customer_id from customer_purchases; -- 54 rows
select distinct customer_id from customer_purchases; -- 26 distict customers

select market_day from market_date_info;
select distinct market_day from market_date_info; -- 2 disitnct market days

select  vendor_id from customer_purchases; 
select distinct vendor_id from customer_purchases; -- 3 distinct vendor_id

select distinct vendor_id,product_id from customer_purchases;

select distinct vendor_id,product_id,customer_id from customer_purchases 
order by customer_id asc, product_id desc;

-- JOIN --
select
product_name
,vendor_id
,market_date
,customer_id
,customer_purchases.product_id
from customer_purchases
inner join product on customer_purchases.product_id = product.product_id;

select
product_name
,a.vendor_id
,a.market_date
,a.customer_id
,b.product_id
from customer_purchases a
inner join product b on a.product_id = a.product_id;

select distinct 
cp.customer_id
,c.customer_first_name
,c.customer_last_name
,cp.vendor_id
,v.vendor_id
,cp.product_id
,p.product_name
from customer_purchases cp
inner join customer c on c.customer_id = cp.customer_id
inner join vendor v on v.vendor_id = cp.vendor_id
inner join product p on p.product_id = cp.product_id; 


-- COUNT --

select count(product_id) as num_of_prods from product;

select distinct
product_size 
,product_qty_type
,count(product_id) as num_of_prods
from product
group by product_size,product_qty_type;


-- SUM/AVG --

select
cp.market_date
,cp.customer_id
,c.customer_first_name
,c.customer_last_name
,sum(cp.quantity*cp.cost_to_customer_per_qty) as total_cost
from customer_purchases cp
inner join customer c on c.customer_id = cp.customer_id
group by cp.market_date,cp.customer_id,c.customer_first_name,c.customer_last_name;

select
cp.market_date
,c.customer_first_name
,c.customer_last_name
,avg(cp.quantity*cp.cost_to_customer_per_qty) as avg_cost
,round(avg(cp.quantity*cp.cost_to_customer_per_qty),2) as rounded_avg_cost
from customer_purchases cp
inner join customer c on c.customer_id = cp.customer_id
group by c.customer_first_name,c.customer_last_name;

-- MAX/MIN --

select
p.product_name
,p.product_qty_type
,max(vi.original_price) most_expensive
,min(vi.original_price) least_expensive
from product p
inner join vendor_inventory vi on vi.product_id = p.product_id
group by p.product_name,p.product_qty_type
order by p.product_qty_type, vi.original_price;

-- HAVING --

-- how much did a customer spend on each day
select
cp.market_date
,cp.customer_id
,c.customer_first_name
,c.customer_last_name
,sum(cp.quantity*cp.cost_to_customer_per_qty) as total_cost
from customer_purchases cp
inner join customer c on c.customer_id = cp.customer_id
where cp.customer_id between 1 and 5
group by cp.market_date,cp.customer_id,c.customer_first_name,c.customer_last_name
Having total_cost >50;

-- how many products were bought
select
count (product_id) as number_prod,
product_id
from customer_purchases
where product_id <= 8 
group by product_id
having count(product_id) between 300 and 500;


-- SUBQUERIES : JOIN --

select
product_name
,max(quantity_purchased)
from product p
inner join (
	select product_id
	,sum(quantity) as quantity_purchased
	from customer_purchases
	group by product_id
) x on p.product_id = x.product_id;


-- -- SUBQUERIES : WHERE --

-- what dates was it raining
select 
market_date 
,customer_id
,vendor_id
,sum(quantity*cost_to_customer_per_qty) as total_cost
from customer_purchases
where market_date in(
	select
	market_date
	from market_date_info
	where market_rain_flag = 1
	)
group by market_date, customer_id, vendor_id;

-- TEMP TABLES --


drop table temp.new_vendor_inventory
create table temp.new_vendor_inventory as
select *
,original_price*5 as inflation
from vendor_inventory;

-- CTE -- 

-- calculate sales per vendor per day

