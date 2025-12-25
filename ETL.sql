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

