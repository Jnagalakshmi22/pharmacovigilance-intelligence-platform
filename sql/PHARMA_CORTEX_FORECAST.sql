-- This is your Cortex Project.
-----------------------------------------------------------
-- SETUP
-----------------------------------------------------------
use role ACCOUNTADMIN;
use warehouse PHARMA_WH;
use database PHARMA_DB;
use schema CURATED;

-- Inspect the first 10 rows of your training data. This is the data we'll use to create your model.
select * from VW_AE_FORECAST_INPUT_FINAL limit 10;

-- Prepare your training data. Timestamp_ntz is a required format. Also, only include select columns.
CREATE OR REPLACE VIEW VW_AE_FORECAST_INPUT_FINAL_v1 AS 
SELECT
    TO_TIMESTAMP_NTZ(REPORT_MONTH) AS REPORT_MONTH_v1,
    AE_REPORT_COUNT,
    MANUFACTURING_SITE
FROM VW_AE_FORECAST_INPUT_FINAL;


-----------------------------------------------------------
-- CREATE PREDICTIONS
-----------------------------------------------------------
-- Create your model.
CREATE SNOWFLAKE.ML.FORECAST AE_FORECAST_MODEL(
    INPUT_DATA => SYSTEM$REFERENCE('VIEW', 'VW_AE_FORECAST_INPUT_FINAL_v1'),
    SERIES_COLNAME => 'MANUFACTURING_SITE',
    TIMESTAMP_COLNAME => 'REPORT_MONTH_v1',
    TARGET_COLNAME => 'AE_REPORT_COUNT',
    CONFIG_OBJECT => { 'ON_ERROR': 'SKIP' }
);

-- Generate predictions and store the results to a table.
BEGIN
    -- This is the step that creates your predictions.
    CALL AE_FORECAST_MODEL!FORECAST(
        FORECASTING_PERIODS => 3,
        -- Here we set your prediction interval.
        CONFIG_OBJECT => {'prediction_interval': 0.95}
    );
    -- These steps store your predictions to a table.
    LET x := SQLID;
    CREATE OR REPLACE TABLE AE_FORECAST_PREDICTIONS AS SELECT * FROM TABLE(RESULT_SCAN(:x));
END;

-- View your predictions.
SELECT * FROM AE_FORECAST_PREDICTIONS;

-- Union your predictions with your historical data, then view the results in a chart.
SELECT MANUFACTURING_SITE, REPORT_MONTH, AE_REPORT_COUNT AS actual, NULL AS forecast, NULL AS lower_bound, NULL AS upper_bound
    FROM VW_AE_FORECAST_INPUT_FINAL
UNION ALL
SELECT replace(series, '"', '') as MANUFACTURING_SITE, ts as REPORT_MONTH, NULL AS actual, forecast, lower_bound, upper_bound
    FROM AE_FORECAST_PREDICTIONS;

-----------------------------------------------------------
-- INSPECT RESULTS
-----------------------------------------------------------

-- Inspect the accuracy metrics of your model. 
CALL AE_FORECAST_MODEL!SHOW_EVALUATION_METRICS();

-- Inspect the relative importance of your features, including auto-generated features. 
CALL AE_FORECAST_MODEL!EXPLAIN_FEATURE_IMPORTANCE();



