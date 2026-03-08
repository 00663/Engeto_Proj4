/*
===============================================================================
ENGETO DATOVÁ AKADEMIE - PROJEKT 4
Autor: Filip Hnilica
===============================================================================
*/

-- ============================================================================
-- 1. Vytvoření primární tabulky (Mzdy a ceny potravin pro ČR za společné roky)
-- ============================================================================
CREATE TABLE t_filip_hnilica_project_SQL_primary_final AS
WITH avg_wages AS (
    SELECT 
        cp.payroll_year AS year,
        cpib.name AS industry_branch,
        ROUND(AVG(cp.value)::numeric, 2) AS avg_wage
    FROM czechia_payroll cp
    JOIN czechia_payroll_industry_branch cpib 
        ON cp.industry_branch_code = cpib.code
    WHERE cp.value_type_code = 5958 
      AND cp.calculation_code = 200 
      AND cp.payroll_year BETWEEN 2006 AND 2018
    GROUP BY 
        cp.payroll_year, 
        cpib.name
),
avg_prices AS (
    SELECT 
        EXTRACT(YEAR FROM cpr.date_from) AS year,
        cpc.name AS food_category,
        cpc.price_value,
        cpc.price_unit,
        ROUND(AVG(cpr.value)::numeric, 2) AS avg_price
    FROM czechia_price cpr
    JOIN czechia_price_category cpc 
        ON cpr.category_code = cpc.code
    GROUP BY 
        EXTRACT(YEAR FROM cpr.date_from), 
        cpc.name,
        cpc.price_value,
        cpc.price_unit
)
SELECT 
    w.year,
    w.industry_branch,
    w.avg_wage,
    p.food_category,
    p.avg_price,
    p.price_value,
    p.price_unit
FROM avg_wages w
JOIN avg_prices p 
    ON w.year = p.year;

-- ============================================================================
-- 2. Vytvoření sekundární tabulky (HDP, GINI a populace pro evropské státy)
-- ============================================================================
CREATE TABLE t_filip_hnilica_project_SQL_secondary_final AS
SELECT 
    e.country,
    e.year,
    e.GDP,
    e.gini,
    e.population
FROM economies e
JOIN countries c 
    ON e.country = c.country
WHERE c.continent = 'Europe'
  AND e.year BETWEEN 2006 AND 2018;

-- ============================================================================
-- VÝZKUMNÉ OTÁZKY
-- ============================================================================

-- Otázka 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
WITH base_wages AS (
    SELECT DISTINCT 
        year, 
        industry_branch, 
        avg_wage
    FROM t_filip_hnilica_project_SQL_primary_final
),
wages_with_lag AS (
    SELECT 
        year,
        industry_branch,
        avg_wage,
        LAG(avg_wage) OVER (PARTITION BY industry_branch ORDER BY year) AS prev_year_wage
    FROM base_wages
)
SELECT 
    year,
    industry_branch,
    prev_year_wage,
    avg_wage,
    ROUND(((avg_wage - prev_year_wage) / prev_year_wage * 100)::numeric, 2) AS pokles_v_procentech
FROM wages_with_lag
WHERE prev_year_wage IS NOT NULL 
  AND avg_wage < prev_year_wage
ORDER BY pokles_v_procentech ASC;

-- Otázka 2: Kolik je možné si koupit litrů mléka a kg chleba za první a poslední srovnatelné období?
SELECT 
    year, 
    food_category,
    ROUND(AVG(avg_wage)::numeric, 2) AS prumerna_mzda_celkem,
    ROUND(AVG(avg_price)::numeric, 2) AS prumerna_cena_potraviny,
    FLOOR(AVG(avg_wage) / AVG(avg_price)) AS kusu_lze_koupit
FROM t_filip_hnilica_project_SQL_primary_final
WHERE year IN (2006, 2018)
  AND food_category IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
GROUP BY 
    year, 
    food_category
ORDER BY 
    food_category, 
    year;

-- Otázka 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
WITH price_diff AS (
    SELECT 
        food_category,
        MIN(CASE WHEN year = 2006 THEN avg_price END) AS cena_2006,
        MAX(CASE WHEN year = 2018 THEN avg_price END) AS cena_2018
    FROM t_filip_hnilica_project_SQL_primary_final
    GROUP BY food_category
)
SELECT 
    food_category,
    cena_2006,
    cena_2018,
    ROUND(((cena_2018 - cena_2006) / cena_2006 * 100)::numeric, 2) AS narust_procenta
FROM price_diff
WHERE cena_2006 IS NOT NULL AND cena_2018 IS NOT NULL
ORDER BY narust_procenta ASC;

-- Otázka 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
WITH yearly_averages AS (
    SELECT 
        year,
        AVG(avg_wage) AS avg_wage_year,
        AVG(avg_price) AS avg_price_year
    FROM t_filip_hnilica_project_SQL_primary_final
    GROUP BY year
),
yearly_growth AS (
    SELECT 
        year,
        ROUND(((avg_wage_year - LAG(avg_wage_year) OVER (ORDER BY year)) / LAG(avg_wage_year) OVER (ORDER BY year) * 100)::numeric, 2) AS wage_growth,
        ROUND(((avg_price_year - LAG(avg_price_year) OVER (ORDER BY year)) / LAG(avg_price_year) OVER (ORDER BY year) * 100)::numeric, 2) AS price_growth
    FROM yearly_averages
)
SELECT 
    year, 
    wage_growth, 
    price_growth,
    (price_growth - wage_growth) AS difference
FROM yearly_growth
WHERE (price_growth - wage_growth) > 10;

-- Otázka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin?
WITH cz_gdp AS (
    SELECT 
        year, 
        GDP,
        ROUND(((GDP - LAG(GDP) OVER (ORDER BY year)) / LAG(GDP) OVER (ORDER BY year) * 100)::numeric, 2) AS gdp_growth
    FROM t_filip_hnilica_project_SQL_secondary_final
    WHERE country = 'Czech Republic'
),
yearly_averages AS (
    SELECT 
        year,
        AVG(avg_wage) AS avg_wage_year,
        AVG(avg_price) AS avg_price_year
    FROM t_filip_hnilica_project_SQL_primary_final
    GROUP BY year
),
yearly_growth AS (
    SELECT 
        year,
        ROUND(((avg_wage_year - LAG(avg_wage_year) OVER (ORDER BY year)) / LAG(avg_wage_year) OVER (ORDER BY year) * 100)::numeric, 2) AS wage_growth,
        ROUND(((avg_price_year - LAG(avg_price_year) OVER (ORDER BY year)) / LAG(avg_price_year) OVER (ORDER BY year) * 100)::numeric, 2) AS price_growth
    FROM yearly_averages
)
SELECT 
    g.year, 
    g.gdp_growth, 
    y.wage_growth, 
    y.price_growth
FROM cz_gdp g
JOIN yearly_growth y 
    ON g.year = y.year
WHERE g.gdp_growth IS NOT NULL;
