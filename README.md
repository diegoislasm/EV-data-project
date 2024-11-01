# Electric Vehicles sales analysis

## Table of contents

- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Tools](#tools)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Results](#results)
- [Recommendations](#recommendations)
- [Limitations](#limitations)

## Project Overview 

This project shows important insights of the global EV sales data throughout the years, offering data about sales, current number of EVs per country divided by their types (BEV, HEV, PHEV) and charging stations by country and year. The purpose of this is to provide key information about the best EV type investment, best country to invest in EV or charging stations, based on trends and current metrics.

## Data Source

The two datasets ([EV_sales.csv](https://github.com/diegoislasm/Data_projects/blob/main/EV_sales.csv) and [EV_charging_points.csv](https://github.com/diegoislasm/Data_projects/blob/main/EV_charging_points.csv)) used for this analysis were obtained from IEA (2024), Global EV Data Explorer, IEA, Paris https://www.iea.org/data-and-statistics/data-tools/global-ev-data-explorer.

## Tools

- SQL Server - Data cleaning and analysis
- Tableau - Creating dashboard

## Data Cleaning and Preparation

In this phase the tasks performed were the following:

1. Review datatypes and fix them.
2. Use UNION function to merge both datasets into temp table.
3. Check for null values.
4. Get the unique values for main fields.
5. Fix outliers.
6. Create temp tables to split data.
7. Create a CTE with a distinct value to use it as primary key.
8. Join temp tables using CTE to have a long format dataset.


## Exploratory Data Analysis

As part of the EDA I started by finding facts like the overall trending sales, the country with more EV sales, the country with more EVs, the most popular type of EV and more. To do this a combination of functions like GROUP BY, PARTITION BY, conditions, LAG and subqueries were used.

Here are some examples of the code used: 

```sql
-- Get the cumulative sales of electric vehicles (BEV and PHEV) by country over the years
SELECT region, year, year_sales, SUM(Year_sales) OVER (PARTITION BY region ORDER BY region, year) AS cumulative_sales
FROM (
SELECT region, year, FCEV_sales, PHEV_sales, BEV_sales, (FCEV_sales + PHEV_sales + BEV_sales) Year_sales
FROM EV_data_long) AS SourceTable
ORDER BY region ASC, year ASC
```

```sql
-- Get stock share of EVs by country and year
SELECT region, year, EV_stock_share, (EV_stock_share / NULLIF((LAG(EV_stock_share, 1, EV_stock_share) OVER (PARTITION BY region ORDER BY year ASC)), 0) -1) * 100 AS Percent_change 
FROM EV_data_long
WHERE EV_stock_share > 0
```

```sql
-- Show number of EVs per charging point by country
SELECT *, 
CASE 
	WHEN Total_EV_stock != 0 AND Total_chargers != 0
	THEN Total_EV_stock / Total_chargers 
	ELSE 0
END
AS EVs_chargers_ratio
FROM
(SELECT region, year, (SUM(FCEV_stock) + SUM(PHEV_stock) + SUM(BEV_stock)) AS Total_EV_stock, (SUM(slow_chargers) + SUM(fast_chargers)) AS Total_chargers
FROM EV_data_long
GROUP BY region, year
) AS cumulated_data
WHERE Total_EV_stock != 0 AND Total_chargers != 0
ORDER BY region, year
```

## Data Analysis

To analize the data an interactive Tableau dashboard was created and used to get to the results. The dashboard can be accessed [here](https://public.tableau.com/app/profile/diego.islas/viz/EVproject_17145381333610/EVDashboard2).

## Results

The analysis results are summarized as follows:

### Electric Vehicles
- Top 5 countries with highest % of cars being EVs in 2023 were **Norway** (29%), **Iceland** (18%), **Sweden** (11%), **Finland** (8%) and **China** (7%), with a **global average** of 2.97%**
- Top 5 countries with highest percentage of EVs sold of total car sales were **Norway** (93%), **Iceland** (71%), **Sweden** (60%), **Finland** (54%) and **Denmark** (46%), with a **global average** of 18%
- The global EV type sales distribution was 0.1% **FCEV**, 31% **PHEV** and 68.8% **BEV**.
- Countries with the highest EV sales in 2023 are **China** with 8.1 million, **USA** with 1.3 million and **Germany** with 700 thousands.

### Charging stations

- Top 5 countries with more chargers per 100 EVs in 2023 were **South Korea** (36), **Chile** (27), **Netherlands** (21), **Greece** (15) and **China** (12) with the **global average** being 8 chargers.
- Some of the top 10 countries with less chargers per 100 EVs in 2023 include **Norway** (3), **United Kingdom** (3), **Iceland** (4), **United States** (4) and **Germany** (4). 
- Chargers per 100 EV have gone from **23** in 2010 to **10** in 2023.
- Number of EVs and chargers globally have grown at a very similar rate since 2010 through 2023, except between **2019 and 2021** when the **number of EVs increased** at a higher rate than the chargers.

## Recommendations

Based on the analysis, I recommend the following actions:
Centralize
Concentrate 
Considering the EV adoption these are the markets with where the attention should be put due to the higher chances of success: 

- The EV type developtment priority based on the market size should follow this order:
  1. **Battery Electric Vehicle (BEV)** having **more than half of the market** for over 10 years.
  2. **Plugins Hybrid Electric Vehicles PHEV** with most of the remaining market (**around 30%** in the last years).
  3. **Fuel Cell Electric Vehicles (FCEV)** with a very small portion of the market with **less that 1%** due to being a new technology.
- Invest in countries where **EVs** are preferred over the **ICE (Internal Combustion Engines or gas cars)** which are **Norway, Iceland, Sweden, Finland, Denmark, Belgium and China.**
- Focus on the giant markets of **United States** and **China**, given that despite the USA having **only 10%** of EV adoption in 2023, the States were the **second country** with the highest EV sales in that same year, while **China was first place**. 

Given that with a higher EV market a charging station network is needed these are the recomendations for that:


- Based on the global trend of chargers per 100 EV ratio, the EVs have been produced at a higher speed compared to the number of chargers to satisfy the demand, considering that after 2010 when the ratio was **20 chargers per 100 EV**, the number of chargers have decreased gradually to only **10 chargers per 100 EV** in 2023, showing unsatisfied demand.
- Invest in charging networks in countries with low number of chargers per EV but with a high adoption of EVs, like **New Zealand, Norway, Iceland, USA and Germany** where the chargers per 100 EV ratio is below 5, (being 8 the average).


## Limitations

- The dataset used only included data from 51 countries and covered from 2010 to 2023.
- There were outliers with 0.034 in charging stations that were fixed with zeros.
- The charging stations were divided in slow chargers and fast chargers in the data source but they were joined to simplify the results of this project.

