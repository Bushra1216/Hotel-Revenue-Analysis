use [Hotel revenue];
select * from dbo.MarketSegment;
select * from dbo.mealCost;

select COUNT(*) from  revenue2018;


--to see how many number of columns in this
SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='revenue2018';

--shoe detailed view of column data type
EXEC sp_help 'revenue2020';
EXEC sp_help 'MarketSegment';

--rename column adr as 'AVG_daily_rate'
EXEC sp_rename 'revenue2018.adr' , 'AVG_daily_rate', 'COLUMN'; 

SELECT TOP 1 * FROM [dbo].[revenue2018];  


ALTER TABLE revenue2020
ALTER COLUMN arrival_date_year INT;

--fetching data from table
select * from dbo.revenue2018
select * from dbo.revenue2019
select * from dbo.revenue2020


--Combine all the tables using JOIN
with hotel_revenue AS(
select * from dbo.revenue2018
UNION
select * from dbo.revenue2019
UNION
select * from dbo.revenue2020)


select * from hotel_revenue LEFT JOIN dbo.MarketSegment ON hotel_revenue.market_segment=MarketSegment.market_segment 
LEFT JOIN dbo.mealCost ON hotel_revenue.meal=mealCost.meal;
--End





--total revenue in each year by hotel type
with hotel_revenue AS(
select * from dbo.revenue2018
UNION
select * from dbo.revenue2019
UNION
select * from dbo.revenue2020),

calculate_revenue AS(

select arrival_date_year,hotel,
(AVG_daily_rate + ISNULL(mealCost.Cost,0))*(stays_in_weekend_nights + stays_in_week_nights)*(1-ISNULL(MarketSegment.Discount,0)) AS Revenue 
from hotel_revenue

LEFT JOIN dbo.MarketSegment ON hotel_revenue.market_segment=MarketSegment.market_segment 
LEFT JOIN dbo.mealCost ON hotel_revenue.meal=mealCost.meal
WHERE is_canceled=0 
)
SELECT arrival_date_year,hotel AS hotel_type,
CAST(SUM(Revenue) AS DECIMAL(10,3)) AS TotalRevenue

from calculate_revenue

GROUP BY arrival_date_year,hotel
ORDER BY arrival_date_year;
--End



--calculate average discount by joining all the tables
WITH hotel_revenue AS (
select * from dbo.revenue2018
UNION
select * from dbo.revenue2019
UNION
select * from dbo.revenue2020
)
SELECT 
   CAST(AVG(Discount) AS DECIMAL(18,5)) AS disk 
FROM 
    hotel_revenue 
    LEFT JOIN dbo.MarketSegment ON hotel_revenue.market_segment = MarketSegment.market_segment 
    LEFT JOIN dbo.mealCost ON hotel_revenue.meal = mealCost.meal;

--End




--see revenue in each country
with hotel_revenue AS(
select * from dbo.revenue2018
UNION
select * from dbo.revenue2019
UNION
select * from dbo.revenue2020),

calculate_revenue AS(

select arrival_date_year,hotel,country,
(AVG_daily_rate + ISNULL(mealCost.Cost,0))*(stays_in_weekend_nights + stays_in_week_nights)*(1-ISNULL(MarketSegment.Discount,0)) AS Revenue 
from hotel_revenue

LEFT JOIN dbo.MarketSegment ON hotel_revenue.market_segment=MarketSegment.market_segment 
LEFT JOIN dbo.mealCost ON hotel_revenue.meal=mealCost.meal
WHERE is_canceled=0)
SELECT arrival_date_year,country,
SUM(Revenue)  AS TotalRevenue

from calculate_revenue

GROUP BY country,arrival_date_year ORDER BY country;
--End





--See how many country have this hotel
WITH hotel_revenue AS (
select * from dbo.revenue2018
UNION
select * from dbo.revenue2019
UNION
select * from dbo.revenue2020
)
SELECT 
   COUNT(DISTINCT country) AS disk 
FROM 
    hotel_revenue 
    LEFT JOIN dbo.MarketSegment ON hotel_revenue.market_segment = MarketSegment.market_segment 
    LEFT JOIN dbo.mealCost ON hotel_revenue.meal = mealCost.meal;
--end



-- Is there any need to increse the parking lot of the hotel
WITH hotel_revenue AS (
select * from dbo.revenue2018
UNION
select * from dbo.revenue2019
UNION
select * from dbo.revenue2020
),
parking_analysis AS (
    SELECT arrival_date_year, hotel,
        SUM(required_car_parking_spaces) AS TotalParkingSpaces, 
        SUM(stays_in_week_nights + stays_in_weekend_nights) AS TotalStayingNights
    FROM hotel_revenue
    WHERE is_canceled = 0
  GROUP BY arrival_date_year, hotel
)
SELECT arrival_date_year, hotel,
    TotalParkingSpaces, 
    TotalStayingNights, 
    round((TotalParkingSpaces / TotalStayingNights)*100,2) AS ParkingRatio
FROM parking_analysis;









