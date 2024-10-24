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

### Data Source

The two datasets ([EV_sales.csv](https://github.com/diegoislasm/Data_projects/blob/main/EV_sales.csv) and [EV_charging_points.csv](https://github.com/diegoislasm/Data_projects/blob/main/EV_charging_points.csv)) used for this analysis were obtained from IEA (2024), Global EV Data Explorer, IEA, Paris https://www.iea.org/data-and-statistics/data-tools/global-ev-data-explorer.

### Tools

- SQL Server - Data cleaning and analysis
- Tableau - Creating dashboard

### Data Cleaning and Preparation

In this phase  the tasks performed were the following:

1. Data loading and data exploration
2. Data cleaning and formatting
3. handling null values

### Exploratory Data Analysis

In the EDA to analyze the sales data the following questions were answered:

- What is the overall trending sales?
- What is the country with more EV sales?
- What is the country with more EVs?
- What is the most popular type of EV?

## Data Analysis

```sql
CREATE VIEW EV_types_distribution AS
SELECT year, 
(FCEV / EV_sales) * 100 AS FCEV_percent, (PHEV / EV_sales) * 100 AS PHEV_percent, (BEV / EV_sales) * 100 AS BEV_percent
FROM (SELECT year, SUM(PHEV_sales) AS  PHEV, SUM(FCEV_sales) AS FCEV, SUM(BEV_sales) AS BEV, (SUM(PHEV_sales) + SUM(FCEV_sales) + SUM(BEV_sales)) AS EV_sales
FROM EV_data_long
GROUP BY year) AS SourceTable
WHERE EV_sales != 0
```

## Results

The analysis results are summarized as follows:

### Electric Vehicles
- The top 5 countries with highest % of cars being EVs in 2023 were **Norway** (29%), **Iceland** (18%), **Sweden** (11%), **Finland** (8%) and **China** (7%), with a **global average** of 2.97%**
- The top 5 countries with highest percentage of EVs sold of total car sales were **Norway** (93%), **Iceland** (71%), **Sweden** (60%), **Finland** (54%) and **Denmark** (46%), with a **global average** of 18%
- The global EV type sales distribution was 0.1% **FCEV**, 31% **PHEV** and 68.8% **BEV**.
- The countries with the highest EV sales in 2023 are **China** with 8.1 million, **USA** with 1.3 million and **Germany** with 700 thousands.

### Charging stations

- The top 5 countries with more chargers per 100 EVs in 2023 were **South Korea** (36), **Chile** (27), **Netherlands** (21), **Greece** (15) and **China** (12) with the **global average** being 8 chargers.
- Some of the top 10 countries with less chargers per 100 EVs in 2023 include **Norway** (3), **United Kingdom** (3), **Iceland** (4), **United States** (4) and **Germany** (4). 
- The chargers per 100 EV have gone from **23** in 2010 to **10** in 2023.
- The number of EVs and chargers globally have grown at a very similar rate since 2010 through 2023, except between 2019 and 2021 when the number of EVs increased at a higher rate than the chargers.

## Recommendations

Based on the analysis, I recommend the following actions:

Although all around the world the EV adoption has shown a clear upward trend, there are some markets and products that could see a bigger adoption that's why these are the recommendations based on that:

- The EV type to focus on to develop would have to be the preferred type of EV by far is the Battery Electric Vehicle (BEV) having more than half of the market for over 10 years, leaving as the runner up the Plugins Hybrid Electric Vehicles with most of the remaining market (around 30% in the last years) and the Fuel Cell Electric Vehicles (FCEV) with a very small portion of the market with less that 1% due to being a new technology.
- Countries where the EVs are preferred over the ICE (internal combustion engines or gas cars), 

- 

Based on the growth in sales in EVs, the obvious move is to look at the charging stations to recharge this type of vehicles, so 

- Invest
- Focus
- Imolement

- Countries with the highest number of cars but not enough chargers
- Countries with the faster growing number of EVs

## Limitations

Not all countries, only some years for some countries, only one source, outliers of 0.034 charging stations

