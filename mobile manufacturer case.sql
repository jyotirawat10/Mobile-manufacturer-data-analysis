

--1. List all the states in which we have customers who have bought cellphones from 2005 till today. 
--Q1--BEGIN 
SELECT DISTINCT COUNTRY FROM 
DIM_LOCATION AS T1
JOIN FACT_TRANSACTIONS AS T2
ON T1.IDLOCATION = T2.IDLOCATION
WHERE DATE >= '01-01-2005'
GROUP BY COUNTRY 

--Q1--END

--2. What state in the US is buying the most 'Samsung' cell phones? 
--Q2--BEGIN

SELECT TOP 1 STATE, COUNT(T3.IDMANUFACTURER)AS CNT FROM DIM_LOCATION AS T1
JOIN FACT_TRANSACTIONS AS T2
ON T1.IDLOCATION = T2.IDLOCATION
JOIN DIM_MODEL AS T3
ON T2.IDMODEL = T3.IDMODEL
JOIN DIM_MANUFACTURER AS T4
ON T3.IDMANUFACTURER = T4.IDMANUFACTURER
WHERE COUNTRY ='US' AND MANUFACTURER_NAME = 'SAMSUNG'
GROUP BY STATE
ORDER BY CNT DESC


--Q2--END

--3. Show the number of transactions for each model per zip code per state. 
--Q3--BEGIN     


SELECT IDMODEL,ZIPCODE, STATE , COUNT (DATE) AS COUNT FROM FACT_TRANSACTIONS AS T1
JOIN
DIM_LOCATION AS T2
ON T1.IDLOCATION = T2.IDLOCATION
GROUP BY IDMODEL,ZIPCODE, STATE 


--Q3--END

--4. Show the cheapest cellphone (Output should contain the price also)
--Q4--BEGIN

SELECT MODEL_NAME  AS MODEL_NAME, UNIT_PRICE AS PRICE FROM DIM_MODEL
WHERE UNIT_PRICE = (SELECT MIN(UNIT_PRICE) FROM DIM_MODEL)


--Q4--END

--5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price. 
--Q5--BEGIN

select manufacturer_name from 

(SELECT TOP 5 MANUFACTURER_NAME FROM FACT_TRANSACTIONS AS T1 
JOIN
DIM_MODEL AS T2
ON T1.IDMODEL = T2.IDMODEL
JOIN 
DIM_MANUFACTURER AS T3
ON T2.IDMANUFACTURER =T3.IDMANUFACTURER
GROUP BY MANUFACTURER_NAME
ORDER BY SUM(QUANTITY) DESC
) as a
intersect

select manufacturer_name  from 
(
SELECT TOP 5 MANUFACTURER_NAME FROM FACT_TRANSACTIONS AS T1 
JOIN
DIM_MODEL AS T2
ON T1.IDMODEL = T2.IDMODEL
JOIN 
DIM_MANUFACTURER AS T3
ON T2.IDMANUFACTURER =T3.IDMANUFACTURER
GROUP BY MANUFACTURER_NAME
ORDER BY avg (totalprice) DESC
)  as b


--Q5--END

--6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500 
--Q6--BEGIN

SELECT CUSTOMER_NAME, AVG(TOTALPRICE) AS AVG_AMOUNT FROM FACT_TRANSACTIONS AS T1
JOIN
DIM_CUSTOMER AS T2
ON T1.IDCUSTOMER = T2.IDCUSTOMER
WHERE YEAR(DATE)='2009'  
GROUP BY CUSTOMER_NAME
HAVING AVG(TOTALPRICE) > 500



--Q6--END

--7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010	
--Q7--BEGIN  

SELECT * FROM (
select TOP 5 MODEL_NAME   AS QUANTITY from FACT_TRANSACTIONS AS T1
JOIN DIM_MODEL AS T2
ON T1.IDMODEL =T2.IDMODEL
WHERE YEAR(DATE)='2008'
GROUP BY MODEL_NAME , YEAR(DATE)
ORDER BY SUM(QUANTITY) DESC)
AS A
intersect
select * from
(select TOP 5 MODEL_NAME   AS QUANTITY from FACT_TRANSACTIONS AS T1
JOIN DIM_MODEL AS T2
ON T1.IDMODEL =T2.IDMODEL
WHERE YEAR(DATE)='2009'
GROUP BY MODEL_NAME , YEAR(DATE)
ORDER BY SUM(QUANTITY) DESC)
AS B
intersect
select * from
(select TOP 5 MODEL_NAME   AS QUANTITY from FACT_TRANSACTIONS AS T1
JOIN DIM_MODEL AS T2
ON T1.IDMODEL =T2.IDMODEL
WHERE YEAR(DATE)='2010'
GROUP BY MODEL_NAME , YEAR(DATE)
ORDER BY SUM(QUANTITY) DESC
)
AS C

--Q7--END

--8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010. 
--Q8--BEGIN

select * from (
select top 1 * from
(select top 2 idmanufacturer, year(date) as year_ , sum(totalprice) as sales from fact_transactions as t1
join dim_model as t2
on 
t1.idmodel = t2.idmodel
where year(date) = 2009
group by idmanufacturer , year(date)
order by sum(totalprice) desc)
as a
order by sales asc
) as c

union

Select * from (
select top 1 * from
(select top 2 idmanufacturer, year(date) as year_ , sum(totalprice) as sales from fact_transactions as t1
join dim_model as t2
on 
t1.idmodel = t2.idmodel
where year(date) = 2010
group by idmanufacturer , year(date)
order by sum(totalprice) desc)
as b
order by sales asc
)
as d

--Q8--END


--9. Show the manufacturers that sold cellphones in 2010 but did not in 2009. 
--Q9--BEGIN
	
select manufacturer_name from(
select distinct manufacturer_name  from fact_transactions as t1
join dim_model as t2
on t1.idmodel = t2.idmodel
join dim_manufacturer as t3
on t2.idmanufacturer = t3.idmanufacturer
where year(date) = 2010)
as a 

where manufacturer_name not in

(select manufacturer_name from

(
select distinct manufacturer_name  from fact_transactions as t1
join dim_model as t2
on t1.idmodel = t2.idmodel
join dim_manufacturer as t3
on t2.idmanufacturer = t3.idmanufacturer
where year(date) = 2009
)
as b
)


--Q9--END

--10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend. 
--Q10--BEGIN
	
select * , lag(avg_spend,1) over (partition by customer_name order by year_) as lag_price from
(
select customer_name, year(date) as year_, avg(totalprice) as avg_spend, sum(quantity) as avg_qty  from fact_transactions as t1
join
dim_customer as t2
on t1.idcustomer = t2.idcustomer

where customer_name in ( select top 10 customer_name from fact_transactions as t1
							join
							dim_customer as t2
							on t1.idcustomer = t2.idcustomer
							group by customer_name
							order by sum(totalprice) desc
							) 

group by customer_name, year(date)
) as a

--Q10--END
	