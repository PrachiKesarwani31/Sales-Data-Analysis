create database if not exists sales_db;

use sales_db;

select * from sales;

#Handling duplicate values
select 
OrderID,
count(*)
from sales
group by 1
having count(*)>1;



create table if not exists product as
select 
row_number() over(order by Category, Sub_Category) as product_id,
Category,
Sub_Category
from (select distinct Category, Sub_Category from sales) s;

create table if not exists customer as 
select 
row_number() over(order by CustomerName) as customer_id,
CustomerName
from (select distinct CustomerName from sales) s;

create table if not exists location as
select 
row_number() over(order by State, City) as location_id,
State,
City
from (select distinct State, City from sales) s;

create table if not exists payment_mode as
select 
row_number() over(order by PaymentMode) as payment_mode_id,
PaymentMode
from (select distinct PaymentMode from sales) s;

create table if not exists date_dim (
date_id date primary key,
cal_year int,
cal_month int,
cal_month_name varchar(15),
fiscal_year int,
fiscal_month int,
fiscal_quarter varchar(5),
YM varchar(7)
);

/*create table if not exists numbers (
n int primary key
);*/

set session cte_max_recursion_depth=10000;

insert into date_dim(
date_id,
cal_year,
cal_month,
cal_month_name,
fiscal_year,
fiscal_month,
fiscal_quarter,
YM)
with recursive dates as(
select 
min(OrderDate) as dt
from sales
union all 
select 
date_add(dt, interval 1 day) 
from dates
where dt<(select max(Orderdate) from sales))
select
dt,
year(dt),
month(dt),
monthname(dt),
case 
when month(dt)>=4 then year(dt)
else year(dt)-1
end,
case
when month(dt)>=4 then month(dt)-3
else month(dt)+9
end,
case 
when month(dt) between 4 and 6 then 'Q1'
when month(dt) between 7 and 9 then 'Q2'
when month(dt) between 10 and 12 then 'Q3'
else 'Q4'
end,
date_format(dt,'%Y-%m')
from dates;


create table if not exists order_details(
order_id varchar(50),
amount decimal(10,2),
profit decimal(10,2),
quantity decimal(10,2),
product_id int,
paymentmode_id int,
order_date date,
customer_id int,
location_id int,
yearmonth date);

insert into order_details(
    order_id,
    amount,
    profit,
    quantity,
    product_id,
    paymentmode_id,
    order_date,
    customer_id,
    location_id,
    yearmonth
)
select 
s.OrderID,
s.Amount as amount,
s.Profit as profit, 
s.Quantity as quantity,
p.product_id,
pm.payment_mode_id,
s.OrderDate as order_date,
c.customer_id,
l.location_id,
s.YearMonth as yearmonth
from sales s
left join product p
on s.Category=p.Category and s.Sub_Category=p.Sub_category
left join payment_mode pm
on s.PaymentMode=pm.PaymentMode
left join customer c
on s.CustomerName=c.CustomerName
left join location l
on s.State=l.State and s.City=l.City;

select * from order_details;