-- Exploratory Data Analysis

/*
Insights on Insurance Provider:
- Total Reimbursement
- Average Reimbursement per Claim
- Number of Claims

Questions Raised:
- Is the total reimbursement in line with expectations?
- Are there any spikes or trends over time (monthly, quarterly, etc.)?
- Are there specific factors (e.g., claim type, insurance provider) that are driving higher reimbursement amounts?
- Are there opportunities for cost-saving by reducing the average reimbursement amount per claim?
- Is the number of claims increasing or decreasing over time?
- Is there any correlation between the number of claims and the total reimbursement or average reimbursement?
*/
SELECT insurance_provider, ROUND(SUM(billing_amount), 0) as total_reimbursement, 
ROUND(AVG(billing_amount), 0) as average_reimbursement,
COUNT(billing_amount) as total_claim
FROM healthcare_staging2
GROUP BY insurance_provider
ORDER BY total_reimbursement DESC;

-- Remove Irrelevant Column
ALTER TABLE healthcare_staging2
DROP COLUMN room_number;

/*
Insights on Annually Financial Data:
- Observed massive spikes in Total Reimbursement during 2020 - 2023
- Blue Cross is the the Highest Paying Insurer in 2020 & 2021 while Medicare is in 2022 & 2023
- Reasons might include:
	+ COVID spike
    + Insurance Policy for the year
    + Need more Data from other Departments to further understand causes & create strategies
*/
SELECT insurance_provider, YEAR(date_of_admission) AS years, 
ROUND(SUM(billing_amount), 0) as total_reimbursement,
ROUND(AVG(billing_amount), 0) as average_reimbursement,
COUNT(billing_amount) as total_claim
FROM healthcare_staging2
GROUP BY insurance_provider, years
ORDER BY years DESC;

/*
Insights on Annually Financial Data:
- Observed massive spikes in Total Reimbursement during 2020 - 2023
- Blue Cross is the the Highest Paying Insurer in 2020 & 2021 while Medicare is in 2022 & 2023
- Reasons might include:
	+ COVID spike
    + Insurance Policy for the year
    + Need more Data from other Departments to further understand causes & create strategies
*/
SELECT CONCAT(FLOOR(age / 10) * 10, '-', FLOOR(age / 10) * 10 + 9) AS age_range,
COUNT(*) AS number_of_people,
ROUND(SUM(billing_amount), 0) as total_reimbursement, 
ROUND(AVG(billing_amount), 0) as average_reimbursement
FROM healthcare_staging2
GROUP BY age_range
ORDER BY age_range;

/*
Insights on Medical Conditions:
- Can be used by Hospital to monitor health, allocate resource, improve patient care
- Can be used by Insurance Provider to costs control, risk assessment, new product developement
- Can be used by Government to improve healthcare policy and planning, research purposes, public health program development
*/
SELECT medical_condition,
COUNT(*) AS number_of_cases,
ROUND(SUM(billing_amount), 0) as total_reimbursement, 
ROUND(AVG(billing_amount), 0) as average_reimbursement
FROM healthcare_staging2
GROUP BY medical_condition
ORDER BY total_reimbursement DESC;

/*
Other Use Cases that requrie further Analysis:
- Hospital stay duration for resource allocation and planning
- Demographic for research and educational purposes
- Medication usage for stock and supply management
- Admission type for develop future education program
- Blood type for identify medical condition trends
*/
