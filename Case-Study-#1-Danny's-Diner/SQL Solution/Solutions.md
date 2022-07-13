# Case Study #1 - Danny's Diner

## Case Study Questions

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

## Bonus Questions

### Join All The Things

The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

Recreate the following table output using the available data: customer_id,	order_date,	product_name,	price,	member(Y/N)

### Rank All The Things

Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

***

###  1. What is the total amount each customer spent at the restaurant?

```sql
  select s.[customer_id], sum(m.[price]) as total_spend
  from [DannyMa].[dbo].[case_1_sales] s
  inner join [DannyMa].[dbo].[case_1_menu] m
  on s.[product_id]=m.[product_id]
  group by s.[customer_id];
``` 
![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q1.jpg)

***

###  2. How many days has each customer visited the restaurant?

```sql
  select [customer_id], count(distinct [order_date]) as days_visited
  from [DannyMa].[dbo].[case_1_sales]
  group by [customer_id];
``` 

![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q2.jpg)

***

###  3. What was the first item from the menu purchased by each customer?

```sql
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
``` 

![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q3.jpg)

***

###  4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
  select top (1) m.product_name, count(product_name) as purchase_count
  from [DannyMa].[dbo].[case_1_sales] s
  inner join [DannyMa].[dbo].[case_1_menu] m
  on s.[product_id]=m.[product_id]
  group by m.[product_name]
  order by purchase_count desc;
``` 
![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q4.jpg)

***

###  5. Which item was the most popular for each customer?

```sql
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
``` 
![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q5.jpg)

***

###  6. Which item was purchased first by the customer after they became a member?

```sql
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
``` 
![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q6.jpg)

***

###  7. Which item was purchased just before the customer became a member?

```sql
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
``` 

![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q7.jpg)

***

###  8. What is the total items and amount spent for each member before they became a member?

```sql
 select s.customer_id, count(distinct s.product_id) as items_purchased, sum(price) as total_spend
 from [DannyMa].[dbo].[case_1_sales] s
 inner join [DannyMa].[dbo].[case_1_members] members
 on s.customer_id=members.customer_id
 inner join [DannyMa].[dbo].[case_1_menu] menu
 on s.product_id=menu.product_id
 where s.order_date<members.join_date
 group by s.customer_id;
``` 
![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q8.jpg)

***

###  9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql
 select s.customer_id, sum(case when menu.product_name like 'sushi' then 20 else 10 end * menu.price) as total_points
 from [DannyMa].[dbo].[case_1_sales] s
 inner join [DannyMa].[dbo].[case_1_menu] menu
 on s.product_id=menu.product_id
 group by s.customer_id;
``` 
![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q9.jpg)

***

###  10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January

```sql
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
``` 

![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q10.jpg)

***

###  Bonus Questions

#### Join All The Things
Create basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. Fill Member column as 'N' if the purchase was made before becoming a member and 'Y' if the after is amde after joining the membership.

```sql
 select s.customer_id, s.order_date, menu.product_name, menu.price, case when s.order_date>=members.join_date then 'Y' else 'N' end as member
 from [DannyMa].[dbo].[case_1_sales] s
 left join [DannyMa].[dbo].[case_1_members] members
 on s.customer_id=members.customer_id
 inner join [DannyMa].[dbo].[case_1_menu] menu
 on s.product_id=menu.product_id
``` 
![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q11.jpg)

***

#### Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

```sql
 with member_classification as
 (
  select s.customer_id, s.order_date, menu.product_name, menu.price, case when s.order_date>=members.join_date then 'Y' else 'N' end as member
 from [DannyMa].[dbo].[case_1_sales] s
 left join [DannyMa].[dbo].[case_1_members] members
 on s.customer_id=members.customer_id
 inner join [DannyMa].[dbo].[case_1_menu] menu
 on s.product_id=menu.product_id
 )

 select *
	,case when member like 'N' then NULL else dense_rank() over (partition by customer_id,member order by order_date) end as ranking
 from member_classification;
``` 

![image](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/blob/main/Case-Study-%231-Danny's-Diner/SQL%20Solution/Images/Q12.jpg)

***
Click [here](https://github.com/LilyElizabethJohn/8WeekSQLChallenge-DannyMa/tree/main/Case-Study-%231-Danny's-Diner) to go back to Danny's Diner!



