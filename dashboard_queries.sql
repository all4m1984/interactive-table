-- ====================================================================
-- DASHBOARD QUERIES FOR HITS2_CSV TABLE
-- Web Analytics / Clickstream Dashboard
-- ====================================================================

-- ====================================================================
-- 1. DAILY TRAFFIC TRENDS
-- Use case: Overview dashboard showing daily traffic patterns
-- ====================================================================
SELECT 
    EventDate,
    COUNT(*) as total_hits,
    COUNT(DISTINCT ClientIP) as unique_visitors,
    SUM(IsRefresh) as refresh_count,
    SUM(DontCountHits) as excluded_hits
FROM HITS2_CSV
WHERE DontCountHits = 0
GROUP BY EventDate
ORDER BY EventDate DESC;


-- ====================================================================
-- 2. SEARCH ENGINE PERFORMANCE
-- Use case: Traffic source analysis, marketing attribution
-- ====================================================================
SELECT 
    CASE SearchEngineID
        WHEN 0 THEN 'Direct/None'
        WHEN 1 THEN 'Google'
        WHEN 2 THEN 'Bing'
        WHEN 3 THEN 'Yahoo'
        WHEN 4 THEN 'DuckDuckGo'
        WHEN 5 THEN 'Other'
    END as search_engine,
    COUNT(*) as hits,
    COUNT(DISTINCT ClientIP) as unique_visitors,
    ROUND(AVG(IsRefresh) * 100, 2) as refresh_rate_pct
FROM HITS2_CSV
WHERE DontCountHits = 0
GROUP BY SearchEngineID
ORDER BY hits DESC;


-- ====================================================================
-- 3. TOP SEARCH PHRASES
-- Use case: SEO analysis, content strategy
-- ====================================================================
SELECT 
    SearchPhrase,
    COUNT(*) as search_count,
    COUNT(DISTINCT ClientIP) as unique_searchers,
    COUNT(DISTINCT EventDate) as days_searched
FROM HITS2_CSV
WHERE SearchPhrase != '' 
    AND DontCountHits = 0
GROUP BY SearchPhrase
ORDER BY search_count DESC
LIMIT 20;


-- ====================================================================
-- 4. MOST VISITED PAGES
-- Use case: Content performance analysis
-- ====================================================================
SELECT 
    Title,
    COUNT(*) as page_views,
    COUNT(DISTINCT ClientIP) as unique_visitors,
    SUM(CASE WHEN SearchPhrase != '' THEN 1 ELSE 0 END) as from_search,
    ROUND(AVG(IsRefresh) * 100, 2) as refresh_rate_pct
FROM HITS2_CSV
WHERE DontCountHits = 0
GROUP BY Title
ORDER BY page_views DESC
LIMIT 20;


-- ====================================================================
-- 5. DEVICE/RESOLUTION ANALYSIS
-- Use case: Responsive design insights, mobile vs desktop usage
-- ====================================================================
SELECT 
    ResolutionWidth,
    CASE 
        WHEN ResolutionWidth <= 768 THEN 'Mobile'
        WHEN ResolutionWidth <= 1024 THEN 'Tablet'
        ELSE 'Desktop'
    END as device_type,
    COUNT(*) as hits,
    COUNT(DISTINCT ClientIP) as unique_visitors,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM HITS2_CSV
WHERE DontCountHits = 0
GROUP BY ResolutionWidth
ORDER BY hits DESC;


-- ====================================================================
-- 6. WEEKLY TRAFFIC PATTERN
-- Use case: Day of week analysis for optimal posting/marketing times
-- ====================================================================
SELECT 
    DAYNAME(EventDate) as day_of_week,
    DAYOFWEEK(EventDate) as day_num,
    COUNT(*) as total_hits,
    COUNT(DISTINCT ClientIP) as unique_visitors,
    ROUND(AVG(IsRefresh) * 100, 2) as refresh_rate_pct
FROM HITS2_CSV
WHERE DontCountHits = 0
GROUP BY DAYNAME(EventDate), DAYOFWEEK(EventDate)
ORDER BY day_num;


-- ====================================================================
-- 7. MONTHLY TRAFFIC SUMMARY
-- Use case: High-level trends, executive dashboard
-- ====================================================================
SELECT 
    DATE_TRUNC('MONTH', EventDate) as month,
    COUNT(*) as total_hits,
    COUNT(DISTINCT ClientIP) as unique_visitors,
    COUNT(DISTINCT EventDate) as active_days,
    ROUND(COUNT(*) / COUNT(DISTINCT EventDate), 2) as avg_daily_hits
FROM HITS2_CSV
WHERE DontCountHits = 0
GROUP BY DATE_TRUNC('MONTH', EventDate)
ORDER BY month DESC;


-- ====================================================================
-- 8. SEARCH CONVERSION FUNNEL
-- Use case: Understanding search effectiveness
-- ====================================================================
SELECT 
    CASE WHEN SearchPhrase != '' THEN 'From Search' ELSE 'Direct' END as traffic_source,
    COUNT(*) as hits,
    COUNT(DISTINCT ClientIP) as unique_visitors,
    COUNT(DISTINCT Title) as pages_viewed,
    ROUND(AVG(IsRefresh) * 100, 2) as refresh_rate_pct
FROM HITS2_CSV
WHERE DontCountHits = 0
GROUP BY CASE WHEN SearchPhrase != '' THEN 'From Search' ELSE 'Direct' END;


-- ====================================================================
-- 9. TOP VISITORS BY ACTIVITY
-- Use case: Identifying power users, potential bot detection
-- ====================================================================
SELECT 
    ClientIP,
    COUNT(*) as total_hits,
    COUNT(DISTINCT EventDate) as days_active,
    COUNT(DISTINCT Title) as unique_pages,
    COUNT(DISTINCT SearchPhrase) as unique_searches,
    MIN(EventDate) as first_visit,
    MAX(EventDate) as last_visit
FROM HITS2_CSV
WHERE DontCountHits = 0
GROUP BY ClientIP
ORDER BY total_hits DESC
LIMIT 50;


-- ====================================================================
-- 10. SEARCH ENGINE + RESOLUTION MATRIX
-- Use case: Cross-analysis for targeted optimization
-- ====================================================================
SELECT 
    CASE SearchEngineID
        WHEN 0 THEN 'Direct'
        WHEN 1 THEN 'Google'
        WHEN 2 THEN 'Bing'
        WHEN 3 THEN 'Yahoo'
        ELSE 'Other'
    END as search_engine,
    CASE 
        WHEN ResolutionWidth <= 768 THEN 'Mobile'
        WHEN ResolutionWidth <= 1024 THEN 'Tablet'
        ELSE 'Desktop'
    END as device_type,
    COUNT(*) as hits,
    COUNT(DISTINCT ClientIP) as unique_visitors
FROM HITS2_CSV
WHERE DontCountHits = 0
GROUP BY SearchEngineID, 
    CASE 
        WHEN ResolutionWidth <= 768 THEN 'Mobile'
        WHEN ResolutionWidth <= 1024 THEN 'Tablet'
        ELSE 'Desktop'
    END
ORDER BY search_engine, hits DESC;


-- ====================================================================
-- 11. BOUNCE RATE APPROXIMATION
-- Use case: Engagement quality metrics
-- ====================================================================
SELECT 
    DATE_TRUNC('DAY', EventDate) as date,
    COUNT(DISTINCT ClientIP) as total_visitors,
    COUNT(DISTINCT CASE WHEN page_count = 1 THEN ClientIP END) as single_page_visitors,
    ROUND(COUNT(DISTINCT CASE WHEN page_count = 1 THEN ClientIP END) * 100.0 / 
          COUNT(DISTINCT ClientIP), 2) as approximate_bounce_rate_pct
FROM (
    SELECT ClientIP, EventDate, COUNT(*) as page_count
    FROM HITS2_CSV
    WHERE DontCountHits = 0
    GROUP BY ClientIP, EventDate
)
GROUP BY DATE_TRUNC('DAY', EventDate)
ORDER BY date DESC;


-- ====================================================================
-- 12. VISITOR RETENTION COHORT
-- Use case: Understanding visitor loyalty and return rates
-- ====================================================================
SELECT 
    first_visit_month,
    COUNT(DISTINCT ClientIP) as unique_visitors,
    COUNT(DISTINCT CASE WHEN visit_months > 1 THEN ClientIP END) as returning_visitors,
    ROUND(COUNT(DISTINCT CASE WHEN visit_months > 1 THEN ClientIP END) * 100.0 / 
          COUNT(DISTINCT ClientIP), 2) as retention_rate_pct
FROM (
    SELECT 
        ClientIP,
        DATE_TRUNC('MONTH', MIN(EventDate)) as first_visit_month,
        COUNT(DISTINCT DATE_TRUNC('MONTH', EventDate)) as visit_months
    FROM HITS2_CSV
    WHERE DontCountHits = 0
    GROUP BY ClientIP
)
GROUP BY first_visit_month
ORDER BY first_visit_month DESC;


-- ====================================================================
-- 13. TRAFFIC GROWTH RATE
-- Use case: Month-over-month growth tracking
-- ====================================================================
SELECT 
    month,
    total_hits,
    unique_visitors,
    LAG(total_hits) OVER (ORDER BY month) as prev_month_hits,
    LAG(unique_visitors) OVER (ORDER BY month) as prev_month_visitors,
    ROUND((total_hits - LAG(total_hits) OVER (ORDER BY month)) * 100.0 / 
          LAG(total_hits) OVER (ORDER BY month), 2) as hits_growth_pct,
    ROUND((unique_visitors - LAG(unique_visitors) OVER (ORDER BY month)) * 100.0 / 
          LAG(unique_visitors) OVER (ORDER BY month), 2) as visitors_growth_pct
FROM (
    SELECT 
        DATE_TRUNC('MONTH', EventDate) as month,
        COUNT(*) as total_hits,
        COUNT(DISTINCT ClientIP) as unique_visitors
    FROM HITS2_CSV
    WHERE DontCountHits = 0
    GROUP BY DATE_TRUNC('MONTH', EventDate)
)
ORDER BY month DESC;


-- ====================================================================
-- 14. PEAK TRAFFIC TIMES (BY DATE)
-- Use case: Identifying busiest days for capacity planning
-- ====================================================================
SELECT 
    EventDate,
    COUNT(*) as total_hits,
    COUNT(DISTINCT ClientIP) as unique_visitors,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as pct_of_total_traffic
FROM HITS2_CSV
WHERE DontCountHits = 0
GROUP BY EventDate
ORDER BY total_hits DESC
LIMIT 20;


-- ====================================================================
-- 15. SEARCH ENGINE EFFECTIVENESS
-- Use case: Which search engines bring the most engaged users
-- ====================================================================
SELECT 
    CASE SearchEngineID
        WHEN 0 THEN 'Direct/None'
        WHEN 1 THEN 'Google'
        WHEN 2 THEN 'Bing'
        WHEN 3 THEN 'Yahoo'
        WHEN 4 THEN 'DuckDuckGo'
        WHEN 5 THEN 'Other'
    END as search_engine,
    COUNT(*) as total_hits,
    COUNT(DISTINCT ClientIP) as unique_visitors,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT ClientIP), 2) as avg_hits_per_visitor,
    ROUND(COUNT(DISTINCT Title) * 1.0 / COUNT(DISTINCT ClientIP), 2) as avg_pages_per_visitor
FROM HITS2_CSV
WHERE DontCountHits = 0
GROUP BY SearchEngineID
ORDER BY avg_hits_per_visitor DESC;

