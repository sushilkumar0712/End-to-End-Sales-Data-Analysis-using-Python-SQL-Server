--drop table 
CREATE TABLE df_orders (
    [order_id] INT PRIMARY KEY,
    [order_date] DATE,
    [ship_mode] VARCHAR(20),
    [segment] VARCHAR(20),
    [country] VARCHAR(20),
    [city] VARCHAR(20),
    [state] VARCHAR(20),
    [postal_code] VARCHAR(20),
    [region] VARCHAR(20),
    [category] VARCHAR(20),
    [sub_category] VARCHAR(20),
    [product_id] VARCHAR(50),
    [quantity] INT,
    [discount] DECIMAL(7,2),
    [sale_price] DECIMAL(7,2),
    [profit] DECIMAL(7,2)
);

select * from df_orders

--find top 10 highest reveue generating products 

select top 10 product_id, sum(sale_price) as rev_gen
from df_orders
group by product_id
order by rev_gen desc

--find top 5 highest selling products in each region
select * from(
	select *,ROW_NUMBER() over(partition by region order by rev_gen desc) as rn from(
		select region, product_id, sum(sale_price) as rev_gen 
		from df_orders
		group by region, product_id)A) B
	where rn<=5

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

select order_month,
	sum(case when order_year=2022 then sales else 0 end) as sales_2022,
	sum(case when order_year=2023 then sales else 0 end) as sales_2023
from(
	select  year(order_date) as order_year ,MONTH(order_date)as order_month,sum(sale_price) as sales
	from df_orders
	group by year(order_date),MONTH(order_date))A
group by order_month


--for each category which month had highest sales 
select * from(
select *, ROW_NUMBER() over(PARTITION BY category ORDER BY sales DESC) AS rn
from(
	select FORMAT(order_date, 'yyyyMM') AS order_year_month,category,SUM(sale_price) as sales
	from df_orders
	group by FORMAT(order_date, 'yyyyMM'),category)A) B
where rn=1

--which sub category had highest growth by profit in 2023 compare to 2022

select top 1*, (sum_sales_2023-sum_sales_2022)*100/sum_sales_2022 as perc_growth from(
select sub_category, sum(case when order_year=2022 then sales else 0 end)as sum_sales_2022,
					 sum(case when order_year=2023 then sales else 0 end)as sum_sales_2023
from(
	select sub_category,YEAR(order_date) AS order_year,SUM(sale_price) AS sales
	from df_orders
	group by sub_category, YEAR(order_date))A
group by sub_category) B
order by (sum_sales_2023-sum_sales_2022)*100/sum_sales_2022 desc