  /***********************************************
  Case Study #1 - Danny's Diner

  https://8weeksqlchallenge.com/case-study-1/
 
  ************************************************/


  /*****************************************************************************************


  Case Study Questions

  Each of the following case study questions can be answered using a single SQL statement:

  ******************************************************************************************/

  --What is the total amount each customer spent at the restaurant?

  select s.[customer_id], sum(m.[price]) as total_spend
  from [DannyMa].[dbo].[case_1_sales] s
  inner join [DannyMa].[dbo].[case_1_menu] m
  on s.[product_id]=m.[product_id]
  group by s.[customer_id];

  --How many days has each customer visited the restaurant?

  select [customer_id], count(distinct [order_date]) as days_visited
  from [DannyMa].[dbo].[case_1_sales]
  group by [customer_id];

  --What was the first item from the menu purchased by each customer?
  
  with apply_rnk as
  (
  select *, rank() over (partition by customer_id order by customer_id, order_date) as rnk
  from [DannyMa].[dbo].[case_1_sales]
  )

  select distinct r.customer_id, m.product_name
  from apply_rnk r
  inner join [DannyMa].[dbo].[case_1_menu] m
  on r.[product_id]=m.[product_id]
  where r.rnk=1;

  --What is the most purchased item on the menu and how many times was it purchased by all customers?

  select top (1) m.product_name, count(product_name) as purchase_count
  from [DannyMa].[dbo].[case_1_sales] s
  inner join [DannyMa].[dbo].[case_1_menu] m
  on s.[product_id]=m.[product_id]
  group by m.[product_name]
  order by purchase_count desc;

  --Which item was the most popular for each customer?

 with aggregated_ranking as
 (
 select customer_id, product_id, count(product_id) as times_purchased, rank() over (partition by customer_id order by count(product_id) desc) as rnk
 from [DannyMa].[dbo].[case_1_sales] s
 group by customer_id, product_id
 )

 select r.customer_id, m.product_name, times_purchased
 from aggregated_ranking r
 inner join [DannyMa].[dbo].[case_1_menu] m
 on r.product_id=m.product_id
 where r.rnk=1;

 --Which item was purchased first by the customer after they became a member?

 with first_order_ranking as
 (
 select s.customer_id, s.order_date, menu.product_name, rank() over (partition by s.customer_id order by order_date asc) as rnk
 from [DannyMa].[dbo].[case_1_sales] s
 inner join [DannyMa].[dbo].[case_1_members] members
 on s.customer_id=members.customer_id
 inner join [DannyMa].[dbo].[case_1_menu] menu
 on s.product_id=menu.product_id
 where s.order_date>=members.join_date
 )

 select customer_id, order_date, product_name
 from first_order_ranking
 where rnk=1;

 --Which item was purchased just before the customer became a member?

  with last_order_ranking as
 (
 select s.customer_id, s.order_date, menu.product_name, rank() over (partition by s.customer_id order by order_date desc) as rnk
 from [DannyMa].[dbo].[case_1_sales] s
 inner join [DannyMa].[dbo].[case_1_members] members
 on s.customer_id=members.customer_id
 inner join [DannyMa].[dbo].[case_1_menu] menu
 on s.product_id=menu.product_id
 where s.order_date<members.join_date
 )

 select customer_id, order_date, product_name
 from last_order_ranking
 where rnk=1;

 --What is the total items and amount spent for each member before they became a member?


 select s.customer_id, count(distinct s.product_id) as items_purchased, sum(price) as total_spend
 from [DannyMa].[dbo].[case_1_sales] s
 inner join [DannyMa].[dbo].[case_1_members] members
 on s.customer_id=members.customer_id
 inner join [DannyMa].[dbo].[case_1_menu] menu
 on s.product_id=menu.product_id
 where s.order_date<members.join_date
 group by s.customer_id;

 --If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

 select s.customer_id, sum(case when menu.product_name like 'sushi' then 20 else 10 end * menu.price) as total_points
 from [DannyMa].[dbo].[case_1_sales] s
 inner join [DannyMa].[dbo].[case_1_menu] menu
 on s.product_id=menu.product_id
 group by s.customer_id;

 --In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

 with custom_fields as
 (
 select *, dateadd(day,6,join_date) as first_week
 from [DannyMa].[dbo].[case_1_members]
 )

 ,calc_points as
 (
 select s.customer_id, s.product_id, menu.product_name, menu.price, s.order_date, members.join_date
	,case when s.order_date>=members.join_date and s.order_date<=first_week then 20*menu.price
	 when s.order_date>=members.join_date and s.order_date<='2021-01-31' and menu.product_name like 'sushi' then 20*menu.price
	 when s.order_date>=members.join_date and s.order_date<='2021-01-31' then 10*menu.price
	 else 0 end as points
 from [DannyMa].[dbo].[case_1_sales] s
 inner join custom_fields members
 on s.customer_id=members.customer_id
 inner join [DannyMa].[dbo].[case_1_menu] menu
 on s.product_id=menu.product_id
 )

 select customer_id, sum(points) as total_points
 from calc_points
 group by customer_id

