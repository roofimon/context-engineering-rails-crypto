# External API Integration Guide

## Using Real Crypto Prices from CoinGecko

### 1. Replace the controller in your view:

**Before:**
```erb
<div data-controller="home">
```

**After:**
```erb
<div data-controller="market-api">
```

### 2. Update target names:

**Before:**
```erb
data-home-target="price"
data-home-target="change"
```

**After:**
```erb
data-market-api-target="price"
data-market-api-target="change"
```

### 3. API Features:

✅ **Free CoinGecko API**
- No API key required
- 50 calls/minute free tier
- Updates every 30 seconds

✅ **Real-time data includes:**
- Current USD price
- 24h price change percentage
- Automatic updates

### 4. Supported Cryptocurrencies:

- Bitcoin (BTC)
- Ethereum (ETH)
- Solana (SOL)
- Tether (USDT)
- Binance Coin (BNB)

### 5. Rate Limits:

- CoinGecko Free: 50 calls/minute
- Current setting: 1 call every 30 seconds (safe)
- Adjust interval in `market_api_controller.js` if needed

### 6. CORS Considerations:

CoinGecko API allows cross-origin requests, so it works directly from the browser!

### 7. Fallback:

If API fails, the controller logs errors to console and keeps existing prices.

### 8. Console Output:

```
=== 📡 MARKET API CONTROLLER CONNECTED ===
✅ Using CoinGecko free API
🔄 Fetching real-time prices from CoinGecko...
✅ Real prices fetched: {bitcoin: {usd: 67234.5...}}
📊 Updated BTC: $67,234.50 (+2.34%)
📊 Updated ETH: $3,456.78 (-1.23%)
```

### 9. Other Free APIs Available:

**CoinCap:**
```javascript
const url = `https://api.coincap.io/v2/assets/${cryptoId}`
```

**Binance:**
```javascript
const url = `https://api.binance.com/api/v3/ticker/24hr?symbol=BTCUSDT`
```

### 10. Switch back to simulated data:

Just change the controller back to `data-controller="home"` in your view!
