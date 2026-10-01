# Earnings Time Series Forecasting
# Series: A84977991W (ABS) - Full Time Adult Ordinary Time Earnings
# Males, Professional, Scientific and Technical Services
# Note: series is biannual (May and November each year), not quarterly

library(readabs)
library(tidyverse)
library(tsibble)
library(feasts)
library(fable)
library(urca)
library(readxl)


## 1. Get the data and set up the series (level + difference)

dat <- read_abs(series_id = 'A84977991W')

# the data is biannual, and tsibble has no built in calendar class for that
# so we index by period number (1,2,3,...) instead of yearquarter/yearmonth
# the real date is kept in its own column so plots can still show it
dat %>%
  select(date, value) %>%
  mutate(date = as.Date(date)) %>%
  filter(date >= as.Date('2005-07-01')) %>%
  arrange(date) %>%
  mutate(period = row_number()) %>%
  as_tsibble(index = period) -> earnings_ts

# first difference of the series
earnings_ts %>%
  mutate(value = difference(value)) %>%
  filter(!is.na(value)) -> earnings_diff_ts


## 2. Time series plots

earnings_ts %>%
  ggplot(aes(x = date, y = value)) +
  geom_line() +
  theme_bw() +
  labs(title = 'Full Time Adult Ordinary Earnings (Level)',
       y = 'Earnings ($)',
       x = 'Date')

earnings_diff_ts %>%
  ggplot(aes(x = date, y = value)) +
  geom_line() +
  theme_bw() +
  labs(title = 'Full Time Adult Ordinary Earnings (First Difference)',
       y = 'Change in Earnings ($)',
       x = 'Date')


## 3. Stationarity: ACF/PACF plots and formal tests

# ACF/PACF for the level series
# slow decaying ACF suggests non-stationarity
earnings_ts %>% ACF(value) %>% autoplot() +
  labs(title = 'ACF - Earnings (Level)')

earnings_ts %>% PACF(value) %>% autoplot() +
  labs(title = 'PACF - Earnings (Level)')

# ACF/PACF for the differenced series
earnings_diff_ts %>% ACF(value) %>% autoplot() +
  labs(title = 'ACF - Earnings (First Difference)')

earnings_diff_ts %>% PACF(value) %>% autoplot() +
  labs(title = 'PACF - Earnings (First Difference)')

# ADF test - level series
# H0: series has a unit root (non-stationary)
# lags chosen via AIC, checked against Ljung-Box to confirm residuals are white noise
adf_level_AIC <- ur.df(earnings_ts$value, type = 'drift', selectlags = 'AIC')
Box.test(residuals(adf_level_AIC@testreg), lag = 6, type = "Ljung-Box")
summary(adf_level_AIC)

# ADF test - differenced series
adf_diff_AIC <- ur.df(earnings_diff_ts$value, type = 'drift', selectlags = 'AIC')
Box.test(residuals(adf_diff_AIC@testreg), lag = 6, type = "Ljung-Box")
summary(adf_diff_AIC)

# KPSS test - opposite null to ADF (H0: series IS stationary)
# useful as a cross check against the ADF result
kpss_level <- ur.kpss(earnings_ts$value, type = 'tau')
summary(kpss_level)

kpss_diff <- ur.kpss(earnings_diff_ts$value, type = 'mu')
summary(kpss_diff)


## 4. Models: fit two models to each series

## --- Level series ---

# Model 1: AR(p), order chosen automatically via AIC
fit_level_ar <- earnings_ts %>%
  model(AR = AR(value))
report(fit_level_ar)

# Model 2: ARIMA, order chosen automatically via AICc
fit_level_arima <- earnings_ts %>%
  model(ARIMA = ARIMA(value))
report(fit_level_arima)

## --- Differenced series ---

# Model 1: AR(p)
fit_diff_ar <- earnings_diff_ts %>%
  model(AR = AR(value))
report(fit_diff_ar)

# Model 2: ARIMA
fit_diff_arima <- earnings_diff_ts %>%
  model(ARIMA = ARIMA(value))
report(fit_diff_arima)


## 5. Forecasts and prediction intervals
## 2 years ahead = 4 periods, since each period is 6 months

## --- Level series forecasts ---

fc_level_ar <- fit_level_ar %>% forecast(h = 4)
fc_level_arima <- fit_level_arima %>% forecast(h = 4)

fc_level_ar %>%
  autoplot(earnings_ts) +
  theme_bw() +
  labs(title = 'AR Forecast - Earnings (Level)')

fc_level_arima %>%
  autoplot(earnings_ts) +
  theme_bw() +
  labs(title = 'ARIMA Forecast - Earnings (Level)')

## --- Differenced series forecasts ---

fc_diff_ar <- fit_diff_ar %>% forecast(h = 4)
fc_diff_arima <- fit_diff_arima %>% forecast(h = 4)

fc_diff_ar %>%
  autoplot(earnings_diff_ts) +
  theme_bw() +
  labs(title = 'AR Forecast - Earnings (First Difference)')

fc_diff_arima %>%
  autoplot(earnings_diff_ts) +
  theme_bw() +
  labs(title = 'ARIMA Forecast - Earnings (First Difference)')