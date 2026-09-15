-- PHASE 1 — STEP 1
-- Check the structure of the Blinkit table

PRAGMA table_info(blinkit);

-- PHASE 1 — STEP 2
-- Count the total number of records in the Blinkit dataset.

SELECT COUNT(*) AS total_records
FROM blinkit;

-- PHASE 1 — STEP 3A
-- Look at a small sample of the actual Blinkit data.

SELECT *
FROM blinkit
LIMIT 10;


-- PHASE 1 — STEP 3B
-- Find all unique values in Item_Fat_Content.

SELECT DISTINCT Item_Fat_Content
FROM blinkit;


-- PHASE 1 — STEP 3C
-- Find all unique product categories.

SELECT DISTINCT Item_Type
FROM blinkit
ORDER BY Item_Type;


-- PHASE 1 — STEP 3D
-- Check the different outlet sizes.

SELECT DISTINCT Outlet_Size
FROM blinkit;

-- PHASE 1 — STEP 3D.1
-- Count records where Outlet_Size is missing.

SELECT COUNT(*) AS missing_outlet_size
FROM blinkit
WHERE Outlet_Size IS NULL
   OR TRIM(Outlet_Size) = '';
   
   
-- PHASE 1 — STEP 3E
-- Check the unique outlet location types.

SELECT DISTINCT Outlet_Location_Type
FROM blinkit
ORDER BY Outlet_Location_Type;   


-- PHASE 1 — STEP 3F
-- Find all unique outlet types.

SELECT DISTINCT Outlet_Type
FROM blinkit
ORDER BY Outlet_Type;



-- PHASE 1 — STEP 3G
-- Find all outlet establishment years.

SELECT DISTINCT Outlet_Establishment_Year
FROM blinkit
ORDER BY Outlet_Establishment_Year;


-- PHASE 1 — STEP 3H
-- Check how many Item_Weight values are missing.

SELECT COUNT(*) AS missing_item_weight
FROM blinkit
WHERE Item_Weight IS NULL
   OR TRIM(Item_Weight) = '';
   
   
-- PHASE 1 — STEP 3I
-- Count products with zero item visibility.

SELECT COUNT(*) AS zero_visibility
FROM blinkit
WHERE Item_Visibility = 0;   



-- PHASE 1 — STEP 3J
-- Check whether Item_MRP has missing values.

SELECT COUNT(*) AS missing_mrp
FROM blinkit
WHERE Item_MRP IS NULL;




-- PHASE 1 — STEP 3J.1
-- Find MRP values that are zero or negative.

SELECT COUNT(*) AS invalid_mrp
FROM blinkit
WHERE Item_MRP <= 0;


-- PHASE 1 — STEP 3K.1
-- Check whether any sales values are missing.

SELECT COUNT(*) AS missing_sales
FROM blinkit
WHERE Item_Outlet_Sales IS NULL;

-- PHASE 1 — STEP 3K.2
-- Check for negative sales values.

SELECT COUNT(*) AS invalid_sales
FROM blinkit
WHERE Item_Outlet_Sales < 0;


-- PHASE 1 — STEP 3L
-- Show some Item_Weight values so we can inspect them.

SELECT Item_Weight
FROM blinkit
LIMIT 20;



-- PHASE 1 — STEP 3M
-- Look at some Item_Visibility values.

SELECT Item_Visibility
FROM blinkit
LIMIT 20;


-- PHASE 1 — STEP 3M.1
-- Find the minimum and maximum item visibility.

SELECT
    MIN(Item_Visibility) AS minimum_visibility,
    MAX(Item_Visibility) AS maximum_visibility
FROM blinkit;


-- PHASE 1 — STEP 3N
-- Find the minimum and maximum MRP.

SELECT
    MIN(Item_MRP) AS minimum_mrp,
    MAX(Item_MRP) AS maximum_mrp
FROM blinkit;


-- PHASE 1 — STEP 3O
-- Find the minimum and maximum sales value.

SELECT
    MIN(Item_Outlet_Sales) AS minimum_sales,
    MAX(Item_Outlet_Sales) AS maximum_sales
FROM blinkit;




-- PHASE 1 — STEP 3P
-- Check for completely duplicate rows.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT
        Item_Identifier || '|' ||
        Item_Weight || '|' ||
        Item_Fat_Content || '|' ||
        Item_Visibility || '|' ||
        Item_Type || '|' ||
        Item_MRP || '|' ||
        Outlet_Identifier || '|' ||
        Outlet_Establishment_Year || '|' ||
        Outlet_Size || '|' ||
        Outlet_Location_Type || '|' ||
        Outlet_Type || '|' ||
        Item_Outlet_Sales
    ) AS unique_rows
FROM blinkit;




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


-- PHASE 1 — STEP 3Q
-- Check whether Item_Weight can be converted to a number.

SELECT
    Item_Weight,
    CAST(Item_Weight AS REAL) AS weight_as_number
FROM blinkit
WHERE Item_Weight IS NOT NULL
LIMIT 10;



-- PHASE 1 — STEP 3R
-- Find the minimum and maximum item weight.

SELECT
    MIN(CAST(Item_Weight AS REAL)) AS minimum_weight,
    MAX(CAST(Item_Weight AS REAL)) AS maximum_weight
FROM blinkit
WHERE Item_Weight IS NOT NULL
  AND TRIM(Item_Weight) <> '';
  
  
-- PHASE 1 — STEP 3S
-- Count visibility values that are exactly zero
-- and values that are greater than zero.

SELECT
    SUM(CASE WHEN Item_Visibility = 0 THEN 1 ELSE 0 END) AS zero_visibility,
    SUM(CASE WHEN Item_Visibility > 0 THEN 1 ELSE 0 END) AS positive_visibility
FROM blinkit;




-- PHASE 2 — STEP 1A
-- Check how many records have each fat-content label.

SELECT
    Item_Fat_Content,
    COUNT(*) AS record_count
FROM blinkit
GROUP BY Item_Fat_Content
ORDER BY record_count DESC;





-- PHASE 2 — STEP 1B
-- Standardize all Low Fat labels.

UPDATE blinkit
SET Item_Fat_Content = 'Low Fat'
WHERE Item_Fat_Content IN ('Low Fat', 'low fat', 'LF');

select distinct Item_Fat_Content
from blinkit ;


-- PHASE 2 — STEP 1C
-- Change the remaining "reg" label to "Regular".

UPDATE blinkit
SET Item_Fat_Content = 'Regular'
WHERE Item_Fat_Content = 'reg';

select distinct Item_Fat_Content
from blinkit ;


-- PHASE 2 — STEP 2A
-- Recheck missing Item_Weight values.

SELECT
    COUNT(*) AS missing_item_weight
FROM blinkit
WHERE Item_Weight IS NULL
   OR TRIM(Item_Weight) = '';
   
   
   
   
-- PHASE 2 — STEP 2B
-- Check whether products with missing weights
-- have a known weight elsewhere in the dataset.

SELECT
    Item_Identifier,
    COUNT(*) AS total_records,
    COUNT(Item_Weight) AS known_weights
FROM blinkit
GROUP BY Item_Identifier
HAVING COUNT(*) > COUNT(Item_Weight)
LIMIT 10;



-- PHASE 2 — STEP 2C
-- Inspect the weights available for product DRA24.

SELECT
    Item_Identifier,
    Item_Weight,
    Outlet_Identifier
FROM blinkit
WHERE Item_Identifier = 'DRA24';

-- PHASE 2 — STEP 2D
-- Find products that have more than one known weight.

SELECT
    Item_Identifier,
    COUNT(DISTINCT Item_Weight) AS different_weights
FROM blinkit
WHERE Item_Weight IS NOT NULL
  AND TRIM(Item_Weight) <> ''
GROUP BY Item_Identifier
HAVING COUNT(DISTINCT Item_Weight) > 1
LIMIT 10;


-- PHASE 2 — STEP 2E
-- Count missing weights that have a known weight
-- for the same product.

SELECT
    COUNT(*) AS missing_weights_with_product_reference
FROM blinkit AS b
WHERE (b.Item_Weight IS NULL OR TRIM(b.Item_Weight) = '')
  AND EXISTS (
      SELECT 1
      FROM blinkit AS x
      WHERE x.Item_Identifier = b.Item_Identifier
        AND x.Item_Weight IS NOT NULL
        AND TRIM(x.Item_Weight) <> ''
  );
  
  
  SELECT
    Item_Identifier,
    Outlet_Identifier
FROM blinkit
WHERE Item_Weight IS NULL
   OR TRIM(Item_Weight) = ''
LIMIT 20;



-- PHASE 2 — STEP 2F
-- Find products where every weight is missing.

SELECT
    Item_Identifier,
    COUNT(*) AS total_records
FROM blinkit
GROUP BY Item_Identifier
HAVING COUNT(Item_Weight) = 0;


-- PHASE 2 — STEP 2G
-- Inspect the 4 products with completely missing weights.

SELECT
    Item_Identifier,
    Item_Type,
    Item_MRP,
    Outlet_Identifier
FROM blinkit
WHERE Item_Identifier IN ('FDE52', 'FDK57', 'FDN52', 'FDQ60');


SELECT
    Item_Identifier,
    MAX(CAST(Item_Weight AS REAL)) AS product_weight
FROM blinkit
WHERE Item_Weight IS NOT NULL
GROUP BY Item_Identifier
LIMIT 10;




-- PHASE 2 — STEP 2H
-- Preview missing weights using the product's known weight.

SELECT
    Item_Identifier,
    Item_Weight,
    (
        SELECT MAX(CAST(Item_Weight AS REAL))
        FROM blinkit AS b2
        WHERE b2.Item_Identifier = b1.Item_Identifier
    ) AS new_weight
FROM blinkit AS b1
WHERE Item_Weight IS NULL
LIMIT 10;




-- PHASE 2 — STEP 2I
-- Fill missing Item_Weight values using
-- the known weight of the same product.

UPDATE blinkit
SET Item_Weight = (
    SELECT MAX(Item_Weight)
    FROM blinkit AS b2
    WHERE b2.Item_Identifier = blinkit.Item_Identifier
      AND b2.Item_Weight IS NOT NULL
)
WHERE Item_Weight IS NULL;


-- PHASE 2 — STEP 2J
-- Check remaining missing Item_Weight values.

SELECT
    COUNT(*) AS missing_item_weight
FROM blinkit
WHERE Item_Weight IS NULL
   OR TRIM(Item_Weight) = '';
   

   
-- PHASE 2 — STEP 3A
-- Check the current Outlet_Size distribution.

SELECT
    Outlet_Size,
    COUNT(*) AS record_count
FROM blinkit
GROUP BY Outlet_Size
ORDER BY record_count DESC;



-- PHASE 2 — STEP 3B
-- Check how many different sizes each outlet has.

SELECT
    Outlet_Identifier,
    COUNT(DISTINCT Outlet_Size) AS different_sizes
FROM blinkit
WHERE Outlet_Size IS NOT NULL
GROUP BY Outlet_Identifier;


-- PHASE 2 — STEP 3C
-- Find the known size for each outlet.

SELECT
    Outlet_Identifier,
    MAX(Outlet_Size) AS outlet_size
FROM blinkit
WHERE Outlet_Size IS NOT NULL
GROUP BY Outlet_Identifier;



-- PHASE 2 — STEP 3D
-- Preview the outlet size for missing records.

SELECT
    Outlet_Identifier,
    Outlet_Size,
    (
        SELECT MAX(Outlet_Size)
        FROM blinkit AS b2
        WHERE b2.Outlet_Identifier = b1.Outlet_Identifier
    ) AS new_size
FROM blinkit AS b1
WHERE Outlet_Size IS NULL
LIMIT 10;



-- PHASE 2 — STEP 3E
-- Find outlets where Outlet_Size is completely missing.

SELECT
    Outlet_Identifier,
    COUNT(*) AS total_records
FROM blinkit
GROUP BY Outlet_Identifier
HAVING COUNT(Outlet_Size) = 0;



-- PHASE 2 — STEP 3F
-- Inspect the outlet type and location of outlets
-- with completely missing Outlet_Size.

SELECT DISTINCT
    Outlet_Identifier,
    Outlet_Type,
    Outlet_Location_Type
FROM blinkit
WHERE Outlet_Identifier IN ('OUT010', 'OUT017', 'OUT045');





-- PHASE 2 — STEP 3G
-- Verify remaining missing Outlet_Size values.

SELECT
    COUNT(*) AS missing_outlet_size
FROM blinkit
WHERE Outlet_Size IS NULL
   OR TRIM(Outlet_Size) = '';
   
   
   
   
-- PHASE 2 — STEP 4A
-- Look at products with zero visibility.

SELECT
    Item_Identifier,
    Item_Type,
    Item_Visibility,
    Item_Outlet_Sales
FROM blinkit
WHERE Item_Visibility = 0
LIMIT 10;



-- PHASE 2 — STEP 4B
-- Find products that have both zero and positive visibility.

SELECT
    Item_Identifier,
    MIN(Item_Visibility) AS minimum_visibility,
    MAX(Item_Visibility) AS maximum_visibility
FROM blinkit
GROUP BY Item_Identifier
HAVING MIN(Item_Visibility) = 0
   AND MAX(Item_Visibility) > 0
LIMIT 10;


-- PHASE 2 — STEP 4C
-- Count zero-visibility records by outlet type.

SELECT
    Outlet_Type,
    COUNT(*) AS zero_visibility_count
FROM blinkit
WHERE Item_Visibility = 0
GROUP BY Outlet_Type
ORDER BY zero_visibility_count DESC;



-- PHASE 2 — STEP 4D
-- Check for negative visibility values.

SELECT
    COUNT(*) AS negative_visibility
FROM blinkit
WHERE Item_Visibility < 0;

-- PHASE 2 — STEP 5A
-- Verify the total number of records after cleaning.

SELECT COUNT(*) AS total_records
FROM blinkit;




SELECT ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit;


SELECT ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit;


SELECT COUNT(*) AS total_items
FROM blinkit;

-- Q3: Sales performance by outlet size

SELECT
    Outlet_Size,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    COUNT(*) AS item_count,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales_per_item
FROM blinkit
GROUP BY Outlet_Size
ORDER BY total_sales DESC;

-- Q4: Which location tier performs best?

SELECT
    Outlet_Location_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    COUNT(*) AS item_count,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales_per_item
FROM blinkit
GROUP BY Outlet_Location_Type
ORDER BY total_sales DESC;

-- Q5: Sales by outlet type

SELECT
    Outlet_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    COUNT(*) AS item_count,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Outlet_Type
ORDER BY total_sales DESC;

-- Q6: Sales by MRP price range

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


SELECT
    Outlet_Type,
    Outlet_Location_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit
GROUP BY Outlet_Type, Outlet_Location_Type
ORDER BY total_sales DESC
LIMIT 10;


SELECT
    Item_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(
        SUM(Item_Outlet_Sales) * 100.0 /
        (SELECT SUM(Item_Outlet_Sales) FROM blinkit),
        2
    ) AS sales_percentage
FROM blinkit
GROUP BY Item_Type
ORDER BY total_sales DESC;

SELECT
    Item_Identifier,
    Item_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit
GROUP BY Item_Identifier, Item_Type
ORDER BY total_sales DESC
LIMIT 10;


SELECT
    Item_Type,
    ROUND(AVG(Item_Visibility), 4) AS avg_visibility,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Item_Type
ORDER BY avg_visibility DESC;


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

SELECT
    Outlet_Identifier,
    Outlet_Type,
    Outlet_Location_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit
GROUP BY Outlet_Identifier
ORDER BY total_sales DESC
LIMIT 10;


SELECT
    Outlet_Identifier,
    Outlet_Type,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Outlet_Identifier
ORDER BY avg_sales DESC
LIMIT 10;



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


SELECT
    Outlet_Establishment_Year,
    COUNT(*) AS item_count,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year;



SELECT
    Outlet_Type,
    Item_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit
GROUP BY Outlet_Type, Item_Type
ORDER BY Outlet_Type, total_sales DESC;



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


SELECT
    Item_Type,
    COUNT(*) AS item_count,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Item_Type
ORDER BY avg_sales DESC;


SELECT
    Outlet_Type,
    COUNT(*) AS item_count,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Outlet_Type
ORDER BY avg_sales DESC;




--Q21
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





SELECT
    Item_Identifier,
    Item_Type,
    ROUND(Item_Visibility, 4) AS visibility,
    ROUND(Item_Outlet_Sales, 2) AS sales
FROM blinkit
WHERE Item_Visibility < 0.05
ORDER BY Item_Outlet_Sales DESC
LIMIT 10;


SELECT
    Outlet_Type,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Outlet_Type;


CREATE VIEW sales_kpis AS
SELECT
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales,
    COUNT(*) AS total_records
FROM blinkit;

CREATE VIEW product_sales_summary AS
SELECT
    Item_Type,
    COUNT(*) AS item_count,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit
GROUP BY Item_Type
ORDER BY total_sales DESC;


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

SELECT *
FROM outlet_performance
ORDER BY total_sales DESC;




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


SELECT *
FROM top_product_by_category
ORDER BY total_sales DESC;



EXPLAIN QUERY PLAN
SELECT *
FROM blinkit
WHERE Item_Type = 'Dairy';

