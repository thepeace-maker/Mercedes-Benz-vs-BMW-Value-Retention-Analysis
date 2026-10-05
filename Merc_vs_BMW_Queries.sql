--01_create_view.sql: one table to query

CREATE OR ALTER VIEW dbo.cars AS
SELECT 'BMW' AS brand, LTRIM(RTRIM(model)) AS model, year, price,
       LTRIM(RTRIM(transmission)) AS transmission, mileage,
       LTRIM(RTRIM(fuelType)) AS fuel_type, tax, mpg, engineSize AS engine_size
FROM dbo.bmw
UNION ALL
SELECT 'Mercedes', LTRIM(RTRIM(model)), year, price,
       LTRIM(RTRIM(transmission)), mileage,
       LTRIM(RTRIM(fuelType)), tax, mpg, engineSize
FROM dbo.Mercedes
UNION ALL
SELECT 'Toyota', LTRIM(RTRIM(model)), year, price,
       LTRIM(RTRIM(transmission)), mileage,
       LTRIM(RTRIM(fuelType)), tax, mpg, engineSize
FROM dbo.toyota;

--02_data_quality.sql: check before you analyze

-- Row counts, nulls, and suspicious values per brand
SELECT brand,
       COUNT(*) AS rows_total,
       SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
       SUM(CASE WHEN engine_size = 0 THEN 1 ELSE 0 END) AS zero_engine,
       SUM(CASE WHEN mpg = 0 THEN 1 ELSE 0 END) AS zero_mpg,
       MIN(year) AS min_year, MAX(year) AS max_year,
       MIN(price) AS min_price, MAX(price) AS max_price
FROM dbo.cars
GROUP BY brand;

-- Exact duplicate listings
SELECT brand, model, year, price, mileage, fuel_type, COUNT(*) AS copies
FROM dbo.cars
GROUP BY brand, model, year, price, mileage, fuel_type, engine_size
HAVING COUNT(*) > 1;

--03_brand_overview.sql: Benz vs BMW headline

SELECT brand,
       COUNT(*) AS listings,
       AVG(price) AS avg_price,
       AVG(mileage) AS avg_mileage,
       AVG(NULLIF(mpg,0)) AS avg_mpg,
       AVG(tax) AS avg_tax
FROM dbo.cars
WHERE brand IN ('BMW','Mercedes')
GROUP BY brand;

--04_depreciation.sql: price by age (your showcase query)

WITH base AS (
    SELECT brand, price,
           (SELECT MAX(year) FROM dbo.cars) - year AS age
    FROM dbo.cars
    WHERE brand IN ('BMW','Mercedes')
),
by_age AS (
    SELECT brand, age, AVG(price) AS avg_price, COUNT(*) AS n
    FROM base
    WHERE age BETWEEN 0 AND 10
    GROUP BY brand, age
)
SELECT brand, age, avg_price, n,
       ROUND(100.0 * avg_price /
             FIRST_VALUE(avg_price) OVER (PARTITION BY brand ORDER BY age), 1)
             AS pct_of_newest_price
FROM by_age
ORDER BY brand, age;

--05_fuel_mix.sql: window function for share

SELECT brand, fuel_type, COUNT(*) AS listings,
       ROUND(100.0 * COUNT(*) /
             SUM(COUNT(*)) OVER (PARTITION BY brand), 1) AS pct_of_brand
FROM dbo.cars
WHERE brand IN ('BMW','Mercedes')
GROUP BY brand, fuel_type
ORDER BY brand, listings DESC;

--06_value_retention_by_model.sql: which models hold value

WITH latest AS (
    SELECT MAX(year) AS max_year FROM dbo.cars
),
m AS (
    SELECT c.brand, c.model,
           AVG(CASE WHEN c.year >= l.max_year - 1 THEN c.price END) AS avg_new,
           AVG(CASE WHEN c.year BETWEEN l.max_year - 6 AND l.max_year - 4
                    THEN c.price END) AS avg_5yr,
           COUNT(*) AS n
    FROM dbo.cars c
    CROSS JOIN latest l
    WHERE c.brand IN ('BMW','Mercedes')
    GROUP BY c.brand, c.model
    HAVING COUNT(*) >= 100
)
SELECT brand, model, n, avg_new, avg_5yr,
       ROUND(100.0 * avg_5yr / avg_new, 1) AS retained_pct
FROM m
WHERE avg_new IS NOT NULL AND avg_5yr IS NOT NULL
ORDER BY retained_pct DESC;