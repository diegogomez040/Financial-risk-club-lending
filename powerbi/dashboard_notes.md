# Power BI Dashboard Design Guide
## Lending Club Loan Performance & Risk Analysis (2007–2018)

This guide describes the recommended layout, data connections, visuals, KPI cards, and analytical context for the interactive Power BI dashboard. It reflects all findings from `02_sql_analysis.ipynb` and `03_eda.ipynb`, including the bivariate interaction analysis and temporal vintage findings added in the most recent notebook revision.

## Key Analytical Benchmarks

Reference these numbers when writing chart titles, tooltips, and KPI card subtitles. Every chart title should state the finding, not the topic.

| Metric | Value | Source |
|---|---|---|
| Portfolio default rate | **21.47%** | `02_sql_analysis` §2.1 |
| Grade A default rate | **6.7%** | `02_sql_analysis` §2.2 |
| Grade G default rate | **51.4%** | `02_sql_analysis` §2.2 |
| Grade A–G spread | **44.7 pp** | `03_eda` §3 takeaways |
| FICO Fair (600–699) default rate | **25.1%** — 61% of volume | `02_sql_analysis` §2.3 |
| FICO Excellent (750+) default rate | **10.1%** | `02_sql_analysis` §2.3 |
| 36-month default rate | **17.2%** | `02_sql_analysis` §4.1 |
| 60-month default rate | **34.6%** (2× multiplier) | `02_sql_analysis` §4.1 |
| DTI Low (<10) default rate | **16.4%** | `02_sql_analysis` §4.2 |
| DTI Very High (30+) default rate | **31.1%** | `02_sql_analysis` §4.2 |
| Business loans default rate | **31.2%** | `02_sql_analysis` §3.1 |
| Debt consolidation share | **79.9% of volume** | `02_sql_analysis` §3.1 |
| Debt consolidation profit | **+$302M** | `02_sql_analysis` §3.2 |
| Business loans profit | **−$13.3M** | `02_sql_analysis` §3.2 |
| Consumer loans profit | **−$13.3M** | `02_sql_analysis` §3.2 |
| Best vintage (avg profit/loan) | **2013: $1,926/loan** | `02_sql_analysis` §5.3 |
| Peak volume year | **2015: 377K loans** | `02_sql_analysis` §5.1 |
| Loss-making vintages | **2016–2018** | `02_sql_analysis` §5.3 |
| Worst vintage avg profit/loan | **2018: −$3,283/loan** | `02_sql_analysis` §5.3 |
| Grade vs. int_rate correlation | **r ≈ 0.95** (multicollinear) | `03_eda` §4.1 |
| Income band spread (low → high) | **6.8 pp** (weak predictor) | `03_eda` §3.4 |

---

## Dashboard Pages

### Page 1 — Portfolio Overview

**Purpose:** Executive summary. A business leader should walk away from this page understanding the portfolio scale, the headline default rate, and the top two risk concentrations — in under 60 seconds.

#### KPI Cards (single row across the top)

| Card | Field | Format | Subtitle (embed in card) |
|---|---|---|---|
| Total Loans | `total_loans` | `1,371,165` | "Across 2007–2018" |
| Total Funded | `total_funded_M` | `$X.X Billion` | "Principal originated" |
| Overall Default Rate | `default_rate_pct` | `21.47%` | "~1 in 5 loans defaults" |
| Total Net Profit | `total_profit_M` | `$X.X Million` | "Interest − principal losses" |
| Avg Interest Rate | `avg_int_rate_pct` | `X.X%` | — |
| Avg FICO Score | `avg_fico_score` | `XXX` | "Portfolio median" |

#### Charts

1. **Donut chart** — Defaulted vs. Non-Defaulted loans
   - *Why donut:* Part-to-whole composition — makes the 21.5% minority class immediately visible to a non-technical audience.
   - Values: `total_defaults` vs. `total_loans − total_defaults`
   - Labels: show both count and percentage
   - Colors: Non-Default `#2ca02c`, Default `#d62728`

2. **Clustered bar chart** — Default Rate vs. Volume Share by Grade
   - *Why clustered bar:* Simultaneously shows that B+C dominate volume (57%) AND that D–G carry rates 2–7× above Grade A — neither fact alone tells the full story.
   - Primary axis (bars): `loans` (volume) — color A→G green-to-red gradient
   - Secondary axis (line): `default_rate_pct`
   - **Title:** *"Grades B and C Hold 57% of Volume — But C Already Exceeds the Portfolio Average"*
   - Add reference line at 21.47% on the default rate axis

3. **Text box** — Analytical context block
   - Include: data source, date range, class imbalance note (78.5% / 21.5%)
   - Bias note: *"2017–2018 default rates are lower-bound estimates — many loans in these vintages are still active."*

---

### Page 2 — Risk by Segment

**Purpose:** Deep-dive into default rate drivers across all key risk dimensions. This page answers: *where is default risk concentrated, and which segments exceed the portfolio average?*

#### Layout: 2×3 chart grid + slicer panel

**Top row:**

1. **Horizontal bar chart** — Default Rate by Purpose Group
   - *Why horizontal bar:* Long category labels are readable; bars rank from highest to lowest risk.
   - Sort: descending by `default_rate_pct`
   - Color: green if below 21.47%, red if above
   - Add reference line at portfolio average (21.47%)
   - **Title:** *"Business Loans Default at 31.2% — 10pp Above Portfolio Average"*
   - Tooltip: show `loans`, `default_rate_pct`, `pct_of_portfolio`

2. **Bar chart** — Default Rate by Credit Grade
   - Sort: A → G (fixed, not by rate — preserves the monotonic story)
   - Color: gradient green (`#2ca02c`) → red (`#a50026`) across A–G
   - Add reference line at 21.47%
   - **Title:** *"Grade Is the Strongest Single Predictor — 44.7pp Spread from A to G"*
   - Data labels: show rate on each bar

3. **Bar chart** — Default Rate by Term
   - Only two bars (36-month, 60-month)
   - **Title:** *"60-Month Loans Default at 2× the Rate of 36-Month Loans"*
   - Add annotation: "34.6% vs. 17.2%"
   - Tooltip: add note — *"Term selection signals constrained cash flow — distinct underwriting criteria warranted"*

**Bottom row:**

4. **Bar chart** — Default Rate by FICO Band
   - Sort: Poor → Fair → Good → Excellent (use `sort_order` field)
   - Color: red → orange → light green → green
   - Add reference line at 21.47%
   - **Title:** *"Fair FICO Borrowers (61% of Volume) Default at 25.1% — the Highest-Leverage Segment"*
   - Tooltip: include volume share (`pct_of_portfolio`)

5. **Bar chart** — Default Rate by DTI Band
   - Sort: Low → Medium → High → Very High
   - Color: green → yellow → orange → red
   - Add reference line at 21.47%
   - **Title:** *"DTI Above 30 Doubles Default Risk vs. Low-DTI Borrowers"*
   - Tooltip: annotate the cliff from High → Very High (+6.6 pp)

6. **Matrix / Table** — Full grade breakdown
   - Columns: `grade`, `loans`, `defaults`, `default_rate_pct`, `avg_int_rate`, `profit`
   - Conditional formatting on `default_rate_pct`: green (<21.47%) / red (>21.47%)
   - Conditional formatting on `profit`: green (positive) / red (negative)
   - Sort: Grade A → G

#### Slicers (left filter panel)
- Grade (multi-select checkboxes)
- Purpose Group (dropdown)
- Loan Term (toggle: 36 / 60)

> **Dashboard warning:** When the Grade slicer is active and filters to D–G only, the "portfolio average" reference lines should dynamically update. Use a DAX measure for the reference value, not a hardcoded 21.47%.

---

### Page 3 — Portfolio Trends

**Purpose:** Time-series view of how the portfolio evolved — volume, default rates, credit quality, and profitability — from 2007 to 2018. Key story: growth came at the cost of credit quality.

#### Charts (stacked vertically)

1. **Line & Clustered Column combo chart** — Volume and Vintage Default Rate
   - Bars: `loans` (left Y-axis, volume in thousands)
   - Line: `default_rate_pct` (right Y-axis)
   - X-axis: `issue_year`
   - Add horizontal reference line at 21.47% on the rate axis
   - **Title:** *"Volume Peaked in 2015 at 377K Loans — Default Rates Had Already Been Rising Since 2013"*
   - **Tooltip:** include `avg_fico`, `avg_loan_amnt`, `avg_int_rate`
   - ⚠️ **Add annotation box on 2017–2018 bars:** *"Lower-bound estimate — loans still active"*

2. **Heatmap (Matrix visual)** — Default Rate by Grade × Vintage Year
   - Rows: Grade (A → G)
   - Columns: `issue_year`
   - Values: `default_rate_pct`
   - Color: RdYlGn_r (red = high default, green = low)
   - **Title:** *"Earlier Vintages and Lower Grades Carry the Highest Realized Default Rates"*
   - *Why heatmap:* Two-variable relationship across a third dimension — instantly reveals whether within-grade quality held across years or deteriorated.
   - ⚠️ Add footnote: *"2007–2010 rates are fully matured. 2017–2018 will increase as loans complete their term."*

3. **Line chart** — Profit per Loan by Vintage Year
   - Y-axis: `avg_profit_per_loan` (format as currency)
   - Add zero reference line
   - Color segments: above zero `#2ca02c`, below zero `#d62728`
   - Annotate: peak ($1,926 in 2013), collapse ($505 in 2015), loss turn (2016: negative)
   - **Title:** *"Profit per Loan Fell 74% from 2013 to 2015 — Platform Turned Loss-Making in 2016"*

#### Slicer
- Year range slider (2007–2018)

> **Interpretive warning to include as a tooltip or text box on this page:**
> *"Vintage default rates are subject to maturity bias: older vintages (2007–2012) are fully seasoned and their rates are final. Vintages 2015–2018 still have active loans whose defaults have not yet been recorded. Do not compare recent vintages to older ones without this adjustment."*

---

### Page 4 — Profitability Analysis

**Purpose:** Compare profit and loss across credit grade and loan purpose. Answers: *which segments create value, and which destroy it?*

#### Charts

1. **Horizontal bar chart** — Profit by Purpose Group
   - Sort: descending by `profit`
   - Conditional formatting: positive bars `#2ca02c`, negative bars `#d62728`
   - Data labels: show `$XM` on each bar
   - **Title:** *"Debt Consolidation Generates $302M — All Other Purpose Groups Except Home Are Loss-Making"*
   - Tooltip: include `default_rate_pct`, `loans`, `pct_of_portfolio`

2. **Bar chart** — Profit by Credit Grade
   - Sort: A → G
   - Conditional formatting: same green/red
   - **Title:** *"Grade A–C Are Profitable — Grades D–G Destroy Portfolio Value"*
   - Data labels: profit in $M per grade

3. **Scatter chart** — Default Rate vs. Profit by Grade (Risk-Return Map)
   - X-axis: `default_rate_pct`
   - Y-axis: `profit`
   - Bubble size: `loans` (portfolio volume)
   - Color by `grade` (A→G gradient)
   - Add quadrant lines at 21.47% (X) and $0 (Y)
   - **Title:** *"Grades A–C: Low Risk and Profitable. Grades D–G: High Risk and Loss-Making"*
   - *Why scatter:* The risk-return relationship is multidimensional — grade, profitability, and volume are each visible simultaneously. The quadrant lines create an instantly readable danger zone.
   - Tooltip: label each bubble with the grade letter

4. **KPI card** — Total portfolio net profit
   - Source: `total_profit_M` from `01_portfolio_summary.csv`
   - Subtitle: *"Driven almost entirely by Debt consolidation (+$302M)"*

> **Business translation for stakeholders (use as a text annotation on this page):**
> *"Business loans generate interest revenue but default at 31.2% — high enough that principal losses exceed interest collected. A 10pp rate increase on Business loans, or an exit from the segment, would eliminate −$13.3M in annual losses with minimal impact on portfolio volume."*

---

### Page 5 — Risk Interactions

**Purpose:** Show that no single variable cleanly separates defaulters from payers — and that the combination of grade, FICO, and DTI is what drives risk. This page is the most analytically dense; target audience is credit risk officers, not general management.

> **Required data exports** (not yet in `data/powerbi/`): export the following aggregates from `03_eda.ipynb` Section 4:
> - Income band × Grade default rate pivot (3×7 matrix)
> - Income band × DTI band default rate pivot (3×3 matrix)
> - FICO score vs. DTI sample for scatter (10K row sample, `fico_score`, `dti`, `default`)

#### Charts

1. **Heatmap (Matrix visual)** — Income Band × Credit Grade Default Rate
   - Rows: Income band (Low / Mid / High)
   - Columns: Grade (A → G)
   - Values: default rate (%)
   - Color: RdYlGn_r
   - **Title:** *"High Income Does Not Protect in Grades D–G — Grade Dominates Income as a Risk Signal"*
   - Key insight to surface in tooltip: *"A high-income borrower in Grade F carries ~48% default rate. A low-income borrower in Grade A carries ~7%."*

2. **Heatmap (Matrix visual)** — Income Band × DTI Band Default Rate
   - Rows: Income band
   - Columns: DTI band (Low / Mid / High)
   - Color: same scale as above (RdYlGn_r)
   - **Title:** *"Low Income + High DTI Compounds Risk — the Combination Is More Dangerous Than Either Alone"*

3. **Scatter chart** — FICO Score vs. DTI (colored by default outcome)
   - X-axis: `fico_score`
   - Y-axis: `dti`
   - Color: Default = red (`#d62728`), No Default = light blue (`#1f77b4`), opacity 40%
   - Note: use a 10K-row sample for performance
   - Add reference lines: FICO = 700 (vertical), DTI = 20 (horizontal)
   - **Title:** *"Defaults Cluster in Low-FICO / High-DTI Space — But No Single Threshold Separates Them"*
   - Add text annotation: *"Heavy overlap at FICO 650–700 / DTI 15–30 — this is the ambiguous zone where multi-variable scoring outperforms single cutoffs"*

4. **Boxplot** — Interest Rate by Grade (Default vs. Non-Default)
   - X-axis: Grade (A → G)
   - Y-axis: Interest rate (%)
   - Split by default outcome (two box plots per grade)
   - **Title:** *"Defaulted Loans Carry Higher Median Rates Within Every Grade — Rate Deviation Signals Intra-Grade Risk"*
   - Business translation tooltip: *"Borrowers assigned a rate above their grade's median were already flagged as higher-risk by the platform's pricing engine — this is a usable feature for risk scoring."*

> **Multicollinearity warning (add as a text box):**
> *"Grade and interest rate have r ≈ 0.95 — they carry the same information. Do not display or filter by both simultaneously, as this creates misleading double-counting of the same risk signal."*

#### Slicers
- Loan Term (to test whether interactions hold within term)
- Issue Year range (to test whether interactions were stable over time)

---

## Formatting Guidelines

### Color Palette

| Usage | Color | Hex |
|---|---|---|
| Low risk / profitable / positive | Green | `#2ca02c` |
| Moderate risk / neutral | Orange | `#ff7f0e` |
| High risk / loss-making / negative | Red | `#d62728` |
| Volume / neutral metric | Blue | `#1f77b4` |
| Grade A | `#2ca02c` | Deep green |
| Grade B | `#5aae61` | Medium green |
| Grade C | `#a6d96a` | Light green |
| Grade D | `#fee08b` | Yellow |
| Grade E | `#f46d43` | Orange |
| Grade F | `#d62728` | Red |
| Grade G | `#a50026` | Deep red |
| Background | `#f8f9fa` | Light gray |

### Typography

- Page titles: Segoe UI Bold, 16pt
- Chart titles (insight titles): Segoe UI Bold, 12–13pt
- Chart labels and axis text: Segoe UI, 10–11pt
- KPI card numbers: Segoe UI Bold, 20–24pt
- KPI subtitles: Segoe UI, 11pt, gray

### General Rules

- Enable tooltips on all charts showing exact values, volume share, and business translation where space allows.
- Add page-level titles in the top-left of each page.
- Format percentages as `X.X%`, currency as `$X,XXX`, large numbers as `XXXk` or `$X.XM`.
- All default rate charts must include the **21.47% portfolio average reference line** with a label.
- Add a data source footer on every page: *"Source: Lending Club 2007–2018 | Kaggle Dataset | 1,371,165 loans"*

---

## DAX Measures

```dax
-- Dynamic portfolio average (respects slicer context)
Portfolio Default Rate =
    DIVIDE(SUM('table'[defaults]), SUM('table'[loans]), 0) * 100

-- Profit in millions
Profit (M) =
    DIVIDE(SUM('table'[profit]), 1000000, 0)

-- Rate above/below portfolio avg (for conditional coloring)
Rate vs Portfolio Avg =
    [Portfolio Default Rate] - 21.47

-- Profit per loan
Avg Profit per Loan =
    DIVIDE(SUM('table'[profit]), SUM('table'[loans]), 0)
```

> **Important:** Use the dynamic `[Portfolio Default Rate]` measure — not the hardcoded 21.47 — for all reference lines on pages where slicers are active. The hardcoded value is only appropriate for the Overview page's static KPI subtitle.

---

## Recommended Interactions

- **Grade slicer** on Page 2 cross-filters all charts on the same page.
- **Year range slicer** on Page 3 filters all trend charts; the portfolio average reference line should update accordingly.
- **Drill-through:** Right-click any grade bar on Page 1 (Overview) → drill through to Page 2 (Risk by Segment) filtered to that grade.
- **Drill-through:** Right-click any vintage year bar on Page 3 → drill through to Page 2 to see the risk breakdown for that cohort.
- **Cross-highlight:** Clicking a purpose group bar on Page 4 (Profitability) should highlight the corresponding row in the Page 2 matrix.

---

## Interpretive Warnings for Dashboard Consumers

Add these as collapsible text boxes or tooltip annotations on the relevant pages.

| Page | Warning |
|---|---|
| Page 1 (Overview) | The 21.47% default rate includes only approved loans. Rejected applicants (below FICO 600) are excluded — the rate for the full addressable market would be higher. |
| Page 3 (Trends) | 2017–2018 vintage default rates are lower-bound estimates. Many loans in these cohorts are still active and have not yet defaulted or been charged off. Do not interpret as an improvement in credit quality. |
| Page 3 (Trends) | FICO scores averaged 694 in 2014 vs. 717–719 in 2007–2010 — a 23-point decline during the rapid growth phase. This is a primary driver of rising default rates in 2014–2016 vintages. |
| Page 5 (Interactions) | Grade and interest rate are near-perfectly correlated (r ≈ 0.95). Do not use both simultaneously as risk filters — they carry the same information and create misleading results. |
| All pages | Income band alone explains only 6.8pp of default rate variation (25.3% low → 18.5% high). Income without grade and DTI context is not a meaningful standalone risk signal. |

---

## Analytical Story — Reading the Dashboard in Sequence

For a guided walkthrough (e.g., presenting to leadership), follow this sequence:

1. **Page 1:** "Here is the portfolio. 1.37M loans, 21.47% default rate — 1 in 5 loans defaults."
2. **Page 2:** "Grade is the single strongest predictor. A 44.7pp spread from 6.7% to 51.4%. Add term — 60-month loans double the risk."
3. **Page 4:** "The profit picture is stark: Debt consolidation (+$302M) subsidizes everything else. Business and Consumer are loss-making."
4. **Page 3:** "The growth story explains why. Volume peaked in 2015, but profit per loan had already collapsed 74% from 2013. The platform turned loss-making in 2016."
5. **Page 5:** "No single variable is sufficient. The risk surface is multi-dimensional — grade, FICO, and DTI together explain what income and rate alone cannot."
