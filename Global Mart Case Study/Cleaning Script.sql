-- Create a staging table to work on
CREATE TABLE `customers_dirty_staging` (
  `customer_id` INT DEFAULT NULL,
  `age` INT DEFAULT NULL,
  `gender` TEXT,
  `region` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO customers_dirty_staging 
SELECT * FROM customers_dirty;

-- Fix typos
UPDATE customers_dirty_staging
SET gender = REPLACE(gender, 'Mle', 'Male')
WHERE gender = 'Mle';

UPDATE customers_dirty_staging
SET gender = REPLACE(gender, 'Femail', 'Female')
WHERE gender = 'Femail';

UPDATE customers_dirty_staging
SET gender = REPLACE(gender, 'Othr', 'Other')
WHERE gender = 'Othr';

UPDATE customers_dirty_staging
SET region = REPLACE(region, UPPER('EAST'), 'East')
WHERE region = UPPER('EAST');

-- Delete null values & unrealistic values
DELETE FROM customers_dirty_staging
WHERE region IS NULL 
   OR gender IS NULL 
   OR region = '' 
   OR gender = ''  
   OR age > 100 
   OR age < 5;

-- Create a clean version to insert
CREATE TABLE `customers_clean` (
  `customer_id` INT DEFAULT NULL,
  `age` INT DEFAULT NULL,
  `gender` TEXT,
  `region` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO customers_clean
SELECT 
  customer_id, 
  age, 
  gender, 
  -- Fix randomly capitalized letters
  CONCAT(UPPER(LEFT(region, 1)), LOWER(SUBSTRING(region, 2))) AS region
FROM customers_dirty_staging;

-- Create staging table for inventory
CREATE TABLE `inventory_staging` (
  `store_id` INT DEFAULT NULL,
  `product_id` INT DEFAULT NULL,
  `stock_level` INT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO inventory_staging
SELECT * FROM inventory_dirty;

-- Fix negative stock level
UPDATE inventory_staging
SET stock_level = REPLACE(stock_level, '-', '')
WHERE stock_level < 0;

-- Create clean version of inventory
CREATE TABLE `inventory_clean` (
  `store_id` INT DEFAULT NULL,
  `product_id` INT DEFAULT NULL,
  `stock_level` INT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO inventory_clean
SELECT * FROM inventory_staging;

-- Create staging table for products
CREATE TABLE `products_stg` (
  `product_id` INT DEFAULT NULL,
  `product_name` TEXT,
  `category` TEXT,
  `brand` TEXT,
  `cost_price` DOUBLE DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO products_stg 
SELECT * FROM products_dirty;

SELECT * FROM products_stg;

-- Fix product names and categories
UPDATE products_stg
SET product_name = CONCAT('Product_', SUBSTRING(product_id, 3, 2))
WHERE product_name NOT LIKE 'Product_%';

UPDATE products_stg
SET category = REPLACE(category, 'Toyz', 'Toys')
WHERE category = 'Toyz';

UPDATE products_stg
SET category = REPLACE(category, 'clothng', 'Clothing')
WHERE category = 'clothng';

-- Fix negative cost price
UPDATE products_stg
SET cost_price = REPLACE(cost_price, '-', '')
WHERE cost_price <= 0;

-- Fix brand names formatting
UPDATE products_stg
SET brand = REPLACE(brand, RIGHT(brand, 1), CONCAT(' ', RIGHT(brand, 1)));

-- Create clean version of products table
CREATE TABLE `products_clean` (
  `product_id` INT DEFAULT NULL,
  `product_name` TEXT,
  `category` TEXT,
  `brand` TEXT,
  `cost_price` DOUBLE DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO products_clean
SELECT * FROM products_stg;





