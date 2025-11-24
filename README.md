# Snowflake Web Analytics Using Interactive Table and Interactive Warehouse

A complete solution for demonstrating Interactive Table and Interactive Warehouse in Snowflake. This project includes synthetic data generation, SQL queries for dashboards, and comprehensive analytics for web traffic analysis.

[![Data Size](https://img.shields.io/badge/records-10,000-blue)]()
[![Database](https://img.shields.io/badge/database-Snowflake-29B5E8)]()
[![Python](https://img.shields.io/badge/python-3.x-green)]()

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Data Schema](#data-schema)
- [Usage](#usage)
- [SQL Queries](#sql-queries)
- [Examples](#examples)
- [Customization](#customization)
- [Contributing](#contributing)

## 🎯 Overview

This project provides a complete framework for web analytics in Snowflake, including:

- **Synthetic Data Generation**: Python script to generate realistic web analytics data
- **Pre-generated Dataset**: 10,000 records of clickstream data ready to load
- **Complete Setup Script**: Automated Snowflake environment setup with Interactive Tables
- **SQL Query Library**: Production-ready queries for dashboards and analytics
- **Interactive Table Demo**: Showcasing Snowflake's high-performance interactive table feature

**Key Features:**
- ⚡ **Interactive Tables**: Optimized for low-latency dashboard queries
- 🎯 **Interactive Warehouse**: Specialized compute for fast query performance
- 📊 **15 Dashboard Queries**: Ready-to-use analytics queries
- 🔄 **Automatic Refresh**: Interactive table stays in sync with source data

**Use Cases:**
- Building real-time web analytics dashboards
- Testing Snowflake Interactive Tables feature
- Learning SQL analytics patterns
- Training and demos
- Performance benchmarking
- BI tool integration testing

## 📁 Project Structure

```
.
├── README.md                      # This file
├── generate_synthetic_data.py     # Python script to generate synthetic data
├── hits2_synthetic_data.csv       # Pre-generated 10,000 records
├── setup.sql                      # Complete Snowflake setup script
└── dashboard_queries.sql          # Core dashboard SQL queries
```

### File Descriptions

| File | Description | Lines of Code |
|------|-------------|---------------|
| `generate_synthetic_data.py` | Generates synthetic web analytics data with configurable parameters | ~142 |
| `hits2_synthetic_data.csv` | Pre-generated CSV with 10,000 records of synthetic clickstream data | 10,001 |
| `setup.sql` | Complete Snowflake setup: database, schema, stage, tables (normal & interactive) | ~119 |
| `dashboard_queries.sql` | 15 essential queries for operational dashboards and analytics | ~300 |

## 🚀 Getting Started

### Prerequisites

- **Snowflake Account**: Active Snowflake account with appropriate permissions
- **Python 3.x**: For generating custom synthetic data (optional)
- **SnowSQL or Snowflake Web UI**: For running queries

### Installation

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd <repo-name>
   ```

2. **Quick Setup (Recommended):**

   Use the provided `setup.sql` script which handles everything automatically:
   
   ```sql
   -- Run the entire setup.sql file in Snowflake
   -- This will:
   -- 1. Create database 'interactive_demo'
   -- 2. Create schema 'test'
   -- 3. Create stage 'demo_stage'
   -- 4. Create table 'HITS2_CSV_NORMAL'
   -- 5. Load data from CSV
   -- 6. Create Interactive Table 'HITS2_CSV_INTERACTIVE'
   -- 7. Create Interactive Warehouse
   ```

   **Steps:**
   - Upload `hits2_synthetic_data.csv` to Snowflake stage (via UI or PUT command)
   - Execute `setup.sql` in Snowflake worksheet
   - Done! Data is loaded and ready to query

3. **Manual Setup (Alternative):**

   **Step 1 - Create table:**
   ```sql
   CREATE OR REPLACE TABLE HITS2_CSV (
       EventDate DATE,
       CounterID INT,
       ClientIP STRING,
       SearchEngineID INT,
       SearchPhrase STRING,
       ResolutionWidth INT,
       Title STRING,
       IsRefresh INT,
       DontCountHits INT
   );
   ```

   **Step 2 - Load data using Snowflake Web UI:**
   - Navigate to Databases → Your Database → Your Schema → Tables
   - Click on `HITS2_CSV` table
   - Click "Load Data" and upload `hits2_synthetic_data.csv`

   **Or using SnowSQL:**
   ```bash
   # Upload file to stage
   PUT file:///path/to/hits2_synthetic_data.csv @~;
   
   # Load into table
   COPY INTO HITS2_CSV
   FROM @~/hits2_synthetic_data.csv
   FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1);
   ```

4. **Verify the data:**
   ```sql
   SELECT COUNT(*) FROM HITS2_CSV_NORMAL;
   -- Should return 10000
   
   SELECT * FROM HITS2_CSV_NORMAL LIMIT 10;
   -- Preview the data
   ```

## 📊 Data Schema

### Table: HITS2_CSV

| Column | Type | Description | Example Values |
|--------|------|-------------|----------------|
| `EventDate` | DATE | Date of the event | 2024-11-24 |
| `CounterID` | INT | Counter/tracking identifier | 1000-9999 |
| `ClientIP` | STRING | Visitor's IP address | 192.168.1.1 |
| `SearchEngineID` | INT | Search engine identifier (0-5) | 0=Direct, 1=Google, 2=Bing, etc. |
| `SearchPhrase` | STRING | Search query used (if any) | "python tutorial", "" |
| `ResolutionWidth` | INT | Screen resolution width | 768, 1024, 1920, 2560 |
| `Title` | STRING | Page title visited | "Home Page", "Product Catalog" |
| `IsRefresh` | INT | Whether page was refreshed (0/1) | 0, 1 |
| `DontCountHits` | INT | Flag to exclude from analytics (0/1) | 0, 1 |

### SearchEngineID Mapping

| ID | Search Engine |
|----|---------------|
| 0 | Direct/None |
| 1 | Google |
| 2 | Bing |
| 3 | Yahoo |
| 4 | DuckDuckGo |
| 5 | Other |

### Device Type Classification

Based on `ResolutionWidth`:
- **Mobile**: ≤ 768px
- **Tablet**: 769 - 1024px
- **Desktop**: > 1024px

## ⚡ Interactive Tables Feature

This project demonstrates Snowflake's **Interactive Tables** - a powerful feature for high-performance analytics.

### What are Interactive Tables?

Interactive Tables are specially optimized tables that provide:
- **Low-latency queries**: Millisecond response times for dashboards
- **Automatic refresh**: Stays in sync with source data (configurable lag)
- **Optimized storage**: Clustered and optimized for analytical queries
- **Dedicated compute**: Uses Interactive Warehouses for best performance

### Setup Architecture

The `setup.sql` creates two tables:

1. **HITS2_CSV_NORMAL** (Standard Table)
   - Raw data storage
   - Source of truth
   - Data is loaded here first

2. **HITS2_CSV_INTERACTIVE** (Interactive Table)
   - Optimized copy of normal table
   - Clustered by `ClientIP`
   - Target lag: 10 minutes
   - Used for dashboard queries

### Performance Comparison

```sql
-- Standard table query (slower)
USE WAREHOUSE COMPUTE_WH;
SELECT COUNT(*) FROM HITS2_CSV_NORMAL;

-- Interactive table query (faster)
USE WAREHOUSE INTERACTIVE_WH;
SELECT COUNT(*) FROM HITS2_CSV_INTERACTIVE;
```

### When to Use Interactive Tables

✅ **Good for:**
- Real-time dashboards
- BI tool connections
- High-concurrency queries
- Low-latency requirements

❌ **Not needed for:**
- Batch ETL processing
- Infrequent queries
- Data loading operations

### Managing Interactive Tables

**Check status:**
```sql
-- View all interactive tables
SHOW INTERACTIVE TABLES;

-- Check refresh status
SELECT * FROM TABLE(INFORMATION_SCHEMA.INTERACTIVE_TABLE_REFRESH_HISTORY(
    'HITS2_CSV_INTERACTIVE'
));
```

**Manual refresh (if needed):**
```sql
ALTER INTERACTIVE TABLE HITS2_CSV_INTERACTIVE REFRESH;
```

**Modify target lag:**
```sql
ALTER INTERACTIVE TABLE HITS2_CSV_INTERACTIVE 
SET TARGET_LAG = '5 minutes';
```

**Check warehouse status:**
```sql
SHOW WAREHOUSES LIKE 'INTERACTIVE_WH';
```

## 💻 Usage

### Generating Custom Synthetic Data

If you need different data parameters, you can regenerate the dataset:

```bash
python generate_synthetic_data.py
```

**Customization options** (edit the script):
```python
NUM_RECORDS = 10000  # Change number of records
OUTPUT_FILE = "hits2_synthetic_data.csv"  # Change output filename
```

The script generates:
- Random dates over the past 365 days
- Realistic IP addresses
- Common search phrases (tech-related)
- Various page titles
- Screen resolutions (mobile to 4K)
- Appropriate distribution of refreshes and exclusions

### Running SQL Queries

**Option 1 - Snowflake Web UI:**
1. Open the SQL file in a text editor
2. Copy desired query
3. Paste into Snowflake worksheet
4. Execute (Ctrl+Enter / Cmd+Enter)

**Option 2 - SnowSQL:**
```bash
snowsql -f dashboard_queries.sql
```

**Option 3 - Python:**
```python
import snowflake.connector

conn = snowflake.connector.connect(
    user='YOUR_USER',
    password='YOUR_PASSWORD',
    account='YOUR_ACCOUNT'
)

cursor = conn.cursor()
cursor.execute("SELECT * FROM HITS2_CSV LIMIT 10")
results = cursor.fetchall()
```

## 📈 SQL Queries

### dashboard_queries.sql

This file contains 15 comprehensive queries for building operational dashboards and analytics:

1. **Daily Traffic Trends** - Daily hits, unique visitors, refresh counts
2. **Search Engine Performance** - Traffic by search engine with engagement metrics
3. **Top Search Phrases** - Most popular search terms (20 most searched)
4. **Most Visited Pages** - Page performance analysis (top 20)
5. **Device/Resolution Analysis** - Mobile vs desktop usage with percentages
6. **Weekly Traffic Pattern** - Day-of-week analysis for optimal timing
7. **Monthly Traffic Summary** - High-level monthly trends with averages
8. **Search Conversion Funnel** - Search vs direct traffic comparison
9. **Top Visitors by Activity** - Most active users (top 50)
10. **Search Engine × Resolution Matrix** - Cross-dimensional analysis
11. **Bounce Rate Approximation** - Engagement quality metrics
12. **Visitor Retention Cohort** - Loyalty and return rates by first visit month
13. **Traffic Growth Rate** - Month-over-month growth percentage
14. **Peak Traffic Times** - Busiest days identification (top 20)
15. **Search Engine Effectiveness** - Engagement metrics by traffic source

**Query Categories:**
- **Basic KPIs**: Queries #1, #7, #13, #14
- **Traffic Sources**: Queries #2, #3, #8, #15
- **Content Analysis**: Queries #4, #11
- **Device Analysis**: Queries #5, #10
- **User Behavior**: Queries #6, #9, #12

## 🎨 Examples

### Example 1: Daily Dashboard

**Query:** (Use Interactive Table for best performance)
```sql
-- Use Interactive Warehouse for low-latency queries
USE WAREHOUSE INTERACTIVE_WH;

SELECT 
    EventDate,
    COUNT(*) as total_hits,
    COUNT(DISTINCT ClientIP) as unique_visitors,
    SUM(IsRefresh) as refresh_count
FROM HITS2_CSV_INTERACTIVE
WHERE DontCountHits = 0
GROUP BY EventDate
ORDER BY EventDate DESC;
```

**Output:**
```
EventDate   | total_hits | unique_visitors | refresh_count
------------|------------|-----------------|---------------
2025-11-24  | 156        | 98              | 38
2025-11-23  | 142        | 87              | 35
2025-11-22  | 168        | 105             | 42
```

### Example 2: Device Distribution

**Query:**
```sql
SELECT 
    CASE 
        WHEN ResolutionWidth <= 768 THEN 'Mobile'
        WHEN ResolutionWidth <= 1024 THEN 'Tablet'
        ELSE 'Desktop'
    END as device_type,
    COUNT(*) as hits,
    COUNT(DISTINCT ClientIP) as unique_visitors
FROM HITS2_CSV_INTERACTIVE
WHERE DontCountHits = 0
GROUP BY device_type
ORDER BY hits DESC;
```

**Output:**
```
device_type | hits  | unique_visitors
------------|-------|----------------
Desktop     | 5234  | 2145
Mobile      | 3456  | 1876
Tablet      | 1310  | 654
```

### Example 3: Top Pages

**Query:**
```sql
SELECT 
    Title,
    COUNT(*) as page_views,
    COUNT(DISTINCT ClientIP) as unique_visitors
FROM HITS2_CSV_INTERACTIVE
WHERE DontCountHits = 0
GROUP BY Title
ORDER BY page_views DESC
LIMIT 10;
```

## 🔧 Customization

### Modifying Data Generation

Edit `generate_synthetic_data.py` to customize:

**1. Add more search phrases:**
```python
def random_search_phrase():
    phrases = [
        "your custom phrase",
        "another phrase",
        # ... add more
    ]
    return random.choice(phrases)
```

**2. Change date range:**
```python
# In main() function
end_date = datetime.now()
start_date = end_date - timedelta(days=730)  # 2 years instead of 1
```

**3. Add custom page titles:**
```python
def random_title():
    titles = [
        "Your Custom Page",
        "Another Page",
        # ... add more
    ]
    return random.choice(titles)
```

### Optimizing Queries

**For large datasets, add clustering:**
```sql
ALTER TABLE HITS2_CSV_NORMAL CLUSTER BY (EventDate);
```

**Use the Interactive Table for better performance:**

The `setup.sql` already creates an Interactive Table (`HITS2_CSV_INTERACTIVE`) which is optimized for fast queries. Use this for dashboard queries:

```sql
-- Instead of querying HITS2_CSV_NORMAL
SELECT * FROM HITS2_CSV_INTERACTIVE WHERE EventDate = '2024-11-24';
```

**Create materialized views for frequent queries:**
```sql
CREATE MATERIALIZED VIEW mv_daily_kpis AS
SELECT 
    EventDate,
    COUNT(*) as hits,
    COUNT(DISTINCT ClientIP) as visitors
FROM HITS2_CSV_NORMAL
WHERE DontCountHits = 0
GROUP BY EventDate;
```

### Connecting to BI Tools

**Tableau:**
1. Use Snowflake connector
2. Import queries as Custom SQL
3. Build dashboards on top

**Power BI:**
1. Get Data → Snowflake
2. Use SQL queries directly
3. Create visualizations

**Looker:**
1. Define LookML models based on queries
2. Create explores and dashboards

## 📊 Key Metrics Glossary

| Metric | Formula | Description |
|--------|---------|-------------|
| **Total Hits** | COUNT(*) | All page views/events |
| **Unique Visitors** | COUNT(DISTINCT ClientIP) | Distinct IP addresses |
| **Hits per Visitor** | Total Hits / Unique Visitors | Average engagement |
| **Refresh Rate** | AVG(IsRefresh) × 100 | % of page refreshes |
| **Search Traffic %** | (SearchEngineID > 0) / Total × 100 | % from search engines |
| **Mobile %** | (ResolutionWidth ≤ 768) / Total × 100 | Mobile traffic share |
| **Bounce Rate** | Single-page sessions / Total sessions | Approximate engagement quality |

## 🛠️ Troubleshooting

### No Data After Loading

```sql
-- Check if data exists in normal table
SELECT COUNT(*) FROM HITS2_CSV_NORMAL;

-- Check if data exists in interactive table
SELECT COUNT(*) FROM HITS2_CSV_INTERACTIVE;

-- Check for errors in copy operation
SELECT * FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME=>'HITS2_CSV_NORMAL',
    START_TIME=>DATEADD(hours, -1, CURRENT_TIMESTAMP())
));
```

### Query Performance Issues

- Ensure proper warehouse size
- Add clustering key on EventDate
- Use result caching
- Consider partitioning for very large datasets

### CSV Loading Errors

```sql
-- Check file format (already defined in setup.sql)
CREATE OR REPLACE FILE FORMAT my_csv_format
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE;

-- Try loading with explicit format
COPY INTO HITS2_CSV_NORMAL
FROM @demo_stage/hits2_synthetic_data.csv
FILE_FORMAT = (FORMAT_NAME = my_csv_format);

-- List files in stage to verify upload
LIST @demo_stage;
```

## 📝 Best Practices

1. **Use Interactive Tables for dashboards**: Query `HITS2_CSV_INTERACTIVE` instead of `HITS2_CSV_NORMAL` for best performance
2. **Use Interactive Warehouse**: Switch to `INTERACTIVE_WH` for dashboard queries: `USE WAREHOUSE INTERACTIVE_WH;`
3. **Always filter DontCountHits**: Use `WHERE DontCountHits = 0` in analytics queries
4. **Monitor Interactive Table lag**: Check refresh status with `SHOW INTERACTIVE TABLES;`
5. **Use CTEs for clarity**: Make complex queries more readable with Common Table Expressions
6. **Leverage result caching**: Snowflake automatically caches results for repeated queries
7. **Right-size your warehouses**: XSMALL is often sufficient for this dataset
8. **Suspend when idle**: Interactive Warehouses auto-suspend, but verify with `ALTER WAREHOUSE ... SUSPEND;`
9. **Document customizations**: Keep track of modifications to queries and schemas


## 📄 License

This project is provided as-is for educational and demonstration purposes.

## 🙋 FAQ

**Q: Can I use this for production?**  
A: The synthetic data is for testing/demo. The SQL queries and Interactive Table setup can be adapted for production use with real data.

**Q: What is an Interactive Table?**  
A: It's a Snowflake feature that provides optimized, low-latency query performance for dashboards. See the [Interactive Tables section](#-interactive-tables-feature) above.

**Q: Which table should I query - NORMAL or INTERACTIVE?**  
A: Use `HITS2_CSV_INTERACTIVE` for dashboard queries and BI tools. Use `HITS2_CSV_NORMAL` for data loading and updates.

**Q: How do I generate more than 10,000 records?**  
A: Edit `NUM_RECORDS = 10000` in `generate_synthetic_data.py` to your desired amount, then regenerate the CSV.

**Q: Are the IP addresses real?**  
A: No, they are randomly generated and may not be valid public IPs.

**Q: Can I modify the table schema?**  
A: Yes! Update the CREATE TABLE statements in `setup.sql` and the data generation script accordingly.

**Q: How do I add time/hour data?**  
A: Modify `generate_synthetic_data.py` to include a timestamp field instead of just date, update the schema in `setup.sql`, and adjust queries.

**Q: How much does the Interactive Warehouse cost?**  
A: Interactive Warehouses use Snowflake credits like standard warehouses. XSMALL size is sufficient for this demo dataset.

**Q: What happens if my Interactive Table falls behind?**  
A: The TARGET_LAG setting (10 minutes) ensures it stays current. You can manually refresh with `ALTER INTERACTIVE TABLE ... REFRESH;`

## 📞 Support

For issues or questions:
- Open an issue in the repository
- Review the Snowflake documentation: https://docs.snowflake.com/
- Check query comments for detailed explanations

## 🎓 Learning Resources

- [Snowflake Documentation](https://docs.snowflake.com/)
- [Snowflake Interactive Tables](https://docs.snowflake.com/en/user-guide/interactive-tables)
- [Snowflake SQL Reference](https://docs.snowflake.com/en/sql-reference.html)
- [Interactive Warehouses Guide](https://docs.snowflake.com/en/user-guide/warehouses-interactive)
- [Web Analytics Metrics Guide](https://en.wikipedia.org/wiki/Web_analytics)
- [SQL for Data Analysis](https://mode.com/sql-tutorial/)

---

**Built with ❄️ for Snowflake Analytics**
