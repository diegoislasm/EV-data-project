--**Exploratory data analysis**
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types, Pivot, Case statements, Subqueries

USE EVs

-- Check the datatypes
EXEC sp_help 'dbo.EV_sales'
EXEC sp_help 'dbo.EV_charging_points'

-- Change datatype of column 'value' to float for tables EV_sales and EV_charging_points
ALTER TABLE dbo.EV_sales
ALTER COLUMN value float

ALTER TABLE dbo.EV_charging_points
ALTER COLUMN value float

-- Review the columns and first entries
SELECT *
FROM EV_sales

SELECT *
FROM EV_charging_points

-- Combine the two tables into a new temp table called 'EV_data'
DROP TABLE IF EXISTS #EV_data
SELECT *
INTO #EV_data
FROM EV_sales

UNION ALL

SELECT *
FROM EV_charging_points

-- Review new table 'EV_data'
SELECT *
FROM #EV_data

-- Check for missing values in columns 'region', 'parameter', 'powertrain', 'year' and 'value'
SELECT COUNT(*) AS MissingValues
FROM #EV_data
WHERE region is NULL OR parameter is NULL or powertrain is NULL OR year is NULL OR value is NULL

-- Check the unique values for 'region' column
SELECT DISTINCT(region)
FROM #EV_data
ORDER BY region ASC

-- Check the unique values for 'category' column
SELECT DISTINCT(category)
FROM #EV_data

-- Check the unique values for 'parameter' column
SELECT DISTINCT(parameter)
FROM #EV_data

-- Check the unique values for 'mode' column
SELECT DISTINCT(mode)
FROM #EV_data

-- Check the unique values for 'powertrain' column
SELECT DISTINCT(powertrain)
FROM #EV_data

-- Check for rows with 'Publicly available slow' and 'Publicly available fast' in column 'powertrain'
SELECT *
FROM #EV_data
WHERE powertrain = 'Publicly available slow' OR powertrain = 'Publicly available fast'

-- Check for rows with 'Publicly available slow' and 'Publicly available fast' in column 'powertrain' when 'value' column is less than 1
SELECT *
FROM #EV_data
WHERE parameter = 'EV charging points' AND value < 1

-- Check the unique values for 'unit' column
SELECT DISTINCT(unit)
FROM #EV_data

-- Check the values of the columns where 'parameter' column is EV stock and EV sales
SELECT *
FROM #EV_data
WHERE parameter = 'EV stock' OR parameter = 'EV sales'

-- Get the countries with the highest stock of BEV and PHEV excluiding groups (World, Europe, EU27)
SELECT region, year, powertrain, value
FROM #EV_data
WHERE region NOT IN('World', 'Europe', 'EU27') AND parameter = 'EV stock'
ORDER BY year DESC, value DESC

-- Get the total historical sales of EVs per country
SELECT region, SUM(value) AS Sum_EV_sales
FROM #EV_data
WHERE region NOT IN('World', 'Europe', 'EU27') AND parameter = 'EV stock'
GROUP BY region
ORDER BY Sum_EV_sales DESC

-- Create temp tables to split the data to later join them together in a long data format
-- Create temp table with EV sales with columns for each type of EV
DROP TABLE IF EXISTS #EV_car_sales
SELECT region, year, [PHEV], [FCEV], [BEV]
INTO #EV_car_sales
FROM
	(
	SELECT region, year, parameter, powertrain, value
	FROM #EV_data
	WHERE parameter = 'EV sales'
	) AS SalesData
PIVOT(
	MAX(value)
	FOR powertrain IN ([PHEV], [FCEV], [BEV])
	) AS PivotSales
ORDER BY year DESC

SELECT *
FROM #EV_car_sales
ORDER BY year DESC, region ASC

-- Create temp table with EV stock with columns for each type of EV
DROP TABLE IF EXISTS #EV_stock
SELECT region, year, [PHEV], [FCEV], [BEV]
INTO #EV_stock
FROM 
	(
	SELECT region, year, parameter, powertrain, value
	FROM #EV_data
	WHERE parameter = 'EV stock'
	) AS StockData
PIVOT(
	MAX(value)
	FOR powertrain IN ([PHEV], [FCEV], [BEV])
	) AS PivotStock
ORDER BY year DESC

SELECT *
FROM #EV_stock
ORDER BY year DESC, region ASC

-- Create temp table with EV charging point with a column for each charging point type
DROP TABLE IF EXISTS #EV_charging
SELECT region, year, [Publicly available slow], [Publicly available fast]
INTO #EV_charging
FROM 
	(
	SELECT region, year, parameter, powertrain, value
	FROM #EV_data
	WHERE parameter = 'EV charging points'
	) AS ChargingData
PIVOT(
	MAX(value)
	FOR powertrain IN ([Publicly available slow], [Publicly available fast])
	) AS PivotCharging
ORDER BY year DESC

SELECT *
FROM #EV_charging
ORDER BY year DESC, region ASC

-- Create temp table with EV sales share with a column for each type of EV
DROP TABLE IF EXISTS #EV_sales_stock_share
SELECT region, year, [EV sales share], [EV stock share]
INTO #EV_sales_stock_share
FROM 
	(
	SELECT region, year, parameter, powertrain, value
	FROM #EV_data
	WHERE parameter = 'EV sales share' or parameter = 'EV stock share'
	) AS StockData
PIVOT(
	MAX(value)
	FOR parameter IN ([EV sales share], [EV stock share])
	) AS PivotStock
ORDER BY year DESC

SELECT *
FROM #EV_sales_stock_share
ORDER BY year DESC, region ASC


-- Join temp tables (#EV_car_sales, #EV_charging, #EV_sales_stock_share, #EV_stock) into new table EV_data_long
-- Create a CTE with the distinct values of concatenating region and year column to join all the subtables together
WITH CTE_regyear AS
(
SELECT distinct(region+CAST(year as varchar(50))) AS RegionYear, region, year
FROM #EV_data
)
-- Join temp tables on year and region
SELECT regyear.region, regyear.year, 
ISNULL(stock.FCEV, 0) AS FCEV_stock, ISNULL(stock.PHEV, 0) AS PHEV_stock, ISNULL(stock.BEV, 0) AS BEV_stock,
ISNULL(sales.FCEV,0) AS FCEV_sales, ISNULL(sales.PHEV, 0) AS PHEV_sales, ISNULL(sales.BEV, 0) AS BEV_sales, 
ISNULL(share.[EV sales share], 0) AS EV_sales_share, ISNULL(share.[EV stock share], 0) AS EV_stock_share,
ISNULL(charging.[Publicly available slow], 0) AS slow_chargers, ISNULL(charging.[Publicly available fast], 0) AS fast_chargers
INTO EV_data_long
FROM CTE_regyear AS regyear
FULL JOIN #EV_car_sales as sales
	ON regyear.region = sales.region AND regyear.year = sales.year
FULL JOIN #EV_charging AS charging
	ON regyear.region = charging.region AND regyear.year = charging.year
FULL JOIN #EV_sales_stock_share AS share
	ON regyear.region = share.region AND regyear.year = share.year
FULL JOIN #EV_stock AS stock
	ON regyear.region = stock.region AND regyear.year = stock.year
ORDER BY year DESC, region ASC

SELECT *
FROM EV_data_long
ORDER BY year DESC, region ASC

-- Get the cumulative sales of electric vehicles (BEV and PHEV) by country over the years
SELECT region, year, year_sales, SUM(Year_sales) OVER (PARTITION BY region ORDER BY region, year) AS cumulative_sales
FROM (
SELECT region, year, FCEV_sales, PHEV_sales, BEV_sales, (FCEV_sales + PHEV_sales + BEV_sales) Year_sales
FROM EV_data_long) AS SourceTable
ORDER BY region ASC, year ASC

-- Get slow_chargers and fast_chargers column value where either of them is less than 1
SELECT region, year, slow_chargers, fast_chargers
FROM EV_data_long
WHERE (slow_chargers > 0 AND slow_chargers <1) OR (fast_chargers > 0 AND fast_chargers < 1)
ORDER BY region ASC, year DESC

-- Fix outliers of EV charging points where the columns slow_chargers or fast_chargers are lower than 1
UPDATE EV_data_long
SET slow_chargers =
CASE
	WHEN slow_chargers > 0 AND slow_chargers < 1
		THEN 0
	ELSE slow_chargers
END

UPDATE EV_data_long
SET fast_chargers =
CASE
	WHEN fast_chargers > 0 AND slow_chargers < 1
		THEN 0
	ELSE fast_chargers
END

-- Get total EV sales by country and year
SELECT region, year, PHEV_sales, FCEV_sales, BEV_sales, (PHEV_sales + FCEV_sales + BEV_sales) AS EV_sales
FROM EV_data_long
ORDER BY year DESC, region ASC

-- Get total EV sales by year
SELECT *, (Total_EV_sales / (LAG(Total_EV_sales, 1, Total_EV_sales) OVER (ORDER BY year ASC)) - 1) * 100 AS Percent_Change
FROM
(SELECT year, SUM(FCEV_sales) AS Total_FCEV_sales, SUM(PHEV_sales) AS Total_PHEV_sales, SUM(BEV_sales) AS Total_BEV_sales, (SUM(PHEV_sales) + SUM(FCEV_sales) + SUM(BEV_sales)) AS Total_EV_sales
FROM EV_data_long
WHERE region NOT IN('World', 'Europe', 'EU27')
GROUP BY year) AS SourceTable


-- Get total EV sales by country
SELECT region, SUM(FCEV_sales) AS Total_FCEV_sales, SUM(PHEV_sales) AS Total_PHEV_sales, SUM(BEV_sales) AS Total_BEV_sales, (SUM(PHEV_sales) + SUM(FCEV_sales) + SUM(BEV_sales)) AS Total_EV_sales
FROM EV_data_long
GROUP BY region
ORDER BY Total_EV_sales DESC

-- Get EV types sales distribution of total sales by country and year
SELECT region, year, 
(FCEV_sales / EV_sales) * 100 AS FCEV_percent, (PHEV_sales / EV_sales) * 100 AS PHEV_percent, (BEV_sales / EV_sales) * 100 AS BEV_percent
FROM (SELECT region, year, PHEV_sales, FCEV_sales, BEV_sales, (PHEV_sales + FCEV_sales + BEV_sales) AS EV_sales
FROM EV_data_long) AS SourceTable
WHERE EV_sales != 0
ORDER BY year DESC, region ASC

-- Get EV types sales distribution of total sales by country
SELECT region, 
(FCEV / EV_sales) * 100 AS FCEV_percent, (PHEV / EV_sales) * 100 AS PHEV_percent, (BEV / EV_sales) * 100 AS BEV_percent
FROM (SELECT region, SUM(PHEV_sales) AS  PHEV, SUM(FCEV_sales) AS FCEV, SUM(BEV_sales) AS BEV, (SUM(PHEV_sales) + SUM(FCEV_sales) + SUM(BEV_sales)) AS EV_sales
FROM EV_data_long
GROUP BY region) AS SourceTable
WHERE EV_sales != 0
ORDER BY region ASC

-- Get EV types sales distribution of total sales by year
SELECT year, 
(FCEV / EV_sales) * 100 AS FCEV_percent, (PHEV / EV_sales) * 100 AS PHEV_percent, (BEV / EV_sales) * 100 AS BEV_percent
FROM (SELECT year, SUM(PHEV_sales) AS  PHEV, SUM(FCEV_sales) AS FCEV, SUM(BEV_sales) AS BEV, (SUM(PHEV_sales) + SUM(FCEV_sales) + SUM(BEV_sales)) AS EV_sales
FROM EV_data_long
GROUP BY year) AS SourceTable
WHERE EV_sales != 0
ORDER BY year ASC

-- Get total charging points per country and year
SELECT region, year, slow_chargers, fast_chargers, (slow_chargers + fast_chargers) AS Total_chargers
FROM EV_data_long
ORDER BY year DESC, region ASC

-- Get sales share of EVs by country and year
SELECT region, year, EV_sales_share
FROM EV_data_long
ORDER BY year DESC, EV_sales_share DESC

-- Get stock share of EVs by country and year
SELECT region, year, EV_stock_share, (EV_stock_share / NULLIF((LAG(EV_stock_share, 1, EV_stock_share) OVER (PARTITION BY region ORDER BY year ASC)), 0) -1) * 100 AS Percent_change 
FROM EV_data_long

-- Check oldest and earliest 
SELECT region, MIN(year) AS earliest_year, MAX(year) AS latest_year
FROM EV_data_long
GROUP BY region

-- Show number of EVs per charging point by country and year
SELECT *, 
CASE 
	WHEN Total_EV_stock != 0 AND Total_chargers != 0
	THEN Total_EV_stock / Total_chargers 
	ELSE 0
END
AS EVs_chargers_ratio
FROM
(SELECT region, year, (FCEV_stock + PHEV_stock + BEV_stock) AS Total_EV_stock, (slow_chargers + fast_chargers) AS Total_chargers
FROM EV_data_long
) AS cumulated_data
ORDER BY  year DESC, EVs_chargers_ratio DESC

-- Show number of EVs per charging point by country
SELECT *, 
CASE 
	WHEN Total_EV_stock != 0 AND Total_chargers != 0
	THEN Total_EV_stock / Total_chargers 
	ELSE 0
END
AS EVs_chargers_ratio
FROM
(SELECT region, (SUM(FCEV_stock) + SUM(PHEV_stock) + SUM(BEV_stock)) AS Total_EV_stock, (SUM(slow_chargers) + SUM(fast_chargers)) AS Total_chargers
FROM EV_data_long
GROUP BY region
) AS cumulated_data
ORDER BY EVs_chargers_ratio DESC

-- Show number of EVs per charging point by year
SELECT year, 
CASE 
	WHEN Total_EV_stock != 0 AND Total_chargers != 0
	THEN Total_EV_stock / Total_chargers
	ELSE 0
END
AS EVs_chargers_ratio
FROM
(SELECT year, (SUM(FCEV_stock) + SUM(PHEV_stock) + SUM(BEV_stock)) AS Total_EV_stock, (SUM(slow_chargers) + SUM(fast_chargers)) AS Total_chargers
FROM EV_data_long
WHERE region NOT IN('World', 'Europe', 'EU27')
GROUP BY year
) AS cumulated
ORDER BY  year DESC, EVs_chargers_ratio DESC

-- Create views for visualizations
-- Create view for chargers EVs distribution
CREATE VIEW ChargersRatio AS
SELECT year, 
CASE 
	WHEN Total_EV_stock != 0 AND Total_chargers != 0
	THEN Total_EV_stock / Total_chargers
	ELSE 0
END
AS EVs_chargers_ratio
FROM
(SELECT year, (SUM(FCEV_stock) + SUM(PHEV_stock) + SUM(BEV_stock)) AS Total_EV_stock, (SUM(slow_chargers) + SUM(fast_chargers)) AS Total_chargers
FROM EV_data_long
WHERE region NOT IN('World', 'Europe', 'EU27')
GROUP BY year
) AS cumulated

-- Create view for EV types distribution
CREATE VIEW EV_types_distribution AS
SELECT year, 
(FCEV / EV_sales) * 100 AS FCEV_percent, (PHEV / EV_sales) * 100 AS PHEV_percent, (BEV / EV_sales) * 100 AS BEV_percent
FROM (SELECT year, SUM(PHEV_sales) AS  PHEV, SUM(FCEV_sales) AS FCEV, SUM(BEV_sales) AS BEV, (SUM(PHEV_sales) + SUM(FCEV_sales) + SUM(BEV_sales)) AS EV_sales
FROM EV_data_long
GROUP BY year) AS SourceTable
WHERE EV_sales != 0


-- Create view for EV sales by year and percent change
CREATE VIEW EV_sales_change AS
SELECT year, Total_EV_sales, (Total_EV_sales / (LAG(Total_EV_sales, 1, Total_EV_sales) OVER (ORDER BY year ASC)) - 1) * 100 AS Percent_Change
FROM
(SELECT year, SUM(FCEV_sales) AS Total_FCEV_sales, SUM(PHEV_sales) AS Total_PHEV_sales, SUM(BEV_sales) AS Total_BEV_sales, (SUM(PHEV_sales) + SUM(FCEV_sales) + SUM(BEV_sales)) AS Total_EV_sales
FROM EV_data_long
WHERE region NOT IN('World', 'Europe', 'EU27')
GROUP BY year) AS SourceTable
