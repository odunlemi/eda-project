-- Exploratory Data Analysis (EDA)

-- A stored procedure to call the table easily
CREATE PROCEDURE layoffs_table()
SELECT *
FROM layoffs_cleaned_data;
CALL layoffs_table();


-- Max total and percentage laid off
SELECT MAX(total_laid_off), 
MAX(percentage_laid_off)	-- 1 represents 100% of employees laid off
FROM layoffs_cleaned_data;

-- Companies that laid off all employees
SELECT *
FROM layoffs_cleaned_data
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Companies that laid off all employees and their funding
SELECT company, location, industry, total_laid_off, percentage_laid_off, funds_raised_millions
FROM layoffs_cleaned_data
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Total employees laid off by each company
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_cleaned_data
GROUP BY company
ORDER BY 2 DESC;

-- Start and end of layoffs 
SELECT MIN(`date`) AS start_of_layoffs_data, MAX(`date`) AS end_of_layoffs_data	-- 2020-03-11 to 2023-03-06
FROM layoffs_cleaned_data;

-- Layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_cleaned_data
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC;

-- Layoffs by country
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_cleaned_data
GROUP BY country
ORDER BY 2 DESC;

-- Layoffs by individual dates
SELECT `date`, SUM(total_laid_off) AS daily_total_laid_off
FROM layoffs_cleaned_data
GROUP BY `date`
ORDER BY 1 DESC;

-- Layoffs by year
SELECT YEAR(`date`), SUM(total_laid_off) AS yearly_total_laid_off
FROM layoffs_cleaned_data
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Layoffs by company stage
SELECT stage, SUM(total_laid_off) AS total_layoffs_by_company_stages
FROM layoffs_cleaned_data
GROUP BY stage
ORDER BY 2 DESC;

-- Layoffs by month
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_cleaned_data
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


-- Rolling sum of employees laid off
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_cleaned_data
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Layoffs of companies per year
SELECT company, YEAR(`date`), SUM(total_laid_off) AS total_laid_off
FROM layoffs_cleaned_data
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;


-- Ranks which years companies laid off the most employees

-- Checks highest ranked companies by layoffs and year
SELECT company, YEAR(`date`), SUM(total_laid_off) AS total_laid_off
FROM layoffs_cleaned_data
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Ranks the companies with the highest layoffs per year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off) AS total_laid_off
FROM layoffs_cleaned_data
GROUP BY company, YEAR(`date`)
)
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;

-- Filters the ranking to the top 5 companies with the highest layoffs per year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off) AS total_laid_off
FROM layoffs_cleaned_data
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL)
SELECT *
FROM Company_Year_Rank
WHERE RANKING <= 5;
