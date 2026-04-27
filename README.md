# Global Health Statistics Analysis

This repository contains an analytical exploration of a global health dataset stored in a table called `global_health_statistics`.

The project focuses on:
- Understanding **disease burden** across countries and time.
- Exploring relationships between **health outcomes** and **healthcare capacity**.
- Analyzing the role of **income, education, and demographics** in health.

---

## Dataset Overview

**Table name:** `global_health_statistics`

Each row typically represents a **country–year–disease–demographic** combination.

### Key Columns

- **Context**
  - `country` – Country name.
  - `year` – Year of observation.

- **Disease information**
  - `disease_name` – Name of the disease (e.g., Diabetes, Malaria).
  - `disease_category` – Category (e.g., Infectious, Non-Communicable).

- **Health metrics (% are in percentage points)**
  - `prevalence_rate_pct` – Percentage of population currently affected.
  - `incidence_rate_pct` – Percentage of new cases in a period.
  - `mortality_rate_pct` – Percentage of affected population that dies.
  - `recovery_rate_pct` – Percentage of affected population that recovers.
  - `dalys` – Disability-Adjusted Life Years (burden of disease).
  - `improvement_5y_pct` – Improvement in outcomes over the last 5 years.

- **Population and demographics**
  - `population_affected` – Number of people affected.
  - `age_group` – Age range most affected .
  - `gender` – `Male`, `Female`, `Other`, or `Both`.

- **Healthcare system and access**
  - `healthcare_access_pct` – Share of population with access to healthcare.
  - `doctors_per_1000` – Number of doctors per 1,000 people.
  - `hospital_beds_per_1000` – Number of hospital beds per 1,000 people.

- **Treatment and costs**
  - `treatment_type` – Main treatment approach .
  - `avg_treatment_cost_usd` – Average treatment cost in USD.
  - `availability_of_vaccines_treatment` – Whether vaccine/treatment exists.

- **Socioeconomic indicators**
  - `per_capita_income_usd` – Average income per person, USD.
  - `education_index` – Education indicator (typically 0–1).
  - `urbanization_rate_pct` – Percentage of population in urban areas.

---

## Files in This Repository

- **`README.md`** – This overview document.
- **`sql_queries.md`** – Curated SQL queries for exploring and analyzing the dataset.
  - `data/` – Folder for CSV / SQL dump of `global_health_statistics`.  
  

---

## How to Use

1. **Load the data** into your database system (e.g., PostgreSQL, MySQL, SQLite) and ensure the table is named:

   ```sql
   global_health_statistics
Confirm column names match those listed above.

If your names differ (for example, prevalence_rate instead of prevalence_rate_pct), update the queries accordingly.
Run the analysis queries from:

👉 sql_queries.md

These queries cover:

Countries and diseases most affected.
Trends over time for specific diseases or countries.
Relationships between healthcare access, doctors, beds, and outcomes.
Differences by age group, gender, income level, and education.
Cost and burden analyses (DALYs, treatment cost, recovery).
Example: Quick Start Query
Total population affected by country and year:

SELECT
    country,
    year,
    SUM(population_affected) AS total_population_affected
FROM global_health_statistics
GROUP BY country, year
ORDER BY total_population_affected DESC;
