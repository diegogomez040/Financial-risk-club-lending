# Financial Risk Club Lending
### Lending Club Loan Performance & Credit Risk Analysis (2007–2018)

A full end-to-end analytics pipeline that transforms 2.26 million raw Lending Club loans into actionable credit risk insights — using Python for data cleaning, SQL for business queries, exploratory data analysis for pattern discovery, and Power BI for interactive dashboards.

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

The dataset captures the full history of Lending Club's peer-to-peer loans: borrower credit profiles, loan terms, repayment outcomes, and financial performance.

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
│  02_sql_analysis.ipynb│  │  03_eda.ipynb             │
│  SQL · ipython-sql   │  │  Python · seaborn ·       │
│                      │  │  matplotlib               │
│  Business queries:   │  │                           │
│  · Default by grade  │  │  · Univariate dists.      │
│  · Default by FICO   │  │  · Default by category    │
│  · Default by income │  │  · Correlation heatmap    │
│  · Profit by purpose │  │  · Scatter plots          │
│  · Term & DTI bands  │  │  · Temporal trends        │
└──────────────────────┘  └───────────┬──────────────┘
                                      │
                          ┌───────────▼──────────────┐
                          │  Stage 4 — Power BI Prep  │
                          │  04_powerbi_export.ipynb  │
                          │  Python · pandas          │
                          │                           │
                          │  Exports 7 aggregated     │
                          │  CSV tables → data/powerbi│
                          └───────────┬──────────────┘
                                      │
                          ┌───────────▼──────────────┐
                          │  Power BI Dashboard       │
                          │  4 interactive pages:     │
                          │  Overview · Risk ·        │
                          │  Trends · Profitability   │
                          └──────────────────────────┘
```

---

## Project Structure

```
Financial-risk-club-lending/
├── README.md
├── data/                          # gitignored — local only
│   ├── club_loan_dataset.csv      # Raw Kaggle dataset (place here)
│   ├── cleaned_data.db            # SQLite output (Stage 1)
│   ├── cleaned_data.csv           # CSV output (Stage 1)
│   └── powerbi/                   # Aggregated CSVs for Power BI (Stage 4)
│       ├── 01_portfolio_summary.csv
│       ├── 02_defaults_by_grade.csv
│       ├── 03_defaults_by_purpose.csv
│       ├── 04_defaults_by_year.csv
│       ├── 05_defaults_by_fico.csv
│       ├── 06_defaults_by_term.csv
│       └── 07_defaults_by_dti.csv
├── notebooks/
│   ├── 01_data_cleaning.ipynb     # Stage 1 — Data cleaning & feature engineering
│   ├── 02_sql_analysis.ipynb      # Stage 2 — SQL business queries
│   ├── 03_eda.ipynb               # Stage 3 — Exploratory data analysis
│   └── 04_powerbi_export.ipynb    # Stage 4 — Power BI data export
├── sql/
│   └── queries.sql                # Standalone SQL reference (10 queries)
└── powerbi/
    └── dashboard_notes.md         # Dashboard design guide & layout
```

---

## Setup

### Requirements

```bash
pip install pandas numpy matplotlib seaborn sqlalchemy ipython-sql
```

### Data

1. Download the Lending Club dataset from [Kaggle](https://www.kaggle.com/datasets/wordsforthewise/lending-club).
2. Place the CSV file at `data/club_loan_dataset.csv`.

### Run the pipeline

Execute notebooks in order:

```
1. notebooks/01_data_cleaning.ipynb     → produces cleaned_data.db + cleaned_data.csv
2. notebooks/02_sql_analysis.ipynb      → business queries on cleaned_data.db
3. notebooks/03_eda.ipynb               → visualizations on cleaned_data.csv
4. notebooks/04_powerbi_export.ipynb    → exports 7 CSVs to data/powerbi/
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

**Output:** 1,371,165 rows · 20 columns · 100% complete · 90 MB

---

### Stage 2 — SQL Business Analysis (`02_sql_analysis.ipynb`)

10 SQL queries on the cleaned SQLite database answer key business questions.

| Query | Key Finding |
|-------|-------------|
| Portfolio overview | 21.47% overall default rate |
| By credit grade (A–G) | 6.7% (A) → 51.4% (G) |
| By FICO band | 10.1% (Excellent) → 25.1% (Fair) |
| By income level | 18.5% (High) → 25.3% (Low) |
| By loan size | 16.6% (Small) → 24.5% (Large) |
| By purpose — default | Business (31.2%) is highest risk |
| By purpose — profit | Debt consolidation: +$369M profit |
| By loan term | 36mo: 17.2% vs 60mo: 34.6% |
| By DTI band | 16.4% (Low) → 31.1% (Very High) |
| By issue year | Vintage analysis 2007–2018 |

All queries are also available as standalone SQL in `sql/queries.sql`.

---

### Stage 3 — Exploratory Data Analysis (`03_eda.ipynb`)

Visual exploration of the cleaned dataset with matplotlib and seaborn.

**Sections:**
1. Univariate distributions (loan amount, interest rate, FICO, DTI)
2. Default rate by purpose group, grade, FICO band, income, and term
3. Correlation heatmap of numeric features
4. Interest rate by grade — defaulted vs non-defaulted (box plots)
5. FICO vs DTI scatter plot colored by default outcome
6. Loan volume and default rate trends over 2007–2018
7. Key findings narrative summary

---

### Stage 4 — Power BI Export (`04_powerbi_export.ipynb`)

Exports 7 pre-aggregated CSV tables to `data/powerbi/`, ready to import into Power BI Desktop.

See `powerbi/dashboard_notes.md` for the full 4-page dashboard layout including:
- **Page 1:** Portfolio Overview (KPI cards + volume chart)
- **Page 2:** Risk by Segment (default rates across all dimensions)
- **Page 3:** Portfolio Trends (time-series line charts)
- **Page 4:** Profitability Analysis (profit/loss by grade and purpose)

---

## Key Findings

| Finding | Detail |
|---------|--------|
| **1 in 5 loans defaults** | 21.47% portfolio default rate across 1.37M loans |
| **Grade is the top predictor** | A: 6.7% → G: 51.4% default rate |
| **60-month loans are 2× riskier** | 34.6% vs 17.2% default rate |
| **Debt consolidation dominates** | 79.9% of volume, +$369M net profit |
| **Business loans are loss-making** | 31.2% default rate, –$11.5M loss |
| **DTI predicts default monotonically** | Low DTI (<10): 16.4% → Very High (30+): 31.1% |
| **Portfolio peaked in 2015–2016** | Then declined; average loan size grew steadily |

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Python · pandas · numpy | Data cleaning, feature engineering, exports |
| matplotlib · seaborn | Exploratory visualizations |
| SQLite · ipython-sql | Business queries on cleaned data |
| sqlalchemy | DataFrame → SQLite export |
| Power BI Desktop | Interactive dashboards |