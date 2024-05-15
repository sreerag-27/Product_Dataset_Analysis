# Product Dataset Analysis Project
-- --------------------------------------------------------------------------------------------------------------------------------------------------
create database product_dataset_analysis;
use product_dataset_analysis;

show global variables like 'local_infile';
set global local_infile='on';

select * from customer;
-- -----------------------------------------------------------------------------------------------------------------------------------------------
# Method 1 To Insert data

create table customer(
customer_id int,
first_name text,
last_name text,
adress text,
city text,
state text, zip int,email text, phone text);

load data local infile 'E:/Project for Resume/My SQL & PowerPoint/Product Dataset Analysis/Product Dataset/Customer.csv'  into table customer
fields terminated by ','
lines terminated by '\n'
ignore 1 lines;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
# Method 2 is by Table Data Import Wizard

-- ---------------------------------------------------------------------------------------------------------------------------------------------
# Data cleaning of table `Customer`
select 
	sum(case when coalesce(customer_id,first_name,last_name,address,city,state,zip,email,phone) is null then 1 
    else 0
    end)  as null_values_in_columns
from customer;

select customer_id, count(*) as duplicates from customer group by customer_id having count(*) > 1;
select * from customer;

select email,count(*) from customer group by email having count(*) > 1;
select phone from customer order by phone asc; -- there are values with minus sign

select trim(leading '-' from phone) from customer order by phone asc;

update customer
set phone = trim(leading '-' from phone);
select distinct(phone) from customer  order by phone asc;

	# Making State column which consist of state name in short form into full name
create table full_name_city (short_form varchar(10), full_name varchar(200));
select * from full_name_city;

load data local infile 'E:/Project for Resume/My SQL & PowerPoint/Product Dataset Analysis/Product Dataset/sf to city.csv' into table full_name_city
fields terminated by  ','
lines terminated by '\n'
ignore 1 lines;

select * from customer;

select f.full_name from customer c
left join full_name_city f
on f.short_form = c.state;

alter table customer add column state_2 varchar(200);
update customer set state_2 = (select f.full_name from customer_2 c
left join full_name_city f
on f.short_form = c.state);

select * from customer;
select * from full_name_city;

select c.state, f.full_name from customer c
left join full_name_city f
on c.state = f.short_form;

update customer c
join full_name_city f
on c.state = f.short_form
set c.state_2 = f.full_name;

select * from customer ;
alter table customer modify state_2 varchar(200) after state;
alter table customer drop column state;
alter table customer rename column state_2 to state;

select length(state) from customer;
select length(trim(state)) from customer;
update customer set state = trim(state);
update customer set state = replace(state,'\n','');
#'Colorado
# '
select length(replace(state,"'",'')) from customer;
  -- ---------------------------------------------------------------------------------------------------------------------------------------------
# Data cleaning of table `netsale`
select * from netsale;
  -- Searching for null values
select sum(case when coalesce(netsale_id,sale_time,customer_id,shipping,tax,total) is null then 1 else 0 end) as duplicates
from netsale;

	# Searching for blank values
select sum(case when coalesce(netsale_id,sale_time,customer_id,shipping,tax,total) ='' then 1 else 0 end) as duplicates
from netsale;

	# Changing sale_time format to date
select sale_time,str_to_date(sale_time,'%m/%d/%y') as date from netsale;
select * from netsale;
select sale_time, substring_index(sale_time,' ',1) as date from netsale;
select sale_time,substring_index(sale_time,' ',-2) as time from netsale;

alter table netsale add column `date` text;
alter table netsale add column `time` text;
update netsale set `date` =  substring_index(sale_time,' ',1);
update netsale set `time` = substring_index(sale_time,' ',-2);
select * from netsale;

select date, str_to_date(date,'%m/%d/%Y') from netsale;
alter table netsale add column date_2 date;
update netsale set date_2 =str_to_date(date,'%m/%d/%Y') ;
alter table netsale drop column `date`;
alter table netsale rename column date_2 to date;
select time,time(time) from netsale;
alter table netsale drop column sale_time;
select * from netsale;
alter table netsale drop column sale_time;
alter table netsale modify time text after date ;

select * from netsale;
alter table netsale rename column total to total_price;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
# Data cleaning of table `netsale_line`

select * from netsale_line;
select sum(case when coalesce(netsale_id,product_id,price,qty,size) is null then 1 else 0 end)
from netsale_line ;
select sum(case 
when netsale_id = '' then 1
when product_id = '' then 1
when price = '' then 1 
when qty = '' then 1 
when size = '' then 1 
else 0 
end) as count
from netsale_line ;

select size , length(size) from netsale_line;

select * from netsale_line where netsale_id is null or netsale_id = '' ;
select * from netsale_line where product_id is null or product_id = '' ;
select * from netsale_line where  price is null or product_id = '' ;
select * from netsale_line where qty is null or qty =''  ;
select * from netsale_line where size is null or size = ''; # 18223 null values because size 

	# Creating total price column ( total_price = price * qty)
alter table netsale_line add column total_price double;
#update netsale_line set total_price = round(price * qty,2);
select * from netsale_line;

-- ---------------------------------------------------------------------------------------------------------------------------------------------
# Data cleaning of table `Product`
select * from product;
select product_id from product where product_id is null or product_id = '';
select name from product where name is null or name = '';
select in_store from product where in_store is null or in_store= '';
select embellishment_type from product where embellishment_type is null or embellishment_type = ''; # 226 blanks
select fabric from product where fabric is null or fabric = ''; # 670 blanks
select fit from product where fit is null or fit = '';# 1180 blanks
select graphic_type from product where graphic_type is null or graphic_type = '';# 237 blanks
select origin from product where origin is null or origin = ''; # 157 blanks
select season_code	 from product where season_code is null or season_code = '';
select vendor from product where vendor is null or vendor = ''; # 1 blank
select color_code from product where color_code is null or color_code = ''; # 642 blanks
select single_sku_catalog_entry from product where single_sku_catalog_entry  is null or single_sku_catalog_entry  =''; # 769 blanks
select  catalog from product where catalog is null or catalog = '';
select category from product where category is null or category = '';
select subcategory from product where subcategory is null or subcategory = ''; # 525 blanks
select current_price from product where current_price is null or current_price = '';

 # Cleaning Name Column
select name, replace(name,'^','') from product;
select name,replace(name,'^un^','') from product;
select name,replace(name,'^color^','') from product;
select name,replace(name,'^ma^','') from product;

update product 
set name =  replace(name,'^un^','') ; 
update product 
set name = replace(name,'^color^','');
update product 
set name = replace(name,'^ma^','') ;
update product 
set name = replace(name,'^','');
update product 
set name = replace(name,'"','');
update product 
set name = trim(name);

select color_code,replace(color_code,'^color^','') from product;
#update  product set color_code = replace(color_code,'^color^','');
select * from product;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
# Data cleaning of table `size`
select * from size;
select *, count(size)as cnts from size group by product_id having cnts > 1;
-- ---------------------------------------------------------------------------------------------------------------------------------------------
# Data cleaning of table `vendor`
select * from vendor;

	# Changing state name to full name
select v.state, f.full_name from vendor v
left join full_name_city f
on f.short_form = v.state;

alter table vendor add column state_2 varchar(200);
select * from vendor;

update vendor v
join full_name_city f
on f.short_form = v.state
set v.state_2 = f.full_name;

alter table vendor modify state_2 varchar(200) after city;
alter table vendor drop column state ;
alter table vendor rename column state_2 to state;


select  state_2, state from vendor where state_2 is null;
update vendor 
set state_2 = 'California'
where state = 'CA ';

-- ---------------------------------------------------------------------------------------------------------------------------------------------
# Data cleaning of table `Wholesale`
select * from wholesale;
	# Removing time from date
select date,substring(date,1,11) from wholesale;

update wholesale 
set date = substring(date,1,11) ;

-- ---------------------------------------------------------------------------------------------------------------------------------------------
# Data cleaning of table `Wholesale_line`
select * from wholesale_line;
	# Adding Total_price
select price, quantity , round(price*quantity,2) from wholesale_line;

alter table wholesale_line add column total_price double;
update wholesale_line
set total_price =  round(price*quantity,2);

select * from wholesale_line;

-- ---------------------------------------------------------------------------------------------------------------------------------------------
# Changing attributes name
select * from product;
alter table product rename column vendor to vendor_name;
select * from vendor;
alter table vendor rename column name to vendor_name;

-- ---------------------------------------------------------------------------------------------------------------------------------------------
select * from customer;
select * from netsale;
select * from netsale_line;
select * from product;
select * from size;
select * from vendor;
select * from wholesale;
select * from wholesale_line;

-- -----------------------------------------------------------------------------------------------------------------------------------------------

# Making ER Diagram using reverse engineer

-- -----------------------------------------------------------------------------------------------------------------------------------------------
			# 10 Easy Level Questions
-- ---------------------------------------------------------------------------------------------------------------------------------------------------

# Q1. How many products are currently in store?
select * from product;
select distinct(name) from product;
select count(distinct name) as total_products from product; # 1099 Products

-- -----------------------------------------------------------------------------------------------------------------------------------------------
# Q2. What are the distinct embellishment types available in the product table?

select * from product;
select distinct embellishment_type from product where embellishment_type != ''; # 11 unique embellishment type

-- -----------------------------------------------------------------------------------------------------------------------------------------------
# Q3. How many different vendors are there?

select distinct(vendor_name) from product;
select count(distinct(vendor_name)) as diferent_types_of_vendors from product; # 98 Different Vendor

-- -----------------------------------------------------------------------------------------------------------------------------------------------
# Q4. What are the top 5 most common fabric types?

select * from product;
select fabric, count(*) as total_count_of_fabric from product
where fabric is not null 
and fabric != '' 
group by  fabric 
order by count(*) desc limit 5;

-- -----------------------------------------------------------------------------------------------------------------------------------------------
# Q5. How many unique sizes are available?
select  s.size ,p.catalog,count(p.catalog) as count_of_catalog from product p
inner join size s
on s.product_id= p.product_id
group by s.size
order by count(p.catalog) desc ; # total 79 different sizes are avaiable 


select distinct t.catalog from (select  s.size ,p.catalog,count(p.catalog) as count_of_catalog from product p
inner join size s
on s.product_id= p.product_id
group by s.size
order by count(p.catalog) desc) as t; #  Only 2 different catgories are present
-- -----------------------------------------------------------------------------------------------------------------------------------------------
# Q6. What is the total quantity sold for a specific product?
select * from product ;
select qty from netsale_line;
select * from wholesale_line;

select p.catalog, p.category, format( sum(n.qty) + sum(w.quantity),0 ) as `Total Quantity Sold` from product p
left join netsale_line n
on p.product_id = n.product_id 
left join wholesale_line w
on p.product_id = w.product_id
group by catalog , category 
order by ( sum(n.qty) + sum(w.quantity) ) desc;

select p.catalog, format( sum(n.qty) + sum(w.quantity),0 ) as `Total Quantity Sold` from product p
left join netsale_line n
on p.product_id = n.product_id 
left join wholesale_line w
on p.product_id = w.product_id
group by catalog  
order by ( sum(n.qty) + sum(w.quantity) ) desc;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
# Q7. How many customers are there in the customer table?
select * from customer;

select state ,count(*) Total_Customers from customer group by state order  by count(*) desc;
select state ,count(*) Total_Customers from customer group by state order  by count(*) desc limit 20;
select state ,count(*) Total_Customers from customer group by state order  by count(*) desc limit 11 offset 40;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------

# Q8. What are the unique colors available in the product table?
select  * from product;
select distinct(color_code) from product  where color_code is not null and color_code !='' ; # 162  different color and color cobinations are present
select count(distinct(color_code)) as Unique_Color_Counts from product  
where color_code is not null and color_code !='' ; # 162  different color and color cobinations are present

-- ---------------------------------------------------------------------------------------------------------------------------------------------------

# Q9.How many unique categories are there in the product table?
select * from product;
select distinct(category) from product; # 18 different Category 

-- ---------------------------------------------------------------------------------------------------------------------------------------------------
# Q10. What is the average current price of products?
select * from product;

select distinct(subcategory) from product;
select subcategory, round(avg(current_price),2) as `Average Price` 
from product
where subcategory != ''
 group by subcategory; # Average price of product followed by each sub_category

select distinct(subcategory) from product;
select subcategory, round(avg(current_price),2) as `Average Price` 
from product
where subcategory != ''
 group by subcategory limit 10 offset 20;

-- -----------------------------------------------------------------------------------------------------------------------------------
			# 10 Medium Level Questions
-- -----------------------------------------------------------------------------------------------------------------------------------
       
# 11. Which vendor has the highest total sales amount?
select * from product;
select * from netsale_line;

select p.product_id,n.product_id, p.vendor_name from product p
left join netsale_line n
on p.product_id = n.product_id
group by vendor_name; # Cross checking if all the product_id of product is matching with product_id of netsale_line

	# Total sales amount in Product Category
select vendor_name, concat('$ ',format(sum(current_price),2)) as `Highest_total_sales_in_Product`
from product 
where vendor_name != ''
group by vendor_name 
order by sum(current_price) desc limit 10;

	# Total sales amount in netsale_line Category
select vendor_name,concat('$ ',format(sum(n.total_price),2)) as total_sales_amt_in_netsale from product p
left join netsale_line n
on p.product_id = n.product_id
where vendor_name != ''
group by vendor_name
order by (sum(n.total_price))desc limit 10; 

	# Total sales amount in wholesale_line Category
select vendor_name,concat('$ ',format(sum(w.total_price),2)) as total_sales_amt_in_Wholesale_line from product p
left join wholesale_line w
on p.product_id = w.product_id
where vendor_name != ''
group by vendor_name
order by sum(w.total_price) desc limit 10; 

-- -------------------------------------------------------------------------------------------------------------------------------------------------

# Q12. What is the average price of products for each embellishment type?
select * from product;

select embellishment_type,round(avg(current_price),2) Average_Price_for_embellishment_type from product 
where embellishment_type != ''
group by embellishment_type order by round(avg(current_price),2) desc; # 11 type of embellishment type with average price;

-- ----------------------------------------------------------------------------------------------------------------------------------

# Q 13. What is the total revenue generated from sales in a specific season?
select * from product;

	# Total Revenue generate by sales only of Product 
select season_code,concat('$ ',round(sum(current_price),2)) as Total_revnue_product 
from product 
group by season_code 
order by sum(current_price) desc;

	# Total Revenue generated by netsale_line
select season_code, concat('$ ',round(sum(total_price),2)) as total_revenue_by_netsale_line from product p
right join netsale_line n
on p.product_id = n.product_id
group by season_code
order by round(sum(total_price),2) desc;

	# Total Revenue generated by wholesale_line
select season_code, concat('$ ',round(sum(total_price),2)) as total_revenue_by_wholesale_line from product p
right join wholesale_line w
on p.product_id = w.product_id
group by season_code
order by round(sum(total_price),2) desc;

-- ----------------------------------------------------------------------------------------------------------------------------------

# Q 14. How many products have been sold in each category?

select * from product;
select * from netsale_line;
select * from wholesale_line;

	 # Netsale 
select p.category,format(sum(n.qty),0) as total_quantity  from product p
right join netsale_line n
on n.product_id = p.product_id
group by p.category
order by sum(n.qty) desc;

	# Wholesale 
select p.category,format(sum(w.quantity),0) as total_quantity  from product p
right join wholesale_line w
on w.product_id = p.product_id
group by p.category
order by sum(w.quantity) desc;

	# Netsale + Wholesale
select p.category,format((sum(w.quantity) + sum(n.qty)),0) as total_quantity  from product p
right join netsale_line n
on n.product_id = p.product_id
right join wholesale_line w
on w.product_id = p.product_id
where p.category != ''
group by p.category
order by (sum(w.quantity) + sum(n.qty) ) desc;

-- ----------------------------------------------------------------------------------------------------------------------------------

# Q. 15 What is the average total price of sales in each city?
select * from netsale;
select * from customer;

select c.state,c.city, concat('$ ',round(avg(n.total),2)) as total_average_price_of_sales from netsale n
right join customer c
on n.customer_id = c.customer_id 
group by c.city
order by avg(n.total) desc;


-- ----------------------------------------------------------------------------------------------------------------------------------

# Q 16. What is the most common fit type for each category?
select * from product;
select catalog, category, subcategory, fit from product;

select category, fit, count(fit) as counts from product 
where fit != ''
group by category, fit
order by count(fit) desc;

-- ----------------------------------------------------------------------------------------------------------------------------------
# Q.17 Which product has the highest total sales quantity?

select * from product;
select * from netsale_line;

select p.catalog , sum(nl.qty) from  product as p
right join netsale_line as nl
on p.product_id = nl.product_id
group by catalog
order by sum(qty) desc;

select p.catalog,sum(nl.qty) from netsale_line nl
left join  product p
using (product_id)
group by catalog
order by sum(qty) desc;

-- ----------------------------------------------------------------------------------------------------------------------------------
# Q 18. What is the total revenue generated from wholesale orders?

select * from wholesale_line;
select concat('Total Revenue Generated by Wholesale - $ ',format(round(sum(total_price),2),2)) as Total_Revenue from wholesale_line;

-- ----------------------------------------------------------------------------------------------------------------------------------
# Q 19. What is the average price of products for each vendor?

select * from product;
select * from netsale_line;

select p.vendor_name, concat('$ ',format(round(avg(nl.total_price),2),2)) as average_price_of_product from product p
right join netsale_line nl
on p.product_id = nl.product_id
group by vendor_name
order by avg(nl.total_price) desc;


-- ----------------------------------------------------------------------------------------------------------------------------------
# Q 20. How many unique customers have made purchases in a specific city?

select * from customer;

select state, count(distinct customer_id) as total_unique_customers from customer
group by state
order by  count(distinct customer_id) desc ;


-- -----------------------------------------------------------------------------------------------------------------------------------
			# 10 Hard Level Questions
-- -----------------------------------------------------------------------------------------------------------------------------------
# Q 21. Can you identify any patterns in sales based on the time of year?

select * from netsale;

select date_format(date,'%Y') as `year`, date_format(date, '%M') as `month`, 
concat('$ ', format(round(sum(total_price),2),2)) as `Total_sales_per_month` 
from netsale
group by date_format(date,'%Y'),date_format(date, '%M') ;

-- -----------------------------------------------------------------------------------------------------------------------------------
# Q 22. Is there a correlation between product price and total sales quantity?

select * from netsale_line;
# price = x
# qty = y

# select  sum(price- avg(price)* (qty - avg(qty)  ) / 
# sqrt( sum(power(price - avg(price),2)))* sqrt(sum(power(qty - avg(qty),2))) as correlation from netsale_line;

SELECT 
    SUM((p.current_price - avg_price) * (n.qty - avg_qty)) /
    (COUNT(*) * STDDEV(p.current_price) * STDDEV(n.qty)) 
    AS correlation_coefficient
FROM 
    product p
JOIN 
    netsale_line n ON p.product_id = n.product_id
CROSS JOIN (
    SELECT 
        AVG(current_price) AS avg_price,
        AVG(qty) AS avg_qty
    FROM 
        product
    JOIN 
        netsale_line ON product.product_id = netsale_line.product_id
) AS avg_values;
-- -----------------------------------------------------------------------------------------------------------------------------------
# Q 23. Can you predict future sales based on historical data?
-- -----------------------------------------------------------------------------------------------------------------------------------
# Q 24. Are there any significant geographical trends in sales?
select * from netsale_line;
select * from netsale;
select * from customer;


select  c.state, c.city, sum(nl.qty) as total_quantity from netsale_line nl
right join netsale n
using (netsale_id)
right join customer c
using (customer_id)
group by c.state
order by sum(nl.qty) desc;
-- -----------------------------------------------------------------------------------------------------------------------------------
# Q 25. Can you identify any outliers in the sales data?

select * from netsale_line;

	# Using z-score to identify Outliers
	# z-score =  (value - mean)/ std. The Threshold limit for z-score is, if the value is greater than 3 or lower than -3 then there is outlier

    select total_price from netsale_line;
    select avg(total_price) from netsale_line;
    select stddev(total_price) from netsale_line;

    select *,( total_price - avg(total_price) over() )/ stddev(total_price) over() as z_score from netsale_line;
    
    with outlier as (
    select *,( total_price - avg(total_price) over() )/ stddev(total_price) over() as z_score from netsale_line
) 
    select * from outlier where z_score >= 4; # There are 292 outliers
    select * from outlier where z_score < -3;
-- ------------------------------------------------------------------------------------------------------------------------
# Q 26. Is there a relationship between product attributes (e.g., fabric, embellishment type) and sales performance?
select * from product;
select * from netsale_line;
select * from netsale;

select p.embellishment_type, p.fabric, sum(nl.qty) as Quantity_sold from product p
right join netsale_line nl
using (product_id)
right join netsale n
using (netsale_id)
where embellishment_type != '' and fabric != ''
group by embellishment_type,fabric	
order by quantity_sold desc;

-- -----------------------------------------------------------------------------------------------------------------------------------
# Q 27. Can you identify any seasonality effects in sales data?
select * from product;
select * from netsale_line;
select * from netsale;
select * from customer;

select distinct(season_code) from product;

select year(date) as year, date_format(date,'%M')  as `Month`, p.season_code, concat('$ ',format(sum(nl.total_price),2)) as Total_Sales from product p
right join netsale_line nl
using (product_id)
right join netsale n
using (netsale_id)
group by year(date), month(date), p.season_code 
order by month(date) asc, Total_sales;

select year(date) as year, date_format(date,'%M')  as `Month`, p.season_code, concat('$ ',format(sum(nl.total_price),2)) as Total_Sales from product p
right join netsale_line nl
using (product_id)
right join netsale n
using (netsale_id)
where p.season_code = 'Basic Non-Seasonal'
group by year(date), month(date), p.season_code 
order by month(date) asc, Total_sales;

-- -----------------------------------------------------------------------------------------------------------------------------------
# Q 28. What is the average number of products purchased per wholesale order?

select * from wholesale_line;

select avg(cnt_productid) from 
(select count(product_id) as cnt_productid from wholesale_line group by order_id) as counts; # 4.2581

	# CTE ( Common table ecpression)
with count_product_id as (select count(product_id) as cnt_product_id from wholesale_line group by order_id)
select avg( cnt_product_id) from count_product_id;  # 4.2581

-- -----------------------------------------------------------------------------------------------------------------------------------
# Q 29. Can you segment customers based on their purchasing behavior?

select * from product;
select * from netsale_line;
select * from netsale;
select * from customer;

select customer_id, concat('$ ',format(sum(nl.total_price),2)) as total_amount_spend,
(case when sum(nl.total_price) >= 500 then 'High_spender'
when sum(nl.total_price) >= 250 then 'Medium_spender'
else 'Low_spender'
end) as customer_segment
from netsale_line nl
right join netsale n
using (netsale_id)
right join customer c
using  (customer_id)
group by customer_id
order by sum(nl.total_price) desc;

# CTE Common Table Expression
with customer_segment_table as (
select customer_id, concat('$ ',format(sum(nl.total_price),2)) as total_amount_spend,
(case when sum(nl.total_price) >= 500 then 'High_spender'
when sum(nl.total_price) >= 250 then 'Medium_spender'
else 'Low_spender'
end) as customer_segment
from netsale_line nl
right join netsale n
using (netsale_id)
right join customer c
using  (customer_id)
group by customer_id
order by sum(nl.total_price) desc
)

select customer_segment,count(customer_segment) as customer_segment_count,
concat(round(((count(customer_segment)/ 7042 )*100),2),'%') as `percentage%` 
from customer_segment_table 
group by customer_segment 
order by count(customer_segment) desc;

select (4453+1669+920) as addition;
-- -----------------------------------------------------------------------------------------------------------------------------------
# Q 30. Is there a relationship between customer demographics and the products they purchase?

select * from netsale_line;
select * from netsale;
select * from customer;

select state, count(product_id) as product_count from netsale_line nl
right join netsale n 
using (netsale_id)
right join customer c
using (customer_id)
group by state
order by product_count desc;

with cust_info as 
(select Customer_id, first_name, last_name, email, phone, state, count(product_id) as total_products_bought from netsale_line nl
right join netsale n
using (netsale_id)
right join customer c 
using (customer_id)
group by state, customer_id
order by  count(product_id) desc)

select * from cust_info where total_products_bought > 10 ;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------
# The End
