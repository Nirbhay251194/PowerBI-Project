CREATE DATABASE coffee_shop_Project;
USE coffee_shop_Project;
SELECT * FROM coffee_shop_sales;

DESCRIBE coffee_shop_sales;

ALTER TABLE coffee_shop_sales
CHANGE ï»¿transaction_id tansaction_id INT;
ALTER TABLE coffee_shop_sales
CHANGE tansaction_id transaction_id INT;

UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');
ALTER TABLE coffee_shop_sales
CHANGE COLUMN `tansaction_id` transaction_id INT;


ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME NOT NULL;

ALTER TABLE coffee_shop_sales
MODIFY COLUMN unit_price TEXT;

-------------- //total sales //-----------------------
SELECT ROUND(SUM(unit_price * transaction_qty))  AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 ; -- for may month

         -------- ----month on month increase or decrease---------------
         
         SELECT 
         MONTH(transaction_date) AS month,
         ROUND(SUM(unit_price * transaction_qty))  AS Total_Sales,
         (SUM(unit_price * transaction_qty) - LAG (SUM(unit_price * transaction_qty),1)
         OVER (ORDER BY MONTH(transaction_date)))/ LAG (SUM(unit_price * transaction_qty),1)
         OVER(ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
         FROM coffee_shop_sales
         WHERE MONTH(transaction_date) IN (4,5)
         GROUP BY MONTH(transaction_date)
         ORDER BY MONTH(transaction_date);
         
         
         --------------total orders ---------------------------------;
         
         
		SELECT COUNT(transaction_id) AS total_orders
        FROM coffee_shop_sales
        WHERE MONTH(transaction_date) = 5 ;
        
        
	----mom increase or decrease in order ------;
    
SELECT 
         MONTH(transaction_date) AS month,
         Round(COUNT(transaction_id)) AS total_orders,
         (COUNT(transaction_id) - LAG (COUNT(transaction_id),1)
         OVER (ORDER BY MONTH(transaction_date)))/  LAG (COUNT(transaction_id),1)
         OVER(ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
         FROM coffee_shop_sales
         WHERE MONTH(transaction_id) IN (4,5)
         GROUP BY MONTH(transaction_id)
         ORDER BY MONTH(transaction_id);
    SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
   //-- total quantity sold --//
   
   SELECT SUM(transaction_qty) AS Total_qunatity_sold
   FROM coffee_shop_sales
   WHERE MONTH(transaction_date) = 5 ;-- for may month --
   
   -- mom increase and decrese of total quantity --
   
   SELECT MONTH(transaction_date) as month ,
   SUM(transaction_qty) AS Total_qunatity_sold,
   (SUM(transaction_qty) - LAG(SUM(transaction_qty),1) OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty),1) OVER (ORDER BY MONTH(transaction_date)) *100 
   AS mom_increase_decrease_percentage
   FROM coffee_shop_sales
   WHERE MONTH(transaction_date) IN (4,5)
   GROUP BY MONTH(transaction_date)
   ORDER BY MONTH(transaction_date);
   
   -- CALENDAR TABLE- DAILY SALES, QUANTITY and TOTAL ORDERS --
   
   SELECT SUM(unit_price * transaction_qty) AS Total_sales,
          SUM(transaction_qty) AS Total_quatity_sold,
          COUNT(transaction_id) AS Total_order
   FROM  coffee_shop_sales
   WHERE transaction_date = '2023-01-04';
   
   -- round off quatity in k --
   SELECT CONCAT(ROUND(SUM(unit_price* transaction_qty)/1000,1),'K') AS Total_sales,
          CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS Total_quatity_sold,
          CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') AS Total_orders
   FROM coffee_shop_sales
   WHERE transaction_date = '2023-01-04';
   
   -- DAILY SALES FOR MONTH SELECTED --
   
SELECT DAY(transaction_date) AS day_of_month,
          CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS Total_Sales
	FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5
    GROUP BY DAY(transaction_date)
    ORDER BY DAY(transaction_date);
    
    -- AVG SALES --

SELECT AVG(CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K')) AS average_sales
	 FROM coffee_shop_sales
	 WHERE MONTH(transaction_date) = 5 ;


SELECT AVG(total_sales) AS average_sales
FROM (
    SELECT 
       SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        coffee_shop_sales
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query;

-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”--
  
 
 SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > average_sales THEN 'Above Average'
        WHEN total_sales < average_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS average_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
-- SALES BY WEEKDAY / WEEKEND --
SELECT 
	CASE 
		WHEN DAYOFWEEK(transaction_date) in (1,7) THEN 'wekends'
        ELSE 'Weekdays'
	END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS Total_sales 
FROM
	coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY CASE 
		WHEN DAYOFWEEK(transaction_date) in (1,7) THEN 'wekends'
        ELSE 'Weekdays'
	END;

-- SALES BY STORE LOCATION --
SELECT 
	store_location ,
    SUM(unit_price * transaction_qty) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY store_location
ORDER BY  SUM(unit_price * transaction_qty) DESC;   
    
-- SALES BY PRODUCT CATEGORY--
SELECT 
	product_category,
    ROUND(SUM(unit_price * transaction_qty),1) AS Total_sales
FROM
	coffee_shop_sales
WHERE MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY ROUND(SUM(unit_price * transaction_qty),1) DESC ;

-- SALES BY PRODUCTS (TOP 10)--

SELECT 
	product_category,
    ROUND(SUM(unit_price * transaction_qty),1) AS Total_sales
FROM
	coffee_shop_sales
WHERE MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY ROUND(SUM(unit_price * transaction_qty),1) DESC
LIMIT 10;

-- SALES BY DAY/HOUR--


SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffee_shop_sales
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)
    
    -- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY--
SELECT 
	CASE 
		WHEN DAYOFWEEK (transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK (transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK (transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK (transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK (transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK (transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
	END AS Day_of_week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY 
	CASE 
		WHEN DAYOFWEEK (transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK (transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK (transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK (transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK (transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK (transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
	END;
	
-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY--
SELECT 
	HOUR(transaction_time) AS Hour_of_day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5 
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time); 

     
