## Pharmacovigilance Intelligence Platform
An end-to-end data engineering project that transforms raw adverse event (AE) reports into a structured, analytics-ready data platform with AI-powered forecasting for early safety signal detection.

## 📌 Project Overview

Pharmaceutical companies receive adverse event reports from physicians, pharmacists, nurses, and consumers. These reports can contain duplicates, missing values, inconsistent formats, and other data quality issues.

This project builds a cloud-based pharmacovigilance data pipeline to:

* Ingest raw adverse event data into AWS S3
* Profile and cleanse the data using Dataiku DSS
* Transform the data into a dimensional model in Snowflake
* Implement production SQL transformations and analytical views
* Apply Snowflake Cortex forecasting to identify unusual AE reporting patterns
* Provide an interactive Power BI dashboard for safety monitoring

> **Important:** Statistical signals identified by the model are intended for analytical review and do not establish clinical causality.

---

## 🏗️ Architecture

```text
Raw AE CSV
    │
    ▼
AWS S3
(raw/)
    │
    ▼
Snowflake RAW
    │
    ▼
Dataiku DSS
(Profile → Clean → Validate)
    │
    ▼
Snowflake STAGING
    │
    ▼
Snowflake CURATED
(Star Schema)
    │
    ├──────────────► SQL Analytical Views
    │
    └──────────────► Snowflake Cortex
                         │
                         ▼
                  AE Forecast Results
                         │
                         ▼
                    Power BI
```

### Pipeline Stages

| Stage       | Description                                                        |
| ----------- | ------------------------------------------------------------------ |
| **INGEST**  | Raw AE reports are stored in AWS S3 and loaded into Snowflake      |
| **PROCESS** | Dataiku DSS profiles, cleans, standardizes, and validates the data |
| **MODEL**   | Clean data is transformed into a Snowflake star schema             |
| **PREDICT** | Snowflake Cortex is used for AE volume forecasting                 |
| **CONSUME** | Power BI provides analytical dashboards and safety insights        |

---

## 🛠️ Technology Stack

* **AWS S3** — Cloud data ingestion and raw data storage
* **AWS IAM** — Access and permissions management
* **Dataiku DSS** — Data profiling, cleansing, and transformation
* **Snowflake** — Cloud data warehouse
* **Snowflake SQL** — Data transformation, modelling, and analytical views
* **Snowflake Cortex** — AI/ML forecasting
* **Power BI** — Interactive dashboard and visualization
* **Git/GitHub** — Version control and project documentation

---

## 📊 Data Quality & Transformation

The source dataset initially contained **83 records and 19 columns**.

During the cleansing process:

* Duplicate `REPORT_ID` records were identified and removed
* Drug names, country, and sex values were standardized
* Dates were normalized to valid date formats
* Missing values were identified
* Missing-value indicator flags were added where appropriate
* Data quality checks were performed before loading the cleaned data

After validation, the cleaned dataset contained **81 valid records and 23 columns**.

### Missing-value handling

Instead of blindly replacing missing values with averages or other estimated values, missing-value flags were created for important fields such as:

* `PATIENT_AGE`
* `DOSE_AMOUNT_MG`
* `CONCOMITANT_MEDICATIONS`

This preserves the distinction between an actual value and an unavailable value.

---

## ⭐ Dimensional Model

The curated Snowflake layer follows a star-schema approach.

### Fact Table

**FACT_AE_REPORT**

Grain:

> One row represents one adverse event report.

### Dimension Tables

* `DIM_DATE`
* `DIM_COUNTRY`
* `DIM_BATCH`
* Drug-related analytical dimensions
* Reporting and demographic attributes

The dimensional model supports analytical queries such as:

* AE reports by drug and month
* Serious event rate by country
* AE volume by manufacturing site
* AE trends over time
* Manufacturing batch-level analysis

---

## 🤖 AI/ML Forecasting

Snowflake Cortex forecasting was applied to historical adverse event reporting volumes.

### Model configuration

* **Target:** AE report count
* **Time series:** Manufacturing site
* **Forecast horizon:** 3 months
* **Prediction interval:** 95%
* **Granularity:** Monthly

The model generates expected future AE reporting volumes that can be reviewed for potential deviations from historical patterns.

### Interpretation

A statistical anomaly or forecast deviation is **not equivalent to clinical causality**.

The output is intended to help safety reviewers identify areas that may require further investigation.

---

## 📈 Power BI Dashboard

The Power BI dashboard provides a high-level view of pharmacovigilance activity.

### Key KPIs

* **81** AE reports
* **40** serious AE reports
* **9** countries
* **5** manufacturing sites

### Dashboard analysis includes

* AE reporting trends
* Serious vs. non-serious events
* Country-level reporting
* Manufacturing-site analysis
* Forecast and signal information
* Safety monitoring indicators

---

## 🧪 Testing & Validation

The pipeline was validated using data quality and functional test cases.

Key validation areas included:

* Source-to-target row counts
* Duplicate `REPORT_ID` checks
* Date validation
* Referential integrity
* Dimension and fact table population
* Analytical view validation
* Forecast execution

**Test result: 18/18 test cases passed.**

---

## 📁 Repository Structure

```text
pharmacovigilance-intelligence-platform/
│
├── data/
│   ├── raw/
│   │   └── pharma_capstone_adverse_events_raw.csv
│   │
│   └── cleaned/
│       └── pharma_capstone_adverse_events_cleaned.csv
│
├── sql/
│   ├── PHARMA_DATA_PIPELINE.sql
│   └── PHARMA_CORTEX_FORECAST.sql
│
├── docs/
│   ├── TECHNICAL_DESIGN_DOCUMENT.pdf
│   └── TEST_REPORT.pdf
│
├── dashboard/
│   └── Pharmacovigilance_Dashboard.pbix
│
└── README.md
```

---

## 🎯 Key Outcomes

This project demonstrates practical experience in:

* Cloud data ingestion
* ETL and data cleansing
* Data quality management
* Dimensional data modelling
* Snowflake data warehousing
* SQL transformation
* AI/ML forecasting
* Business intelligence and visualization
* Data pipeline testing and documentation

---

