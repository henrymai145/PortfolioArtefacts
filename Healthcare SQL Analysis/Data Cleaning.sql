/* 
Data Cleaning Project
Dataset URL: https://www.kaggle.com/datasets/prasad22/healthcare-dataset

Steps Taken:
	1. Remove Duplicates
	2. Standardize the Data
	3. Handling Null Values or Blank Values
	4. Remove Redudant Columns
*/

-- Create a Staging Table to Reserve Original Data
CREATE TABLE healthcare_staging
LIKE healthcare;
INSERT healthcare_staging
SELECT *
FROM healthcare;

-- Change Column Names
ALTER TABLE healthcare_staging
CHANGE COLUMN `Name` name TEXT,
CHANGE COLUMN `Age` age INT,
CHANGE COLUMN `Gender` gender TEXT,
CHANGE COLUMN `Blood Type` blood_type TEXT,
CHANGE COLUMN `Medical Condition` medical_condition TEXT,
CHANGE COLUMN `Date of Admission` date_of_admission TEXT,
CHANGE COLUMN `Doctor` doctor TEXT,
CHANGE COLUMN `Hospital` hospital TEXT,
CHANGE COLUMN `Insurance Provider` insurance_provider TEXT,
CHANGE COLUMN `Billing Amount` billing_amount double,
CHANGE COLUMN `Room Number` room_number INT,
CHANGE COLUMN `Admission Type` admission_type TEXT,
CHANGE COLUMN `Discharge Date` discharge_date TEXT,
CHANGE COLUMN `Medication` medication TEXT,
CHANGE COLUMN `Test Results` test_results TEXT;

SELECT * FROM healthcare_staging;

-- Finding Duplicates using Billing Amount 
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY billing_amount) AS row_num
FROM healthcare_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Create another Staging Table for Updating Column
CREATE TABLE `healthcare_staging2` (
  `name` text,
  `age` int DEFAULT NULL,
  `gender` text,
  `blood_type` text,
  `medical_condition` text,
  `date_of_admission` text,
  `doctor` text,
  `hospital` text,
  `insurance_provider` text,
  `billing_amount` double DEFAULT NULL,
  `room_number` int DEFAULT NULL,
  `admission_type` text,
  `discharge_date` text,
  `medication` text,
  `test_results` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert Duplicates Column for Deletion
INSERT healthcare_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY billing_amount) AS row_num
FROM healthcare_staging;

-- Remove Duplicates & Column
DELETE 
FROM healthcare_staging2
WHERE row_num > 1;
ALTER TABLE healthcare_staging2
DROP COLUMN row_num;

-- Change Data Type to Date
ALTER TABLE healthcare_staging2
MODIFY COLUMN date_of_admission DATE;
ALTER TABLE healthcare_staging2
MODIFY COLUMN discharge_date DATE;

-- Check if the Date Type has changed
SHOW COLUMNS FROM healthcare_staging2;

-- Round to 2 decimal places
UPDATE healthcare_staging2
SET billing_amount = ROUND(billing_amount, 2);

-- Check if there is any NULL Values
SELECT *
FROM healthcare_staging2
WHERE billing_amount = '' OR billing_amount IS NULL;

-- Separating First and Last Name from Name
SELECT SUBSTRING_INDEX(name, ' ', -1) AS first_name
FROM healthcare_staging2;

-- Remove Irrelevant Columns
ALTER TABLE healthcare_staging2
DROP COLUMN name;
ALTER TABLE healthcare_staging2
DROP COLUMN doctor;
ALTER TABLE healthcare_staging2
DROP COLUMN hospital;

SELECT *
FROM healthcare_staging2;

