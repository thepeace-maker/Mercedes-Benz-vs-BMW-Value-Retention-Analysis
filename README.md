# Mercedes-Benz vs BMW: Value Retention Analysis 🚗

## Project Overview

This repository hosts the Power BI Desktop file (`MercVsBMW.pbix`) and SQL Server queries (`Merc_vs_BMW_Queries.sql`) for an analysis of UK used-car listings, comparing **Mercedes-Benz** and **BMW** on price, mileage and how well each brand holds its value as cars age.

---

## 🔑 Headline Finding

**Mercedes-Benz holds more of its value than BMW in years 2 to 5, and in all six segments that had enough data to compare.**

- At age 2, Mercedes listings average **72.6%** of the nearly-new price, against **64.2%** for BMW.
- BMW's steepest drop comes in year 2 (about 23 points from age 1 to age 2). Mercedes loses about 16 points over the same year.
- The gap is biggest in SUVs: the GLC keeps **63.1%** vs **49.5%** for the X3, and the GLA keeps **70.7%** vs **59.8%** for the X1.
- The Executive segment is close (E Class **49.8%** vs 5 Series **46.9%**), so treat it as "slightly ahead".

| Segment | BMW | Mercedes-Benz | Mercedes advantage |
|---|---|---|---|
| Small SUV (X1 / GLA) | 59.8% | 70.7% | +10.9 pts |
| Mid SUV (X3 / GLC) | 49.5% | 63.1% | +13.6 pts |
| Large SUV (X5 / GLE) | 53.0% | 55.7% | +2.7 pts |
| Compact hatch (1 Series / A Class) | 54.1% | 56.0% | +1.9 pts |
| Compact exec (3 Series / C Class) | 49.1% | 56.7% | +7.6 pts |
| Executive (5 Series / E Class) | 46.9% | 49.8% | +2.9 pts |

*Value retained = average listing price of cars aged 4-6 years ÷ average listing price of nearly-new cars (age 0-1), by model.*

### Market snapshot (cars aged 0-10 years)

| | Mercedes-Benz | BMW |
|---|---|---|
| Listings | 12,998 | 10,660 |
| Average price | 24,875 | 22,923 |
| Average mileage | 21,391 | 24,792 |

Mpg and road tax are almost identical across the two brands, so running costs don't explain the gap.

---

## 🧩 Key Features

📉 Value-retention curve by car age

🚘 Rival-model comparison across six segments

💷 Price, mileage and listing KPIs by brand

🔍 Slicers for fuel type, transmission and model

---

## 🗂️ Data

- **Source:** "100,000 UK Used Car Data Set" on Kaggle (by adityadesai13), files `bmw.csv` and `merc.csv`.
- **Contents:** scraped UK used-car listings with model, year, price, transmission, mileage, fuel type, road tax, mpg and engine size.
- **Currency:** UK listings, so prices are presumably in pounds.

---

### 🛠️ Tools Used

- SQL Server (SSMS): data cleaning and analysis
- Power BI Desktop
- DAX (Measures & Calculations)
- Power Query (loading and shaping)

### SQL Highlights (`Merc_vs_BMW_Queries.sql`)

| Section | Purpose |
|---|---|
| 01 Create view | Combines the brand tables into one view and trims stray spaces from text fields |
| 02 Data quality | Checks row counts, nulls, zero values and duplicates |
| 03 Brand overview | Listings, average price, mileage, mpg and tax by brand |
| 04 Depreciation | Average price by car age as a percentage of the newest cars' price (CTEs, window functions) |
| 05 Fuel mix | Fuel-type share of listings by brand |
| 06 Value retention by model | Nearly-new vs 4-6-year-old prices by model |

### Data Model Highlights (DAX)

- `Age = CALCULATE(MAX(cars[year]), ALL(cars)) - cars[year]`
- `Pct of Newest Price`: average price at an age ÷ average price of the newest cars, shown only where an age/brand group has at least 100 listings.
- `Retention 5yr vs New`: average price at ages 4-6 ÷ average price at ages 0-1, shown only where both groups have at least 30 listings.
- `Segment`: calculated column pairing each BMW model with its direct Mercedes rival.

Page filters: brand is BMW or Mercedes; car age is 0 to 10 years.

---

## ⚠️ Limitations

1. **Listings, not sales.** The data shows UK asking prices at a point in time, not what buyers paid or which brand sells more.
2. **Retention is not true depreciation.** It compares different cars at different ages, not one car tracked over time. Redesigns and model mix can move the numbers.
3. **Thin data at older ages.** Ages 8 to 10 have small samples, so conclusions rest on ages 1 to 5.
4. **Segment pairs are my judgment.** The 7 Series / S Class pair is excluded because the 7 Series has too few listings (106) to compare reliably.
5. **Age window.** Cars older than 10 years are excluded, so dashboard counts are slightly lower than the raw file counts.

---

## 🚀 Getting Started

To view and interact with the Power BI file:

1. **Download** the `MercVsBMW.pbix` file from this repository.
2. **Install** [Power BI Desktop](https://powerbi.microsoft.com/desktop/).
3. **Open** the file in Power BI Desktop.

To rerun the SQL:

1. Download the CSVs from the Kaggle dataset linked above.
2. Import `bmw.csv` and `merc.csv` into SQL Server (use `int` for price, mileage and tax, since `smallint` overflows on prices above 32,767).
3. Run `Merc_vs_BMW_Queries.sql` from top to bottom.

---
