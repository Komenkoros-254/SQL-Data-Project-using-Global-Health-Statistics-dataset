# SQL Analysis Queries for `global_health_statistics`

--This document contains example SQL queries to analyze the `global_health_statistics` table.--

> **Table name:** `global_health_statistics`  
> **Example columns:**  
> - `country`  
> - `year`  
> - `disease_name`, `disease_category`  
> - `prevalence_rate_pct`, `incidence_rate_pct`, `mortality_rate_pct`  
> - `age_group`, `gender`, `population_affected`  
> - `healthcare_access_pct`, `doctors_per_1000`, `hospital_beds_per_1000`  
> - `treatment_type`, `avg_treatment_cost_usd`, `availability_of_vaccines_treatment`  
> - `recovery_rate_pct`, `dalys`, `improvement_5y_pct`  
> - `per_capita_income_usd`, `education_index`, `urbanization_rate_pct`

---

## 1. --Countries most affected (by total population affected)--

```sql
SELECT
    country,
    year,
    SUM(population_affected) AS total_population_affected
FROM global_health_statistics
GROUP BY country, year
ORDER BY total_population_affected DESC;

(Purpose: Identify which countries and years have the highest total number of people affected by all diseases combined.)

2. --Most common diseases in a specific country and year--
SELECT
    disease_name,
    disease_category,
    prevalence_rate_pct
FROM global_health_statistics
WHERE country = 'Russia'
  AND year = 2023
ORDER BY prevalence_rate_pct DESC
LIMIT 10;
Purpose: Find the top 10 diseases in Russia in 2023 by prevalence rate.

3. --Dangerous diseases (high mortality, low recovery)--
SELECT
    country,
    year,
    disease_name,
    mortality_rate_pct,
    recovery_rate_pct
FROM global_health_statistics
WHERE year = 2021
ORDER BY mortality_rate_pct DESC,
         recovery_rate_pct ASC;
Purpose: Highlight disease–country–year combinations where death rates are high and recovery is low.

4. --Impact of healthcare access on outcomes--
SELECT
    country,
    AVG(healthcare_access_pct) AS avg_healthcare_access,
    AVG(recovery_rate_pct)     AS avg_recovery_rate,
    AVG(mortality_rate_pct)    AS avg_mortality_rate
FROM global_health_statistics
WHERE year BETWEEN 2020 AND 2025
GROUP BY country
ORDER BY avg_healthcare_access DESC;
Purpose: Check whether better healthcare access is associated with higher recovery and lower mortality between 2001 and 2024.

5.-- Doctors and hospital beds vs. mortality--
SELECT
    country,
    year,
    AVG(doctors_per_1000)       AS avg_doctors_per_1000,
    AVG(hospital_beds_per_1000) AS avg_beds_per_1000,
    AVG(mortality_rate_pct)     AS avg_mortality_rate
FROM global_health_statistics
GROUP BY country, year
ORDER BY avg_mortality_rate DESC;
Purpose: Explore how healthcare capacity (doctors and beds) relates to mortality rates by country and year.

6. --Income, education, and health outcomes--
SELECT
    country,
    year,
    AVG(per_capita_income_usd) AS avg_income,
    AVG(education_index)       AS avg_education_index,
    AVG(prevalence_rate_pct)   AS avg_prevalence_rate,
    AVG(mortality_rate_pct)    AS avg_mortality_rate
FROM global_health_statistics
GROUP BY country, year
ORDER BY avg_income DESC;
Purpose: Compare income and education levels with prevalence and mortality outcomes.

7. --Trend over time for a specific disease (example: Diabetes)--
SELECT
    year,
    country,
    disease_name,
    AVG(prevalence_rate_pct) AS avg_prevalence,
    AVG(incidence_rate_pct)  AS avg_incidence,
    AVG(mortality_rate_pct)  AS avg_mortality,
    AVG(improvement_5y_pct)  AS avg_5y_improvement
FROM global_health_statistics
WHERE disease_name = 'Diabetes'
GROUP BY year, country, disease_name
ORDER BY year, country;
Purpose: See whether Diabetes is getting better or worse over time across countries.

8. --DALYs: burden of disease--
8.1 --Burden by disease category per country--
SELECT
    country,
    disease_category,
    SUM(dalys) AS total_dalys
FROM global_health_statistics
GROUP BY country, disease_category
ORDER BY total_dalys DESC;
Purpose: Rank country–category combinations by total disease burden (DALYs).

8.2 --Top 10 diseases globally by DALYs--
SELECT
    disease_name,
    disease_category,
    SUM(dalys) AS total_dalys
FROM global_health_statistics
GROUP BY disease_name, disease_category
ORDER BY total_dalys DESC
LIMIT 10;
Purpose: Identify the diseases with the highest global burden.

9. --Cost analysis of treatment--
SELECT
    country,
    disease_name,
    AVG(avg_treatment_cost_usd) AS avg_cost,
    AVG(recovery_rate_pct)      AS avg_recovery_rate,
    AVG(mortality_rate_pct)     AS avg_mortality_rate
FROM global_health_statistics
GROUP BY country, disease_name
HAVING COUNT(*) >= 1
ORDER BY avg_cost DESC;
Purpose: Identify high-cost diseases and compare their outcomes by country.

10. --Healthcare access by income group--
SELECT
    CASE
        WHEN per_capita_income_usd < 3000 THEN 'Low income'
        WHEN per_capita_income_usd BETWEEN 3000 AND 10000 THEN 'Lower-middle income'
        WHEN per_capita_income_usd BETWEEN 10001 AND 30000 THEN 'Upper-middle income'
        ELSE 'High income'
    END AS income_group,
    AVG(healthcare_access_pct) AS avg_healthcare_access
FROM global_health_statistics
GROUP BY income_group
ORDER BY avg_healthcare_access DESC;
Purpose: Compare healthcare access across different income groups.

11. --Trend of hospital beds per 1000 (example: Turkey)--
SELECT
    year,
    AVG(hospital_beds_per_1000) AS avg_beds
FROM global_health_statistics
WHERE country = 'Turkey'
GROUP BY year
ORDER BY year;
Purpose: Track how hospital bed availability in Turkey changes over time.

12. --Top diseases affecting older adults (61+, by mortality)--
SELECT
    disease_name,
    AVG(mortality_rate_pct) AS avg_mortality
FROM global_health_statistics
WHERE age_group = '61+'
GROUP BY disease_name
ORDER BY avg_mortality DESC
LIMIT 10;
Purpose: Find which diseases cause the highest mortality among people aged 61+.

13. --Most common disease per age group (by average prevalence)--
SELECT
    age_group,
    disease_name,
    avg_prevalence
FROM (
    SELECT
        age_group,
        disease_name,
        AVG(prevalence_rate_pct) AS avg_prevalence,
        ROW_NUMBER() OVER (
            PARTITION BY age_group
            ORDER BY AVG(prevalence_rate_pct) DESC
        ) AS rn
    FROM global_health_statistics
    GROUP BY age_group, disease_name
) t
WHERE rn = 1;
Purpose: Identify the single most prevalent disease in each age group.

14.-- Deadliest disease per age group (by average mortality)--
SELECT
    age_group,
    disease_name,
    avg_mortality
FROM (
    SELECT
        age_group,
        disease_name,
        AVG(mortality_rate_pct) AS avg_mortality,
        ROW_NUMBER() OVER (
            PARTITION BY age_group
            ORDER BY AVG(mortality_rate_pct) DESC
        ) AS rn
    FROM global_health_statistics
    GROUP BY age_group, disease_name
) t
WHERE rn = 1;
Purpose: Identify the deadliest disease (highest mortality) in each age group.

15. --Gender differences in mortality rate--
SELECT
    disease_name,
    male_mortality,
    female_mortality,
    other_mortality
FROM (
    SELECT
        disease_name,
        AVG(CASE WHEN gender = 'Male'   THEN mortality_rate_pct END) AS male_mortality,
        AVG(CASE WHEN gender = 'Female' THEN mortality_rate_pct END) AS female_mortality,
        AVG(CASE WHEN gender = 'Other'  THEN mortality_rate_pct END) AS other_mortality
    FROM global_health_statistics
    WHERE gender IN ('Male', 'Female', 'Other')
    GROUP BY disease_name
) t
ORDER BY (male_mortality - female_mortality) DESC;
Purpose: Compare average mortality between males, females, and others for each disease, ordered by the male–female mortality gap.

16. --Country profile summary (example: Nigeria)--
SELECT
    year,
    SUM(population_affected)    AS total_affected,
    AVG(prevalence_rate_pct)    AS avg_prevalence,
    AVG(mortality_rate_pct)     AS avg_mortality,
    AVG(healthcare_access_pct)  AS avg_healthcare_access,
    AVG(per_capita_income_usd)  AS avg_income
FROM global_health_statistics
WHERE country = 'Nigeria'
GROUP BY year
ORDER BY year;
Purpose: Summarize Nigeria’s health burden, outcomes, and context by year.

17.-- Disease profile summary (example: Malaria)--
SELECT
    year,
    SUM(population_affected)    AS total_affected,
    AVG(prevalence_rate_pct)    AS avg_prevalence,
    AVG(mortality_rate_pct)     AS avg_mortality,
    AVG(recovery_rate_pct)      AS avg_recovery,
    AVG(healthcare_access_pct)  AS avg_healthcare_access
FROM global_health_statistics
WHERE disease_name = 'Malaria'
GROUP BY year
ORDER BY year;
Purpose: Track how Malaria’s burden and outcomes change over time globally.
