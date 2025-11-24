/*
 * Creates the database 'interactive_demo' if it doesn't already exist.
 * This is the primary container for all objects in this demo.
 */
CREATE DATABASE IF NOT EXISTS interactive_demo;

/*
 * Creates the schema 'test' within the 'interactive_demo' database.
 * Schemas logically group database objects like tables and stages.
 */
CREATE SCHEMA IF NOT EXISTS interactive_demo.test;


/*
 * Creates or replaces an internal stage named 'demo_stage'.
 * This stage will hold the external data file for loading.
 */
CREATE OR REPLACE STAGE demo_stage
    FILE_FORMAT = (
        /* Specifies that the file to be loaded is in CSV format. */
        TYPE = 'CSV'
        /* Instructs the COPY command to skip the first row, which is assumed to be a header. */
        SKIP_HEADER = 1
        /* Defines the character used to optionally enclose fields (e.g., to handle commas within a string). */
        FIELD_OPTIONALLY_ENCLOSED_BY ='"'
    );

/*
 * Creates or replaces a standard (non-interactive) table to hold the raw hit data.
 * The structure defines the columns and their data types.
 */
CREATE OR REPLACE TABLE HITS2_CSV_NORMAL (
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

/*
 * Sets the current session's compute resource to the 'COMPUTE_WH' warehouse.
 * This warehouse will be used for the subsequent data loading operation.
 */
USE WAREHOUSE COMPUTE_WH;

/*
 * Loads data from the file 'hits2_synthetic_data.csv' located in the '@demo_stage'
 * into the 'HITS2_CSV_NORMAL' table using the specified file format definition.
 */
COPY INTO HITS2_CSV_NORMAL FROM  @demo_stage/hits2_synthetic_data.csv
  FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1);

/*
 * Disables the use of the result cache for the current session.
 * This forces the subsequent SELECT query to execute fully, often used for performance testing.
 */
ALTER SESSION SET USE_CACHED_RESULT = FALSE;

/*
 * Executes a query to retrieve all rows from the newly loaded 'HITS2_CSV_NORMAL' table.
 */
SELECT * FROM HITS2_CSV_NORMAL;

/*
 * Creates or replaces a special 'INTERACTIVE TABLE'.
 * This table automatically maintains a highly optimized copy of the base table
 * for fast, low-latency queries, specifically tuned for dashboards and BI tools.
 */
CREATE OR REPLACE INTERACTIVE TABLE HITS2_CSV_INTERACTIVE 
    /* Specifies the column to physically cluster the data on for query optimization. */
    CLUSTER BY (clientip)
    /* Sets the maximum allowed time delay between an update in the base table and its reflection here. */
    TARGET_LAG = '10 minutes'
    /* Designates the standard warehouse responsible for the background task of data refresh. */
    WAREHOUSE = compute_wh
/* Defines the content of the Interactive Table as a full copy of the normal table. */
AS
    SELECT * FROM HITS2_CSV_NORMAL;

/*
 * Creates or replaces an 'INTERACTIVE WAREHOUSE'.
 * This is a specialized warehouse type optimized for Interactive Table refresh and query.
 */
CREATE OR REPLACE INTERACTIVE WAREHOUSE interactive_wh
    /* Explicitly links the warehouse to manage the refresh and queries for the specified interactive table(s). */
    TABLES (hits2_csv_interactive)
    /* Sets the compute size for the warehouse. */
    WAREHOUSE_SIZE = 'XSMALL';

/*
 * Switches the current session's active warehouse to the newly created 'INTERACTIVE_WH'.
 * All subsequent queries will use this warehouse.
 */
USE WAREHOUSE INTERACTIVE_WH;

/*
 * Activates the 'INTERACTIVE_WH' warehouse if it was suspended.
 * This is necessary before it can execute queries or maintain the Interactive Table.
 */
ALTER WAREHOUSE INTERACTIVE_WH RESUME;

/*
 * Executes a query to retrieve all rows from the 'HITS2_CSV_INTERACTIVE' table.
 * This query will utilize the specialized Interactive Warehouse.
 */
SELECT * FROM HITS2_CSV_INTERACTIVE;

/*
 * Suspends the 'interactive_wh' warehouse.
 * This stops the compute resources, preventing further credit consumption
 * when the warehouse is not actively being used for queries or maintenance.
 */
ALTER WAREHOUSE interactive_wh SUSPEND;

