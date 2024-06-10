
library(tidyquant)
library(dplyr)
AAPL  <- tq_get("AAPL", get = "stock.prices", from = "2014-01-01")

#export the Apple dataframe:
write.csv(AAPL, "AAPL Stock")

# showing closing price for single stock
library(ggplot2)
tq_get(c("AAPL"), get="stock.prices", from= "2014-01-01") %>%
  ggplot(aes(date, close)) +
  geom_line(color = "purple") +
  labs(title = "AAPL Stock")

# showing monthly return for single stock
tq_get(c("TSLA"), get="stock.prices") %>%
  tq_transmute(select=adjusted,
               mutate_fun=periodReturn,
               period="monthly",
               col_rename = "monthly_return") %>%
  ggplot(aes(date, monthly_return)) +
  geom_line()


# get historical data for multiple stocks. e.g. GAFA
group <- tq_get(c("GOOGL","AMZN"), get="stock.prices")

# Create a multiple line chart of the closing prices of the four stocks,
# showing each stock in a different color on the same graph.
tq_get(c("GOOGL","AMZN"), get="stock.prices") %>%
  ggplot(aes(date, close, color=symbol)) +
  geom_line()+
  labs(title = "Amazon and Google Stock Prices")+
  facet_wrap(~ symbol, ncol = 2, scales = "free_y") +
  theme_tq() + 
  scale_fill_tq()

tq_get(c("GOOG", "AMZN", "TSLA", "AAPL"), get = "stock.prices", from = "2021-01-01") %>%
  group_by(symbol) %>%
  tq_transmute(select = adjusted,
               mutate_fun = periodReturn,
               period = "monthly",
               col_rename = "monthly_return") %>% 
  ggplot(aes(date, monthly_return, color = symbol)) +
  geom_line()

## FANG = FB, AAPL, Netflix, Google
data("FANG")
FANG_annual_returns <- FANG %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted, 
               mutate_fun = periodReturn, 
               period     = "yearly", 
               type       = "arithmetic")
FANG_annual_returns

## Facet wrap separates by symbol (or any variable after ~)
FANG_annual_returns %>%
  ggplot(aes(x = date, y = yearly.returns, fill = symbol)) +
  geom_col() +
  geom_hline(yintercept = 0, color = palette_light()[[1]]) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "FANG: Annual Returns",
       subtitle = "Get annual returns quickly with tq_transmute!",
       y = "Annual Returns", x = "") +
  facet_wrap(~ symbol, ncol = 2, scales = "free_y") +
  theme_tq() + 
  scale_fill_tq()

# macd= moving average convergence divergence
# mutate = change the data to moving averages
FANG_macd <- FANG %>%
  group_by(symbol) %>%
  tq_mutate(select     = close, 
            mutate_fun = MACD, 
            nFast      = 12, 
            nSlow      = 26, 
            nSig       = 9, 
            maType     = SMA) %>%
  mutate(diff = macd - signal) %>%
  select(-(open:volume))
FANG_macd

#only 4 months, hline= horizontal (x-axis), linetype 2 = dashed, subtitle = ... (in labs), labs = labels
FANG_macd %>%
  filter(date >= as_date("2016-10-01")) %>%
  ggplot(aes(x = date)) + 
  geom_hline(yintercept = 0, color = palette_light()[[1]]) +
  geom_line(aes(y = macd, col = symbol)) +
  geom_line(aes(y = signal), color = "blue", linetype = 2) +
  geom_bar(aes(y = diff), stat = "identity", color = palette_light()[[1]]) +
  facet_wrap(~ symbol, ncol = 2, scale = "free_y") +
  labs(title = "FANG: Moving Average Convergence Divergence",
       y = "MACD", x = "", color = "",
       subtitle = "Thursday!") +
  theme_tq() +
  scale_color_tq()

FANG_max_by_qtr <- FANG %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted, 
               mutate_fun = apply.quarterly, 
               FUN        = max, 
               col_rename = "max.close") %>%
  mutate(year.qtr = paste0(year(date), "-Q", quarter(date))) %>%
  select(-date)
FANG_max_by_qtr

#Graph on own
FANG_min_by_qtr <- FANG %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted, 
               mutate_fun = apply.quarterly, 
               FUN        = min, 
               col_rename = "min.close") %>%
  mutate(year.qtr = paste0(year(date), "-Q", quarter(date))) %>%
  select(-date)

FANG_by_qtr <- left_join(FANG_max_by_qtr, FANG_min_by_qtr,
                         by = c("symbol"   = "symbol",
                                "year.qtr" = "year.qtr"))
FANG_by_qtr

FANG_by_qtr %>%
  ggplot(aes(x = year.qtr, color = symbol)) +
  geom_segment(aes(xend = year.qtr, y = min.close, yend = max.close),
               size = 1) +
  geom_point(aes(y = max.close), size = 2) +
  geom_point(aes(y = min.close), size = 2) +
  facet_wrap(~ symbol, ncol = 2, scale = "free_y") +
  labs(title = "FANG: Min/Max Price By Quarter",
       y = "Stock Price", color = "") +
  theme_tq() +
  scale_color_tq() +
  scale_y_continuous(labels = scales::dollar) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        axis.title.x = element_blank())

