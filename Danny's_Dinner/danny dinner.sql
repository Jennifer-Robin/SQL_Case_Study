create database danny;
use danny;
#What is the total amount each customer spent at the restaurant?
select customer_id,sum(price) as total_spent
from sales inner join menu using(product_id)
group by customer_id;
# How many days has each customer visited the restaurant?
Select customer_id,count(distinct order_date)from sales group by customer_id;
 #What was the first item from the menu purchased by each customer?
 select customer_id,order_date,product_name from(
 select *,row_number()
 over(partition by customer_id order by order_date asc) as rn
 from sales s inner join menu m using(product_id)) as t
 where rn = 1;
 # What is the most purchased item on the menu and how many times was it purchased by all customers?
 select * from(
 select product_name,count(*) as No_of_Times,rank() over(order by count(product_name)desc)as rn
 from sales s inner join menu m using (product_id) group by product_name) as t where rn = 1;
 
 # Which item was the most popular for each customer?
 select * from(
 select customer_id,product_name,count(*) as No_of_orders,
 rank()over(partition by customer_id order by count(*) desc) rnk
 from sales s inner join menu m using(product_id)
 group by customer_id,product_name) as t where rnk = 1;
 # Which item was purchased first by the customer after they became a member?
 with first_purchased as(
 select s.customer_id,order_date,product_name,
 row_number() over(partition by s.customer_id order by order_date asc)as rn 
 from sales s inner join members mb on s.customer_id = mb.customer_id and
 s.order_date>mb.join_date inner join menu m using(product_id))
 select * from first_purchased where rn = 1;
 #Which item was purchased just before the customer became a member?
 
 with first_purchased_before as(
 select s.customer_id,order_date,product_name,
 row_number() over(partition by s.customer_id order by order_date asc)as rn 
 from sales s inner join members mb on s.customer_id = mb.customer_id and
 s.order_date<mb.join_date inner join menu m using(product_id))
 select * from first_purchased_before;
 # What is the total items and amount spent for each member before they became a member?
 select s.customer_id,count(*) as No_of_times,sum(price) from sales s inner join members mb  
 on s.customer_id = mb.customer_id and s.order_date<mb.join_date inner join menu m using(product_id) group by s.customer_id order by s.customer_id;
 # If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select customer_id,sum(case when product_name ='sushi' then price * 20 else price * 10 end) 
as Total_points from sales s inner join menu m using(product_id)
group by customer_id;
 # In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?*/
select s.customer_id,sum(case when order_date between mb.join_date and date_add(join_date,interval 7 day)
then price * 20 when product_name= 'sushi' then price * 20 else price * 10 end ) as Total_Points
from sales s inner join members mb using(customer_id) inner join menu m using(product_id)
where order_date <= '2021-01-31'
group by s.customer_id order by customer_id;