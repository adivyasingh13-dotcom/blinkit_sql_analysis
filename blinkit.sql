/* ============================================================
   BLINKIT GROCERY SALES — SQL DATA ANALYSIS PROJECT
   Database: SQLite
   Tool: DB Browser for SQLite

   Project Sections:
   1. Database Setup
   2. Data Understanding
   3. Data Quality Checks
   4. Data Cleaning
   5. KPI Analysis
   6. Product Analysis
   7. Outlet Analysis
   8. Pricing Analysis
   9. Visibility Analysis
   10. Advanced SQL
   11. Business Analysis
   12. SQL Views
   13. Query Optimization
   ============================================================ */


/* ============================================================
   PHASE 0 — DATABASE SETUP
   ============================================================ */

-- Create the Blinkit table structure.
-- Import the dataset into this table using DB Browser for SQLite.

DROP TABLE IF EXISTS blinkit;

CREATE TABLE blinkit (
    Item_Identifier TEXT,
    Item_Weight TEXT,
    Item_Fat_Content TEXT,
    Item_Visibility REAL,
    Item_Type TEXT,
    Item_MRP REAL,
    Outlet_Identifier TEXT,
    Outlet_Establishment_Year INTEGER,
    Outlet_Size TEXT,
    Outlet_Location_Type TEXT,
    Outlet_Type TEXT,
    Item_Outlet_Sales REAL
);


/* ============================================================
   PHASE 1 — DATA UNDERSTANDING
   ============================================================ */

-- STEP 1: Check the structure of the table.

PRAGMA table_info(blinkit);


-- STEP 2: Count total records.

SELECT COUNT(*) AS total_records
FROM blinkit;


-- STEP 3: View a sample of the data.

SELECT *
FROM blinkit
LIMIT 10;


-- STEP 4: Check unique fat-content values.

SELECT DISTINCT Item_Fat_Content
FROM blinkit
ORDER BY Item_Fat_Content;


-- STEP 5: Check unique product categories.

SELECT DISTINCT Item_Type
FROM blinkit
ORDER BY Item_Type;


-- STEP 6: Check outlet sizes.

SELECT DISTINCT Outlet_Size
FROM blinkit;


-- STEP 7: Check missing outlet sizes.

SELECT COUNT(*) AS missing_outlet_size
FROM blinkit
WHERE Outlet_Size IS NULL
   OR TRIM(Outlet_Size) = '';


-- STEP 8: Check outlet location types.

SELECT DISTINCT Outlet_Location_Type
FROM blinkit
ORDER BY Outlet_Location_Type;


-- STEP 9: Check outlet types.

SELECT DISTINCT Outlet_Type
FROM blinkit
ORDER BY Outlet_Type;


-- STEP 10: Check outlet establishment years.

SELECT DISTINCT Outlet_Establishment_Year
FROM blinkit
ORDER BY Outlet_Establishment_Year;


-- STEP 11: Check missing item weights.

SELECT COUNT(*) AS missing_item_weight
FROM blinkit
WHERE Item_Weight IS NULL
   OR TRIM(Item_Weight) = '';


-- STEP 12: Count zero-visibility records.

SELECT COUNT(*) AS zero_visibility
FROM blinkit
WHERE Item_Visibility = 0;


-- STEP 13: Check missing MRP values.

SELECT COUNT(*) AS missing_mrp
FROM blinkit
WHERE Item_MRP IS NULL;


-- STEP 14: Check invalid MRP values.

SELECT COUNT(*) AS invalid_mrp
FROM blinkit
WHERE Item_MRP <= 0;


-- STEP 15: Check missing sales values.

SELECT COUNT(*) AS missing_sales
FROM blinkit
WHERE Item_Outlet_Sales IS NULL;


-- STEP 16: Check negative sales.

SELECT COUNT(*) AS invalid_sales
FROM blinkit
WHERE Item_Outlet_Sales < 0;


-- STEP 17: Check item-weight values.

SELECT Item_Weight
FROM blinkit
LIMIT 20;


-- STEP 18: Check visibility values.

SELECT Item_Visibility
FROM blinkit
LIMIT 20;


-- STEP 19: Find minimum and maximum visibility.

SELECT
    MIN(Item_Visibility) AS minimum_visibility,
    MAX(Item_Visibility) AS maximum_visibility
FROM blinkit;


-- STEP 20: Find minimum and maximum MRP.

SELECT
    MIN(Item_MRP) AS minimum_mrp,
    MAX(Item_MRP) AS maximum_mrp
FROM blinkit;


-- STEP 21: Find minimum and maximum sales.

SELECT
    MIN(Item_Outlet_Sales) AS minimum_sales,
    MAX(Item_Outlet_Sales) AS maximum_sales
FROM blinkit;


/* ============================================================
   PHASE 1 — DUPLICATE CHECKS
   ============================================================ */

-- Check for repeated Product + Outlet combinations.

SELECT
    Item_Identifier,
    Outlet_Identifier,
    COUNT(*) AS occurrence_count
FROM blinkit
GROUP BY
    Item_Identifier,
    Outlet_Identifier
HAVING COUNT(*) > 1
LIMIT 10;


/* ============================================================
   PHASE 2 — DATA CLEANING
   ============================================================ */


/* ------------------------------------------------------------
   STEP 1 — STANDARDIZE FAT CONTENT
   ------------------------------------------------------------ */

-- Check current labels.

SELECT
    Item_Fat_Content,
    COUNT(*) AS record_count
FROM blinkit
GROUP BY Item_Fat_Content
ORDER BY record_count DESC;


-- Standardize Low Fat labels.

UPDATE blinkit
SET Item_Fat_Content = 'Low Fat'
WHERE Item_Fat_Content IN ('Low Fat', 'low fat', 'LF');


-- Standardize Regular labels.

UPDATE blinkit
SET Item_Fat_Content = 'Regular'
WHERE Item_Fat_Content = 'reg';


-- Verify the cleaned values.

SELECT DISTINCT Item_Fat_Content
FROM blinkit
ORDER BY Item_Fat_Content;


/* ------------------------------------------------------------
   STEP 2 — HANDLE MISSING ITEM WEIGHT
   ------------------------------------------------------------ */

-- Check missing weights.

SELECT COUNT(*) AS missing_item_weight
FROM blinkit
WHERE Item_Weight IS NULL
   OR TRIM(Item_Weight) = '';


-- Find products with missing weights but known weights elsewhere.

SELECT
    Item_Identifier,
    COUNT(*) AS total_records,
    COUNT(Item_Weight) AS known_weights
FROM blinkit
GROUP BY Item_Identifier
HAVING COUNT(*) > COUNT(Item_Weight)
LIMIT 10;


-- Find products where all weights are missing.

SELECT
    Item_Identifier,
    COUNT(*) AS total_records
FROM blinkit
GROUP BY Item_Identifier
HAVING COUNT(Item_Weight) = 0;


-- Fill missing weights using the known weight
-- of the same product.

UPDATE blinkit
SET Item_Weight = (
    SELECT MAX(Item_Weight)
    FROM blinkit AS b2
    WHERE b2.Item_Identifier = blinkit.Item_Identifier
      AND b2.Item_Weight IS NOT NULL
)
WHERE Item_Weight IS NULL;


-- Verify remaining missing weights.

SELECT COUNT(*) AS remaining_missing_weights
FROM blinkit
WHERE Item_Weight IS NULL
   OR TRIM(Item_Weight) = '';


/* ------------------------------------------------------------
   STEP 3 — OUTLET SIZE INVESTIGATION
   ------------------------------------------------------------ */

-- Check outlet-size distribution.

SELECT
    Outlet_Size,
    COUNT(*) AS record_count
FROM blinkit
GROUP BY Outlet_Size
ORDER BY record_count DESC;


-- Check known size for each outlet.

SELECT
    Outlet_Identifier,
    MAX(Outlet_Size) AS outlet_size
FROM blinkit
WHERE Outlet_Size IS NOT NULL
GROUP BY Outlet_Identifier;


-- Find outlets where size is completely missing.

SELECT
    Outlet_Identifier,
    COUNT(*) AS total_records
FROM blinkit
GROUP BY Outlet_Identifier
HAVING COUNT(Outlet_Size) = 0;


-- Inspect outlets with completely missing size.

SELECT DISTINCT
    Outlet_Identifier,
    Outlet_Type,
    Outlet_Location_Type
FROM blinkit
WHERE Outlet_Identifier IN
      ('OUT010', 'OUT017', 'OUT045');


/*
   Decision:
   Outlet_Size values that cannot be reliably determined
   are kept as NULL rather than guessing.
*/


-- Verify remaining missing outlet sizes.

SELECT COUNT(*) AS missing_outlet_size
FROM blinkit
WHERE Outlet_Size IS NULL
   OR TRIM(Outlet_Size) = '';


/* ------------------------------------------------------------
   STEP 4 — ITEM VISIBILITY INVESTIGATION
   ------------------------------------------------------------ */

-- Look at zero-visibility products.

SELECT
    Item_Identifier,
    Item_Type,
    Item_Visibility,
    Item_Outlet_Sales
FROM blinkit
WHERE Item_Visibility = 0
LIMIT 10;


-- Check products having both zero and positive visibility.

SELECT
    Item_Identifier,
    MIN(Item_Visibility) AS minimum_visibility,
    MAX(Item_Visibility) AS maximum_visibility
FROM blinkit
GROUP BY Item_Identifier
HAVING MIN(Item_Visibility) = 0
   AND MAX(Item_Visibility) > 0
LIMIT 10;


-- Count zero visibility by outlet type.

SELECT
    Outlet_Type,
    COUNT(*) AS zero_visibility_count
FROM blinkit
WHERE Item_Visibility = 0
GROUP BY Outlet_Type
ORDER BY zero_visibility_count DESC;


-- Check for negative visibility.

SELECT COUNT(*) AS negative_visibility
FROM blinkit
WHERE Item_Visibility < 0;


/* ============================================================
   PHASE 2 — CLEANING VERIFICATION
   ============================================================ */

SELECT COUNT(*) AS total_records_after_cleaning
FROM blinkit;


/* ============================================================
   PHASE 3 — CORE KPIs
   ============================================================ */

-- KPI 1: Total Sales.

SELECT
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit;


-- KPI 2: Average Sales per Record.

SELECT
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit;


-- KPI 3: Total Records.

SELECT
    COUNT(*) AS total_records
FROM blinkit;


/* ============================================================
   PHASE 4 — PRODUCT ANALYSIS
   ============================================================ */

-- Q1: Sales by Fat Content.

SELECT
    Item_Fat_Content,
    COUNT(*) AS item_count,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Item_Fat_Content
ORDER BY total_sales DESC;


-- Q2: Which product categories generate the most revenue?

SELECT
    Item_Type,
    COUNT(*) AS item_count,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit
GROUP BY Item_Type
ORDER BY total_sales DESC;


-- Q3: Category contribution to total sales.

SELECT
    Item_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(
        SUM(Item_Outlet_Sales) * 100.0 /
        (SELECT SUM(Item_Outlet_Sales)
         FROM blinkit),
        2
    ) AS sales_percentage
FROM blinkit
GROUP BY Item_Type
ORDER BY total_sales DESC;


-- Q4: Top 10 individual products by total sales.

SELECT
    Item_Identifier,
    Item_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit
GROUP BY Item_Identifier, Item_Type
ORDER BY total_sales DESC
LIMIT 10;


-- Q5: Average sales by product category.

SELECT
    Item_Type,
    COUNT(*) AS item_count,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Item_Type
ORDER BY avg_sales DESC;


/* ============================================================
   PHASE 5 — OUTLET ANALYSIS
   ============================================================ */

-- Q6: Sales performance by outlet size.

SELECT
    Outlet_Size,
    COUNT(*) AS item_count,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Outlet_Size
ORDER BY total_sales DESC;


-- Q7: Which location tier performs best?

SELECT
    Outlet_Location_Type,
    COUNT(*) AS item_count,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Outlet_Location_Type
ORDER BY total_sales DESC;


-- Q8: Sales by outlet type.

SELECT
    Outlet_Type,
    COUNT(*) AS item_count,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Outlet_Type
ORDER BY total_sales DESC;


-- Q9: Outlet type + location combination.

SELECT
    Outlet_Type,
    Outlet_Location_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit
GROUP BY Outlet_Type, Outlet_Location_Type
ORDER BY total_sales DESC
LIMIT 10;


-- Q10: Top individual outlets by total sales.

SELECT
    Outlet_Identifier,
    Outlet_Type,
    Outlet_Location_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit
GROUP BY Outlet_Identifier
ORDER BY total_sales DESC
LIMIT 10;


-- Q11: Top individual outlets by average sales.

SELECT
    Outlet_Identifier,
    Outlet_Type,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Outlet_Identifier
ORDER BY avg_sales DESC
LIMIT 10;


/* ============================================================
   PHASE 6 — PRICING ANALYSIS
   ============================================================ */

-- Q12: Total sales by MRP range.

SELECT
    CASE
        WHEN Item_MRP < 50 THEN 'Under 50'
        WHEN Item_MRP <= 100 THEN '50-100'
        WHEN Item_MRP <= 200 THEN '100-200'
        ELSE '200+'
    END AS price_range,

    COUNT(*) AS item_count,

    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales

FROM blinkit

GROUP BY price_range

ORDER BY total_sales DESC;


-- Q13: Average sales by MRP range.

SELECT
    CASE
        WHEN Item_MRP < 50 THEN 'Under 50'
        WHEN Item_MRP <= 100 THEN '50-100'
        WHEN Item_MRP <= 200 THEN '100-200'
        ELSE '200+'
    END AS price_range,

    COUNT(*) AS item_count,

    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales

FROM blinkit

GROUP BY price_range

ORDER BY avg_sales DESC;


/* ============================================================
   PHASE 7 — VISIBILITY ANALYSIS
   ============================================================ */

-- Q14: Average visibility and average sales by category.

SELECT
    Item_Type,
    ROUND(AVG(Item_Visibility), 4) AS avg_visibility,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Item_Type
ORDER BY avg_visibility DESC;


-- Q15: Compare sales across visibility groups.

SELECT
    CASE
        WHEN Item_Visibility = 0 THEN 'Zero Visibility'
        WHEN Item_Visibility < 0.05 THEN 'Low Visibility'
        WHEN Item_Visibility < 0.10 THEN 'Medium Visibility'
        ELSE 'High Visibility'
    END AS visibility_group,

    COUNT(*) AS item_count,

    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales

FROM blinkit

GROUP BY visibility_group

ORDER BY avg_sales DESC;


-- Q16: High-selling products with low visibility.

SELECT
    Item_Identifier,
    Item_Type,
    ROUND(Item_Visibility, 4) AS visibility,
    ROUND(Item_Outlet_Sales, 2) AS sales
FROM blinkit
WHERE Item_Visibility < 0.05
ORDER BY Item_Outlet_Sales DESC
LIMIT 10;


/* ============================================================
   PHASE 8 — OUTLET ESTABLISHMENT ANALYSIS
   ============================================================ */

-- Q17: Sales by outlet establishment year.

SELECT
    Outlet_Establishment_Year,
    COUNT(*) AS item_count,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year;


/* ============================================================
   PHASE 9 — CATEGORY + OUTLET ANALYSIS
   ============================================================ */

-- Q18: Product category performance by outlet type.

SELECT
    Outlet_Type,
    Item_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit
GROUP BY Outlet_Type, Item_Type
ORDER BY Outlet_Type, total_sales DESC;


/* ============================================================
   PHASE 10 — ADVANCED SQL
   WINDOW FUNCTIONS
   ============================================================ */


/* ------------------------------------------------------------
   Q19 — RANK()
   Top-selling product in every category
   ------------------------------------------------------------ */

SELECT
    Item_Type,
    Item_Identifier,
    ROUND(total_sales, 2) AS total_sales
FROM (
    SELECT
        Item_Type,
        Item_Identifier,
        SUM(Item_Outlet_Sales) AS total_sales,

        RANK() OVER (
            PARTITION BY Item_Type
            ORDER BY SUM(Item_Outlet_Sales) DESC
        ) AS sales_rank

    FROM blinkit

    GROUP BY Item_Type, Item_Identifier
)

WHERE sales_rank = 1

ORDER BY total_sales DESC;


/* ------------------------------------------------------------
   Q20 — DENSE_RANK()
   Top 3 products in every category
   ------------------------------------------------------------ */

SELECT
    Item_Type,
    Item_Identifier,
    ROUND(total_sales, 2) AS total_sales,
    sales_rank
FROM (
    SELECT
        Item_Type,
        Item_Identifier,
        SUM(Item_Outlet_Sales) AS total_sales,

        DENSE_RANK() OVER (
            PARTITION BY Item_Type
            ORDER BY SUM(Item_Outlet_Sales) DESC
        ) AS sales_rank

    FROM blinkit

    GROUP BY Item_Type, Item_Identifier
)

WHERE sales_rank <= 3

ORDER BY Item_Type, sales_rank;


/* ------------------------------------------------------------
   Q21 — ROW_NUMBER()
   One highest-selling product per category
   ------------------------------------------------------------ */

SELECT
    Item_Type,
    Item_Identifier,
    ROUND(total_sales, 2) AS total_sales
FROM (
    SELECT
        Item_Type,
        Item_Identifier,
        SUM(Item_Outlet_Sales) AS total_sales,

        ROW_NUMBER() OVER (
            PARTITION BY Item_Type
            ORDER BY SUM(Item_Outlet_Sales) DESC
        ) AS row_num

    FROM blinkit

    GROUP BY Item_Type, Item_Identifier
)

WHERE row_num = 1

ORDER BY total_sales DESC;


/* ============================================================
   PHASE 11 — CTE ANALYSIS
   ============================================================ */


/* ------------------------------------------------------------
   Q22 — Categories above average category sales
   ------------------------------------------------------------ */

WITH category_sales AS (

    SELECT
        Item_Type,
        SUM(Item_Outlet_Sales) AS total_sales
    FROM blinkit
    GROUP BY Item_Type

)

SELECT
    Item_Type,
    ROUND(total_sales, 2) AS total_sales

FROM category_sales

WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM category_sales
)

ORDER BY total_sales DESC;


/* ------------------------------------------------------------
   Q23 — Outlets above average outlet sales
   ------------------------------------------------------------ */

WITH outlet_sales AS (

    SELECT
        Outlet_Identifier,
        SUM(Item_Outlet_Sales) AS total_sales
    FROM blinkit
    GROUP BY Outlet_Identifier

)

SELECT
    Outlet_Identifier,
    ROUND(total_sales, 2) AS total_sales

FROM outlet_sales

WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM outlet_sales
)

ORDER BY total_sales DESC;


/* ============================================================
   PHASE 12 — BUSINESS ANALYSIS
   ============================================================ */


/* ------------------------------------------------------------
   Q24 — Best category for each outlet type
   ------------------------------------------------------------ */

WITH category_sales AS (

    SELECT
        Outlet_Type,
        Item_Type,
        SUM(Item_Outlet_Sales) AS total_sales
    FROM blinkit
    GROUP BY Outlet_Type, Item_Type

),

ranked_categories AS (

    SELECT
        Outlet_Type,
        Item_Type,
        total_sales,

        ROW_NUMBER() OVER (
            PARTITION BY Outlet_Type
            ORDER BY total_sales DESC
        ) AS row_num

    FROM category_sales

)

SELECT
    Outlet_Type,
    Item_Type,
    ROUND(total_sales, 2) AS total_sales

FROM ranked_categories

WHERE row_num = 1

ORDER BY total_sales DESC;


/* ============================================================
   PHASE 13 — SQL VIEWS
   ============================================================ */


/* ------------------------------------------------------------
   VIEW 1 — Main Sales KPIs
   ------------------------------------------------------------ */

DROP VIEW IF EXISTS sales_kpis;

CREATE VIEW sales_kpis AS

SELECT
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales,
    COUNT(*) AS total_records

FROM blinkit;


/* Check the KPI view */

SELECT *
FROM sales_kpis;


/* ------------------------------------------------------------
   VIEW 2 — Product Sales Summary
   ------------------------------------------------------------ */

DROP VIEW IF EXISTS product_sales_summary;

CREATE VIEW product_sales_summary AS

SELECT
    Item_Type,
    COUNT(*) AS item_count,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales

FROM blinkit

GROUP BY Item_Type;


/* Check product summary */

SELECT *
FROM product_sales_summary

ORDER BY total_sales DESC;


/* ------------------------------------------------------------
   VIEW 3 — Outlet Performance
   ------------------------------------------------------------ */

DROP VIEW IF EXISTS outlet_performance;

CREATE VIEW outlet_performance AS

SELECT
    Outlet_Identifier,
    Outlet_Type,
    Outlet_Location_Type,
    COUNT(*) AS item_count,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales

FROM blinkit

GROUP BY Outlet_Identifier;


/* Check outlet performance */

SELECT *
FROM outlet_performance

ORDER BY total_sales DESC;


/* ------------------------------------------------------------
   VIEW 4 — Top Product by Category
   ------------------------------------------------------------ */

DROP VIEW IF EXISTS top_product_by_category;

CREATE VIEW top_product_by_category AS

SELECT
    Item_Type,
    Item_Identifier,
    ROUND(total_sales, 2) AS total_sales

FROM (

    SELECT
        Item_Type,
        Item_Identifier,
        SUM(Item_Outlet_Sales) AS total_sales,

        ROW_NUMBER() OVER (
            PARTITION BY Item_Type
            ORDER BY SUM(Item_Outlet_Sales) DESC
        ) AS row_num

    FROM blinkit

    GROUP BY Item_Type, Item_Identifier

)

WHERE row_num = 1;


/* Check top products */

SELECT *
FROM top_product_by_category

ORDER BY total_sales DESC;


/* ============================================================
   PHASE 14 — QUERY OPTIMIZATION
   ============================================================ */


/* Check how SQLite executes the query */

EXPLAIN QUERY PLAN

SELECT *
FROM blinkit

WHERE Item_Type = 'Dairy';


/* Create an index to help searches by Item_Type */

CREATE INDEX IF NOT EXISTS idx_item_type
ON blinkit(Item_Type);


/* Check the query plan again */

EXPLAIN QUERY PLAN

SELECT *
FROM blinkit

WHERE Item_Type = 'Dairy';


/* ============================================================
   PROJECT COMPLETION CHECK
   ============================================================ */

-- Final record count

SELECT COUNT(*) AS final_record_count
FROM blinkit;


-- Final total sales

SELECT
    ROUND(SUM(Item_Outlet_Sales), 2) AS final_total_sales
FROM blinkit;


-- Final average sales

SELECT
    ROUND(AVG(Item_Outlet_Sales), 2) AS final_average_sales
FROM blinkit;


-- Final fat-content categories

SELECT DISTINCT Item_Fat_Content
FROM blinkit
ORDER BY Item_Fat_Content;


/* ============================================================
   END OF BLINKIT SQL ANALYSIS PROJECT
   ============================================================ */