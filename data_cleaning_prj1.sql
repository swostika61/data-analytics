-- data cleaning
SELECT *
FROM layoffs;

-- ** copy all the raw table data(layoff) to staging table

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1.REMOVE DUPLICATE
SELECT * ,
ROW_NUMBER() OVER(
	PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, 
    `date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

-- check for duplicates
WITH duplicate_cte AS
(SELECT * ,
ROW_NUMBER() OVER(
	PARTITION BY company,location, industry, total_laid_off, percentage_laid_off,
    `date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging)
SELECT * 
FROM duplicate_cte
WHERE row_num>1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(
	PARTITION BY company,location, industry, total_laid_off, percentage_laid_off,
    `date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;



DELETE FROM layoffs_staging2
WHERE row_num>1;
SELECT * 
FROM layoffs_staging2 
WHERE row_num > 1;

--    ***********2.STANDARDIZING THE DATA : finding issues in your data and fixing it

SELECT * FROM layoffs_staging2;

-- checking the company data
SELECT DISTINCT(company), (TRIM(company))
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company=TRIM(company);

-- checking the industry data
SELECT DISTINCT(industry)
FROM layoffs_staging2;

SELECT DISTINCT(industry)
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';

-- checking the country
SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1; 

SELECT DISTINCT(country )
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country='United States' -- another way >> country=TRIM(TRAILING'.' FROM country)
WHERE country LIKE 'United States%';

-- changing the date data type which is in text to date format.
SELECT `date`
FROM layoffs_staging2;

SELECT `date` 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

-- since date is in text format change column into date.
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


