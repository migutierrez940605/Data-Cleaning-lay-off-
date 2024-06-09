--DataCleaning Layoff


---Create a new table as copy from the original for Training 

SELECT *
FROM layoff

SELECT *
INTO layoff_test
FROM layoff;

SELECT *
FROM layoff_test

-----1-Remove Duplicates

SELECT company, location, industry, total_laid_off, country, date, count(company)
FROM layoff
group by company, location, country, date, industry, total_laid_off
HAVING count(company)>1
order by count(company) desc

SELECT company, location, industry, total_laid_off, country, date
FROM layoff_test
group by company, location, country, date, industry, total_laid_off
HAVING count(company)=2 
order by count(company) desc
----delete duplicates but also delete both rows--------DOESN'T WORK 
--DELETE FROM layoff_test
--WHERE company IN (
--SELECT company 
--FROM layoff_test
--group by company, location, country, date, industry, total_laid_off
--HAVING count(company)>1)
----------------------------------------------------------------

---Create another Table for test and find another way
SELECT *
INTO layoff_test1
FROM layoff;

SELECT *
FROM layoff_test1

SELECT *,
RN=ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, country, date, funds_raised_millions order by company)
FROM layoff_test1
-------Use CTE
WITH duplicate_CTE AS
(
SELECT company, location, industry, total_laid_off, country, date, funds_raised_millions,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, country, date, funds_raised_millions order by location) AS RN
FROM layoff_test1
)
DELETE
FROM  Duplicate_CTE
WHERE RN>1
--We check if it is ok
WITH duplicate_CTE AS
(
SELECT company, location, industry, total_laid_off, country, date, funds_raised_millions,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, country, date, funds_raised_millions order by location) AS RN
FROM layoff_test1
)
SELECT*
FROM duplicate_CTE
WHERE RN>2
---------Done----------


-----2-Standardize the Data
---a-delete the blank space of company column 
SELECT company, TRIM(company)
FROM layoff_test1

UPDATE layoff_test1
SET company= TRIM(company)
---b-Working on industry column
--To put Crypto instead CryptoCurrency
SELECT DISTINCT industry
FROM layoff_test1
ORDER BY 1

SELECT * 
FROM layoff_test1
WHERE industry LIKE 'Crypto%'
--
UPDATE layoff_test1
SET industry='Crypto'
WHERE industry LIKE 'Crypto%'
---c-delete the blank space of total_laid_off column 
SELECT total_laid_off, REPLACE(total_laid_off,' ','')
FROM layoff_test1

UPDATE layoff_test1
SET total_laid_off = REPLACE(total_laid_off,' ','')
---d-Standarize Date
---doesn't work 
Select date, try_convert(date,date)
 from layoff_test1

UPDATE layoff_test1
SET date = Convert(Date,date)
------------Let's try another way
ALTER TABLE layoff_test1
ADD dateconverted date

UPDATE layoff_test1
SET dateconverted = Convert(Date,date)
---e-Remove dot in the end of United State
SELECT DISTINCT country
FROM layoff_test1
ORDER BY 1

SELECT DISTINCT country, TRIM(REPLACE(country,'.',''))
FROM layoff_test1

UPDATE layoff_test1
SET country = TRIM(REPLACE(country,'.',''))
SELECT * 
FROM layoff_test1
---f-Standarize percentage_laid_off
SELECT * 
FROM layoff_test1
WHERE percentage_laid_off='NULL'

percentage_laid_off IS NULL
UPDATE layoff_test1
SET percentage_laid_off= NULL
WHERE percentage_laid_off= 'NULL'

--3-Null or blank values

--Assign AirBNB An Industry  
SELECT l1.company,l1.location, l1.industry,l2.industry
FROM layoff_test1 l1
JOIN layoff_test1 l2
ON l1.company=l2.company and l1.location=l2.location
WHERE l1.industry IS NULL AND l2.industry IS NOT NULL 

UPDATE l1
SET l1.industry=l2.industry
FROM layoff_test1 l1
JOIN layoff_test1 l2
ON l1.company=l2.company and l1.location=l2.location
WHERE l1.industry IS NULL AND l2.industry IS NOT NULL



----4-Remove Any Columns or Rows
---a-Delete the rows that have the percentage_laid_off and total_laid_off nulls-
SELECT * 
FROM layoff_test1
WHERE percentage_laid_off IS NULL AND
total_laid_off IS NULL

DELETE FROM layoff_test1
WHERE percentage_laid_off IS NULL AND
total_laid_off IS NULL

---b-Delete the column date-
ALTER TABLE layoff_test1
DROP COLUMN date;

