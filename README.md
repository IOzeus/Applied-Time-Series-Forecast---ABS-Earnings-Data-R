# Applied Time Series Analysis: Australian Earnings Forecasting

Time series analysis and forecasting of Average Weekly Earnings data from the Australian Bureau of Statistics (ABS).

## Overview

This project analyses **A84977991W**, Full Time Adult Ordinary Time Earnings for Males in the Professional, Scientific and Technical Services industry (ABS Table 10A), covering November 2005 to November 2022 at a biannual (May/November) frequency.

The analysis walks through the standard applied time series workflow: exploratory analysis, formal stationarity testing, model identification, model fitting, and forecasting with prediction intervals.

## Methods

- **Exploratory analysis**: level and first-difference time series plots
- **Stationarity testing**: Augmented Dickey-Fuller (ADF) and KPSS tests, with lag selection validated via Ljung-Box residual diagnostics
- **Model identification**: ACF/PACF analysis to inform AR order selection
- **Forecasting models**: AR and ARIMA models fit to both the level and first-differenced series, compared on specification and forecast behaviour
- **Forecasts**: 2-year-ahead forecasts with 80%/95% prediction intervals

## Key Findings

- The level series behaves as a **random walk with drift**: non-stationary, requiring first-order differencing to achieve stationarity
- The first-differenced series is **stationary**, confirmed by both ADF and KPSS tests
- A plain AR model fit directly to the non-stationary level series produced an unreliable mean estimate, so **ARIMA(1,1,0) with drift** was used instead, correctly handling the non-stationarity via differencing
- AR and ARIMA model selection converge on the same AR(1) structure for the differenced series, indicating no additional MA component is needed
- Observed cyclical dips in the series are consistent with real-world events affecting the industry, including the 2014 to 2016 downturn in Australian mining investment

## Tools

R, with `readabs`, `tsibble`, `feasts`, `fable`, `urca`, and `tidyverse`.

## Contents

| File | Description |
|---|---|
| `ABS_earnings_time_series_forecast.R` | Full analysis script |
| `Presentation Slides - ABS Data Forecast.pptx` | Presentation slides summarising the analysis and findings |

## Author

Adam, Monash University, double degree in Computer Science (Data Science) and Commerce (Mathematical Foundations of Econometrics)
