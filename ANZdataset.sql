-- SETTING UP NEW COLUMN WITH EXISTING COLUMN AS A NEW TABLE
CREATE TABLE aa AS (
SELECT 
ANZdataset.*
-- CREATING AGE BUCKET CATEGORY
,CASE 
	WHEN age < 26 THEN '<26'
	WHEN age >= 26 AND age < 35 THEN '26-35'
	WHEN age >= 35 AND age < 50 THEN '35-50'
	WHEN age >= 50 THEN '50+'
END AS age_bucket
	
	
-- CREATING SPEND BUCKET CATEGORY
,CASE 
	WHEN amount >= 0 AND amount < 50 THEN '<50'
	WHEN amount >= 50 AND amount < 100 THEN '50-100'
	WHEN amount >= 100 AND amount < 500 THEN '100-500'
	WHEN amount >= 500 AND amount < 1000 THEN '500-1k'
	WHEN amount >= 1000 AND amount < 3000 THEN '1k-3k'
	WHEN amount >= 3000 AND amount < 5000 THEN '3k-5k'
	WHEN amount >= 5000 THEN '5k+'
END AS spend_bucket
FROM ANZdataset)


-- CREATE NEW TABLE BY FILTERING DISTINCT ACCOUNT
CREATE TABLE dst_account AS (
SELECT DISTINCT account, age_bucket, spend_bucket, ROUND(SUM(amount),2) as Total_Amount FROM aa
GROUP BY account, age_bucket, spend_bucket)


-- FILTERING AGE_BUCKET
SELECT 
age_bucket AS customer_age, 
	SUM(CASE WHEN age_bucket='<26' THEN 1 ELSE 0 END) AS under26,
	SUM(CASE WHEN age_bucket='26-35' THEN 1 ELSE 0 END) AS age_26_35,
	SUM(CASE WHEN age_bucket='35-50' THEN 1 ELSE 0 END) AS age_35_50,
	SUM(CASE WHEN age_bucket='50+' THEN 1 ELSE 0 END) AS age_50_plus
FROM dst_account
GROUP BY age_bucket
ORDER BY age_bucket ASC


-- FILTERING SPEND_BUCKET
SELECT
spend_bucket,
	SUM(CASE WHEN spend_bucket='<50' THEN 1 ELSE 0 END) AS group50,
	SUM(CASE WHEN spend_bucket='50-100' THEN 1 ELSE 0 END) AS group100,
	SUM(CASE WHEN spend_bucket='100-500' THEN 1 ELSE 0 END) AS group500,
	SUM(CASE WHEN spend_bucket='500-1k' THEN 1 ELSE 0 END) AS group1k,
	SUM(CASE WHEN spend_bucket='1k-3k' THEN 1 ELSE 0 END) AS group3k,
	SUM(CASE WHEN spend_bucket='3k-5k' THEN 1 ELSE 0 END) AS group5k,
	SUM(CASE WHEN spend_bucket='5k+' THEN 1 ELSE 0 END) AS group5kplus
FROM aa
GROUP BY spend_bucket
ORDER BY spend_bucket ASC


-- AVERAGE SPEND AGE_BUCKET (IN_GENERAL)
SELECT age_bucket, ROUND(AVG(amount),2) as average_transaction_by_age_bucket FROM aa
WHERE age_bucket IN ('<26','26-35','35-50','50+')
GROUP BY age_bucket


-- AVERAGE SPEND AGE_BUCKET (PER/ACCOUNT)
SELECT age_bucket, ROUND(AVG(total_amount),2) as average_transaction_by_age_bucket FROM dst_account
WHERE age_bucket IN ('<26','26-35','35-50','50+')
GROUP BY age_bucket
ORDER BY age_bucket


-- FILTERING MONTLY AVERAGE SPEND/AGE 
SELECT 
DISTINCT 
MONTH(date)
,AGE_BUCKET
,ROUND(AVG(amount) OVER (PARTITION BY MONTH(date)),2) AS avg_mth_spend
,ROUND(AVG(amount) OVER (PARTITION BY MONTH(date), AGE_BUCKET),2) AS AVG_SPEND_PER_AGE_MTH
FROM aa


-- FILTERING AVERAGE TRANSACTION / STATE
SELECT DISTINCT merchant_state, MONTH(date), ROUND(AVG(amount),2), ROUND(SUM(amount),2)
FROM aa
GROUP BY merchant_state, month(date)
ORDER BY month(date)