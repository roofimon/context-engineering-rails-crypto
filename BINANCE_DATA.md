# Binance Historical Data Integration

## Overview
This application can fetch real historical price data from Binance API and store it in SQLite database for use in market trend charts instead of generated data.

## Database Setup

### Run Migration
```bash
rails db:migrate
```

This creates the `historical_price_data` table with:
- `symbol` (string) - Asset symbol (BTC, ETH, etc.)
- `date` (string) - Date in MM/DD format
- `open`, `high`, `low`, `close` (decimal) - Price data
- Indexes on `symbol` and `[symbol, date]` for fast queries

## How to Fetch Data

### Run the Rake Task
```bash
rails binance:fetch_historical
```

This will:
1. Fetch 30 days of historical data from Binance for:
   - BTC (Bitcoin)
   - ETH (Ethereum)
   - SOL (Solana)
   - USDT (uses USDC/USDT as proxy)
   - BNB (Binance Coin)

2. Save the data to SQLite database: `storage/development.sqlite3`

3. The data is stored in the `historical_price_data` table with:
   - Dates (MM/DD format)
   - OHLC data: open, high, low, close prices for each day

## How It Works

### Data Flow
1. **Fetch**: Rake task fetches data from Binance API
2. **Store**: Data is saved to SQLite database in `historical_price_data` table
3. **Load**: Controller automatically loads data from database when displaying market trend page
4. **Fallback**: If no data in database, uses generated candlestick data

### Controller Logic
The `market_trend` action in `MarketDataController`:
- First tries to load Binance data from SQLite database
- If available, uses real Binance historical prices
- If not available, falls back to generated candlestick data

### Database Structure

```
historical_price_data table:
  - id (integer, primary key)
  - symbol (string, indexed)
  - date (string, indexed with symbol for uniqueness)
  - open (decimal)
  - high (decimal)
  - low (decimal)
  - close (decimal)
  - created_at (datetime)
  - updated_at (datetime)
```

## Model Methods

The `HistoricalPriceData` model provides:
- `for_symbol(symbol)` - Scope to filter by symbol
- `ordered_by_date` - Scope to order by date
- `fetch_for_symbol(symbol, days: 30)` - Get recent data for a symbol
- `upsert_data(symbol, date, open, high, low, close)` - Insert or update a record
- `clear_symbol(symbol)` - Delete all data for a symbol

## Updating Data

### Automatic Daily Updates
The data is automatically fetched from Binance **daily at 1:00 AM** using Solid Queue recurring jobs.

**Configuration:** `config/recurring.yml`
- Runs automatically in both development and production
- Fetches 30 days of historical data for all symbols
- Updates existing data in SQLite database

### Manual Updates
To manually refresh the data with latest prices:
```bash
rails binance:fetch_historical
```

The data will be updated with the most recent 30 days from Binance.

## Notes

- **Automatic Updates**: Data is fetched daily at 1:00 AM automatically via Solid Queue
- **USDT**: Since USDT/USDT doesn't exist on Binance, the task uses USDC/USDT as a proxy
- **Rate Limits**: Binance API has rate limits, but fetching 5 symbols once is well within limits
- **Offline Mode**: If no data in database, the app will use generated data automatically
- **Dates**: Dates are extracted from Binance timestamps to ensure accuracy
- **Upsert**: The rake task clears existing data for each symbol before inserting new data to avoid duplicates
- **Database**: Data is stored in SQLite for easy querying and persistence
- **Solid Queue**: Make sure Solid Queue worker is running (`bin/jobs` or via `SOLID_QUEUE_IN_PUMA: true`)

