CREATE DATABASE pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  `runner_id` INT PRIMARY KEY,
  `registration_date` DATE
);

INSERT INTO runners (`runner_id`, `registration_date`)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  `order_id` INT,
  `customer_id` INT,
  `pizza_id` INT,
  `exclusions` VARCHAR(20),  -- Increased length
  `extras` VARCHAR(20),      -- Increased length
  `order_time` DATETIME
);

INSERT INTO customer_orders (`order_id`, `customer_id`, `pizza_id`, `exclusions`, `extras`, `order_time`)
VALUES
  (1, 101, 1, NULL, NULL, '2020-01-01 18:05:02'),
  (2, 101, 1, NULL, NULL, '2020-01-01 19:00:52'),
  (3, 102, 1, NULL, NULL, '2020-01-02 23:51:23'),
  (3, 102, 2, NULL, NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', NULL, '2020-01-04 13:23:46'),
  (4, 103, 2, '4', NULL, '2020-01-04 13:23:46'),
  (5, 104, 1, NULL, '1', '2020-01-08 21:00:29'),
  (6, 101, 2, NULL, NULL, '2020-01-08 21:03:13'),
  (7, 105, 2, NULL, '1', '2020-01-08 21:20:29'),
  (8, 102, 1, NULL, NULL, '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1,5', '2020-01-10 11:22:59'),
  (10, 104, 1, NULL, NULL, '2020-01-11 18:34:49'),
  (10, 104, 1, '2,6', '1,4', '2020-01-11 18:34:49');

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  `order_id` INT,
  `runner_id` INT,
  `pickup_time` DATETIME NULL,
  `distance` DECIMAL(5,2) NULL,  -- Numeric value without 'km'
  `duration` INT NULL,  -- Numeric value without 'minutes'
  `cancellation` VARCHAR(50) NULL
);

INSERT INTO runner_orders (`order_id`, `runner_id`, `pickup_time`, `distance`, `duration`, `cancellation`)
VALUES
  (1, 1, '2020-01-01 18:15:34', 20.00, 32, NULL),
  (2, 1, '2020-01-01 19:10:54', 20.00, 27, NULL),
  (3, 1, '2020-01-03 00:12:37', 13.40, 20, NULL),
  (4, 2, '2020-01-04 13:53:03', 23.40, 40, NULL),
  (5, 3, '2020-01-08 21:10:57', 10.00, 15, NULL),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', 25.00, 25, NULL),
  (8, 2, '2020-01-10 00:15:02', 23.40, 15, NULL),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', 10.00, 10, NULL);

DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  `pizza_id` INT PRIMARY KEY,
  `pizza_name` VARCHAR(50)
);

INSERT INTO pizza_names (`pizza_id`, `pizza_name`)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  `pizza_id` INT,
  `toppings` TEXT
);

INSERT INTO pizza_recipes (`pizza_id`, `toppings`)
VALUES
  (1, '1,2,3,4,5,6,8,10'),
  (2, '4,6,7,9,11,12');

DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  `topping_id` INT PRIMARY KEY,
  `topping_name` VARCHAR(50)
);

INSERT INTO pizza_toppings (`topping_id`, `topping_name`)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  select * from runners;
  select * from customer_orders;
  select * from runner_orders;
  select * from pizza_names;
  select * from pizza_recipes;
  select * from pizza_toppings;
  #1) How many pizzas were ordered?
select count(*) as total_order from customer_orders;
#2) How many unique customer orders were made?
select distinct customer_id ,count(order_id) as total_order from customer_orders group by customer_id;
#3) How many successful orders were delivered by each runner?
select runner_id,count( distinct order_id)as total_count from runner_orders where cancellation is null or cancellation = '' group by runner_id; 
#4)How many of each type of pizza was delivered?
select c.pizza_id ,count(*) as no_of_pizza from customer_orders as c inner join runner_orders as r using(order_id) where r.cancellation is null or r.cancellation = ''
group by c.pizza_id order by no_of_pizza desc;
#5)How many Vegetarian and Meatlovers were ordered by each customer?
select c.customer_id,pn.pizza_name,count(*) as total_order from customer_orders as c inner join pizza_names as pn using(pizza_id) group by c.customer_id,pn.pizza_name order by c.customer_id;
#6) What was the maximum number of pizzas delivered in a single order?
select c.order_id,count(*) as no_of_order from customer_orders as c inner join runner_orders as r using(order_id) 
where r.cancellation is null or r.cancellation ='' group by c.order_id order by no_of_order desc;
#7)For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select c.customer_id,
sum(case when ( c.exclusions is not null and c.exclusions <> '') or ( c.extras is not null and c.extras <> '') then 1 else 0 end) as changed_pizzas,
sum(case when (c.exclusions is null or c.exclusions = '') and (c.extras is null or c.extras = '') then 1 else 0 end) as unchanged_pizzas from customer_orders as c
inner join runner_orders as r using(order_id) where r.cancellation is null or r.cancellation = '' group by c.customer_id order by c.customer_id;
#8) How many pizzas were delivered that had both exclusions and extras?
  select count(*) as exclusions_extras from customer_orders as c inner join runner_orders as r on c.order_id = r.order_id
  where ( c.exclusions is not null and c.exclusions <> '')
  and(c.extras is not null and c.extras <> '')
  and(r.cancellation is null or r.cancellation ='');
 #9) What was the total volume of pizzas ordered for each hour of the day?
select extract(hour from order_time) as order_per_hour,count(*) as total_orders from customer_orders group by order_per_hour order by order_per_hour;
#10)What was the volume of orders for each day of the week?
select dayname(order_time) as order_day,count(distinct order_id) as total_orders from customer_orders group by order_day 
order by order_day;   
#11)How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select yearweek(registration_date,1) as reg,count(runner_id) as run from runners group by reg order by reg;
select registration_date as reg, count(runner_id) as run from runners group by reg order by reg;
#12)What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select avg(pickup_time) as pic_time from runner_orders; 
select r.runner_id, avg(timestampdiff(minute, c.order_time,r.pickup_time)) as avg_time from runner_orders as r
inner join customer_orders as c using(order_id) where r.pickup_time is not null group by r.runner_id ;
#13)Is there any relationship between the number of pizzas and how long the order takes to prepare?
select c.order_id, count(c.pizza_id) as total_pizzas, timestampdiff(minute,min(c.order_time),r.pickup_time)as prepare_time from customer_orders
as c inner join runner_orders as r using(order_id) where r.pickup_time is not null group by r.pickup_time, c.order_id;
#14)What was the average distance travelled for each customer?
select c.customer_id,avg(r.distance) as average from customer_orders as c inner join runner_orders as r using(order_id) group by c.customer_id;
#15)What was the difference between the longest and shortest delivery times for all orders?
select order_id,runner_id,min(duration) as mini, max(duration) as maxi from runner_orders group by runner_id,order_id;
  select max(cast(replace(duration, 'minutes','')as unsigned))-min(cast(replace(duration,'minutes','')as unsigned)) as delivery_difference
  from runner_orders where duration is not null;
#16)What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id,order_id, round(cast(replace(distance,'km','') as decimal)/(cast(replace(duration,'minutes','') as decimal)/60)) 
as avg_speed from runner_orders where distance and duration is not null and cancellation is null;

select runner_id,order_id,avg(duration) as average from runner_orders where distance and duration is not null and cancellation is null group by 
runner_id,order_id;
#17)What is the successful delivery percentage for each runner?

select r.runner_id, count(r.order_id) as total_order, sum(case when r.cancellation is null or r.cancellation ='' then 1 else 0 end) as deleivery_success,
round((sum(case when r.cancellation is null or r.cancellation = '' then 1 else 0 end)/ count(r.order_id))* 100 ,2) as percentage_success from runner_orders as r
group by r.runner_id ;
#18)What are the standard ingredients for each pizza?

select pn.pizza_name,group_concat(pt.topping_name order by pt.topping_id separator ',') as ingredients
from pizza_names as pn join pizza_recipes as pr using(pizza_id) join pizza_toppings as pt on find_in_set(pt.topping_id,pr.toppings) group by pn.pizza_name;
#19)What was the most commonly added extra?

select p.topping_name ,count(*) as count from customer_orders as c join pizza_toppings as p on find_in_set(p.topping_id,c.extras)
where c.extras is not null group by p.topping_name order by count desc limit 1;
#20)What was the most common exclusion?
select p.topping_id,p.topping_name ,count(*) as count from customer_orders as c join pizza_toppings as p on find_in_set(p.topping_id,c.exclusions)
where c.exclusions is not null group by p.topping_name,p.topping_id order by count desc limit 1;
#21)Generate an order item for each record in the customers_orders table in the format of one of the following:
#Meat Lovers
#Meat Lovers - Exclude Beef
#Meat Lovers - Extra Bacon
#Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers



#22)Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
#For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

with base_ingredients as ( select co.order_id,co.customer_id,pn.pizza_name,pt.topping_name from customer_orders as co join pizza_names as pn on co.pizza_id = pn.pizza_id
join pizza_recipes as pr on co.pizza_id = pn.pizza_id join pizza_toppings as pt on find_in_set(pt.topping_id,pr.toppings) where not find_in_set(pt.topping_id,co.exclusions)),
extra_ingredients as( select co.order_id,co.customer_id,pn.pizza_name,pt.topping_name from customer_orders as co join pizza_names as pn on co.pizza_id = pn.pizza_id
join pizza_toppings as pt on find_in_set(pt.topping_id,co.extras)) select bi.order_id,bi.customer_id,concat(bi.pizza_name,':', group_concat( case 
when ei.topping_name is not null then concat('2x', bi.topping_name) else bi.topping_name end order by bi_topping_name separator ',')) as ingredient_list
from base_ingredients as bi left join extra_ingredients as ei on bi.order_id = ei.order_id and bi.topping_name = ei.topping_name group by bi.order_id, bi.customer_id,bi.pizza_name order by bi.order_id;


