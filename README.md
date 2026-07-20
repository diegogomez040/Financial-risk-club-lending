# Financial Risk Club Lending
### Lending Club Loan Performance & Credit Risk Analysis (2007–2018)

A full end-to-end analytics and credit risk modelling pipeline that transforms 2.26 million raw Lending Club loans into actionable credit risk insights — using Python for data cleaning and EDA, SQL for business queries, Power BI for interactive dashboards, and scikit-learn / LightGBM for a Basel II/III Expected Loss model.

![Python](https://img.shields.io/badge/Python-3.10-blue) ![SQL](https://img.shields.io/badge/SQL-SQLite-lightgrey) ![PowerBI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow) ![scikit-learn](https://img.shields.io/badge/scikit--learn-1.x-orange) ![LightGBM](https://img.shields.io/badge/LightGBM-4.x-green) ![Basel II](https://img.shields.io/badge/Basel%20II%2FIII-EL%20Framework-red) ![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

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
│  01 Analysis/01_data_cleaning.ipynb     │
│  Python · pandas · sqlalchemy           │
│                                         │
│  · Select 20 core features              │
│  · Handle missing values                │
│  · Remove current/ambiguous statuses    │
│  · Engineer: default, fico_score,       │
│    ever_delinq, credit_history_months   │
│  · Keep purpose at full 14-category     │
│    granularity (WoE-encoded in Stage 5) │
│  · Optimize memory (5.9 GB → 90 MB)    │
└────────────┬────────────────────────────┘
             │
             ├── cleaned_data.db (SQLite)
             └── cleaned_data.csv
                      │
          ┌───────────┴───────────────────────────────────────┐
          ▼                       ▼                           ▼
┌──────────────────────┐  ┌──────────────────────────┐  ┌─────────────────────────────────────────────┐
│  Stage 2 — SQL       │  │  Stage 3 — EDA            │  │  Stage 5 — Data Preparation (Modelling)     │
│  02_sql_analysis     │  │  03_eda.ipynb             │  │  03 Modeling/05_data_preparation.ipynb      │
│  .ipynb              │  │  Python · seaborn ·       │  │  Python · pandas · scikit-learn             │
│  SQL · ipython-sql   │  │  matplotlib               │  │                                             │
│                      │  │                           │  │  · Remove leakage (total_pymnt only)        │
│  Business queries:   │  │  · Univariate dists.      │  │  · Drop int_rate/installment                │
│  · Default by grade  │  │  · Default by category    │  │    (multicollinearity, r ≥ 0.95)             │
│  · Default by FICO   │  │  · Correlation heatmap    │  │  · Out-of-time split: train 2007–2016 /     │
│  · Default by income │  │  · Scatter plots          │  │    test 2017–2018                           │
│  · Profit by vintage │  │  · Temporal trends        │  │  · Export 6 parquet files                   │
│  · Term & DTI bands  │  │                           │  └──────────────┬──────────────────────────────┘
│  · Vintage analysis  │  │                           │                 │
└──────────────────────┘  └───────────┬──────────────┘    ┌────────────┴─────────────────────────────┐
                                      │                    ▼                                         ▼
                          ┌───────────▼──────────────┐  ┌────────────────────────┐  ┌────────────────────────┐
                          │  Stage 4 — Power BI       │  │  Stage 6 — PD Model    │  │  Stage 7 — LGD Model   │
                          │  02 Power_BI/             │  │  06_PD_model.ipynb     │  │  07_LGD_model.ipynb    │
                          │  04_powerbi_report.pbix   │  │  Logistic Regression   │  │  LightGBM severity     │
                          │                           │  │  LightGBM              │  │  regressor             │
                          │  4-page interactive       │  │                        │  │                        │
                          │  dashboard connecting     │  │  Test AUC:  0.6831     │  │  Test MAE:  0.2163     │
                          │  directly to               │  │  Test KS:   0.2667     │  │  vs baseline: −19%     │
                          │  cleaned_data.csv/.db     │  └──────────┬─────────────┘  └──────────┬─────────────┘
                          └──────────────────────────┘             │                            │
                                                         ┌──────────▼─────────────┐             │
                                                         │  Stage 8 — EAD Model   │             │
                                                         │  08_EAD_model.ipynb    │             │
                                                         │  LightGBM CCF model    │             │
                                                         │  + amortisation formula│             │
                                                         │                        │             │
                                                         │  Test MAE:  0.1908     │             │
                                                         │  vs baseline: −7%      │             │
                                                         └──────────┬─────────────┘             │
                                                                    │                            │
                                                         ┌──────────▼────────────────────────────▼──────┐
                                                         │  Stage 9 — Portfolio Expected Loss            │
                                                         │  09_Expected_Loss_portfolio.ipynb             │
                                                         │  EL = PD × LGD × EAD                         │
                                                         │                                               │
                                                         │  Portfolio EL: $2,806M on $19.84B volume      │
                                                         │  Mean EL rate: 13.10%                         │
                                                         │  Grade A: 5.33% → Grade G: 34.52%            │
                                                         └───────────────────────────────────────────────┘
```

---

## Project Structure

```
Financial-risk-club-lending/
├── README.md
├── .gitignore                          # Excludes data/ folder and raw files
├── 01 Analysis/
│   ├── 01_data_cleaning.ipynb          # Stage 1 — Data cleaning & feature engineering
│   ├── 02_sql_analysis.ipynb           # Stage 2 — SQL business queries (10 queries)
│   └── 03_eda.ipynb                    # Stage 3 — Exploratory data analysis
├── 02 Power_BI/
│   ├── 04_powerbi_report.pbix          # Stage 4 — 4-page interactive dashboard
│   └── 04_powerbi_report.pdf           # Stage 4 — Static export of the dashboard
└── 03 Modeling/
    ├── 05_data_preparation.ipynb       # Stage 5 — Feature selection, OOT split, leakage removal
    ├── 06_PD_model.ipynb               # Stage 6 — Probability of Default (LR champion)
    ├── 07_LGD_model.ipynb              # Stage 7 — Loss Given Default (LightGBM severity)
    ├── 08_EAD_model.ipynb              # Stage 8 — Exposure at Default (CCF + amortisation)
    ├── 09_Expected_Loss_portfolio.ipynb # Stage 9 — EL = PD × LGD × EAD, portfolio view
    ├── credit_risk_report.docx         # Professional report — Stages 5–9
    └── models/                         # Saved model artefacts (.pkl)
        ├── pd_model.pkl
        ├── pd_scaler.pkl
        ├── lgd_severity_model.pkl
        └── ead_model.pkl

data/                                    # Gitignored — populated by running the notebooks
├── club_loan_dataset.csv               # Raw Kaggle download
├── cleaned_data.db / cleaned_data.csv  # Stage 1 output
└── processed/                          # Stage 5–9 parquet splits, scores, and chart images
```

> **Note:** The `data/` folder is gitignored. Raw and cleaned data files are stored locally only.

---

## Setup

### Requirements

```bash
# EDA & SQL stages (1–4)
pip install pandas numpy matplotlib seaborn sqlalchemy ipython-sql

# Modelling stages (5–9)
pip install scikit-learn lightgbm pyarrow joblib
```

### Data

1. Download the Lending Club dataset from [Kaggle](https://www.kaggle.com/datasets/wordsforthewise/lending-club).
2. Create a `data/` folder at the repo root and place the CSV at `data/club_loan_dataset.csv`.

### Run the pipeline

Execute notebooks in order:

```
# EDA & business intelligence
1. 01 Analysis/01_data_cleaning.ipynb         → produces data/cleaned_data.db + data/cleaned_data.csv
2. 01 Analysis/02_sql_analysis.ipynb          → business queries on cleaned_data.db
3. 01 Analysis/03_eda.ipynb                   → visualizations on cleaned_data.csv
4. 02 Power_BI/04_powerbi_report.pbix         → open in Power BI Desktop, connect to cleaned_data.db

# Basel II/III Expected Loss modelling
5. 03 Modeling/05_data_preparation.ipynb        → produces data/processed/*.parquet train/test splits
6. 03 Modeling/06_PD_model.ipynb                → produces models/pd_model.pkl + data/processed/pd_scores.parquet
7. 03 Modeling/07_LGD_model.ipynb               → produces models/lgd_severity_model.pkl + lgd_scores.parquet
8. 03 Modeling/08_EAD_model.ipynb               → produces models/ead_model.pkl + ead_scores.parquet
9. 03 Modeling/09_Expected_Loss_portfolio.ipynb → portfolio EL aggregation and reporting
```

---

## Stage Guide

### Stage 1 — Data Cleaning (`01_data_cleaning.ipynb`)

Transforms the raw 5.9 GB dataset into a clean, analysis-ready 90 MB file.

**Key steps:**
- Select 20 core features from 151 columns
- Drop rows with missing core variables; median-impute DTI and revol_util
- Cap outliers at the 99th percentile
- Engineer binary `default` target from loan status categories (`Current`/`In Grace Period` loans excluded as outcome-unresolved)
- Consolidate FICO range into single `fico_score`
- Derive `ever_delinq` (pre-origination delinquency flag) and `credit_history_months`
- Keep `purpose` at full 14-category granularity — default rates vary meaningfully within broader groupings (e.g. `small_business` 31.5% vs. `renewable_energy` 25.1%); WoE encoding is deferred to Stage 5, fit on training data only
- Optimize dtypes (float64 → float32, category columns)
- Export to `cleaned_data.db` (SQLite) and `cleaned_data.csv`

| Metric | Raw | Cleaned |
|---|---|---|
| Rows | 2,260,701 | 1,371,165 |
| Columns | 151 | 20 |
| Memory | 5,992 MB | 90 MB |
| Missing values | 108,486,252 | 0 |
| Data completeness | 68.22% | 100.00% |

---

### Stage 2 — SQL Business Analysis (`02_sql_analysis.ipynb`)

SQL queries on the cleaned SQLite database answer key business questions across default rate, credit quality, and profitability.

| Query | Key Finding |
|-------|-------------|
| Portfolio overview | 21.47% overall default rate |
| By credit grade (A–G) | 6.7% (A) → 51.4% (G) |
| By FICO band | 10.1% (Excellent) → 25.1% (Fair) |
| By income level | 18.5% (High) → 25.3% (Low) |
| By purpose | `small_business` highest risk (~31.5%); `debt_consolidation` dominant by volume (~58%, 22.6% default) |
| By loan term | 36-month: 17.2% vs 60-month: 34.6% |
| By DTI band | 16.4% (Low) → 31.1% (Very High) |
| Grade × DTI × FICO compounding | Grade G + Very High DTI + Fair FICO = 60.29% — 2.8× the portfolio average |
| By issue year — volume | Portfolio peaked at 377K loans in 2015 |
| By issue year — profit | 2013 golden vintage (+$1,926/loan) → 2016 turn (−$311/loan) → 2018 collapse (−$3,283/loan) |

---

### Stage 3 — Exploratory Data Analysis (`03_eda.ipynb`)

Visual confirmation and interaction-effect analysis that SQL alone can't show — where Stage 2 quantifies risk one dimension at a time, this notebook tests whether risk compounds continuously and whether any single variable cleanly separates defaulters from payers.

**Sections:**
1. Default rate by category (purpose, grade, FICO, term, DTI) — volume and rate side by side
2. Bivariate & correlation analysis — correlation heatmap, interest rate by grade, FICO × interest rate scatter, combined risk surfaces (income × grade, FICO × term)
3. Temporal analysis — loan volume and grade-mix evolution over 2007–2018
4. Key Findings — five-finding synthesis motivating the Phase 2 modelling approach

---

### Stage 4 — Power BI Dashboard (`04_powerbi_report.pbix`)

4-page interactive dashboard connecting directly to `cleaned_data.db`/`cleaned_data.csv`.

| Page | Title | Story |
|------|-------|-------|
| 1 | **Lending Club Portfolio: Where Risk Erodes Returns** | Is the portfolio healthy? Returns peaked at 13.09% in 2013 and collapsed to −21.53% by 2018 |
| 2 | **Risk by Segment: Not All Borrowers Are Created Equal** | Grade, DTI, and FICO combined produce a 56.02pp risk gap — worst profile hits 60.29% |
| 3 | **Risk Intersections: No Single Factor Tells the Whole Story** | Purpose × Grade, FICO × Term, and Income × Grade — `debt_consolidation` + Grade G hits 52.98% |
| 4 | **A Decade of Drift: Risk Climbed as Volume Scaled** | Volume grew 1,503× (2007–2015) then contracted while default rate climbed from 12.60% to 27.21% |

---

### Stage 5 — Data Preparation for Modelling (`05_data_preparation.ipynb`)

Prepares the cleaned dataset for Basel II/III credit risk modelling with strict leakage controls, a multicollinearity check, and an out-of-time validation split.

**Key steps:**
- Remove post-outcome leakage: `total_pymnt` (only observable after the loan outcome is known). `ever_delinq` is a pre-origination credit-history flag and is correctly retained as a feature.
- Drop `int_rate` and `installment` for multicollinearity — near-duplicates of `grade` (r = 0.955) and `loan_amnt` (r = 0.954) respectively, verified on the training set only
- Apply out-of-time split: **train 2007–2016** / **test 2017–2018**
- Encode `grade` as a numeric ordinal scale and `purpose` via Weight-of-Evidence (fit on train only)
- Export train/test splits to parquet for downstream modelling stages — final modelling feature count: **15**

| Split | Loans | Share | Default Rate |
|-------|-------|-------|-------------|
| Train (2007–2016) | 1,127,206 | 82.2% | 20.23% |
| Test (2017–2018)  | 243,959   | 17.8% | 27.20%* |
| **Total**         | **1,371,165** | **100%** | **21.47%** |

*Test default rate is elevated due to loan maturity censoring — `Current` loans are excluded from the dataset, so the 2017–2018 cohort over-represents fast-resolving early defaults relative to still-performing loans that haven't reached full term.

---

### Stage 6 — Probability of Default Model (`06_PD_model.ipynb`)

Binary classification model predicting the likelihood a borrower will default, using the 15-feature set from Stage 5.

**Models compared:**

| Model | Train AUC | Test AUC | Test KS | AUC Gap | Decision |
|-------|-----------|----------|---------|---------|----------|
| Logistic Regression | 0.7060 | **0.6831** | **0.2667** | 0.0229 | **Champion** |
| LightGBM | 0.7062 | 0.6800 | 0.2646 | 0.0262 | Challenger |

Logistic Regression was selected as champion: better out-of-time generalisation (smaller train-test AUC gap) and higher KS statistic. `grade`'s coefficient (0.410) is the largest in the model — it absorbed most of `int_rate`'s signal once that column was dropped in Stage 5. `class_weight='balanced'` improves discrimination but inflates predicted probabilities above the empirical default rate — see calibration note in Stage 9.

---

### Stage 7 — Loss Given Default Model (`07_LGD_model.ipynb`)

Regression model predicting the fraction of outstanding balance lost in the event of default. Estimated on defaulted loans only (294,415 loans).

**Two-stage approach explored:**

A cure rate classifier was tested first (loans with LGD < 5% = "cured"). Temporal censoring made this infeasible out-of-time:

| Split | Mean LGD | Cure Rate |
|-------|----------|-----------|
| Train (2007–2016) | 0.4117 | 12.59% |
| Test (2017–2018)  | 0.6584 | 0.37%  |

Cure classifiers achieved near-random AUCs on the test set (Logistic Regression: 0.569, LightGBM: 0.506). Final model is a **severity-only LightGBM regressor** trained on non-cured training loans.

**Severity model results:**

| Approach | Test MAE | Test RMSE | vs Baseline |
|----------|----------|-----------|-------------|
| Mean baseline | 0.2678 | 0.3061 | — |
| Single-stage LightGBM | 0.2554 | 0.2938 | −5% |
| **Severity model (champion)** | **0.2163** | **0.2533** | **−19%** |

---

### Stage 8 — Exposure at Default Model (`08_EAD_model.ipynb`)

Models the outstanding principal balance at the moment of default using an amortisation-based Credit Conversion Factor (CCF).

**Amortisation formula:**

```
B(k) = loan_amnt × (1 + r)^k − installment × [(1 + r)^k − 1] / r

where r = int_rate / 12  (monthly rate)
      k = payments made before default  (estimated from total_pymnt / installment)
      CCF = EAD / loan_amnt
```

The same censoring pattern as LGD appears in EAD (fast defaults = more principal outstanding):

| Metric | Train (2007–2016) | Test (2017–2018) |
|--------|-------------------|------------------|
| Mean EAD ($) | $9,879 | $13,312 |
| Mean CCF | 0.6164 | 0.8005 |
| Median payments made (k) | 19 | 10 |

**CCF model results:**

| Approach | Test MAE | Test RMSE | vs Baseline |
|----------|----------|-----------|-------------|
| Mean baseline | 0.2048 | 0.2298 | — |
| Grade × Term segments | 0.2045 | 0.2311 | 0% |
| **LightGBM (champion)** | **0.1908** | **0.2168** | **−7%** |

---

### Stage 9 — Portfolio Expected Loss (`09_Expected_Loss_portfolio.ipynb`)

Combines PD × LGD × EAD scores across all 1.37M loans to produce a portfolio-level Expected Loss estimate under the Basel II/III framework.

**Portfolio summary:**

| Metric | Value |
|--------|-------|
| Total loan volume | $19.84B |
| Total predicted EL | $2,806M |
| Mean EL rate | 13.10% |
| Train predicted EL | $2,268M |
| Train actual losses | $1,478M |
| Calibration ratio (train) | 1.54× |

**EL rate by grade (monotonically increasing — model validity check):**

| Grade | Mean EL Rate | Total EL ($M) | % of Portfolio EL |
|-------|-------------|---------------|-------------------|
| A | 5.33% | $176M | 6.3% |
| B | 9.18% | $501M | 17.9% |
| C | 14.03% | $816M | 29.1% |
| D | 18.78% | $621M | 22.1% |
| E | 24.61% | $431M | 15.4% |
| F | 29.99% | $192M | 6.9% |
| G | **34.52%** | $68M | 2.4% |

Grade G carries **6.5× the EL rate of grade A**. `debt_consolidation` dominates concentration risk at **64.5% of total portfolio EL** ($1,811M) despite a near-average EL rate (13.87%) — pure volume effect (795,338 loans, 58% of originations). `credit_card` adds a further 18.8%; together the two refinancing purposes account for 83.3% of total EL. Calibration ratio of 1.54× is attributed to `class_weight='balanced'` in the PD model inflating predicted probabilities. Platt scaling is identified as the primary next step.

---

## Key Findings

| Finding | Detail |
|---------|--------|
| **1 in 5 loans defaults** | 21.47% portfolio default rate across 1.37M loans |
| **Returns peaked then collapsed** | Return rate peaked at +13.09% in 2013 and collapsed to −21.53% by 2018 |
| **Grade is the top predictor** | A: 6.7% → G: 51.4% default rate — a 44.7pp spread, wider than any other variable |
| **60-month loans are 2× riskier** | 34.6% vs 17.2% default rate, and the gap compounds with FICO |
| **Debt consolidation anchors the portfolio** | ~58% of volume at a near-average 22.6% default rate — the segment that most moves the headline number |
| **Small business is the highest-risk purpose** | 31.5% default rate, ~10pp above the portfolio average |
| **Risk compounds across dimensions** | Grade G + Very High DTI + Fair FICO = 60.29% default — 2.8× the portfolio average, higher than any single factor |
| **No single variable cleanly separates defaults** | FICO is the strongest independent numeric signal; multi-variable scoring is required |
| **Volume explosion then collapse** | Portfolio grew 1,503× from 2007 to the 2015 peak, then contracted through 2018 |
| **Risk rose through mix shift and within-grade deterioration** | Grade C rose from 19% (2007) to 32% (2018); Grade F from 29% to 55% — within-grade deterioration is the larger driver |
| **EL grade monotonicity confirmed** | EL rate strictly increases A (5.33%) → G (34.52%) — 6.5× spread |
| **Volume concentration in debt consolidation** | 64.5% of total EL ($1,811M of $2,806M) driven by volume, not the highest risk rate |
| **Censoring limits LGD/EAD evaluation** | 2017–2018 test defaults are the fast-resolving minority of that vintage — distribution shift documented and carried through Stage 9 |
| **PD over-predicts by 1.54×** | `class_weight='balanced'` inflates probabilities; Platt scaling recommended |

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Python · pandas · numpy | Data cleaning, feature engineering |
| matplotlib · seaborn | Exploratory visualizations |
| SQLite · ipython-sql | Business queries on cleaned data |
| sqlalchemy | DataFrame → SQLite export |
| Power BI Desktop | 4-page interactive dashboard |
| scikit-learn | Logistic Regression PD model, preprocessing |
| LightGBM | LGD severity model, EAD CCF model |
| pyarrow · parquet | Efficient scored-dataset storage between stages |

---

## Author

**Diego Gómez** — Junior Data Analyst
- GitHub: [@diegogomez040](https://github.com/diegogomez040)
- Location: Ubaté, Colombia

---

*This project demonstrates a complete data analytics and credit risk modelling pipeline: raw data ingestion, cleaning, SQL business analysis, exploratory data analysis, interactive BI dashboards, and a Basel II/III Expected Loss model (PD · LGD · EAD) validated out-of-time on 1.37 million Lending Club loans.*
