-- ============================================================
-- Lending Club Loan Performance & Risk Analysis (2007-2018)
-- Stage 2: SQL Business Queries
-- Source database: data/cleaned_data.db  |  Table: loans
-- ============================================================


-- ------------------------------------------------------------
-- 1. PORTFOLIO OVERVIEW
-- ------------------------------------------------------------
-- Total loans, defaults, default rate, and total amount funded
SELECT
    COUNT(*)                                        AS total_loans,
    SUM("default")                                  AS total_defaults,
    ROUND(SUM("default") * 100.0 / COUNT(*), 2)    AS default_rate_pct,
    ROUND(SUM(loan_amnt) / 1e9, 3)                 AS total_funded_B,
    ROUND(AVG(int_rate), 2)                         AS avg_interest_rate
FROM loans;


-- ------------------------------------------------------------
-- 2. DEFAULT RATE BY CREDIT GRADE
-- ------------------------------------------------------------
SELECT
    grade,
    COUNT(*)                                            AS loans,
    SUM("default")                                      AS defaults,
    ROUND(SUM("default") * 100.0 / COUNT(*), 2)        AS default_rate_pct,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_portfolio
FROM loans
GROUP BY grade
ORDER BY grade;


-- ------------------------------------------------------------
-- 3. DEFAULT RATE BY FICO BAND
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN fico_score < 600 THEN 'Poor (<600)'
        WHEN fico_score < 700 THEN 'Fair (600-699)'
        WHEN fico_score < 750 THEN 'Good (700-749)'
        ELSE                       'Excellent (750+)'
    END                                                 AS fico_band,
    COUNT(*)                                            AS loans,
    SUM("default")                                      AS defaults,
    ROUND(100.0 * SUM("default") / COUNT(*), 2)        AS default_rate_pct
FROM loans
GROUP BY fico_band
ORDER BY CASE fico_band
    WHEN 'Poor (<600)'       THEN 1
    WHEN 'Fair (600-699)'    THEN 2
    WHEN 'Good (700-749)'    THEN 3
    ELSE                          4
END;


-- ------------------------------------------------------------
-- 4. DEFAULT RATE BY INCOME LEVEL
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN annual_inc < 40000  THEN 'Low (<$40K)'
        WHEN annual_inc < 80000  THEN 'Middle ($40K-$80K)'
        ELSE                          'High ($80K+)'
    END                                                 AS income_group,
    COUNT(*)                                            AS loans,
    SUM("default")                                      AS defaults,
    ROUND(100.0 * SUM("default") / COUNT(*), 2)        AS default_rate_pct
FROM loans
GROUP BY income_group
ORDER BY CASE income_group
    WHEN 'Low (<$40K)'          THEN 1
    WHEN 'Middle ($40K-$80K)'   THEN 2
    ELSE                             3
END;


-- ------------------------------------------------------------
-- 5. DEFAULT RATE BY LOAN SIZE
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN loan_amnt < 5000   THEN 'Small (<$5K)'
        WHEN loan_amnt < 15000  THEN 'Medium ($5K-$15K)'
        ELSE                         'Large ($15K+)'
    END                                                 AS loan_size,
    COUNT(*)                                            AS loans,
    SUM("default")                                      AS defaults,
    ROUND(SUM("default") * 100.0 / COUNT(*), 2)        AS default_rate_pct
FROM loans
GROUP BY loan_size
ORDER BY CASE loan_size
    WHEN 'Small (<$5K)'       THEN 1
    WHEN 'Medium ($5K-$15K)'  THEN 2
    ELSE                           3
END;


-- ------------------------------------------------------------
-- 6. DEFAULT RATE BY LOAN PURPOSE
-- ------------------------------------------------------------
SELECT
    purpose_group,
    COUNT(*)                                            AS loans,
    SUM("default")                                      AS defaults,
    ROUND(100.0 * SUM("default") / COUNT(*), 2)        AS default_rate_pct,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_portfolio
FROM loans
GROUP BY purpose_group
ORDER BY default_rate_pct DESC;


-- ------------------------------------------------------------
-- 7. PROFIT BY LOAN PURPOSE
-- ------------------------------------------------------------
SELECT
    purpose_group,
    COUNT(*)                                            AS loans,
    ROUND(SUM(total_pymnt - loan_amnt), 2)             AS profit
FROM loans
GROUP BY purpose_group
ORDER BY profit DESC;


-- ------------------------------------------------------------
-- 8. DEFAULT RATE BY LOAN TERM
-- ------------------------------------------------------------
SELECT
    term,
    COUNT(*)                                            AS loans,
    SUM("default")                                      AS defaults,
    ROUND(100.0 * SUM("default") / COUNT(*), 2)        AS default_rate_pct,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_portfolio
FROM loans
GROUP BY term
ORDER BY term;


-- ------------------------------------------------------------
-- 9. DEFAULT RATE BY DTI BAND
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN dti < 10  THEN 'Low (<10)'
        WHEN dti < 20  THEN 'Medium (10-20)'
        WHEN dti < 30  THEN 'High (20-30)'
        ELSE                'Very High (30+)'
    END                                                 AS dti_band,
    COUNT(*)                                            AS loans,
    SUM("default")                                      AS defaults,
    ROUND(100.0 * SUM("default") / COUNT(*), 2)        AS default_rate_pct
FROM loans
GROUP BY dti_band
ORDER BY CASE dti_band
    WHEN 'Low (<10)'        THEN 1
    WHEN 'Medium (10-20)'   THEN 2
    WHEN 'High (20-30)'     THEN 3
    ELSE                         4
END;


-- ------------------------------------------------------------
-- 10. DEFAULT RATE BY ISSUE YEAR (VINTAGE ANALYSIS)
-- ------------------------------------------------------------
SELECT
    issue_year,
    COUNT(*)                                            AS loans,
    SUM("default")                                      AS defaults,
    ROUND(100.0 * SUM("default") / COUNT(*), 2)        AS default_rate_pct,
    ROUND(AVG(loan_amnt), 0)                            AS avg_loan_amnt
FROM loans
GROUP BY issue_year
ORDER BY issue_year;
