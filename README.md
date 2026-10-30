# Swiggy Restaurant Market Analysis

An end-to-end data analyst capstone project analyzing restaurant market data from Swiggy — covering data cleaning, SQL analysis, statistical testing, Excel cross-validation, and an interactive Power BI dashboard.

## Business Problem

A food delivery platform needs to understand its restaurant market to guide decisions on city expansion, cuisine partnerships, pricing strategy, and restaurant quality monitoring. This project analyzes 148,541 restaurant listings to answer five key business questions: where restaurants are concentrated, which cuisines dominate or are underserved, how pricing relates to quality, whether popularity predicts rating, and which high-volume restaurants are underperforming.

## Tools Used

- **Python (pandas)** — data cleaning and preparation
- **SQL (PostgreSQL)** — core analysis and querying
- **Excel** — cross-validation via PivotTables and formulas
- **Power BI** — interactive dashboard
- **scipy (Python)** — statistical testing

## Data

- **Source:** Swiggy restaurant dataset, 148,541 rows, 11 original columns
- **Cleaning steps:**
  - Parsed `rating` (replaced "--" with NA, converted to numeric)
  - Parsed `cost` (stripped ₹ symbol, converted to numeric)
  - Created `rating_count_num` from text values (e.g., "1K+ ratings" → 1000, "Too Few Ratings" → NA)
  - Created `cost_band` (Budget / Mid / Premium) via binning
  - Split the `cuisine` column (comma-separated) into one row per restaurant-cuisine pair, saved separately as `swiggy_cuisine`, to support cuisine-level analysis without affecting restaurant-level counts

## Analysis & Findings

### Q1: Which cities have the most restaurants, and how do their average ratings compare?
Restaurant count and average rating are not clearly related — cities with more restaurants don't consistently rate higher or lower. This is consistent with the weak correlation found in Q4.

### Q2a: Which cuisines are strongest in each city?
North Indian, Chinese, and Indian cuisines appear among the top 3 in many cities, but local patterns still differ — e.g., Adajan, Surat has Snacks and Chinese at the top, while Adityapur shows a particularly high concentration of Chinese restaurants. This pattern was independently confirmed across SQL, Excel, and Power BI.

### Q2b: Which cuisines are well-rated but possibly underserved?
Using restaurants with a rating count between 10-50 and average rating ≥ 4.2, **Desserts** and **Ice Cream** emerged as the dominant underserved cuisines — occurring far more often than the next tier (Beverages, Bakery). This required a custom approach in Excel: PivotTable filters apply by hierarchy level rather than row-level AND logic, so compound filtering was done via a flat-table AutoFilter and independently verified with COUNTIFS/AVERAGEIFS formulas — both matched SQL exactly.

### Q3: Does cost predict rating?
Premium-priced restaurants have a slightly higher average rating (4.02) than Budget (3.88) and Mid (3.86), but the difference is small — cost band is a weak predictor of restaurant quality.

### Q4: Is restaurant popularity (rating count) related to rating?
A Spearman correlation test found rho = 0.11 (p < 0.001) — statistically significant due to the large sample size, but practically negligible. Popularity does not meaningfully predict rating quality.

### Q5: Which high-volume restaurants are underperforming?
Restaurants with rating_count_num ≥ 500 and rating < 3.5 (top 50 by volume) are concentrated roughly one-third in Hyderabad, with most ratings in the 3.0-3.4 range — suggesting underperformance rather than outright failure.

## Cross-Tool Validation

Every finding in this project was validated across at least two independent tools (SQL, Excel, and/or Python/Power BI), using different calculation methods each time. Where tool-specific limitations arose — such as Excel PivotTables' inability to apply compound filters, or Top-N filters recalculating against the full dataset rather than a filtered subset — these were identified, documented, and solved with alternative approaches (flat-table filtering, formula-based cross-checks).

## Dashboard

An interactive Power BI dashboard provides a high-level market overview: total restaurant count, average rating, average cost, and share of low-rated restaurants, broken down by city, cuisine, and cost band, with city and cost-band slicers for exploration.

*(Insert dashboard screenshot here)*

## Key Recommendations

1. Prioritize cuisine partnerships in **Desserts** and **Ice Cream** categories — high ratings with low current supply suggest unmet demand.
2. Use pricing-based quality assumptions cautiously — cost band is only a weak signal of restaurant rating.
3. Flag high-order-volume, low-rating restaurants (identified in Q5) for operational review, particularly in Hyderabad.

## Limitations

- The `city` field combines locality and city (e.g., "Indiranagar,Bangalore"), so city-level comparisons may be more granular than expected.
- Some restaurants have missing cost or rating data, which was excluded from relevant calculations (not treated as zero).
- Correlation findings (Q4) indicate association, not causation.

## What I'd Do Next

- Expand the risk-flagging logic (Q5) into a monitoring view for operations teams
- Analyze cuisine-level pricing patterns in more depth
- Explore delivery time or location-based factors if additional data becomes available

