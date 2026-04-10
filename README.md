# Financial Risk Club Lending
### Lending Club Loan Performance & Credit Risk Analysis (2007–2018)

A full end-to-end analytics pipeline that transforms 2.26 million raw Lending Club loans into actionable credit risk insights — using Python for data cleaning and EDA, SQL for business queries, and Power BI for interactive dashboards.

![Python](https://img.shields.io/badge/Python-3.10-blue) ![SQL](https://img.shields.io/badge/SQL-SQLite-lightgrey) ![PowerBI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow) ![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

---

## Dataset

| Property | Value |
|----------|-------|
| **Source** | [Kaggle — Lending Club Loan Data](https://www.kaggle.com/datasets/wordsforthewise/lending-club) |
| **Period** | 2007 – 2018 |
| **Raw size** | 2.26M loans × 151 columns (5.9 GB) |
| **Cleaned size** | 1.37M loans × 20 columns (90 MB) |
| **Target variable** | `default` — binary (1 = defaulted, 0 = repaid) |
| **Default rate** | 21.47% across the cleaned portfolio |

---

## Pipeline Architecture

```
Raw CSV (2.26M rows, 151 cols, 5.9 GB)
         │
         ▼
┌─────────────────────────────────────────┐
│  Stage 1 — Data Cleaning                │
│  notebooks/01_data_cleaning.ipynb       │
│  Python · pandas · sqlalchemy           │
│                                         │
│  · Select 20 core features              │
│  · Handle missing values                │
│  · Remove current/ambiguous statuses    │
│  · Engineer: default, fico_score,       │
│    purpose_group, credit_history_months │
│  · Optimize memory (5.9 GB → 90 MB)    │
└────────────┬────────────────────────────┘
             │
             ├── cleaned_data.db (SQLite)
             └── cleaned_data.csv
                      │
          ┌───────────┴───────────┐
          ▼                       ▼
┌──────────────────────┐  ┌──────────────────────────┐
│  Stage 2 — SQL       │  │  Stage 3 — EDA            │
│  02_sql_analysis     │  │  03_eda.ipynb             │
│  .ipynb              │  │  Python · seaborn ·       │
│  SQL · ipython-sql   │  │  matplotlib               │
│                      │  │                           │
│  Business queries:   │  │  · Univariate dists.      │
│  · Default by grade  │  │  · Default by category    │
│  · Default by FICO   │  │  · Correlation heatmap    │
│  · Default by income │  │  · Scatter plots          │
│  · Profit by purpose │  │  · Temporal trends        │
│  · Term & DTI bands  │  │                           │
│  · Vintage analysis  │  │                           │
└──────────────────────┘  └───────────┬──────────────┘
                                      │
                          ┌───────────▼──────────────┐
                          │  Stage 4 — Power BI       │
                          │  power_BI/                │
                          │  04_powerbi_report.pbix   │
                          │                           │
                          │  4-page interactive       │
                          │  dashboard connecting     │
                          │  directly to              │
                          │  cleaned_data.csv         │
                          └──────────────────────────┘
```

---

## Project Structure

```
Financial-risk-club-lending/
├── README.md
├── .gitignore                         # Excludes data/ folder and raw files
├── notebooks/
│   ├── 01_data_cleaning.ipynb         # Stage 1 — Data cleaning & feature engineering
│   ├── 02_sql_analysis.ipynb          # Stage 2 — SQL business queries (10 queries)
│   └── 03_eda.ipynb                   # Stage 3 — Exploratory data analysis
└── power_BI/
    └── 04_powerbi_report.pbix         # Stage 4 — 4-page interactive dashboard
```

> **Note:** The `data/` folder is gitignored. Raw and cleaned data files are stored locally only.

---

## Setup

### Requirements

```bash
pip install pandas numpy matplotlib seaborn sqlalchemy ipython-sql
```

### Data

1. Download the Lending Club dataset from [Kaggle](https://www.kaggle.com/datasets/wordsforthewise/lending-club).
2. Create a `data/` folder at the repo root and place the CSV at `data/club_loan_dataset.csv`.

### Run the pipeline

Execute notebooks in order:

```
1. notebooks/01_data_cleaning.ipynb   → produces data/cleaned_data.db + data/cleaned_data.csv
2. notebooks/02_sql_analysis.ipynb    → business queries on cleaned_data.db
3. notebooks/03_eda.ipynb             → visualizations on cleaned_data.csv
4. power_BI/04_powerbi_report.pbix    → open in Power BI Desktop, connect to cleaned_data.db
```

---

## Stage Guide

### Stage 1 — Data Cleaning (`01_data_cleaning.ipynb`)

Transforms the raw 5.9 GB dataset into a clean, analysis-ready 90 MB file.

**Key steps:**
- Select 20 core features from 151 columns
- Drop rows with missing core variables; median-impute DTI and revol_util
- Cap outliers at the 99th percentile
- Engineer binary `default` target from loan status categories
- Consolidate FICO range into single `fico_score`
- Map 14 loan purposes into 6 groups (Debt, Home, Consumer, Business, Health/Education, Other)
- Calculate `credit_history_months` from issue date and earliest credit line
- Optimize dtypes (float64 → float32, category columns)
- Export to `cleaned_data.db` (SQLite) and `cleaned_data.csv`

| Metric | Raw | Cleaned |
|---|---|---|
| Rows | 2,260,701 | 1,371,165 |
| Columns | 151 | 20 |
| Memory | 5.9 GB | 90 MB |
| Missing values | 108,486,252 | 0 |
| Data completeness | 68.22% | 100.00% |

---

### Stage 2 — SQL Business Analysis (`02_sql_analysis.ipynb`)

10 SQL queries on the cleaned SQLite database answer key business questions.

| Query | Key Finding |
|-------|-------------|
| Portfolio overview | 21.47% overall default rate |
| By credit grade (A–G) | 6.7% (A) → 51.4% (G) |
| By FICO band | 10.1% (Excellent) → 25.1% (Fair) |
| By income level | 18.5% (High) → 25.3% (Low) |
| By purpose — default | Business (31.2%) is highest risk |
| By purpose — profit | Debt consolidation: +$302M profit |
| By loan term | 36-month: 17.2% vs 60-month: 34.6% |
| By DTI band | 16.4% (Low) → 31.1% (Very High) |
| By issue year — volume | Portfolio peaked at 377K loans in 2015 |
| By issue year — profit | 2013 golden vintage (+$1,926/loan) → 2016 turn (−$311/loan) → 2018 collapse (−$3,283/loan) |

---

### Stage 3 — Exploratory Data Analysis (`03_eda.ipynb`)

Visual exploration of the cleaned dataset with matplotlib and seaborn.

**Sections:**
1. Univariate distributions (loan amount, interest rate, FICO, DTI)
2. Default rate by purpose group, grade, FICO band, income, and term
3. Correlation heatmap of numeric features
4. Interest rate by grade — defaulted vs non-defaulted
5. FICO vs DTI scatter plot colored by default outcome
6. Loan volume and default rate trends over 2007–2018

---

### Stage 4 — Power BI Dashboard (`04_powerbi_report.pbix`)

4-page interactive dashboard connecting directly to `cleaned_data.db`.

| Page | Title | Story |
|------|-------|-------|
| 1 | **Lending Club Portfolio: Where Risk Erodes Returns** | Is the portfolio healthy? Returns peaked in 2013 and collapsed by 2016 |
| 2 | **Risk by Segment: Not All Borrowers Are Created Equal** | Credit quality creates a 26pp risk spread — worst profile hits 34.86% |
| 3 | **Segment Intersections: Where Grade Meets Purpose, Losses Multiply** | Grade dominates risk — Health/Education + G hits 52.67% default |
| 4 | **A Decade of Drift: Default Rates Nearly Doubled as the Portfolio Scaled** | Volume grew 1,503x then collapsed while default rate silently doubled |

---

## Key Findings

| Finding | Detail |
|---------|--------|
| **1 in 5 loans defaults** | 21.47% portfolio default rate across 1.37M loans |
| **Returns peaked then collapsed** | Return rate peaked at +13.09% in 2013 and collapsed to −21.53% by 2018 |
| **Grade is the top predictor** | A: 6.7% → G: 51.4% default rate |
| **60-month loans are 2× riskier** | 34.6% vs 17.2% default rate |
| **Debt consolidation sustains the portfolio** | Only profitable purpose — every other purpose loses money |
| **Business loans are loss-making** | 31.2% default rate, highest among all purposes |
| **Worst borrower profile** | Health/Education + Grade G = 52.67% default — 2.5× the average |
| **Credit quality gap** | 26pp spread between best (8.66%) and worst (34.86%) segments |
| **Volume explosion then collapse** | Portfolio grew 1,503× from 2007 to 2015 peak, then collapsed |
| **Risk silently climbed** | Default rate rose +9.24pp from 2007 to 2018 despite portfolio shrinking |

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Python · pandas · numpy | Data cleaning, feature engineering |
| matplotlib · seaborn | Exploratory visualizations |
| SQLite · ipython-sql | Business queries on cleaned data |
| sqlalchemy | DataFrame → SQLite export |
| Power BI Desktop | 4-page interactive dashboard |

---

## Author

**Diego Gómez** — Junior Data Analyst
- GitHub: [@diegogomez040](https://github.com/diegogomez040)
- Location: Ubaté, Colombia

---

*This project demonstrates an end-to-end data analytics pipeline: raw data ingestion, cleaning, SQL business analysis, exploratory data analysis, and interactive business intelligence dashboards.*