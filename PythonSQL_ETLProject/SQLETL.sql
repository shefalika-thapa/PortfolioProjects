use shifdb;
select * from df_orders;

-- Find top 10 highest revenue generating products
select product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
LIMIT 10;

-- Find top 5 highest selling products in each region

with cte as(
select region, product_id, sum(sale_price) as sales
from df_orders
group by region, product_id)
select * from (
select *, row_number() over(partition by region order by sales desc) as rn
from cte) as A
where rn<=5;

-- Find month over month comparison for 2022 and 2023 sales 

with cte as (
select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales 
from df_orders
group by year(order_date), month(order_date))
select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;


-- For each category which month had the highest sale

with cte as(
select category, DATE_FORMAT(order_date, '%Y%m') as order_year_month, sum(sale_price) as sales
from df_orders
group by category, DATE_FORMAT(order_date, '%Y%m')
-- order by category, DATE_FORMAT(order_date, '%Y%m')
)
select * from (
select *,
row_number() over (partition by category order by sales desc) as rn
from cte) A
where rn=1;

-- Which sub category had the highest growth by profit in 2023 compared to 2022?
with cte as (
select sub_category, year(order_date) as order_year, sum(sale_price) as sales 
from df_orders
group by sub_category, year(order_date))
, cte2 as (
select sub_category,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category)

select *, (sales_2023-sales_2022) as growth_profit
from cte2
order by (sales_2023-sales_2022) desc
LIMIT 1;
