-- ***********EXPLORATORY DATA ANALYSIS
SELECT * FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off) 
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY total_laid_off DESC;

SELECT company, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- by year
SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
-- *****rolling off
WITH rolling_total AS
(
SELECT SUBSTRING(`DATE`,1,7) AS `MONTH`,SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`DATE`,1,7) IS NOT NULL
GROUP BY 1
ORDER BY 1
)
SELECT `MONTH`,total_off,SUM(total_off)OVER(ORDER BY `MONTH`) AS rolling_total 
FROM rolling_total;

SELECT company,YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
ORDER BY 3 DESC;

-- top 5 company according total laid-off with year
WITH company_year(company,years,total_laid_off) AS
(SELECT company,YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
),
company_ranking AS
(SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off desc) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT * 
FROM company_ranking
WHERE ranking<=5;












