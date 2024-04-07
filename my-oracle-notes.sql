
--you can not use sum and avg with varchar or dates
SELECT sum(first_name), avg(first_name)
FROM 
EMPLOYEES;

--all columns in the select should appear in group by
SELECT DEPARTMENT_ID,job_id, SUM(SALARY)
FROM  EMPLOYEES
GROUP BY DEPARTMENT_ID 

--you can not make group by using alias 
SELECT DEPARTMENT_ID d , SUM(SALARY)
FROM  EMPLOYEES
GROUP BY D;

--but you can make order using alias 
SELECT DEPARTMENT_ID d , SUM(SALARY)
FROM  EMPLOYEES
GROUP BY DEPARTMENT_ID
order by d;

--where and group by  and order by 
--where first then group by then order by 
SELECT DEPARTMENT_ID, SUM(SALARY)
FROM  EMPLOYEES
where DEPARTMENT_ID>30
GROUP BY DEPARTMENT_ID  
order by DEPARTMENT_ID ;

 --very important note, you can not use where to restrict groups
SELECT DEPARTMENT_ID, SUM(SALARY)
FROM  EMPLOYEES
where SUM(SALARY)>156400 -- this not coorect , you should use having
GROUP BY DEPARTMENT_ID  
order by DEPARTMENT_ID ;

--so use having 
SELECT DEPARTMENT_ID, SUM(SALARY)
FROM  EMPLOYEES
GROUP BY DEPARTMENT_ID  
having SUM(SALARY)>150000
order by DEPARTMENT_ID ;

--it could be using having before group by, but not recomnded

SELECT DEPARTMENT_ID, SUM(SALARY)
FROM  EMPLOYEES
HAVING SUM(SALARY)>150000
GROUP BY DEPARTMENT_ID  
order by DEPARTMENT_ID ;

-- we can only nested two function
select max(sum(salary))
from employees
group by department_id 
order by 1;

---------------------------------ROLLUP() OPERATOR------------------------------
--ROLLUP is an extension of the GROUP BY clause.
--Use the ROLLUP operation to produce cumulative aggregates, such as Grandtotals & subtotals.
/*
The ROLLUP operator creates groupings by moving in one direction, 
from right to left, along the list
of columns specified in the GROUP BY clause. 
It then applies the aggregate function to these groupings.
*/

-- group by  rollup same rules of group by  
--all cols in the select list should be in group by rollup clause
--this will give error
select region, country,city,shop, sum(amount) 
from info_sales2
group by  rollup (region, country,city)
---------------------------------CUBE()--------------------------------
/*
The CUBE operator is an additional switch in the GROUP BY clause in a SELECT statement. The
CUBE operator can be applied to all aggregate functions, including AVG, SUM, MAX, MIN, and COUNT. 
It is used to produce result sets that are typically used for cross-tabular reports. 

ROLLUP vs CUBE
ROLLUP produces only a fraction of possible subtotal combinations, 
whereas CUBE produces subtotals for all
possible combinations of groupings specified in the GROUP BY clause, and a grand total.
*/
---------------------------------GROUPING() FUNCTION------------------------
-- ONLY TAKE ONE ARGUMENT PASS
SELECT DECODE(GROUPING(DEPARTMENT_ID), 1 , 'GRAND TOATAL', 0, NVL(TO_CHAR(DEPARTMENT_ID), 'NO DEPT')) DEPT_ID,
SUM(SALARY) EMP_SALARY
FROM EMPLOYEES
GROUP BY ROLLUP(DEPARTMENT_ID)
ORDER BY DEPARTMENT_ID

/*
Working with the GROUPING Function
The GROUPING function:
� Is used with the CUBE or ROLLUP operator
� Is used to find the groups forming the subtotal in a row
� Is used to differentiate stored NULL values from NULL values created by ROLLUP or CUBE
� Returns 0 or 1
*/

--the null make the result not clear
select department_id , sum(salary) sum_sal 
FROM
employees
group by rollup( department_id  )
order by department_id ;

--this also will not help
select nvl( to_char( department_id ) ,'no dept' ) , sum(salary) sum_sal 
FROM
employees
group by rollup( department_id  )
order by department_id ;

--the solution is to use : GROUPING
select department_id , sum(salary) sum_sal ,
GROUPING (department_id) grand
FROM
employees
group by rollup( department_id  )
order by department_id ;
/*
The GROUPING function uses a single column as its argument.
The expr in the GROUPING function must match one of the expressions in the GROUP BY clause.
A value of 0 returned by the GROUPING function based on an expression indicates one of the
following:
� The expression has been used to calculate the aggregate value.
� The NULL value in the expression column is a stored NULL value.
A value of 1 returned by the GROUPING function based on an expression indicates one of the
following:
� The expression has not been used to calculate the aggregate value.
� The NULL value in the expression column is created by ROLLUP or CUBE as a result of
grouping.
*/

select  decode ( GROUPING (department_id), 1,'Grand total' ,
                                           0,nvl(to_char(department_id ), 'no dept')  
               ) dept_id  , 
sum(salary) sum_sal 
FROM
employees
group by rollup( department_id  )
order by department_id 


select  decode ( GROUPING (department_id), 1,'Grand total' ,
                                           0,nvl(to_char(department_id ), 'no dept')  
               ) dept_id  , 
count(employee_id) emp_count
FROM
employees
group by rollup( department_id  )
order by department_id 
-------------------------

--now this will make things not clear 
select department_id ,job_id, sum(salary) sum_sal 
FROM
employees
group by ROLLUP (department_id ,job_id) 
order by 1



select department_id ,job_id, sum(salary) sum_sal ,
GROUPING (department_id) group1,
GROUPING (job_id) group2
FROM
employees
group by ROLLUP (department_id ,job_id) 
order by 1

--0 0 Represents a row containing regular subtotal we would expect from a GROUP BY operation.
--0 1 Represents a row containing a subtotal for a distinct value of the Group1 column, as generated by ROLLUP and CUBE operations.
--1 1 Represents a row containing a grand total for the query, as generated by ROLLUP and CUBE operations.

select department_id ,job_id, sum(salary) sum_sal ,
GROUPING (department_id) group1,
GROUPING (job_id) group2
FROM
employees
group by cube (department_id ,job_id) 
order by 1
--0 0  Represents a row containing regular subtotal we would expect from a GROUP BY operation.
--0 1 Represents a row containing a subtotal for a distinct value of the Group1 column, as generated by ROLLUP and CUBE operations.
--1 1  Represents a row containing a grand total for the query, as generated by ROLLUP and CUBE operations.
--1,0 : Represents a row containing a subtotal for a distinct value of the group 2 column, which we would only see in a CUBE operation.
select region, country,city, sum(amount) ,
GROUPING (region) g1,
GROUPING (country) g2,
GROUPING (city) g3
from info_sales
group by  rollup (region, country,city )


select region, country,city, sum(amount) ,
GROUPING (region) g1,
GROUPING (country) g2,
GROUPING (city) g3
from info_sales
group by  cube (region, country,city )

-------------------------------GROUPING_ID()--------------------------------------
SELECT DEPARTMENT_ID, JOB_ID, SUM(SALARY) EMP_SALARY,
GROUPING_ID(DEPARTMENT_ID, JOB_ID) GROUPID
FROM EMPLOYEES
    --WHERE DEPARTMENT_ID IS NOT NULL
GROUP BY ROLLUP(DEPARTMENT_ID, JOB_ID)
ORDER BY DEPARTMENT_ID
--CHECK FOR CUBE OPERATOR ALSO

/*The GROUPING_ID function provides an alternate and more 
compact way to identify subtotal rows. Passing the dimension columns as arguments, 
it returns a number indicating the GROUP BY level.
so each subtotal type will have a specific ID Number 
*/

--this when using GROUPING
select department_id ,job_id, sum(salary) sum_sal ,
GROUPING (department_id) group_1,
GROUPING (job_id) group_2
FROM
employees
group by rollup (department_id ,job_id) 
order by 1

--it is better to use GROUPING_id 
select department_id ,job_id, sum(salary) sum_sal ,
GROUPING_id (department_id,job_id) group_id
FROM
employees
group by rollup (department_id ,job_id) 
order by 1



select region, country,city, sum(amount) ,
GROUPING_id (region, country,city ) 
from info_sales
group by  rollup (region, country,city )


select region, country,city, sum(amount) ,
GROUPING_id (region, country,city ) 
from info_sales
group by  cube (region, country,city )

------------------------------- GROUPING SET--------------------------------
--note: we created this table in Grouping and Aggregating Data Using SQL 5.sql
select * from  info_sales

select region,country, city , sum(amount) sum_amount
from info_sales
group by region,country, city 

select region,country, city , sum(amount) sum_amount
from info_sales
group by rollup (region,country, city )

--1 gives sub total based on the sets. In this case it will give you subtotal for the country and grouping_id which return 0 or 1
-- 0 for set 1 and if not 0 then it is for another set
select region,country, city , sum(amount) sum_amount ,  GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by 
GROUPING SETS  (
              (region,country, city ) , (country) 
              )
              
--2 --> this will give me grand total for empty braces       

select region,country, city , sum(amount) sum_amount ,  GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by 
GROUPING SETS  (
              (region,country, city ) , () 
              )
              
--3

select region,country, city , sum(amount) sum_amount ,  GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by 
GROUPING SETS  (
              (region,country, city ) , (region) 
              )
              
--4

select region,country, city , sum(amount) sum_amount ,  GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by 
GROUPING SETS  (
              (region,country, city ) , (region,country) 
              )
              
              
--5

select region,country, city , sum(amount) sum_amount ,  GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by 
GROUPING SETS  (
              (region,country, city ) , (region,country) ,(city) , ()
              )              
              
              
/*

important:

ROLLUP(a, b,c) =
GROUPING SETS (
                (a,b,c) ,(a,b) ,(a) , ()
              )
              
CUBE(a, b, c)  = 
GROUPING SETS
(
(a, b, c), (a, b), (a, c), (b, c),(a), (b), (c), ()
)


*/

  --this is very very important       
select region,country, city , sum(amount) sum_amount ,  GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by 
GROUPING SETS  (
               (region,country, city )
              )            
                        
 -----------------------           
select region,country, city , sum(amount) sum_amount ,  GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by 
GROUPING SETS  (
               region,country, city 
              )   
              
      
select region,country, city , sum(amount) sum_amount ,  GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by 
GROUPING SETS  ( (region ),(country),( city )
              )  
 -----------------------             
--this will give error   
select region,country, city , sum(amount) sum_amount ,  GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by 
GROUPING SETS  ( (region ),(country)
              )  
-------



  ---try to know this by ur self           
select region,country, city , sum(amount) sum_amount ,  GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by 
GROUPING SETS  (
               (region,country, city ) , cube(region,country)
              )  
-------------------------------------------Composit columns--------------------------------------------------------------------

--A composite column is a collection of columns that are
--treated as a unit.

select region,country, city , sum(amount) sum_amount,GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by rollup (region,country, city )


select region,country, city , sum(amount) sum_amount, GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by rollup (region, (country, city ) )

--go to Composite Columns.xlsx  Tab=(Composite Columns part 1)
----------------------------

  select region,country, city , sum(amount) sum_amount,GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by cube (region,country, city )


select region,country, city , sum(amount) sum_amount, GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by cube (region, (country, city ) )

--go to Composite Columns.xlsx  Tab=(Composite Columns part 2)

--==========================================concatenated grouping================================================

--Concatenated Groupings
select region,country, city , sum(amount) sum_amount,GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by  
GROUPING SETS (
        (region), (country, city  )
      )
      
 
--The result is a cross-product of groupings from each GROUPING SET.     
select region,country, city , sum(amount) sum_amount,GROUPING_ID(region, country,city) AS grouping_id
from info_sales
group by  
GROUPING SETS (region ) , GROUPING SETS (country,city)

--The result is a cross-product of groupings from each GROUPING SET.     
select region,country, city , shop, sum(amount) sum_amount,GROUPING_ID(region, country,city) AS grouping_id
from info_sales2
group by  
GROUPING SETS (region ) , GROUPING SETS (country,city,shop)

--The result is a cross-product of groupings from each GROUPING SET.  
select region,country, city , shop, sum(amount) sum_amount,GROUPING_ID(region, country,city) AS grouping_id
from info_sales2
group by  
GROUPING SETS (region ,country) , GROUPING SETS (city,shop)


--==============================================DenseRank()==================================================================