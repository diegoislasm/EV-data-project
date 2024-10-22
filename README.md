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

**Top 5 countries with highest % of cars being EVs in 2023:**
1. Norway - **29%**
2. Iceland - **18%**
3. Sweden - **11%**
4. Finland - **8%**
5. China - **7%**

  **Global Average - 2.97%**


**Top 5 countries with highest percentage of EVs sold of total car sales:**
1. Norway - **93%**
2. Iceland - **71%**
3. Sweden - **60%**
4. Finland - **54%**
5. Denmark - **46%**

   **Global Average - 18%**
  
The EV type sales distribution was **0.1%** FCEV, **31%** PHEV and **68.8%** BEV.

The countries with the highest EV sales in 2023 are China with **8.1 million**, USA with **1.3 million** and Germany with **700 thousands**.

1. amae
2. dad
3. 131

## Recommendations

Based on the analysis, I recommend the following actions:
- Invest
- Focus
- Imolement

## Limitations

Not all countries, only some years for some countries, only one source, outliers of 0.034 charging stations

